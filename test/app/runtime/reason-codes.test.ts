import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { Task } from "@/schema/system/component/task";
import {
  type Customer,
  createTestContext,
  execute,
  getFieldByName,
} from "@/test/prelude";
import { assert, assertNonNull, map, mapOrElse } from "@/util";
import { Faker, base, en } from "@faker-js/faker";
import type { Maybe } from "graphql/jsutils/Maybe";
import { createCustomer } from "./prelude/canonical";
import {
  CreateReasonCodeDocument,
  DeleteReasonCodeDocument,
  GetReasonCodeCompletionsDocument,
  ListReasonCodes2Document,
  ListReasonCodesDocument,
  ListTemplatesDocument,
} from "./reason-codes.test.generated";

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

describe("runtime + reason codes", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: Customer;

  test("only the initial reason codes", async () => {
    const result = await execute(ctx, schema, ListReasonCodesDocument, {
      // FIXME: Should not be required:
      owner: CUSTOMER.id,
      // FIXME: This is not particularly ergonomic :/
      // Note that this is the entityinstanceuuid for the "Reason Code" systag:
      parent: ["f875b28c-ccc9-4c69-b5b4-9f10ad89d23b"],
    });
    expect(result.errors).toBeFalsy();
    expect(result.data?.instances?.totalCount).toBe(4);
  }, 10_000);

  let DOWN_TIME: Maybe<Task>;
  let IDLE_TIME: Maybe<Task>;
  test("grab the Downtime and Idle Time templates", async () => {
    const result = await execute(ctx, schema, ListTemplatesDocument, {
      owner: CUSTOMER.id,
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
      const result = await execute(ctx, schema, CreateReasonCodeDocument, {
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

    const result = await execute(ctx, schema, ListReasonCodesDocument, {
      // FIXME: Should not be required:
      owner: CUSTOMER.id,
      // FIXME: This is not particularly ergonomic :/
      // Note that this is the entityinstanceuuid for the "Reason Code" systag:
      parent: ["f875b28c-ccc9-4c69-b5b4-9f10ad89d23b"],
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  }, 10_000);

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
    const codes = await execute(ctx, schema, ListReasonCodes2Document, {
      // FIXME: Should not be required:
      owner: CUSTOMER.id,
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

    const r0 = await execute(ctx, schema, DeleteReasonCodeDocument, {
      node: code,
    });
    expect(r0.errors).toBeFalsy();
    expect(r0.data?.deleteNode).toContain(code);

    const r1 = await execute(ctx, schema, ListReasonCodesDocument, {
      // FIXME: Should not be required:
      owner: CUSTOMER.id,
      // FIXME: This is not particularly ergonomic :/
      // Note that this is the entityinstanceuuid for the "Reason Code" systag:
      parent: ["f875b28c-ccc9-4c69-b5b4-9f10ad89d23b"],
    });
    expect(r1.errors).toBeFalsy();
    expect(r1.data?.instances?.totalCount).toBe(7); // -Masheen Dawn
  }, 10_000);

  test("create some reason codes (for Idle Time)", async () => {
    const t = assertNonNull(IDLE_TIME);
    const f = await getFieldByName(t, "Reason Code");

    let order = 0;
    for (const code of ["Lunch Break", "Nothin to do!"]) {
      const result = await execute(ctx, schema, CreateReasonCodeDocument, {
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
    const r0 = await execute(ctx, schema, GetReasonCodeCompletionsDocument, {
      task: assertNonNull(DOWN_TIME).id,
    });
    expect(r0.errors).toBeFalsy();
    expect(r0.data).toMatchSnapshot();

    const r1 = await execute(ctx, schema, GetReasonCodeCompletionsDocument, {
      task: assertNonNull(IDLE_TIME).id,
    });
    expect(r1.errors).toBeFalsy();
    expect(r1.data).toMatchSnapshot();
  });

  beforeAll(async () => {
    await sql.begin(async sql => {
      CUSTOMER = await createCustomer({ faker, seed }, ctx, sql);
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
