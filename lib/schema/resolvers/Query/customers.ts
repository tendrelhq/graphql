import { sql, user } from "@/datasources/postgres";
import type { Customer, QueryResolvers } from "@/schema";

export const customers: NonNullable<QueryResolvers["customers"]> = async (
  _,
  __,
  ctx,
) => {
  const u = await user.byIdentityId.load(ctx.auth.userId);

  return await sql<Customer[]>`
    SELECT
        c.customeruuid AS id,
        (c.customerenddate IS NULL OR c.customerenddate > now()) AS active,
        c.customernamelanguagemasterid AS name_id,
        l.systaguuid AS default_language_id
    FROM public.worker AS u
    INNER JOIN public.workerinstance AS w
        ON w.workerinstanceworkerid = u.workerid
    INNER JOIN public.customer AS c
        ON w.workerinstancecustomerid = c.customerid
    INNER JOIN public.systag AS l
        ON c.customerlanguagetypeid = l.systagid
    WHERE u.workeruuid = ${u.id};
  `;
};
