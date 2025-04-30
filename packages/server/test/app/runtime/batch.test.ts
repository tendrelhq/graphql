import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { type Customer, createTestContext, execute } from "@/test/prelude";
import { assert, assertNonNull, map, mapOrElse } from "@/util";
import { Faker, en } from "@faker-js/faker";
import {
  AssignBatchMutationDocument,
  CreateBatchMutationDocument,
  TestBatchEntrypointDocument,
  TestListBatchTemplatesDocument,
} from "./batch.test.generated";
import { createCustomer } from "./prelude/batch";
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
const faker = new Faker({ locale: [en], seed });

const customerName = seed.toString();

describe("runtime + batch tracking", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: Customer;

  let initialEntrypointData: TestRuntimeEntrypointQuery | null;
  test("entrypoint query", async () => {
    const result = await execute(schema, TestRuntimeEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();

    expect(result.data?.trackables?.edges?.length).toBe(5);
    expect(result.data?.trackables?.edges).toMatchObject([
      {
        node: {
          name: {
            value: "Mixing Line",
          },
          tracking: {
            edges: [
              {
                node: {
                  fsm: null, // Not an instance!
                  name: {
                    value: "Run",
                  },
                  state: null, // Not an instance!
                },
              },
            ],
          },
        },
      },
      {
        node: {
          name: {
            value: "Fill Line",
          },
        },
      },
      {
        node: {
          name: {
            value: "Assembly Line",
          },
        },
      },
      {
        node: {
          name: {
            value: "Cartoning Line",
          },
        },
      },
      {
        node: {
          name: {
            value: "Packaging Line",
          },
        },
      },
    ]);

    // biome-ignore lint/suspicious/noExplicitAny:
    initialEntrypointData = result.data as any;
  });

  test.todo("the normal Runtime test suite", async () => {
    //
  });

  test("batch entrypoint query", async () => {
    const result = await execute(schema, TestBatchEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();
    // We have yet to create any Batch instances!
    expect(result.data?.trackables?.edges?.length).toBe(0);
  });

  test("create some batches", async () => {
    const result0 = await execute(schema, TestListBatchTemplatesDocument, {
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
      const result = await execute(schema, CreateBatchMutationDocument, {
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
    const result = await execute(schema, TestRuntimeEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(result.data).toEqual(initialEntrypointData);
  });

  test("batch query has updated", async () => {
    const result = await execute(schema, TestBatchEntrypointDocument, {
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
              // Batches are instantiated at the site-level, which have the same
              // name as the customer (in this test).
              parent: {
                name: {
                  value: customerName,
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
            value: "Batch 3",
          },
          fsm: {
            active: {
              // Batches are instantiated at the site-level, which have the same
              // name as the customer (in this test).
              parent: {
                name: {
                  value: customerName,
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
              // Batches are instantiated at the site-level, which have the same
              // name as the customer (in this test).
              parent: {
                name: {
                  value: customerName,
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
              // Batches are instantiated at the site-level, which have the same
              // name as the customer (in this test).
              parent: {
                name: {
                  value: customerName,
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
              // Batches are instantiated at the site-level, which have the same
              // name as the customer (in this test).
              parent: {
                name: {
                  value: customerName,
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

  test("assign all batches", async () => {
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
      schema,
      TestRuntimeEntrypointDocument,
      {
        includeTrackingIds: true,
        parent: CUSTOMER.id,
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

    const batchQuery = await execute(schema, TestBatchEntrypointDocument, {
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

    expect(locations.length).toBe(batches.length);

    for (let i = 0; i < 5; i++) {
      const batch = assertNonNull(batches.at(i)?.id);
      const location = assertNonNull(locations.at(i));
      const run = assertNonNull(
        map(location.tracking?.edges?.at(0)?.node, node => {
          assert(node.__typename === "Task");
          return (node as typeof node & { __typename: "Task" }).id;
        }),
      );
      const result = await execute(schema, AssignBatchMutationDocument, {
        base: batch,
        node: run,
        location: location.id,
      });
      expect(result.errors).toBeFalsy();
    }
  });

  test("batches open, runs opens", async () => {
    const batchQuery = await execute(schema, TestBatchEntrypointDocument, {
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
                  value: "Mixing Line",
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
                value: "Run",
              },
              parent: {
                name: {
                  value: "Fill Line",
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
                value: "Run",
              },
              parent: {
                name: {
                  value: "Assembly Line",
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
                value: "Run",
              },
              parent: {
                name: {
                  value: "Cartoning Line",
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
                value: "Run",
              },
              parent: {
                name: {
                  value: "Packaging Line",
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
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
      },
    );
    expect(entrypointQuery.errors).toBeFalsy();

    expect(entrypointQuery.data?.trackables?.edges?.length).toBe(5);
    expect(entrypointQuery.data?.trackables?.edges).toMatchObject([
      {
        node: {
          name: {
            value: "Mixing Line",
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
                      value: "Mixing Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 4",
                    },
                    parent: {
                      name: {
                        value: customerName,
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
      {
        node: {
          name: {
            value: "Fill Line",
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
                      value: "Fill Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 3",
                    },
                    parent: {
                      name: {
                        value: customerName,
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
      {
        node: {
          name: {
            value: "Assembly Line",
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
                      value: "Assembly Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 2",
                    },
                    parent: {
                      name: {
                        value: customerName,
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
      {
        node: {
          name: {
            value: "Cartoning Line",
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
                      value: "Cartoning Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 1",
                    },
                    parent: {
                      name: {
                        value: customerName,
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
      {
        node: {
          name: {
            value: "Packaging Line",
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
                      value: "Packaging Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 0",
                    },
                    parent: {
                      name: {
                        value: customerName,
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

  test("start all batches", async () => {
    const batchQuery = await execute(schema, TestBatchEntrypointDocument, {
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
  });

  test("batches in-progress, runs remain open", async () => {
    const batchQuery = await execute(schema, TestBatchEntrypointDocument, {
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
                  value: "Mixing Line",
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
                value: "Run",
              },
              parent: {
                name: {
                  value: "Fill Line",
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
            value: "Batch 2",
          },
          fsm: {
            active: {
              name: {
                value: "Run",
              },
              parent: {
                name: {
                  value: "Assembly Line",
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
            value: "Batch 1",
          },
          fsm: {
            active: {
              name: {
                value: "Run",
              },
              parent: {
                name: {
                  value: "Cartoning Line",
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
            value: "Batch 0",
          },
          fsm: {
            active: {
              name: {
                value: "Run",
              },
              parent: {
                name: {
                  value: "Packaging Line",
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
    ]);

    const entrypointQuery = await execute(
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
      },
    );
    expect(entrypointQuery.errors).toBeFalsy();

    expect(entrypointQuery.data?.trackables?.edges?.length).toBe(5);
    expect(entrypointQuery.data?.trackables?.edges).toMatchObject([
      {
        node: {
          name: {
            value: "Mixing Line",
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
                      value: "Mixing Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 4",
                    },
                    parent: {
                      name: {
                        value: customerName,
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
      {
        node: {
          name: {
            value: "Fill Line",
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
                      value: "Fill Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 3",
                    },
                    parent: {
                      name: {
                        value: customerName,
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
      {
        node: {
          name: {
            value: "Assembly Line",
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
                      value: "Assembly Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 2",
                    },
                    parent: {
                      name: {
                        value: customerName,
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
      {
        node: {
          name: {
            value: "Cartoning Line",
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
                      value: "Cartoning Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 1",
                    },
                    parent: {
                      name: {
                        value: customerName,
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
      {
        node: {
          name: {
            value: "Packaging Line",
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
                      value: "Packaging Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 0",
                    },
                    parent: {
                      name: {
                        value: customerName,
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

  test("start all runs", async () => {
    const batchQuery = await execute(schema, TestBatchEntrypointDocument, {
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
      const result = await execute(
        schema,
        TestRuntimeTransitionMutationDocument,
        {
          opts: {
            fsm: {
              id: assertNonNull(batch.id),
              hash: assertNonNull(batch.hash),
            },
            task: {
              id: assertNonNull(batch.fsm?.active?.id),
              hash: assertNonNull(batch.fsm?.active?.hash),
            },
          },
        },
      );
      expect(result.errors).toBeFalsy();
    }
  });

  test("batches in-progress, runs in-progress", async () => {
    const batchQuery = await execute(schema, TestBatchEntrypointDocument, {
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
                  value: "Mixing Line",
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
                value: "Run",
              },
              parent: {
                name: {
                  value: "Fill Line",
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
                value: "Run",
              },
              parent: {
                name: {
                  value: "Assembly Line",
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
                value: "Run",
              },
              parent: {
                name: {
                  value: "Cartoning Line",
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
                value: "Run",
              },
              parent: {
                name: {
                  value: "Packaging Line",
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
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
      },
    );
    expect(entrypointQuery.errors).toBeFalsy();

    expect(entrypointQuery.data?.trackables?.edges?.length).toBe(5);
    expect(entrypointQuery.data?.trackables?.edges).toMatchObject([
      {
        node: {
          name: {
            value: "Mixing Line",
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
                      value: "Mixing Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 4",
                    },
                    parent: {
                      name: {
                        value: customerName,
                      },
                    },
                  },
                  state: {
                    __typename: "InProgress",
                  },
                },
              },
            ],
          },
        },
      },
      {
        node: {
          name: {
            value: "Fill Line",
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
                      value: "Fill Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 3",
                    },
                    parent: {
                      name: {
                        value: customerName,
                      },
                    },
                  },
                  state: {
                    __typename: "InProgress",
                  },
                },
              },
            ],
          },
        },
      },
      {
        node: {
          name: {
            value: "Assembly Line",
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
                      value: "Assembly Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 2",
                    },
                    parent: {
                      name: {
                        value: customerName,
                      },
                    },
                  },
                  state: {
                    __typename: "InProgress",
                  },
                },
              },
            ],
          },
        },
      },
      {
        node: {
          name: {
            value: "Cartoning Line",
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
                      value: "Cartoning Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 1",
                    },
                    parent: {
                      name: {
                        value: customerName,
                      },
                    },
                  },
                  state: {
                    __typename: "InProgress",
                  },
                },
              },
            ],
          },
        },
      },
      {
        node: {
          name: {
            value: "Packaging Line",
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
                      value: "Packaging Line",
                    },
                  },
                  root: {
                    name: {
                      value: "Batch 0",
                    },
                    parent: {
                      name: {
                        value: customerName,
                      },
                    },
                  },
                  state: {
                    __typename: "InProgress",
                  },
                },
              },
            ],
          },
        },
      },
    ]);
  });

  test("close all runs", async () => {
    const batchQuery = await execute(schema, TestBatchEntrypointDocument, {
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
      const result = await execute(
        schema,
        TestRuntimeTransitionMutationDocument,
        {
          opts: {
            fsm: {
              id: assertNonNull(batch.id),
              hash: assertNonNull(batch.hash),
            },
            task: {
              id: assertNonNull(batch.fsm?.active?.id),
              hash: assertNonNull(batch.fsm?.active?.hash),
            },
          },
        },
      );
      expect(result.errors).toBeFalsy();
    }
  });

  test("batches in-progress, runs closed", async () => {
    const batchQuery = await execute(schema, TestBatchEntrypointDocument, {
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
                value: "Batch 4",
              },
              parent: {
                name: {
                  value: customerName,
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
                  value: customerName,
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
                  value: customerName,
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
                  value: customerName,
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
                  value: customerName,
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
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
      },
    );
    expect(entrypointQuery.errors).toBeFalsy();

    expect(entrypointQuery.data?.trackables?.edges?.length).toBe(5);
    expect(entrypointQuery.data).toEqual(initialEntrypointData);
  });

  test("close all batches", async () => {
    const batchQuery = await execute(schema, TestBatchEntrypointDocument, {
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
  });

  test("batches closed, runs closed", async () => {
    const batchQuery = await execute(schema, TestBatchEntrypointDocument, {
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
            ],
          },
          chainAgg: [
            {
              group: "Batch",
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
            ],
          },
          chainAgg: [
            {
              group: "Batch",
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
            ],
          },
          chainAgg: [
            {
              group: "Batch",
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
            ],
          },
          chainAgg: [
            {
              group: "Batch",
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
            ],
          },
          chainAgg: [
            {
              group: "Batch",
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
    ]);

    const entrypointQuery = await execute(
      schema,
      TestRuntimeEntrypointDocument,
      {
        parent: CUSTOMER.id,
      },
    );
    expect(entrypointQuery.errors).toBeFalsy();

    expect(entrypointQuery.data?.trackables?.edges?.length).toBe(5);
    expect(entrypointQuery.data).toEqual(initialEntrypointData);
  });

  beforeAll(async () => {
    CUSTOMER = await createCustomer(customerName, ctx);
  });

  afterAll(async () => {
    const rows = await sql`
      select id, systagtype as status
      from public.workinstance
      inner join public.systag on workinstancestatusid = systagid
      where
          workinstancecustomerid in (
              select customerid
              from public.customer
              where customeruuid = ${CUSTOMER._id}
          )
          and workinstancestatusid in (706, 707)
      ;
    `;

    if (rows.count) {
      console.warn(
        `
==========
Test suite finished with ${rows.length} open/in progress instances lingering.
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
