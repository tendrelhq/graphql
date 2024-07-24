import { sql } from "@/datasources/postgres";
import type { Organization, PageInfo, UserResolvers } from "@/schema";

export const User: UserResolvers = {
  async authentication_provider(parent, _, ctx) {
    if (!parent.authentication_provider_id) return null;
    return ctx.orm.tag.load(parent.authentication_provider_id as string);
  },
  language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.language_id as string);
  },
  async organizations(parent, args, _) {
    const { first, last, after, before } = args;

    const rows = await sql<Organization[]>`
      SELECT
          customeruuid AS id,
          (customerenddate IS null OR customerenddate > now()) AS active,
          customerstartdate::text AS activated_at,
          customerenddate::text AS deactivated_at,
          customerexternalid AS billing_id,
          languagemasteruuid AS name_id
      FROM public.workerinstance
      INNER JOIN public.customer
          ON workerinstancecustomerid = customerid
      INNER JOIN public.languagemaster
          ON customernamelanguagemasterid = languagemasterid
      WHERE
          workerinstanceworkerid = (
              SELECT workerid
              FROM public.worker
              WHERE workeruuid = ${parent.id}
          )
          ${
            after
              ? sql`
          AND workerinstancecustomerid > (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${after}
          )
              `
              : sql``
          }
          ${
            before
              ? sql`
          AND workerinstancecustomerid < (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${before}
          )
              `
              : sql``
          }
      ORDER BY workerinstancecustomerid ASC
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
                  FROM public.workerinstance
                  WHERE
                      workerinstanceworkerid = (
                          SELECT workerid
                          FROM public.worker
                          WHERE workeruuid = ${parent.id}
                      )
                      AND workerinstancecustomerid > (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${endCursor ?? null}
                      )
                  ORDER BY workerinstancecustomerid ASC
              )
          ) AS "hasNextPage",
          (
              EXISTS (
                  SELECT 1
                  FROM public.workerinstance
                  WHERE
                      workerinstanceworkerid = (
                          SELECT workerid
                          FROM public.worker
                          WHERE workeruuid = ${parent.id}
                      )
                      AND workerinstancecustomerid < (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${startCursor ?? null}
                      )
                  ORDER BY workerinstancecustomerid ASC
              )
          ) AS "hasPrevPage"
    `;

    return {
      edges: rows.map(row => ({ organization: row })),
      pageInfo: {
        startCursor: startCursor as string,
        endCursor: endCursor as string,
        hasNextPage,
        hasPrevPage,
      },
    };
  },
  tags() {
    return [];
  },
};
