import { sql } from "@/datasources/postgres";
import {
  Task,
  type ConstructorArgs as TaskConstructor,
} from "@/schema/system/component/task";
import type { Context } from "@/schema/types";
import { type Customer, createDefaultCustomer } from "@/test/prelude";
import { map } from "@/util";
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

export function formatDuration(ms: number): string {
  if (ms <= 0) return "";
  if (ms < 1000) return `${ms}ms`; // <1s
  if (ms < 60_000) return `${ms / 1000}s`; // <60s
  return `${Math.floor(ms / 60_000)}m ${formatDuration(ms % 60_000)}`.trim();
}
