import { sql } from "@/datasources/postgres";
import type { EnabledLanguage, OrganizationResolvers } from "@/schema";

export const Organization: OrganizationResolvers = {
  async name(parent, _, ctx) {
    const u = await ctx.orm.user.byIdentityId.load(ctx.auth.userId);
    return ctx.orm.name.load({
      id: parent.name_id as string,
      language_id: u.language_id as string,
    });
  },
  async languages(parent, _, ctx) {
    return await sql<EnabledLanguage[]>`
        SELECT
            l.customerrequestedlanguageuuid AS id,
            (
                l.customerrequestedlanguageenddate IS NULL
                OR
                l.customerrequestedlanguageenddate > NOW()
            ) AS active,
            l.customerrequestedlanguagestartdate::text AS activated_at,
            l.customerrequestedlanguageenddate::text AS deactivated_at,
            s.systaguuid AS language_id,
            (l.customerrequestedlanguagelanguageid = o.customerlanguagetypeid) AS primary
        FROM public.customerrequestedlanguage AS l
        INNER JOIN public.customer AS o
            ON l.customerrequestedlanguagecustomerid = o.customerid
        INNER JOIN public.systag AS s
            ON l.customerrequestedlanguagelanguageid = s.systagid
        WHERE o.customeruuid = ${parent.id};
    `;
  },
};
