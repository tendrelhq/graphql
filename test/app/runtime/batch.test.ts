import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import type { Location } from "@/schema/platform/archetype/location";
import type { Task } from "@/schema/system/component/task";
import {
  type Customer,
  createEmptyCustomer,
  createTestContext,
  execute,
  getFieldByName,
} from "@/test/prelude";
import { assert, assertNonNull, map } from "@/util";
import type { Maybe } from "graphql/jsutils/Maybe";
import type { ID } from "grats";
import {
  CreateBatchMutationDocument,
  TestBatchEntrypointDocument,
} from "./batch.test.generated";
import {
  getLatestFsm,
  mostRecentInstance,
  mostRecentlyInProgress,
} from "./prelude";
import {
  TestRuntimeDetailDocument,
  TestRuntimeEntrypointDocument,
  TestRuntimeTransitionMutationDocument,
} from "./runtime.test.generated";

describe.skip("runtime + batch tracking", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: Customer;
  let BATCH_TEMPLATE: Task;
  let FACTORY: Location;

  test("no batches at first", async () => {
    const result = await execute(schema, TestRuntimeEntrypointDocument, {
      root: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  let batchId = 0;

  test("create a new batch", async () => {
    // Note that this only creates an *open* Batch instance. In particular, this
    // would not show up on the current Runtime home screen.
    const customer = await getFieldByName(BATCH_TEMPLATE, "Customer");
    const productName = await getFieldByName(BATCH_TEMPLATE, "Product Name");
    const sku = await getFieldByName(BATCH_TEMPLATE, "SKU");
    const result = await execute(schema, CreateBatchMutationDocument, {
      batchTemplateId: BATCH_TEMPLATE.id,
      batchId: (batchId++).toString(),
      fields: [
        {
          field: customer.id,
          valueType: customer.valueType,
          value: { string: "Ross's Salsa" },
        },
        {
          field: productName.id,
          valueType: productName.valueType,
          value: { string: "Mild Green Salsa" },
        },
        {
          field: sku.id,
          valueType: sku.valueType,
          value: { string: "SLS-GRN-ML" },
        },
      ],
      location: FACTORY.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("still no batches via the canonical entrypoint query", async () => {
    const result = await execute(schema, TestRuntimeEntrypointDocument, {
      root: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("but it shows up via the batch entrypoint query", async () => {
    const result = await execute(schema, TestBatchEntrypointDocument, {
      customerId: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  let nextTransition: Maybe<ID>;

  test("put the batch in-progress", async () => {
    const t = await mostRecentInstance(BATCH_TEMPLATE);
    const h = await t.hash();
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        includeTransitionIds: true,
        opts: {
          fsm: {
            id: t.id,
            hash: h,
          },
          task: {
            id: t.id,
            hash: h,
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchObject({
      advance: {
        root: {
          fsm: {
            active: {
              name: {
                value: "Batch",
              },
              parent: {
                name: {
                  value: "Frozen Tendy Factory",
                },
              },
              state: {
                __typename: "InProgress",
              },
            },
            transitions: {
              edges: [
                {
                  node: {
                    name: {
                      value: "Run",
                    },
                  },
                  target: {
                    name: {
                      value: "Mixing Line",
                    },
                  },
                },
                {
                  node: {
                    name: {
                      value: "Run",
                    },
                  },
                  target: {
                    name: {
                      value: "Fill Line",
                    },
                  },
                },
                {
                  node: {
                    name: {
                      value: "Run",
                    },
                  },
                  target: {
                    name: {
                      value: "Assembly Line",
                    },
                  },
                },
                {
                  node: {
                    name: {
                      value: "Run",
                    },
                  },
                  target: {
                    name: {
                      value: "Cartoning Line",
                    },
                  },
                },
                {
                  node: {
                    name: {
                      value: "Run",
                    },
                  },
                  target: {
                    name: {
                      value: "Packaging Line",
                    },
                  },
                },
              ],
            },
          },
        },
      },
    });

    nextTransition = map(
      result.data?.advance?.root?.fsm?.transitions?.edges?.find(
        e => e.target?.name.value === "Cartoning Line",
      ),
      e => e.id,
    );
  });

  // Note that I am starting here (Cartoning) just for the sake of testing:
  test("transition to cartoning", async () => {
    const t = assertNonNull(nextTransition);
    const fsm = await mostRecentInstance(BATCH_TEMPLATE);
    const startCartoning = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: fsm.id,
            hash: await fsm.hash(),
          },
          task: {
            id: t,
            hash: "", // doesn't matter when transitioning
          },
        },
      },
    );
    expect(startCartoning.errors).toBeFalsy();
    expect(startCartoning.data).toMatchSnapshot();

    // Close out cartoning and move to packaging.
    const i = await mostRecentlyInProgress(fsm);
    const finishCartoning = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: fsm.id,
            hash: await fsm.hash(),
          },
          task: {
            id: i.id,
            hash: await i.hash(),
          },
        },
      },
    );
    expect(finishCartoning.errors).toBeFalsy();
    expect(finishCartoning.data).toMatchSnapshot();
  });

  // FIXME: the user would still see the in-progress transitions after
  // completing this task. Do we have any way to avoid this? Could we use a
  // field+state rule? What about auto-close? I'm not sure we have the ability
  // to do that right now... but certainly in the forthcoming new model.
  // Note that this is the final transition:
  test("start + close packaging", async () => {
    // Due to how we've set things up, we should *already have* an open instance
    // at the Packaging Line.
    const { root, fsm } = await getLatestFsm(BATCH_TEMPLATE);
    assert(root.id !== fsm.active?.id, "should be in runtime");
    const active = assertNonNull(fsm.active);
    const startPackaging = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: root.id,
            hash: await root.hash(),
          },
          task: {
            id: active.id,
            hash: await active.hash(),
          },
        },
      },
    );
    expect(startPackaging.errors).toBeFalsy();
    expect(startPackaging.data).toMatchSnapshot();

    const i = await mostRecentlyInProgress(root);
    const finishCartoning = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: root.id,
            hash: await root.hash(),
          },
          task: {
            id: i.id,
            hash: await i.hash(),
          },
        },
      },
    );
    expect(finishCartoning.errors).toBeFalsy();
    expect(finishCartoning.data).toMatchSnapshot();
  });

  test("close out the batch", async () => {
    const { root, fsm } = await getLatestFsm(BATCH_TEMPLATE);
    assert(root.id === fsm.active?.id, "expected batch to be all that's left");
    const rootHash = await root.hash();
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: root.id,
            hash: rootHash,
          },
          task: {
            id: root.id,
            hash: rootHash,
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("closed batch view", async () => {
    const i = await mostRecentInstance(BATCH_TEMPLATE);
    const result = await execute(schema, TestRuntimeDetailDocument, {
      node: i.id,
      overTypes: ["Batch", "Runtime"],
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchObject({
      node: {
        __typename: "Task",
        chain: {
          __typename: "TaskConnection",
          edges: [
            {
              __typename: "TaskEdge",
              node: {
                __typename: "Task",
                name: {
                  __typename: "DisplayName",
                  value: "Batch", // FIXME
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
            {
              __typename: "TaskEdge",
              node: {
                __typename: "Task",
                name: {
                  __typename: "DisplayName",
                  value: "Run",
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
            {
              __typename: "TaskEdge",
              node: {
                __typename: "Task",
                name: {
                  __typename: "DisplayName",
                  value: "Run",
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
          ],
          totalCount: 3,
        },
        chainAgg: [
          {
            __typename: "Aggregate",
            group: "Batch",
            value: expect.stringMatching(/\d+.\d+/),
          },
          {
            __typename: "Aggregate",
            group: "Runtime",
            value: expect.stringMatching(/\d+.\d+/),
          },
        ],
        parent: {
          __typename: "Location",
          name: {
            __typename: "Name",
            value: "Frozen Tendy Factory",
          },
        },
      },
    });
  });

  beforeAll(async () => {
    // Setup:
    await sql.begin(async sql => {
      const ctx = await createTestContext();
      await setCurrentIdentity(sql, ctx);

      CUSTOMER = await createEmptyCustomer(
        { name: "Frozen Tendy Factory" },
        ctx,
        sql,
      );

      await CUSTOMER.addWorker(
        { identityId: assertNonNull(process.env.X_TENDREL_USER) },
        ctx,
        sql,
      );

      // Setup "Runtime" and configure "Batch tracking".
      // This involves:
      // 1. Locations: site + Mixing, Fill, Assembly, Cartoning and Packaging Lines
      // 2. Templates:
      //   - Batch: instantiated at the site level
      //   - Run, Down, Idle: instantiated at the "Lines" level
      // 3. Rules:
      //   - *No* in-progress/respawn rule. Batches (instances) must be created
      //     manually.
      //   - When a Run instance is Closed, an Open Run instance should be
      //     [eagerly] created at the "next" line. Same originator (i.e. Batch).

      // Locations.
      FACTORY = await CUSTOMER.addLocation(
        { name: "Frozen Tendy Factory", type: "Frozen Tendy Factory" },
        ctx,
        sql,
      );
      const mixingLine = await FACTORY.insertChild(
        { name: "Mixing Line", order: 0, type: "Runtime Location" },
        ctx,
        sql,
      );
      const fillLine = await FACTORY.insertChild(
        { name: "Fill Line", order: 1, type: "Runtime Location" },
        ctx,
        sql,
      );
      const assemblyLine = await FACTORY.insertChild(
        { name: "Assembly Line", order: 2, type: "Runtime Location" },
        ctx,
        sql,
      );
      const cartoningLine = await FACTORY.insertChild(
        { name: "Cartoning Line", order: 3, type: "Runtime Location" },
        ctx,
        sql,
      );
      const packagingLine = await FACTORY.insertChild(
        { name: "Packaging Line", order: 4, type: "Runtime Location" },
        ctx,
        sql,
      );

      // Templates.
      BATCH_TEMPLATE = await FACTORY.createTemplate(
        {
          name: "Batch",
          fields: [
            { name: "Customer", type: "string" },
            { name: "Product Name", type: "string" },
            { name: "SKU", type: "string" },
          ],
          types: ["Batch"],
        },
        ctx,
        sql,
      );
      const runTemplate = await FACTORY.createTemplate(
        {
          name: "Run",
          fields: [
            // Note that we still have the primary/order requirement for
            // Overrides (primary + 0 => start, 1 => end).
            // This will be removed in the future.
            {
              name: "Override Start Time",
              type: "timestamp",
              isPrimary: true,
              order: 0,
            },
            {
              name: "Override End Time",
              type: "timestamp",
              isPrimary: true,
              order: 1,
            },
            { name: "Run Output", type: "number", order: 2 },
            { name: "Reject Count", type: "number", order: 3 },
            { name: "Comments", type: "string", order: 99 },
          ],
          types: ["Trackable", "Runtime"],
        },
        ctx,
        sql,
      );
      const downTemplate = await FACTORY.createTemplate(
        {
          name: "Downtime",
          fields: [
            {
              name: "Override Start Time",
              type: "timestamp",
              isPrimary: true,
              order: 0,
            },
            {
              name: "Override End Time",
              type: "timestamp",
              isPrimary: true,
              order: 1,
            },
            { name: "Description", type: "string", order: 99 },
          ],
          types: ["Downtime"],
        },
        ctx,
        sql,
      );
      const idleTemplate = await FACTORY.createTemplate(
        {
          name: "Idle Time",
          fields: [
            {
              name: "Override Start Time",
              type: "timestamp",
              isPrimary: true,
              order: 0,
            },
            {
              name: "Override End Time",
              type: "timestamp",
              isPrimary: true,
              order: 1,
            },
            { name: "Description", type: "string", order: 99 },
          ],
          types: ["Idle Time"],
        },
        ctx,
        sql,
      );

      // Constraints.
      await BATCH_TEMPLATE.ensureInstantiableAt(
        { locations: [FACTORY.id] },
        ctx,
        sql,
      );
      await BATCH_TEMPLATE.ensureInstantiableAt(
        { locations: [FACTORY.id] },
        ctx,
        sql,
      );
      for (const t of [runTemplate, downTemplate, idleTemplate]) {
        await t.ensureInstantiableAt(
          {
            locations: [
              mixingLine.id,
              fillLine.id,
              assemblyLine.id,
              cartoningLine.id,
              packagingLine.id,
            ],
          },
          ctx,
          sql,
        );
      }

      // Rules.
      // When the Batch goes in-progress, prompt the user to choose where it
      // should go next. For the purposes of this test, we will allow for the
      // Batch to start at any Line.
      for (const l of [
        mixingLine,
        fillLine,
        assemblyLine,
        cartoningLine,
        packagingLine,
      ]) {
        await BATCH_TEMPLATE.createTransition(
          {
            whenStatusChangesTo: "InProgress",
            instantiate: {
              template: runTemplate.id,
              atLocation: l.id,
              withType: "On Demand", // Choice.
            },
          },
          ctx,
          sql,
        );
      }

      // Mixing -> Fill
      await runTemplate.createTransition(
        {
          atLocation: mixingLine.id,
          whenStatusChangesTo: "Closed",
          instantiate: {
            template: runTemplate.id,
            atLocation: fillLine.id,
            withType: "Task", // Eager. This is the default.
          },
        },
        ctx,
        sql,
      );

      // Fill -> Assembly
      await runTemplate.createTransition(
        {
          atLocation: fillLine.id,
          whenStatusChangesTo: "Closed",
          instantiate: {
            template: runTemplate.id,
            atLocation: assemblyLine.id,
          },
        },
        ctx,
        sql,
      );

      // Assembly -> Cartoning
      await runTemplate.createTransition(
        {
          atLocation: assemblyLine.id,
          whenStatusChangesTo: "Closed",
          instantiate: {
            template: runTemplate.id,
            atLocation: cartoningLine.id,
          },
        },
        ctx,
        sql,
      );

      // Cartoning -> Packaging
      await runTemplate.createTransition(
        {
          atLocation: cartoningLine.id,
          whenStatusChangesTo: "Closed",
          instantiate: {
            template: runTemplate.id,
            atLocation: packagingLine.id,
          },
        },
        ctx,
        sql,
      );

      // FIXME: use Keller's API for customer create through the entity model.
      // await sql`call entity.import_entity(null)`;
    });
  });

  afterAll(async () => {
    // Cleanup:
    // await cleanup(CUSTOMER);
  });
});
