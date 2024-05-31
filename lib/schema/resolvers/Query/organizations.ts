import { sql, user } from "@/datasources/postgres";
import type { Organization, QueryResolvers } from "@/schema";

export const organizations: NonNullable<QueryResolvers["organizations"]> =
  async (_, __, ctx) => {
    const u = await user.byIdentityId.load(ctx.auth.userId);
    return await sql<Organization[]>`
        SELECT
            c.customeruuid AS id,
            (c.customerenddate IS NULL OR c.customerenddate > now()) AS active,
            c.customerstartdate AS activated_at,
            c.customerenddate AS deactivated_at,
            c.customerexternalid AS billing_id,
            n.languagemasteruuid AS name_id
        FROM public.worker AS u
        INNER JOIN public.workerinstance AS w
            ON w.workerinstanceworkerid = u.workerid
        INNER JOIN public.customer AS c
            ON w.workerinstancecustomerid = c.customerid
        INNER JOIN public.languagemaster AS n
            ON c.customernamelanguagemasterid = n.languagemasterid
        WHERE u.workeruuid = ${u.id};
    `;
  };
