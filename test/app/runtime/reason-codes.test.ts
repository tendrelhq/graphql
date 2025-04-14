import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { setCurrentIdentity } from "@/auth";
import { type TxSql, sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId } from "@/schema/system";
import type { Field } from "@/schema/system/component";
import { Task } from "@/schema/system/component/task";
import {
  createTestContext,
  execute,
  findAndEncode,
  setup,
} from "@/test/prelude";
import { assert, map } from "@/util";
import {
  CreateReasonCodeDocument,
  GetReasonCodeCompletionsDocument,
  ListReasonCodesDocument,
} from "./reason-codes.test.generated";

// Not yet ready for primetime :(
// `entity.import_entity` depends on some datawarehouse bullshit and I simply
// refuse to pull in that dependency here.
describe.skipIf(!!process.env.CI)("runtime + reason codes", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: string;
  let DOWN_TIME: Task;
  let IDLE_TIME: Task;

  // FIXME: This does not list associated templates, which is necessary in the
  // console view.
  test("list reason codes", async () => {
    // Name, Category (template)
    const result = await execute(schema, ListReasonCodesDocument, {
      // FIXME: Should not be required:
      owner: decodeGlobalId(CUSTOMER).id,
      // FIXME: This is not particularly ergonomic :/
      // Note that this is the entityinstanceuuid for the "Reason Code" systag:
      parent: ["d9b10b97-73aa-4407-948a-29f8434d525e"],
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test.todo("list reason codes (with filters)", async () => {
    // Filters: active
  });

  // FIXME: Ditto above: does not list associated templates.
  test.todo("create a new reason code", async () => {
    // Name, Category (template)
    const result = await execute(schema, CreateReasonCodeDocument, {
      name: "Overwhelming Confusion",
      // FIXME: Should not be required:
      owner: decodeGlobalId(CUSTOMER).id,
      parent: "d9b10b97-73aa-4407-948a-29f8434d525e",
      templates: [DOWN_TIME.id],
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
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
      findAndEncode("next", "worktemplate", logs),
      id => new Task({ id }),
    );
    IDLE_TIME = map(
      findAndEncode("next", "worktemplate", logs, { skip: 1 }),
      id => new Task({ id }),
    );
    await sql.begin(async sql => {
      await setCurrentIdentity(sql, ctx);

      // 2. Import the new customer into the entity model
      // FIXME: use Keller's API for customer create through the entity model.
      await sql`call entity.import_entity(null)`;

      const DOWN_TIME_CODES = [
        "Machine Down",
        "Waiting for Materials",
        "Scheduled Maintenance",
      ];
      const IDLE_TIME_CODES = ["Lunch Break", "Nothin to do!"];
      for (const [t, codes] of [
        [DOWN_TIME, DOWN_TIME_CODES],
        [IDLE_TIME, IDLE_TIME_CODES],
      ] as const) {
        // 3. Patch our template to have a 'Reason Code' field
        const field = await t.addField(ctx, {
          name: "Reason Code",
          type: "String",
        });

        // 4. Create demo reason codes for Downtime
        let order = 0;
        for (const code of codes) {
          await addReasonCodeToTemplate(
            sql,
            decodeGlobalId(CUSTOMER).id,
            code,
            order++,
            t,
            field,
          );
        }
      }
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

async function addReasonCodeToTemplate(
  sql: TxSql,
  customer: string,
  code: string,
  order: number,
  template: Task,
  field: Field,
) {
  assert(template._type === "worktemplate");
  const { id: fieldId, type: fieldType } = decodeGlobalId(field.id);
  assert(fieldType === "workresult");

  // Grab the owner id.
  const [{ owner }] = await sql`
    select entityinstanceuuid as owner
    from entity.entityinstance
    where entityinstanceoriginaluuid = ${customer}
  `;
  // Create the custag and entity_instance first.
  const [{ create_custaguuid: custag_id }] = await sql<
    [{ create_custaguuid: string }]
  >`
    call entity.crud_custag_create(
      ${owner},
      'd9b10b97-73aa-4407-948a-29f8434d525e',
      null,
      ${order},
      ${code},
      null,
      null,
      null,
      null, 
      null, 
      null,
      null,
      null,
      337::bigint
    );
  `;
  // Then create the template constraint.
  await sql`
    insert into public.worktemplateconstraint (
      worktemplateconstraintcustomerid,
      worktemplateconstraintcustomeruuid,
      worktemplateconstrainttemplateid,
      worktemplateconstraintresultid,
      worktemplateconstraintconstrainedtypeid,
      worktemplateconstraintconstraintid,
      worktemplateconstraintmodifiedby
    )
    select
      customerid,
      customeruuid,
      worktemplate.id,
      workresult.id,
      systag.systaguuid,
      custag.custaguuid,
      895
    from
      public.customer,
      public.worktemplate,
      public.workresult,
      public.systag,
      public.custag
    where customeruuid = ${customer}
      and worktemplate.id = ${template._id}
      and workresult.id = ${fieldId}
      and systag.systagtype = 'Reason Code'
      and custag.custaguuid = ${custag_id}
  `;
}
