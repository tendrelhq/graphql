import { sql } from "@/datasources/postgres";
import type { Organization, QueryResolvers } from "@/schema";

export const organizations: NonNullable<QueryResolvers['organizations']> =
  async (_, __, ctx) => {
    const u = await ctx.orm.user.byIdentityId.load(ctx.auth.userId);
    return await sql<Organization[]>`
        SELECT
            o.customeruuid AS id,
            (o.customerenddate IS NULL OR o.customerenddate > now()) AS active,
            o.customerstartdate AS activated_at,
            o.customerenddate AS deactivated_at,
            (
                SELECT o.customerexternalid
                FROM public.systag AS s
                WHERE
                    o.customerexternalsystemid IS NOT NULL
                    AND s.systagid = o.customerexternalsystemid
                    AND s.systagtype = 'Stripe'
            ) AS billing_id,
            n.languagemasteruuid AS name_id
        FROM public.customer AS o
        INNER JOIN public.workerinstance AS w
            ON
                o.customerid = w.workerinstancecustomerid
                AND w.workerinstanceworkerid = (
                    SELECT workerid
                    FROM public.worker
                    WHERE workeruuid = ${u.id}
                )
        INNER JOIN public.languagemaster AS n
            ON o.customernamelanguagemasterid = n.languagemasterid;
    `;
  };
