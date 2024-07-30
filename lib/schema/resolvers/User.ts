import { sql } from "@/datasources/postgres";
import type { Organization, PageInfo, UserResolvers } from "@/schema";
import { type WithKey, decodeGlobalId } from "@/util";

export const User: UserResolvers = {
  async authenticationProvider(parent, _, ctx) {
    if (!parent.authenticationProviderId) return null;
    return ctx.orm.tag.load(parent.authenticationProviderId as string);
  },
  language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.languageId as string);
  },
  async organizations(parent, args, _) {
    const { first, last } = args;
    const parentId = decodeGlobalId(parent.id as string).id;
    const after = args.after ? decodeGlobalId(args.after).id : null;
    const before = args.before ? decodeGlobalId(args.before).id : null;

    const rows = await sql<WithKey<Organization>[]>`
      SELECT
          customeruuid AS _key,
          encode(('organization:' || customeruuid)::bytea, 'base64') AS id,
          (customerenddate IS null OR customerenddate > now()) AS active,
          customerstartdate::text AS "activatedAt",
          customerenddate::text AS "deactivatedAt",
          customerexternalid AS "billingId",
          languagemasteruuid AS "nameId"
      FROM public.workerinstance
      INNER JOIN public.customer
          ON workerinstancecustomerid = customerid
      INNER JOIN public.languagemaster
          ON customernamelanguagemasterid = languagemasterid
      WHERE
          workerinstanceworkerid = (
              SELECT workerid
              FROM public.worker
              WHERE workeruuid = ${parentId}
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
      ORDER BY workerinstancecustomerid ${last ? sql`DESC` : sql`ASC`}
      LIMIT ${first ?? last ?? null};
    `;

    const startCursor = rows.at(0);
    const endCursor = rows.at(rows.length - 1);

    const [{ hasNextPage, hasPreviousPage }] = await sql<
      [Pick<PageInfo, "hasNextPage" | "hasPreviousPage">]
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
                          WHERE workeruuid = ${parentId}
                      )
                      AND workerinstancecustomerid > (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${endCursor?._key ?? null}
                      )
                  ORDER BY workerinstancecustomerid ${last ? sql`DESC` : sql`ASC`}
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
                          WHERE workeruuid = ${parentId}
                      )
                      AND workerinstancecustomerid < (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${startCursor?._key ?? null}
                      )
                  ORDER BY workerinstancecustomerid ${last ? sql`DESC` : sql`ASC`}
              )
          ) AS "hasPreviousPage"
    `;

    return {
      edges: rows.map(row => ({ node: row })),
      pageInfo: {
        startCursor: startCursor?.id as string,
        endCursor: endCursor?.id as string,
        hasNextPage,
        hasPreviousPage,
      },
    };
  },
  tags() {
    return [];
  },
};
