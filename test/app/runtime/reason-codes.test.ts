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
import { map } from "@/util";
import {
  CreateReasonCodeDocument,
  GetReasonCodeCompletionsDocument,
  ListReasonCodesDocument,
} from "./reason-codes.test.generated";

describe("runtime + reason codes", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: string;
  let DOWN_TIME: Task;
  let IDLE_TIME: Task;

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

  test("create some reason codes (for Downtime)", async () => {
    const f = await getFieldByName(DOWN_TIME, "Reason Code");

    let order = 0;
    for (const code of [
      "Machine Down",
      "Scheduled Maintenance",
      "Waiting for Materials",
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

  test.todo("delete a reason code", async () => {
    // Soft.
  });

  test("create some reason codes (for Idle Time)", async () => {
    const f = await getFieldByName(IDLE_TIME, "Reason Code");

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

  test("in the app, get completions", async () => {
    // For both Downtime and Idle Time.
    const r0 = await execute(schema, GetReasonCodeCompletionsDocument, {
      task: DOWN_TIME.id,
    });
    expect(r0.errors).toBeFalsy();
    expect(r0.data).toMatchSnapshot();

    const r1 = await execute(schema, GetReasonCodeCompletionsDocument, {
      task: IDLE_TIME.id,
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
    DOWN_TIME = map(
      findAndEncode("next", "worktemplate", logs, { skip: 1 }),
      id => new Task({ id }),
    );
    assertTaskIsNamed(DOWN_TIME, "Downtime", ctx);
    IDLE_TIME = map(
      findAndEncode("next", "worktemplate", logs),
      id => new Task({ id }),
    );
    assertTaskIsNamed(IDLE_TIME, "Idle Time", ctx);

    await sql.begin(async sql => {
      await setCurrentIdentity(sql, ctx);
      // FIXME: use Keller's API for customer create through the entity model.
      await sql`call entity.import_entity(null)`;
      // Patch our templates to have 'Reason Code' fields:
      await DOWN_TIME.addField(ctx, {
        name: "Reason Code",
        type: "String",
      });
      await IDLE_TIME.addField(ctx, {
        name: "Reason Code",
        type: "String",
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
