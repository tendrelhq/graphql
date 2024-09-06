import { sql } from "@/datasources/postgres";
import type { PageInfo, UserResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";

export const User: UserResolvers = {
  async authenticationProvider(parent, _, ctx) {
    if (parent.authenticationProviderId) {
      return ctx.orm.tag.load(parent.authenticationProviderId as string);
    }
  },
  language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.languageId as string);
  },
  async organizations(parent, args, ctx) {
    const { first, last } = args;
    const parentId = decodeGlobalId(parent.id as string).id;
    const after = args.after ? decodeGlobalId(args.after).id : null;
    const before = args.before ? decodeGlobalId(args.before).id : null;

    // biome-ignore lint/complexity/noBannedTypes:
    const keys = await sql<WithKey<{}>[]>`
      SELECT customeruuid AS _key
      FROM public.workerinstance
      INNER JOIN public.customer
          ON workerinstancecustomerid = customerid
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
                          WHERE customeruuid = ${keys.at(-1)?._key ?? null}
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
                          WHERE customeruuid = ${keys.at(0)?._key ?? null}
                      )
                  ORDER BY workerinstancecustomerid ${last ? sql`DESC` : sql`ASC`}
              )
          ) AS "hasPreviousPage"
    `;

    const rows = await ctx.orm.organization.loadMany(keys.map(e => e._key));
    const startCursor = rows.at(0);
    const endCursor = rows.at(-1);

    if (startCursor instanceof Error) {
      throw startCursor;
    }
    if (endCursor instanceof Error) {
      throw endCursor;
    }

    return {
      edges: rows.map(row => {
        if (row instanceof Error) {
          throw row;
        }

        return {
          cursor: row.id as string,
          node: row,
        };
      }),
      pageInfo: {
        startCursor: startCursor?.id as string,
        endCursor: endCursor?.id as string,
        hasNextPage,
        hasPreviousPage,
      },
      totalCount: (
        await sql<[{ count: number }]>`
          SELECT count(*)
          FROM public.workerinstance
          WHERE workerinstanceworkerid = (
              SELECT workerid
              FROM public.worker
              WHERE workeruuid = ${parentId}
        );`
      )[0].count,
    };
  },
  tags() {
    return [];
  },
};
