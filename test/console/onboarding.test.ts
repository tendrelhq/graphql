import { afterAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { encodeGlobalId } from "@/schema/system";
import { cleanup } from "../prelude";

describe("onboarding", () => {
  let CUSTOMER: string;
  let SITE: string;

  test("customer create", async () => {
    const [result] = await sql`
      call public.crud_customer_create(
        create_customername := 'Fake Tendy Factory',
        create_sitename := 'Fake Tendy Factory',
        create_customeruuid := null,
        create_customerbillingid := ${Date.now().toString()},
        create_customerbillingsystemid := '0033c894-fb1b-4994-be36-4792090f260b',
        -- create_customerbillingsystemid := (
        --     select systaguuid
        --     from public.systag
        --     where systagparentid = 959 and systagtype = 'Test'
        -- ),
        create_adminfirstname := 'Jerry',
        create_adminlastname := 'Garcia',
        create_adminemailaddress := ${`${Date.now()}@tendrel.io`},
        create_adminphonenumber := '',
        create_adminidentityid := ${Date.now().toString()},
        create_adminidentitysystemuuid := '829824cd-a7d4-4e9e-b75d-eab099812d8d',
        -- create_adminidentitysystemuuid := (
        --     select systaguuid
        --     from public.systag
        --     where systagparentid = 914 and systagtype = 'Tendrel'
        -- ),
        create_adminuuid := null,
        create_siteuuid := null,
        create_timezone := 'America/Denver',
        create_languagetypeuuids := array['7ebd10ee-5018-4e11-9525-80ab5c6aebee','c3f18dd6-bfc5-4ba5-b3c1-bb09e2a749a9'],
        -- create_languagetypeuuids := (
        --     select array_agg(systaguuid)
        --     from public.systag
        --     where systagparentid = 2 and systagtype in ('en', 'es')
        -- ),
        create_modifiedby := 895
      );
    `;
    expect(result.create_customeruuid).toEqual(expect.any(String));
    expect(result.create_siteuuid).toEqual(expect.any(String));

    CUSTOMER = result.create_customeruuid;
    SITE = result.create_siteuuid;
  });

  test("enable checklist", async () => {
    await sql`
      call public.crud_checklist_create_customer(
        create_customeruuid := ${CUSTOMER},
        create_siteuuid := ${SITE},
        create_adminuuid := null,
        create_timezone := 'America/Denver',
        create_modifiedby := 895
      );
    `;
  });

  test("enable pinpoint", async () => {
    await sql`
      call public.crud_rtls_create_customer(
        create_customeruuid := ${CUSTOMER},
        create_siteuuid := ${SITE},
        create_timezone := 'America/Denver',
        create_modifiedby := 895
      );
    `;
  });

  test("enable runtime", async () => {
    const rows = await sql`
      select *
      from public.enable_runtime(
        customer_id := ${CUSTOMER},
        site_uuid := ${SITE},
        language_type := 'en',
        timezone := 'America/Denver',
        modified_by := 895
      );
    `;
    expect(rows.length).toBeGreaterThan(0);
  });

  test("enable timesheet", async () => {
    await sql`
      call public.crud_timesheet_create_customer_v2(
        create_customeruuid := ${CUSTOMER},
        create_siteuuid := ${SITE},
        create_adminuuid := null,
        create_timezone := 'America/Denver',
        create_modifiedby := 895
      );
    `;
  });

  afterAll(async () => {
    if (CUSTOMER) {
      await cleanup(encodeGlobalId({ type: "organization", id: CUSTOMER }));
    } else {
      console.warn("Nothing to clean up?");
    }
  });
});
