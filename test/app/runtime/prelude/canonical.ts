import { setCurrentIdentity } from "@/auth";
import { type TxSql, sql } from "@/datasources/postgres";
import type { Context } from "@/schema";
import { Customer } from "@/test/prelude";
import { assertNonNull } from "@/util";
import type { Faker } from "@faker-js/faker";

export async function createCustomer(
  args: {
    faker: Faker;
    seed: number;
  },
  ctx: Context,
  sql: TxSql,
): Promise<Customer> {
  await setCurrentIdentity(sql, ctx);

  // The procedure below logs so much shit.
  await sql`set local client_min_messages to warning`;
  const rows = await sql`
    call public.crud_customer_create(
      create_customername := ${args.seed.toString()},
      create_sitename := '',
      create_customeruuid := null,
      create_customerbillingid := ${args.faker.string.uuid()},
      create_customerbillingsystemid := '0033c894-fb1b-4994-be36-4792090f260b',
      -- create_customerbillingsystemid := (
      --     select systaguuid
      --     from public.systag
      --     where systagparentid = 959 and systagtype = 'Test'
      -- ),
      create_adminfirstname := '',
      create_adminlastname := '',
      create_adminemailaddress := '',
      create_adminphonenumber := '',
      create_adminidentityid := ${ctx.auth.userId},
      create_adminidentitysystemuuid := '0c1e3a50-ed4c-4469-95bd-e091104ae9d5',
      -- create_adminidentitysystemuuid := (
      --     select systaguuid
      --     from public.systag
      --     where systagparentid = 914 and systagtype = 'Clerk'
      -- ),
      create_adminuuid := null,
      create_siteuuid := null,
      create_timezone := ${args.faker.location.timeZone()},
      create_languagetypeuuids := array['7ebd10ee-5018-4e11-9525-80ab5c6aebee','c3f18dd6-bfc5-4ba5-b3c1-bb09e2a749a9'],
      -- create_languagetypeuuids := (
      --     select array_agg(systaguuid)
      --     from public.systag
      --     where systagparentid = 2 and systagtype in ('en', 'es')
      -- ),
      create_modifiedby := 895
    );
  `;

  const customerId = assertNonNull(rows.at(0)?.create_customeruuid);
  return Customer.fromTypeId("organization", customerId);
}
