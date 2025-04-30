import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { Task } from "@/schema/system/component/task";
import {
  assertTaskIsNamed,
  createTestContext,
  execute,
  findAndEncode,
  getFieldByName,
  setup,
} from "@/test/prelude";
import { assertNonNull, map } from "@/util";
import type { Maybe } from "graphql/jsutils/Maybe";
import {
  CreateReasonCodeDocument,
  DeleteReasonCodeDocument,
  GetReasonCodeCompletionsDocument,
  ListReasonCodes2Document,
  ListReasonCodesDocument,
  ListTemplatesDocument,
} from "./reason-codes.test.generated";

describe("runtime + reason codes", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: string;

  test("demo has no reason codes set up at first", async () => {
    const result = await execute(schema, ListReasonCodesDocument, {
      // FIXME: Should not be required:
      owner: CUSTOMER,
      // FIXME: This is not particularly ergonomic :/
      // Note that this is the entityinstanceuuid for the "Reason Code" systag:
      parent: ["f875b28c-ccc9-4c69-b5b4-9f10ad89d23b"],
    });
    expect(result.errors).toBeFalsy();
    expect(result.data?.instances?.totalCount).toBe(0);
  });

  let DOWN_TIME: Maybe<Task>;
  let IDLE_TIME: Maybe<Task>;
  test("grab the Downtime and Idle Time templates", async () => {
    const result = await execute(schema, ListTemplatesDocument, {
      owner: CUSTOMER,
      types: ["Downtime", "Idle Time"],
    });
    expect(result.errors).toBeFalsy();

    DOWN_TIME = map(
      result.data?.templates?.edges
        ?.flatMap(e => {
          if (e.node?.asTask?.name?.value === "Downtime")
            return e.node.asTask.id;
          return [];
        })
        .at(0),
      id => new Task({ id }),
    );
    expect(DOWN_TIME).toBeTruthy();

    IDLE_TIME = map(
      result.data?.templates?.edges
        ?.flatMap(e => {
          if (e.node?.asTask?.name?.value === "Idle Time")
            return e.node.asTask.id;
          return [];
        })
        .at(0),
      id => new Task({ id }),
    );
  });

  test("create some reason codes (for Downtime)", async () => {
    const t = assertNonNull(DOWN_TIME);
    // Note that in a real application you would grab this from Task.fields:
    const f = await getFieldByName(t, "Reason Code");

    let order = 0;
    for (const code of [
      "Machine Down",
      "Scheduled Maintenance",
      "Waiting for Materials",
      "Masheen Dawn",
    ]) {
      const result = await execute(schema, CreateReasonCodeDocument, {
        field: f.id,
        name: code,
        // FIXME: This is not particularly ergonomic :/
        // Note that this is the entityinstanceuuid for the "Reason Code" systag:
        parent: "f875b28c-ccc9-4c69-b5b4-9f10ad89d23b",
        order: order++,
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchObject({
        createCustagAsFieldTemplateValueTypeConstraint: {
          node: {
            name: {
              value: code,
            },
          },
          asFieldTemplateValueType: {
            edges: [
              {
                node: {
                  id: expect.any(String),
                  name: {
                    value: "Reason Code",
                  },
                  parent: {
                    name: {
                      value: "Downtime",
                    },
                  },
                },
              },
            ],
          },
        },
      });
    }

    const result = await execute(schema, ListReasonCodesDocument, {
      // FIXME: Should not be required:
      owner: CUSTOMER,
      // FIXME: This is not particularly ergonomic :/
      // Note that this is the entityinstanceuuid for the "Reason Code" systag:
      parent: ["f875b28c-ccc9-4c69-b5b4-9f10ad89d23b"],
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test.todo("list reason codes (with filters)", async () => {
    // Filters: active
  });

  test.todo("update a reason code", async () => {
    // e.g. rename, add to more templates?
  });

  test.todo("deactivate a reason code", async () => {
    // Not sure if necessary.
  });

  test("delete a reason code", async () => {
    const codes = await execute(schema, ListReasonCodes2Document, {
      // FIXME: Should not be required:
      owner: CUSTOMER,
      // FIXME: This is not particularly ergonomic :/
      // Note that this is the entityinstanceuuid for the "Reason Code" systag:
      parent: ["f875b28c-ccc9-4c69-b5b4-9f10ad89d23b"],
    });

    const code = assertNonNull(
      codes.data?.instances?.edges
        ?.flatMap(e =>
          e.node?.name?.value === "Masheen Dawn" ? e.node.id : [],
        )
        .at(0),
    );

    const r0 = await execute(schema, DeleteReasonCodeDocument, {
      node: code,
    });
    expect(r0.errors).toBeFalsy();
    expect(r0.data?.deleteNode).toContain(code);

    const r1 = await execute(schema, ListReasonCodesDocument, {
      // FIXME: Should not be required:
      owner: CUSTOMER,
      // FIXME: This is not particularly ergonomic :/
      // Note that this is the entityinstanceuuid for the "Reason Code" systag:
      parent: ["f875b28c-ccc9-4c69-b5b4-9f10ad89d23b"],
    });
    expect(r1.errors).toBeFalsy();
    expect(r1.data?.instances?.totalCount).toBe(3); // -Masheen Dawn
  });

  test("create some reason codes (for Idle Time)", async () => {
    const t = assertNonNull(IDLE_TIME);
    const f = await getFieldByName(t, "Reason Code");

    let order = 0;
    for (const code of ["Lunch Break", "Nothin to do!"]) {
      const result = await execute(schema, CreateReasonCodeDocument, {
        field: f.id,
        name: code,
        // FIXME: This is not particularly ergonomic :/
        // Note that this is the entityinstanceuuid for the "Reason Code" systag:
        parent: "f875b28c-ccc9-4c69-b5b4-9f10ad89d23b",
        order: order++,
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchObject({
        createCustagAsFieldTemplateValueTypeConstraint: {
          node: {
            name: {
              value: code,
            },
          },
          asFieldTemplateValueType: {
            edges: [
              {
                node: {
                  id: expect.any(String),
                  name: {
                    value: "Reason Code",
                  },
                  parent: {
                    name: {
                      value: "Idle Time",
                    },
                  },
                },
              },
            ],
          },
        },
      });
    }
  });

  // FIXME: Deleting an entity instance does not propagate to the custag.
  test("in the app, get completions", async () => {
    // For both Downtime and Idle Time.
    const r0 = await execute(schema, GetReasonCodeCompletionsDocument, {
      task: assertNonNull(DOWN_TIME).id,
    });
    expect(r0.errors).toBeFalsy();
    expect(r0.data).toMatchSnapshot();

    const r1 = await execute(schema, GetReasonCodeCompletionsDocument, {
      task: assertNonNull(IDLE_TIME).id,
    });
    expect(r1.errors).toBeFalsy();
    expect(r1.data).toMatchSnapshot();
  });

  beforeAll(async () => {
    // Setup:
    const ctx = await createTestContext();
    // 1. Create the demo customer
    const logs = await setup(ctx);
    CUSTOMER = findAndEncode("customer", "organization", logs);
    const downTemplate = map(
      findAndEncode("next", "worktemplate", logs, { skip: 1 }),
      id => new Task({ id }),
    );
    assertTaskIsNamed(downTemplate, "Downtime", ctx);
    const idleTemplate = map(
      findAndEncode("next", "worktemplate", logs),
      id => new Task({ id }),
    );
    assertTaskIsNamed(idleTemplate, "Idle Time", ctx);

    await sql.begin(async sql => {
      await setCurrentIdentity(sql, ctx);
      // FIXME: use Keller's API for customer create through the entity model.
      await sql`call entity.import_entity(null)`;
      // Patch our templates to have 'Reason Code' fields:
      await downTemplate.addField(ctx, {
        name: "Reason Code",
        type: "string",
      });
      await idleTemplate.addField(ctx, {
        name: "Reason Code",
        type: "string",
      });
    });
  });

  afterAll(async () => {
    // Cleanup:
    // await cleanup(CUSTOMER);
    // 1. Delete reason codes
    // 2. Delete demo customer
    // 3. Call entity.import()?
  });
});
