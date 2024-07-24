import { sql } from "@/datasources/postgres";
import type {
  EnabledLanguage,
  Location,
  OrganizationResolvers,
  PageInfo,
} from "@/schema";

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
  async locations(parent, args, ctx) {
    const { first, last, after, before } = args;

    const rows = await sql<Location[]>`
      SELECT
          l.locationuuid AS id,
          (l.locationenddate IS null OR l.locationenddate > now()) AS active,
          l.locationstartdate::text AS activated_at,
          l.locationenddate::text AS deactivated_at,
          n.languagemasteruuid AS name_id,
          p.locationuuid AS parent_id,
          l.locationscanid AS scan_code,
          s.locationuuid AS site_id
      FROM public.location AS l
      INNER JOIN public.languagemaster AS n
          ON l.locationnameid = n.languagemasterid
      INNER JOIN public.location AS s
          ON l.locationsiteid = s.locationid
      LEFT JOIN public.location AS p
          ON l.locationparentid = p.locationid
      WHERE
          l.locationcustomerid = (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${parent.id}
          )
          ${
            after
              ? sql`
          AND l.locationid > (
              SELECT locationid
              FROM public.location
              WHERE locationuuid = ${after}
          )
              `
              : sql``
          }
          ${
            before
              ? sql`
          AND l.locationid < (
              SELECT locationid
              FROM public.location
              WHERE locationuuid = ${before}
          )
              `
              : sql``
          }
      ORDER BY l.locationid ASC
      LIMIT ${first ?? last ?? null};
    `;

    const startCursor = rows.at(0)?.id;
    const endCursor = rows.at(rows.length - 1)?.id;

    const [{ hasNextPage, hasPrevPage }] = await sql<
      [Pick<PageInfo, "hasNextPage" | "hasPrevPage">]
    >`
      SELECT
          (
              EXISTS (
                  SELECT 1
                  FROM public.location
                  WHERE
                      locationcustomerid = (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${parent.id}
                      )
                      AND locationid > (
                          SELECT locationid
                          FROM public.location
                          WHERE locationuuid = ${endCursor ?? null}
                      )
                  ORDER BY locationid ASC

              )
          ) AS "hasNextPage",
          (
              EXISTS (
                  SELECT 1
                  FROM public.location
                  WHERE
                      locationcustomerid = (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${parent.id}
                      )
                      AND locationid < (
                          SELECT locationid
                          FROM public.location
                          WHERE locationuuid = ${startCursor ?? null}
                      )
                  ORDER BY locationid ASC

              )
          ) AS "hasPrevPage"
    `;

    return {
      edges: rows.map(row => ({ location: row })),
      pageInfo: {
        startCursor: startCursor as string,
        endCursor: endCursor as string,
        hasNextPage,
        hasPrevPage,
      },
    };
  },
};
