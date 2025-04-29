import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import type { Location } from "@/schema/platform/archetype/location";
import type { Task } from "@/schema/system/component/task";
import {
  type Customer,
  assertTaskIsNamed,
  assertTaskParentIs,
  createEmptyCustomer,
  createTestContext,
  execute,
  getFieldByName,
} from "@/test/prelude";
import { assert, assertNonNull } from "@/util";
import {
  AssignBatchMutationDocument,
  CreateBatchMutationDocument,
  TestBatchEntrypointDocument,
} from "./batch.test.generated";
import { getLatestFsm, mostRecentInstance } from "./prelude";
import {
  TestRuntimeDetailDocument,
  TestRuntimeEntrypointDocument,
  TestRuntimeTransitionMutationDocument,
} from "./runtime.test.generated";

const ctx = await createTestContext();

describe("runtime + batch tracking", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: Customer;
  let BATCH_TEMPLATE: Task;
  let FACTORY: Location;
  let MIXING_LINE: Location;
  let FILL_LINE: Location;
  let RUN_TEMPLATE: Task;

  test("no batches at first", async () => {
    const result = await execute(schema, TestBatchEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data?.trackables?.edges?.length).toBe(0);
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
      parent: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("but it shows up via the batch entrypoint query", async () => {
    const result = await execute(schema, TestBatchEntrypointDocument, {
      parent: CUSTOMER.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("assign the batch", async () => {
    const node = await RUN_TEMPLATE.instantiate(
      {
        location: MIXING_LINE.id,
      },
      ctx,
    );
    const base = await mostRecentInstance(BATCH_TEMPLATE);
    expect(node.id).not.toBe(base.id);

    const result = await execute(schema, AssignBatchMutationDocument, {
      node: node.id,
      base: base.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchObject({
      rebase: {
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
            value: "Batch",
          },
        },
        state: {
          __typename: "Open",
        },
      },
    });
  });

  test("start the batch", async () => {
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
        },
      },
    });
  });

  test("start run @ mixing line", async () => {
    // We should already have an *open* Run instance at the Mixing Line because
    // we rebased onto the Batch in an earlier test!
    const { fsm, root } = await getLatestFsm(BATCH_TEMPLATE);
    const active = assertNonNull(fsm.active, "should be active");
    assertTaskIsNamed(active, "Run", ctx);
    assertTaskParentIs(active, MIXING_LINE);

    const startRun = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: true,
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
    expect(startRun.errors).toBeFalsy();
    expect(startRun.data?.advance?.root?.fsm?.active).toMatchSnapshot();
  });

  test("end run @ mixing line", async () => {
    const { fsm, root } = await getLatestFsm(BATCH_TEMPLATE);
    const active = assertNonNull(fsm.active, "should be active");
    assertTaskIsNamed(active, "Run", ctx);

    const finishRun = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: true,
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
    expect(finishRun.errors).toBeFalsy();
    expect(finishRun.data?.advance?.root?.fsm?.active).toMatchSnapshot();
    expect(finishRun.data?.advance?.root?.chain).toMatchSnapshot();
  });

  test("start run @ fill line", async () => {
    // The engine will have created a Run instance at the Fill Line, as per the
    // transitions we configure in the `beforeAll` phase.
    const { fsm, root } = await getLatestFsm(BATCH_TEMPLATE);
    const active = assertNonNull(fsm.active, "should be active");
    assertTaskIsNamed(active, "Run", ctx);
    assertTaskParentIs(active, FILL_LINE);

    const startRun = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: true,
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
    expect(startRun.errors).toBeFalsy();
    expect(startRun.data?.advance?.root?.fsm?.active).toMatchSnapshot();
  });

  test("end run @ fill line", async () => {
    const { fsm, root } = await getLatestFsm(BATCH_TEMPLATE);
    const active = assertNonNull(fsm.active, "should be active");
    assertTaskIsNamed(active, "Run", ctx);

    const finishRun = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: true,
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
    expect(finishRun.errors).toBeFalsy();
    expect(finishRun.data?.advance?.root?.fsm?.active).toMatchSnapshot();
    expect(finishRun.data?.advance?.root?.chain).toMatchSnapshot();
  });

  test("close out the batch", async () => {
    const { root } = await getLatestFsm(BATCH_TEMPLATE);
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
      includeChainParents: true,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchObject({
      node: {
        chain: {
          edges: [
            {
              node: {
                name: {
                  value: "Batch", // FIXME
                },
                parent: {
                  name: {
                    value: "Frozen Tendy Factory",
                  },
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
                parent: {
                  name: {
                    value: "Mixing Line",
                  },
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
                parent: {
                  name: {
                    value: "Fill Line",
                  },
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
            // TODO: Cascade when operating on the root?
            // Or, ideally, any ancestor.
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
                state: {
                  __typename: "Open",
                },
              },
            },
          ],
          totalCount: 4,
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
        parent: {
          name: {
            value: "Frozen Tendy Factory",
          },
        },
      },
    });
  });

  beforeAll(async () => {
    // Setup:
    await sql.begin(async sql => {
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
      MIXING_LINE = await FACTORY.insertChild(
        { name: "Mixing Line", order: 0, type: "Runtime Location" },
        ctx,
        sql,
      );
      FILL_LINE = await FACTORY.insertChild(
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
      RUN_TEMPLATE = await FACTORY.createTemplate(
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
      for (const t of [RUN_TEMPLATE, downTemplate, idleTemplate]) {
        await t.ensureInstantiableAt(
          {
            locations: [
              MIXING_LINE.id,
              FILL_LINE.id,
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
        MIXING_LINE,
        FILL_LINE,
        assemblyLine,
        cartoningLine,
        packagingLine,
      ]) {
        await BATCH_TEMPLATE.createTransition(
          {
            whenStatusChangesTo: "InProgress",
            instantiate: {
              template: RUN_TEMPLATE.id,
              atLocation: l.id,
              withType: "On Demand", // Choice.
            },
          },
          ctx,
          sql,
        );
      }

      // Mixing -> Fill
      await RUN_TEMPLATE.createTransition(
        {
          atLocation: MIXING_LINE.id,
          whenStatusChangesTo: "Closed",
          instantiate: {
            template: RUN_TEMPLATE.id,
            atLocation: FILL_LINE.id,
            withType: "Task", // Eager. This is the default.
          },
        },
        ctx,
        sql,
      );

      // Fill -> Assembly
      await RUN_TEMPLATE.createTransition(
        {
          atLocation: FILL_LINE.id,
          whenStatusChangesTo: "Closed",
          instantiate: {
            template: RUN_TEMPLATE.id,
            atLocation: assemblyLine.id,
          },
        },
        ctx,
        sql,
      );

      // Assembly -> Cartoning
      await RUN_TEMPLATE.createTransition(
        {
          atLocation: assemblyLine.id,
          whenStatusChangesTo: "Closed",
          instantiate: {
            template: RUN_TEMPLATE.id,
            atLocation: cartoningLine.id,
          },
        },
        ctx,
        sql,
      );

      // Cartoning -> Packaging
      await RUN_TEMPLATE.createTransition(
        {
          atLocation: cartoningLine.id,
          whenStatusChangesTo: "Closed",
          instantiate: {
            template: RUN_TEMPLATE.id,
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
