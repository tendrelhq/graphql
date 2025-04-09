import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { setCurrentIdentity } from "@/auth";
import { type TxSql, sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId } from "@/schema/system";
import type { Field } from "@/schema/system/component";
import { Task } from "@/schema/system/component/task";
import {
  cleanup,
  createTestContext,
  execute,
  findAndEncode,
  getFieldByName,
  setup,
  testGlobalId,
} from "@/test/prelude";
import { assert, assertUnderlyingType, map } from "@/util";
import {
  CreateReasonCodeDocument,
  GetReasonCodeCompletionsDocument,
  ListReasonCodesDocument,
} from "./reason-codes.test.generated";

describe("runtime + reason codes", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: string;
  let TEMPLATE: Task; // instance

  describe.skip("console flows", () => {
    test.todo("list reason codes", async () => {
      // Name, Category (template)
      const result = await execute(schema, ListReasonCodesDocument);
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test.todo("list reason codes (with filters)", async () => {
      // Filters: active
    });

    test.todo("create a new reason code", async () => {
      // Name, Category (template)
      const result = await execute(schema, CreateReasonCodeDocument, {
        owner: "",
        name: "",
        templates: [],
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
  });

  describe("mobile flows", () => {
    test("completions", async () => {
      // For both Downtime and Idle Time.
      const result = await execute(schema, GetReasonCodeCompletionsDocument, {
        task: TEMPLATE.id,
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });
  });

  beforeAll(async () => {
    // Setup:
    const ctx = await createTestContext();
    // 1. Create the demo customer
    const logs = await setup(ctx);
    CUSTOMER = findAndEncode("customer", "organization", logs);
    TEMPLATE = map(
      findAndEncode("next", "worktemplate", logs),
      id => new Task({ id }),
    );
    // 2. Patch our template to have a 'Reason Code' field.
    const field = await TEMPLATE.addField(ctx, {
      name: "Reason Code",
      type: "String",
    });
    await sql.begin(async sql => {
      await setCurrentIdentity(sql, ctx);
      // 3. Call entity.import()
      await sql`call entity.import_entity(null)`;
      // 4. Create demo reason codes for downtime + idle time
      let order = 0;
      for (const code of [
        "Machine Down",
        "Waiting for Materials",
        "Scheduled Maintenance",
      ]) {
        await addReasonCodeToTemplate(
          sql,
          decodeGlobalId(CUSTOMER).id,
          code,
          order++,
          TEMPLATE,
          field,
        );
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
      'a1b8da7a-768f-4046-83d7-739d11e32b67',
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
  const r = await sql`
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
  console.log(`r.count: ${r.count}`);
}
