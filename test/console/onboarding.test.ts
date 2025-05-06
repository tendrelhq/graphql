import { afterAll, describe, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { assert, mapOrElse } from "@/util";
import { Faker, en } from "@faker-js/faker";

const seed = mapOrElse(
  process.env.SEED,
  seed => {
    const s = Number.parseInt(seed);
    assert(Number.isFinite(s), "invalid seed");
    return s;
  },
  Date.now(),
);
const faker = new Faker({ locale: [en], seed });

const customerName = seed.toString();
describe("onboarding", () => {
  test("customer create", async () => {
    await sql.begin(async sql => {
      // The procedure below logs so much shit.
      await sql`set local client_min_messages to warning`;

      const admin = {
        firstName: faker.person.firstName(),
        lastName: faker.person.lastName(),
      };
      const rows = await sql`
        call public.crud_customer_create(
          create_customername := ${customerName},
          create_sitename := ${customerName},
          create_customeruuid := null,
          create_customerbillingid := ${Date.now().toString()},
          create_customerbillingsystemid := '0033c894-fb1b-4994-be36-4792090f260b',
          -- create_customerbillingsystemid := (
          --     select systaguuid
          --     from public.systag
          --     where systagparentid = 959 and systagtype = 'Test'
          -- ),
          create_adminfirstname := ${admin.firstName},
          create_adminlastname := ${admin.lastName},
          create_adminemailaddress := ${faker.internet.exampleEmail(admin)},
          create_adminphonenumber := '',
          create_adminidentityid := ${faker.string.uuid()},
          create_adminidentitysystemuuid := '829824cd-a7d4-4e9e-b75d-eab099812d8d',
          -- create_adminidentitysystemuuid := (
          --     select systaguuid
          --     from public.systag
          --     where systagparentid = 914 and systagtype = 'Tendrel'
          -- ),
          create_adminuuid := null,
          create_siteuuid := null,
          create_timezone := ${faker.location.timeZone()},
          create_languagetypeuuids := array['7ebd10ee-5018-4e11-9525-80ab5c6aebee','c3f18dd6-bfc5-4ba5-b3c1-bb09e2a749a9'],
          -- create_languagetypeuuids := (
          --     select array_agg(systaguuid)
          --     from public.systag
          --     where systagparentid = 2 and systagtype in ('en', 'es')
          -- ),
          create_modifiedby := 895
        );
      `;
      assert(rows.at(0)?.create_customeruuid);
      console.log(rows.at(0)?.create_customeruuid);
    });
  });

  afterAll(() => {
    console.log(`
To reproduce this test:

  SEED=${seed} bun test onboarding.test --bail
    `);
  });
});
