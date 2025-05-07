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

  const customerName = args.seed.toString();
  const admin = {
    firstName: args.faker.person.firstName(),
    lastName: args.faker.person.lastName(),
    provider: customerName,
  };
  const adminIdentity = args.faker.string.uuid();

  // The procedure below logs so much shit.
  await sql`set local client_min_messages to warning`;
  const rows = await sql`
    call public.crud_customer_create(
      create_customername := ${customerName},
      create_sitename := ${customerName},
      create_customeruuid := null,
      create_customerbillingid := ${args.faker.string.uuid()},
      create_customerbillingsystemid := '0033c894-fb1b-4994-be36-4792090f260b',
      -- create_customerbillingsystemid := (
      --     select systaguuid
      --     from public.systag
      --     where systagparentid = 959 and systagtype = 'Test'
      -- ),
      create_adminfirstname := ${admin.firstName},
      create_adminlastname := ${admin.lastName},
      create_adminemailaddress := ${args.faker.internet.email(admin)},
      create_adminphonenumber := '',
      create_adminidentityid := ${adminIdentity},
      create_adminidentitysystemuuid := '829824cd-a7d4-4e9e-b75d-eab099812d8d',
      -- create_adminidentitysystemuuid := (
      --     select systaguuid
      --     from public.systag
      --     where systagparentid = 914 and systagtype = 'Tendrel'
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

  ctx.auth.userId = adminIdentity;

  const customerId = assertNonNull(rows.at(0)?.create_customeruuid);
  return Customer.fromTypeId("organization", customerId);
}
