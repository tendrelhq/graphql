import { setCurrentIdentity } from "@/auth";
import { type TxSql, sql } from "@/datasources/postgres";
import {
  Task,
  type ConstructorArgs as TaskConstructor,
} from "@/schema/system/component/task";
import type { Context } from "@/schema/types";
import { Customer } from "@/test/prelude";
import { assertNonNull, map } from "@/util";
import type { Faker } from "@faker-js/faker";

export async function createCustomer(
  args: {
    faker: Faker;
    seed: number;
    /** @default 1 */
    multiplicity?: number;
  },
  ctx: Context,
): Promise<Customer> {
  return await sql.begin(async sql => {
    const customer = await createDefaultCustomer(args, ctx, sql);

    if (args.multiplicity) {
      for (let i = 0; i < args.multiplicity; i++) {
        await customer.addWorker(
          {
            identityId: args.faker.string.uuid(),
          },
          ctx,
          sql,
        );
        const location = await customer.addLocation(
          {
            name: args.faker.location.buildingNumber(),
            type: "Runtime Location",
          },
          ctx,
          sql,
        );

        const template = map(
          await sql<[TaskConstructor]>`
            select engine1.base64_encode(
              convert_to('worktemplate:' || id, 'utf8')
            ) as id
            from public.worktemplate
            inner join public.worktemplatetype
              on worktemplateid = worktemplatetypeworktemplateid
            inner join public.systag
              on worktemplatetypesystagid = systagid
              and systagtype = 'Runtime'
            where worktemplatecustomerid = (
              select customerid
              from public.customer
              where customeruuid = ${customer._id}
            )
          `,
          ([row]) => new Task(row),
        );
        await template.instantiate(
          {
            parent: location.id,
          },
          ctx,
          sql,
        );
      }
    }

    return customer;
  });
}

export async function createDefaultCustomer(
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
      create_modifiedby := 895 -- cheers! -rugg
    );
  `;

  const customerId = assertNonNull(
    rows.at(0)?.create_customeruuid,
    "customer create failed 😠",
  );

  return Customer.fromTypeId("organization", customerId);
}
