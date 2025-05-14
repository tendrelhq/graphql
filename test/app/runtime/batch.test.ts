import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { type Customer, createTestContext, execute } from "@/test/prelude";
import {
  assert,
  assertNonNull,
  assertUnderlyingType2,
  map,
  mapOrElse,
} from "@/util";
import { Faker, base, en } from "@faker-js/faker";
import {
  AssignBatchMutationDocument,
  CreateBatchMutationDocument,
  TestBatchEntrypointDocument,
  TestHistoryQueryDocument,
  TestListBatchTemplatesDocument,
} from "./batch.test.generated";
import { createCustomer } from "./prelude/canonical";
import {
  TestRuntimeEntrypointDocument,
  type TestRuntimeEntrypointQuery,
  TestRuntimeTransitionMutationDocument,
} from "./runtime.test.generated";

const ctx = await createTestContext();

const seed = mapOrElse(
  process.env.SEED,
  seed => {
    const s = Number.parseInt(seed);
    assert(Number.isFinite(s), "invalid seed");
    return s;
  },
  Date.now(),
);
const faker = new Faker({ locale: [en, base], seed });

describe("runtime + batch tracking", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: Customer;

  let initialEntrypointData: TestRuntimeEntrypointQuery | null;
  test("entrypoint query", async () => {
    const result = await execute(ctx, schema, TestRuntimeEntrypointDocument, {
      parent: CUSTOMER.id,
      includeTransitionIds: true,
    });
    expect(result.errors).toBeFalsy();

    expect(result.data?.trackables?.edges?.length).toBe(1);
    expect(result.data?.trackables?.edges?.at(0)).toMatchObject({
      node: {
        name: {
          value: "My First Location",
        },
        tracking: {
          edges: [
            {
              node: {
                fsm: {
                  active: {
                    name: {
                      value: "Run",
                    },
                    parent: {
                      name: {
                        value: "My First Location",
                      },
                    },
                    types: ["Trackable", "Runtime"],
                  },
                },
                name: {
                  value: "Run",
                },
                state: {
                  __typename: "Open",
                },
              },
            },
          ],
        },
      },
    });

    // biome-ignore lint/suspicious/noExplicitAny:
    initialEntrypointData = result.data as any;
  });

  test("batch entrypoint query", async () => {
    const result = await execute(ctx, schema, TestBatchEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();
    // We have yet to create any Batch instances!
    expect(result.data?.trackables?.edges?.length).toBe(0);
  });

  test("create some batches", async () => {
    const result0 = await execute(ctx, schema, TestListBatchTemplatesDocument, {
      owner: CUSTOMER.id,
    });
    expect(result0.errors).toBeFalsy();

    const batchTemplate = assertNonNull(
      result0.data?.templates?.edges?.at(0)?.node?.asTask,
      "no batch template?",
    );
    const factory = assertNonNull(
      result0.data?.owner.__typename === "Organization"
        ? result0.data.owner.locations.edges.at(0)?.node
        : undefined,
      "no site?",
    );

    const customerField = assertNonNull(batchTemplate.customer?.id);
    const productNameField = assertNonNull(batchTemplate.productName?.id);
    const skuField = assertNonNull(batchTemplate.sku?.id);
    for (let batchId = 0; batchId < 5; batchId++) {
      const result = await execute(ctx, schema, CreateBatchMutationDocument, {
        batchTemplateId: batchTemplate.id,
        batchId: `Batch ${batchId}`,
        fields: [
          {
            field: customerField,
            value: { string: faker.company.name() },
            valueType: "string",
          },
          {
            field: productNameField,
            value: { string: faker.commerce.productName() },
            valueType: "string",
          },
          {
            field: skuField,
            value: { string: faker.commerce.isbn() },
            valueType: "string",
          },
        ],
        location: factory.id,
      });
      expect(result.errors).toBeFalsy();
    }
  });

  test("entrypoint query has not changed", async () => {
    const result = await execute(ctx, schema, TestRuntimeEntrypointDocument, {
      parent: CUSTOMER.id,
      includeTransitionIds: true,
    });
    expect(result.data).toEqual(initialEntrypointData);
  });

  test("batch query has updated", async () => {
    const result = await execute(ctx, schema, TestBatchEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();
    // Most recent first.
    expect(result.data?.trackables?.edges).toMatchObject([
      {
        node: {
          name: {
            value: "Batch 4",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 4",
              },
              // Batches are instantiated at the site-level, which have the same
              // name as the customer (in this test).
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "Open",
              },
              types: ["Batch"],
            },
            transitions: {
              edges: [],
            },
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 3",
          },
          fsm: {
            active: {
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "Open",
              },
            },
            transitions: {
              edges: [],
            },
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 2",
          },
          fsm: {
            active: {
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "Open",
              },
            },
            transitions: {
              edges: [],
            },
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 1",
          },
          fsm: {
            active: {
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "Open",
              },
            },
            transitions: {
              edges: [],
            },
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 0",
          },
          fsm: {
            active: {
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "Open",
              },
            },
            transitions: {
              edges: [],
            },
          },
        },
      },
    ]);
  });

  test("assign a batch", async () => {
    // We do this from the perspective of the entrypoint query, which is
    // location-based. At each location we know we have an "on-demand" sitting
    // there waiting for us to grab it. An important difference with the
    // canonical configuration is that these "on-demand" tasks are actually
    // worktemplates, not workinstances! We do not pre-create instances in this
    // more modern configuration. An implication of this is that the "Start Run"
    // button will return a *different Task* upon calling advance! On the
    // frontend this will need handling, e.g. via a router call:
    // ```typescript
    // onComplete(result) {
    //   if (result.root.id !== selectedTaskId) {
    //     router.replace(...); // re-render with a different Task
    //   }
    // }
    // ```
    const entrypointQuery = await execute(
      ctx,
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
        includeTrackingIds: true,
        includeTransitionIds: true,
      },
    );
    expect(entrypointQuery.errors).toBeFalsy();

    const locations = assertNonNull(
      entrypointQuery.data?.trackables?.edges?.map(e => {
        assert(e.node?.__typename === "Location");
        return assertNonNull(e.node) as typeof e.node & {
          __typename: "Location";
        };
      }),
      "no locations?",
    );

    const batchQuery = await execute(ctx, schema, TestBatchEntrypointDocument, {
      includeTrackingIds: true,
      parent: CUSTOMER.id,
    });
    expect(batchQuery.errors).toBeFalsy();

    const batches = assertNonNull(
      batchQuery.data?.trackables?.edges?.map(e => {
        assert(e.node?.__typename === "Task");
        return assertNonNull(e.node) as typeof e.node & { __typename: "Task" };
      }),
      "no batches?",
    );

    // expect(locations.length).toBe(batches.length);

    for (let i = 0; i < 1; i++) {
      const batch = assertNonNull(batches.at(i)?.id);
      const location = assertNonNull(locations.at(i));
      const run = assertNonNull(
        map(location.tracking?.edges?.at(0)?.node, node => {
          assert(node.__typename === "Task");
          return (node as typeof node & { __typename: "Task" }).id;
        }),
      );
      const result = await execute(ctx, schema, AssignBatchMutationDocument, {
        base: batch,
        node: run,
        parent: location.id,
      });
      expect(result.errors).toBeFalsy();
    }
  }, 10_000);

  test("batches open, runs open", async () => {
    const batchQuery = await execute(ctx, schema, TestBatchEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(batchQuery.errors).toBeFalsy();
    // Most recent first.
    expect(batchQuery.data?.trackables?.edges?.length).toBe(5);
    expect(batchQuery.data?.trackables?.edges).toMatchObject([
      {
        node: {
          name: {
            value: "Batch 4",
          },
          fsm: {
            active: {
              name: {
                value: "Run",
              },
              parent: {
                name: {
                  value: "My First Location",
                },
              },
              state: {
                __typename: "Open",
              },
            },
            transitions: {
              edges: [],
            },
          },
          state: {
            __typename: "Open",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 3",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 3",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "Open",
              },
            },
            transitions: {
              edges: [],
            },
          },
          state: {
            __typename: "Open",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 2",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 2",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "Open",
              },
            },
            transitions: {
              edges: [],
            },
          },
          state: {
            __typename: "Open",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 1",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 1",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "Open",
              },
            },
            transitions: {
              edges: [],
            },
          },
          state: {
            __typename: "Open",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 0",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 0",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "Open",
              },
            },
            transitions: {
              edges: [],
            },
          },
          state: {
            __typename: "Open",
          },
        },
      },
    ]);

    const entrypointQuery = await execute(
      ctx,
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
      },
    );
    expect(entrypointQuery.errors).toBeFalsy();

    expect(entrypointQuery.data?.trackables?.edges?.length).toBe(1);
    expect(entrypointQuery.data?.trackables?.edges?.at(0)).toMatchObject({
      node: {
        name: {
          value: "My First Location",
        },
        tracking: {
          edges: [
            {
              node: {
                name: {
                  value: "Run",
                },
                parent: {
                  name: {
                    value: "My First Location",
                  },
                },
                root: {
                  name: {
                    value: "Batch 4",
                  },
                  parent: {
                    name: {
                      value: "My Site",
                    },
                  },
                },
                state: {
                  __typename: "Open",
                },
              },
            },
          ],
        },
      },
    });
  });

  test("start all batches", async () => {
    const batchQuery = await execute(ctx, schema, TestBatchEntrypointDocument, {
      includeTrackingIds: true,
      parent: CUSTOMER.id,
    });
    expect(batchQuery.errors).toBeFalsy();

    const batches = assertNonNull(
      batchQuery.data?.trackables?.edges?.map(e => {
        assert(e.node?.__typename === "Task");
        return assertNonNull(e.node) as typeof e.node & { __typename: "Task" };
      }),
      "no batches?",
    );

    expect(batches.length).toBe(5);
    for (const batch of batches) {
      const batchId = assertNonNull(batch.id);
      const hash = assertNonNull(batch.hash);
      const result = await execute(
        ctx,
        schema,
        TestRuntimeTransitionMutationDocument,
        {
          opts: {
            fsm: {
              id: batchId,
              hash: hash,
            },
            task: {
              id: batchId,
              hash: hash,
            },
          },
        },
      );
      expect(result.errors).toBeFalsy();
    }
  }, 10_000);

  test("batches in-progress, runs remain open", async () => {
    const batchQuery = await execute(ctx, schema, TestBatchEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(batchQuery.errors).toBeFalsy();
    expect(batchQuery.data?.trackables?.edges?.length).toBe(5);
    expect(batchQuery.data?.trackables?.edges).toMatchObject([
      {
        node: {
          name: {
            value: "Batch 4",
          },
          fsm: {
            active: {
              name: {
                value: "Run",
              },
              parent: {
                name: {
                  value: "My First Location",
                },
              },
              state: {
                __typename: "Open",
              },
            },
          },
          state: {
            __typename: "InProgress",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 3",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 3",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "InProgress",
              },
            },
          },
          state: {
            __typename: "InProgress",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 2",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 2",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "InProgress",
              },
            },
          },
          state: {
            __typename: "InProgress",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 1",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 1",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "InProgress",
              },
            },
          },
          state: {
            __typename: "InProgress",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 0",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 0",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "InProgress",
              },
            },
          },
          state: {
            __typename: "InProgress",
          },
        },
      },
    ]);

    const entrypointQuery = await execute(
      ctx,
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
      },
    );
    expect(entrypointQuery.errors).toBeFalsy();

    expect(entrypointQuery.data?.trackables?.edges?.length).toBe(1);
    expect(entrypointQuery.data?.trackables?.edges?.at(0)).toMatchObject({
      node: {
        name: {
          value: "My First Location",
        },
        tracking: {
          edges: [
            {
              node: {
                name: {
                  value: "Run",
                },
                parent: {
                  name: {
                    value: "My First Location",
                  },
                },
                root: {
                  name: {
                    value: "Batch 4",
                  },
                  parent: {
                    name: {
                      value: "My Site",
                    },
                  },
                },
                state: {
                  __typename: "Open",
                },
              },
            },
          ],
        },
      },
    });
  });

  test("start a run", async () => {
    const batchQuery = await execute(ctx, schema, TestBatchEntrypointDocument, {
      includeTrackingIds: true,
      parent: CUSTOMER.id,
    });
    expect(batchQuery.errors).toBeFalsy();

    const batches = assertNonNull(
      batchQuery.data?.trackables?.edges?.map(e => {
        assert(e.node?.__typename === "Task");
        return assertNonNull(e.node) as typeof e.node & { __typename: "Task" };
      }),
      "no batches?",
    );

    // expect(batches.length).toBe(5);
    // for (const batch of batches) {
    const batch = batches.at(0);
    const result = await execute(
      ctx,
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        opts: {
          fsm: {
            id: assertNonNull(batch?.id),
            hash: assertNonNull(batch?.hash),
          },
          task: {
            id: assertNonNull(batch?.fsm?.active?.id),
            hash: assertNonNull(batch?.fsm?.active?.hash),
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
  }, 10_000);

  test("batches in-progress, runs in-progress", async () => {
    const batchQuery = await execute(ctx, schema, TestBatchEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(batchQuery.errors).toBeFalsy();
    // Most recent first.
    expect(batchQuery.data?.trackables?.edges).toMatchObject([
      {
        node: {
          name: {
            value: "Batch 4",
          },
          fsm: {
            active: {
              name: {
                value: "Run",
              },
              parent: {
                name: {
                  value: "My First Location",
                },
              },
              state: {
                __typename: "InProgress",
              },
            },
          },
          state: {
            __typename: "InProgress",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 3",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 3",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "InProgress",
              },
            },
          },
          state: {
            __typename: "InProgress",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 2",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 2",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "InProgress",
              },
            },
          },
          state: {
            __typename: "InProgress",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 1",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 1",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "InProgress",
              },
            },
          },
          state: {
            __typename: "InProgress",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 0",
          },
          fsm: {
            active: {
              name: {
                value: "Batch 0",
              },
              parent: {
                name: {
                  value: "My Site",
                },
              },
              state: {
                __typename: "InProgress",
              },
            },
          },
          state: {
            __typename: "InProgress",
          },
        },
      },
    ]);

    const entrypointQuery = await execute(
      ctx,
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
      },
    );
    expect(entrypointQuery.errors).toBeFalsy();
    expect(entrypointQuery.data?.trackables?.edges).toMatchObject([
      {
        __typename: "TrackableEdge",
        node: {
          __typename: "Location",
          name: {
            __typename: "Name",
            value: "My First Location",
          },
          tracking: {
            edges: [
              {
                node: {
                  __typename: "Task",
                  fsm: {
                    active: {
                      assignees: {
                        edges: [
                          {
                            node: {
                              assignedTo: {
                                displayName: expect.any(String),
                              },
                            },
                          },
                        ],
                      },
                      description: null,
                      fields: {
                        edges: [
                          {
                            node: {
                              description: null,
                              name: {
                                value: "Override Start Time",
                              },
                              value: {
                                __typename: "TimestampValue",
                                timestamp: null,
                              },
                              valueType: "timestamp",
                            },
                          },
                          {
                            node: {
                              description: null,
                              name: {
                                value: "Override End Time",
                              },
                              value: {
                                __typename: "TimestampValue",
                                timestamp: null,
                              },
                              valueType: "timestamp",
                            },
                          },
                          {
                            node: {
                              description: null,
                              name: {
                                value: "Run Output",
                              },
                              value: {
                                __typename: "NumberValue",
                              },
                              valueType: "number",
                            },
                          },
                          {
                            node: {
                              description: null,
                              name: {
                                value: "Reject Count",
                              },
                              value: {
                                __typename: "NumberValue",
                              },
                              valueType: "number",
                            },
                          },
                          {
                            node: {
                              description: null,
                              name: {
                                value: "Comments",
                              },
                              value: {
                                __typename: "StringValue",
                                string: null,
                              },
                              valueType: "string",
                            },
                          },
                        ],
                      },
                      name: {
                        value: "Run",
                      },
                      parent: {
                        name: {
                          value: "My First Location",
                        },
                      },
                      state: {
                        __typename: "InProgress",
                        inProgressBy: {
                          displayName: expect.any(String),
                        },
                      },
                    },
                    transitions: {
                      edges: [
                        {
                          node: {
                            fields: {
                              edges: [
                                {
                                  node: {
                                    name: {
                                      value: "Override Start Time",
                                    },
                                    value: {
                                      __typename: "TimestampValue",
                                    },
                                  },
                                },
                                {
                                  node: {
                                    name: {
                                      value: "Override End Time",
                                    },
                                    value: {
                                      __typename: "TimestampValue",
                                    },
                                  },
                                },
                                {
                                  node: {
                                    name: {
                                      value: "Description",
                                    },
                                    value: {
                                      __typename: "StringValue",
                                    },
                                  },
                                },
                                {
                                  node: {
                                    name: {
                                      value: "Reason Code",
                                    },
                                    value: {
                                      __typename: "StringValue",
                                    },
                                  },
                                },
                              ],
                            },
                            name: {
                              value: "Downtime",
                            },
                          },
                          target: {
                            name: {
                              value: "My First Location",
                            },
                          },
                        },
                        {
                          node: {
                            fields: {
                              edges: [
                                {
                                  node: {
                                    name: {
                                      value: "Override Start Time",
                                    },
                                    value: {
                                      __typename: "TimestampValue",
                                    },
                                  },
                                },
                                {
                                  node: {
                                    name: {
                                      value: "Override End Time",
                                    },
                                    value: {
                                      __typename: "TimestampValue",
                                    },
                                  },
                                },
                                {
                                  node: {
                                    name: {
                                      value: "Description",
                                    },
                                    value: {
                                      __typename: "StringValue",
                                    },
                                  },
                                },
                                {
                                  node: {
                                    name: {
                                      value: "Reason Code",
                                    },
                                    value: {
                                      __typename: "StringValue",
                                    },
                                  },
                                },
                              ],
                            },
                            name: {
                              value: "Idle Time",
                            },
                          },
                          target: {
                            name: {
                              value: "My First Location",
                            },
                          },
                        },
                      ],
                    },
                  },
                  name: {
                    value: "Run",
                  },
                  parent: {
                    name: {
                      value: "My First Location",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 4",
                    },
                    parent: {
                      name: {
                        value: "My Site",
                      },
                    },
                  },
                  state: {
                    __typename: "InProgress",
                  },
                },
              },
              {
                node: {
                  __typename: "Task",
                  fsm: {
                    active: {
                      assignees: {
                        edges: [
                          {
                            node: {
                              assignedTo: null,
                            },
                          },
                        ],
                      },
                      description: null,
                      fields: {
                        edges: [
                          {
                            node: {
                              description: null,
                              name: {
                                value: "Override Start Time",
                              },
                              value: {
                                __typename: "TimestampValue",
                                timestamp: null,
                              },
                              valueType: "timestamp",
                            },
                          },
                          {
                            node: {
                              description: null,
                              name: {
                                value: "Override End Time",
                              },
                              value: {
                                __typename: "TimestampValue",
                                timestamp: null,
                              },
                              valueType: "timestamp",
                            },
                          },
                          {
                            node: {
                              description: null,
                              name: {
                                value: "Run Output",
                              },
                              value: {
                                __typename: "NumberValue",
                              },
                              valueType: "number",
                            },
                          },
                          {
                            node: {
                              description: null,
                              name: {
                                value: "Reject Count",
                              },
                              value: {
                                __typename: "NumberValue",
                              },
                              valueType: "number",
                            },
                          },
                          {
                            node: {
                              description: null,
                              name: {
                                value: "Comments",
                              },
                              value: {
                                __typename: "StringValue",
                                string: null,
                              },
                              valueType: "string",
                            },
                          },
                        ],
                      },
                      name: {
                        value: "Run",
                      },
                      parent: {
                        name: {
                          value: "My First Location",
                        },
                      },
                      state: {
                        __typename: "Open",
                      },
                    },
                    transitions: {
                      edges: [],
                    },
                  },
                  name: {
                    value: "Run",
                  },
                  parent: {
                    name: {
                      value: "My First Location",
                    },
                  },
                  root: {
                    name: {
                      value: "Run",
                    },
                    parent: {
                      name: {
                        value: "My First Location",
                      },
                    },
                  },
                  state: {
                    __typename: "Open",
                  },
                },
              },
            ],
          },
        },
      },
    ]);
  });

  test("start and end downtime", async () => {
    // This test simulates how the mobile app would work e.g. via the Locations
    // home screen. That is to say: under Batch specifically what will be passed
    // to advance will be the Run, not the Batch, even though the latter is
    // technically the root of the chain.
    const entrypointQuery = await execute(
      ctx,
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
        includeHashes: true,
        includeTransitionIds: true,
      },
    );
    const runAtMixingLine = assertNonNull(
      map(
        entrypointQuery.data?.trackables?.edges
          ?.at(0)
          ?.node?.tracking?.edges?.at(0)?.node,
        node => assertUnderlyingType2(node, "Task"),
      ),
      "no run at mixing line?",
    );

    const downTransition = assertNonNull(
      runAtMixingLine.fsm?.transitions?.edges?.at(0),
      "no down transition?",
    );
    const startDowntimeMutation = await execute(
      ctx,
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        opts: {
          fsm: {
            // Simulating the mobile app which is operating on the Run instance.
            id: assertNonNull(runAtMixingLine.id),
            hash: assertNonNull(runAtMixingLine.hash),
          },
          task: {
            id: assertNonNull(downTransition.id),
            hash: assertNonNull(downTransition.node?.hash),
          },
        },
        includeChain: true,
        includeHashes: true,
        includeRoot: true, // This is a misnomer.
        includeTransitionIds: true,
      },
    );
    expect(startDowntimeMutation.errors).toBeFalsy();

    const startDowntimeAdvance = assertNonNull(
      startDowntimeMutation.data?.advance,
    );
    expect(startDowntimeAdvance.instantiations?.length).toBe(0);
    expect(startDowntimeAdvance.diagnostics).toBeFalsy();
    expect(startDowntimeAdvance.root?.chain?.edges?.length).toBe(2);
    expect(startDowntimeAdvance.root?.fsm?.active?.name?.value).toBe(
      "Downtime",
    );
    expect(startDowntimeAdvance.root?.fsm?.active?.state?.__typename).toBe(
      "InProgress",
    );
    expect(startDowntimeAdvance.root?.fsm?.transitions?.edges?.length).toBe(0);
    expect(startDowntimeAdvance.root?.state?.__typename).toBe("InProgress");

    const downInstance = assertNonNull(
      // Note that `root` here is still the Run!
      startDowntimeMutation.data?.advance?.root?.fsm?.active,
      "no down instance?",
    );

    const endDowntimeMutation = await execute(
      ctx,
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        opts: {
          fsm: {
            id: assertNonNull(runAtMixingLine.id),
            hash: assertNonNull(runAtMixingLine.hash),
          },
          task: {
            id: assertNonNull(downInstance.id),
            hash: assertNonNull(downInstance.hash),
          },
        },
        includeChain: true,
        includeRoot: true,
      },
    );
    expect(endDowntimeMutation.errors).toBeFalsy();

    const endDowntimeAdvance = assertNonNull(endDowntimeMutation.data?.advance);
    expect(endDowntimeAdvance.instantiations?.length).toBe(0);
    expect(endDowntimeAdvance.diagnostics).toBeFalsy();
    expect(endDowntimeAdvance.root?.chain?.edges?.length).toBe(2);
    expect(endDowntimeAdvance.root?.fsm?.active?.name?.value).toBe("Run");
    expect(endDowntimeAdvance.root?.fsm?.active?.state?.__typename).toBe(
      "InProgress",
    );
    expect(endDowntimeAdvance.root?.fsm?.transitions?.edges?.length).toBe(2);
    expect(endDowntimeAdvance.root?.state?.__typename).toBe("InProgress");
  }, 10_000);

  test("close all runs", async () => {
    const batchQuery = await execute(ctx, schema, TestBatchEntrypointDocument, {
      includeTrackingIds: true,
      parent: CUSTOMER.id,
    });
    expect(batchQuery.errors).toBeFalsy();

    const batches = assertNonNull(
      batchQuery.data?.trackables?.edges?.map(e => {
        assert(e.node?.__typename === "Task");
        return assertNonNull(e.node) as typeof e.node & { __typename: "Task" };
      }),
      "no batches?",
    );

    expect(batches.length).toBe(5);

    const batch = batches.at(0);
    // for (const batch of batches) {
    const result = await execute(
      ctx,
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        opts: {
          fsm: {
            id: assertNonNull(batch?.id),
            hash: assertNonNull(batch?.hash),
          },
          task: {
            id: assertNonNull(batch?.fsm?.active?.id),
            hash: assertNonNull(batch?.fsm?.active?.hash),
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
  }, 10_000);

  test("batches in-progress, runs closed", async () => {
    const batchQuery = await execute(ctx, schema, TestBatchEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(batchQuery.errors).toBeFalsy();
    expect(batchQuery.data?.trackables?.edges?.length).toBe(5);
    expect(batchQuery.data?.trackables?.edges?.at(0)).toMatchObject({
      node: {
        name: {
          value: "Batch 4",
        },
        fsm: {
          active: {
            name: {
              value: "Batch 4",
            },
            parent: {
              name: {
                value: "My Site",
              },
            },
            state: {
              __typename: "InProgress",
            },
          },
        },
        state: {
          __typename: "InProgress",
        },
      },
    });

    const entrypointQuery = await execute(
      ctx,
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
        includeTransitionIds: true,
      },
    );
    expect(entrypointQuery.errors).toBeFalsy();

    expect(entrypointQuery.data?.trackables?.edges?.length).toBe(1);
    // expect(entrypointQuery.data).toEqual(initialEntrypointData);
  });

  test("close all batches", async () => {
    const batchQuery = await execute(ctx, schema, TestBatchEntrypointDocument, {
      includeTrackingIds: true,
      parent: CUSTOMER.id,
    });
    expect(batchQuery.errors).toBeFalsy();

    const batches = assertNonNull(
      batchQuery.data?.trackables?.edges?.map(e => {
        assert(e.node?.__typename === "Task");
        return assertNonNull(e.node) as typeof e.node & { __typename: "Task" };
      }),
      "no batches?",
    );

    expect(batches.length).toBe(5);
    for (const batch of batches) {
      const batchId = assertNonNull(batch.id);
      const hash = assertNonNull(batch.hash);
      const result = await execute(
        ctx,
        schema,
        TestRuntimeTransitionMutationDocument,
        {
          opts: {
            fsm: {
              id: batchId,
              hash: hash,
            },
            task: {
              id: batchId,
              hash: hash,
            },
          },
        },
      );
      expect(result.errors).toBeFalsy();
    }
  }, 10_000);

  test("batches closed, runs closed", async () => {
    const batchQuery = await execute(ctx, schema, TestBatchEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(batchQuery.errors).toBeFalsy();
    // Most recent first.await createTestContext(),
    expect(batchQuery.data?.trackables?.edges).toMatchObject([
      {
        node: {
          name: {
            value: "Batch 4",
          },
          chain: {
            edges: [
              {
                node: {
                  name: {
                    value: "Batch 4",
                  },
                  state: {
                    __typename: "Closed",
                  },
                },
              },
              {
                node: {
                  name: {
                    value: "Run",
                  },
                  state: {
                    __typename: "Closed",
                  },
                },
              },
              {
                node: {
                  name: {
                    value: "Downtime",
                  },
                  state: {
                    __typename: "Closed",
                  },
                },
              },
            ],
          },
          chainAgg: [
            {
              group: "Batch",
              value: expect.stringMatching(/\d+.\d+/),
            },
            {
              group: "Downtime",
              value: expect.stringMatching(/\d+.\d+/),
            },
            {
              group: "Runtime",
              value: expect.stringMatching(/\d+.\d+/),
            },
          ],
          fsm: null,
          state: {
            __typename: "Closed",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 3",
          },
          chain: {
            edges: [
              {
                node: {
                  name: {
                    value: "Batch 3",
                  },
                  state: {
                    __typename: "Closed",
                  },
                },
              },
            ],
          },
          chainAgg: [
            {
              group: "Batch",
              value: expect.stringMatching(/\d+.\d+/),
            },
          ],
          fsm: null,
          state: {
            __typename: "Closed",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 2",
          },
          chain: {
            edges: [
              {
                node: {
                  name: {
                    value: "Batch 2",
                  },
                  state: {
                    __typename: "Closed",
                  },
                },
              },
            ],
          },
          chainAgg: [
            {
              group: "Batch",
              value: expect.stringMatching(/\d+.\d+/),
            },
          ],
          fsm: null,
          state: {
            __typename: "Closed",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 1",
          },
          chain: {
            edges: [
              {
                node: {
                  name: {
                    value: "Batch 1",
                  },
                  state: {
                    __typename: "Closed",
                  },
                },
              },
            ],
          },
          chainAgg: [
            {
              group: "Batch",
              value: expect.stringMatching(/\d+.\d+/),
            },
          ],
          fsm: null,
          state: {
            __typename: "Closed",
          },
        },
      },
      {
        node: {
          name: {
            value: "Batch 0",
          },
          chain: {
            edges: [
              {
                node: {
                  name: {
                    value: "Batch 0",
                  },
                  state: {
                    __typename: "Closed",
                  },
                },
              },
            ],
          },
          chainAgg: [
            {
              group: "Batch",
              value: expect.stringMatching(/\d+.\d+/),
            },
          ],
          fsm: null,
          state: {
            __typename: "Closed",
          },
        },
      },
    ]);

    const entrypointQuery = await execute(
      ctx,
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
        includeTransitionIds: true,
      },
    );
    expect(entrypointQuery.errors).toBeFalsy();

    expect(entrypointQuery.data?.trackables?.edges?.length).toBe(1);
    // expect(entrypointQuery.data).toEqual(initialEntrypointData);
  });

  test("history view", async () => {
    const query = await execute(ctx, schema, TestHistoryQueryDocument, {
      parent: CUSTOMER.id,
    });
    expect(query.errors).toBeFalsy();
    expect(query.data?.trackables?.edges).toMatchObject([
      {
        node: {
          name: {
            value: "Run",
          },
          parent: {
            name: {
              value: "My First Location",
            },
          },
          root: {
            name: {
              value: "Batch 4",
            },
            state: {
              __typename: "Closed",
            },
          },
          state: {
            __typename: "Closed",
          },
        },
      },
    ]);
  });

  beforeAll(async () => {
    await sql.begin(async sql => {
      CUSTOMER = await createCustomer({ faker, seed }, ctx, sql);
    });
  });

  afterAll(async () => {
    const rows = await sql`
      select id, systagtype as status
      from public.workinstance
      inner join public.systag on workinstancestatusid = systagid
      inner join public.worktemplatetype
        on workinstanceworktemplateid = worktemplatetypeworktemplateid
        and worktemplatetypesystagid in (
          select systagid
          from public.systag
          where systagtype in ('Batch', 'Downtime', 'Idle Time', 'Runtime')
        )
      where
          workinstancecustomerid in (
              select customerid
              from public.customer
              where customeruuid = ${CUSTOMER._id}
          )
          and workinstancestatusid in (706, 707)
      ;
    `;

    const expectedOpenCount = 1;
    if (rows.count > expectedOpenCount) {
      console.warn(
        `
==========
Test suite finished with too many open/in progress instances lingering.
We expect there to only be ${expectedOpenCount} *Open* instance remaining due to respawn rules.
This should be considered a BUG!

Linguine instances:
${rows.map(r => ` - ${r.id} (${r.status})`).join("\n")}
==========
        `,
      );
    }

    // Cleanup:
    // await cleanup(CUSTOMER);

    console.log(`
To reproduce this test:

  SEED=${seed} bun test batch.test --bail
    `);
  });
});
