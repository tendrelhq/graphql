import { sql } from "@/datasources/postgres";
import type { PageInfo, UserResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";

export const User: UserResolvers = {
  async authenticationProvider(parent, _, ctx) {
    if (parent.authenticationProviderId) {
      return ctx.orm.tag.load(parent.authenticationProviderId);
    }
  },
  language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.languageId);
  },
  async organizations(parent, args, ctx) {
    const { first, last, withApp } = args;

    const parentId = decodeGlobalId(parent.id).id;
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
            withApp
              ? sql`
          AND EXISTS (
              SELECT 1
              FROM public.customerconfig
              INNER JOIN public.systag
                  ON customerconfigtypeuuid = systaguuid
              WHERE
                  customerconfigcustomeruuid = customeruuid
                  AND
                  systagtype IN ${sql(withApp)}
                  AND
                  customerconfigvalue = 'true'
                  AND
                  customerconfigenddate is null
          )`
              : sql``
          }
          ${
            after
              ? sql`
          AND workerinstancecustomerid > (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${after}
          )`
              : sql`AND true`
          }
          ${
            before
              ? sql`
          AND workerinstancecustomerid < (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${before}
          )`
              : sql`AND true`
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
          cursor: row.id,
          node: row,
        };
      }),
      pageInfo: {
        startCursor: startCursor?.id.toString(),
        endCursor: endCursor?.id.toString(),
        hasNextPage,
        hasPreviousPage,
      },
      totalCount: Number(
        (
          await sql<[{ count: bigint }]>`
            SELECT count(*)
            FROM public.workerinstance
            WHERE workerinstanceworkerid = (
                SELECT workerid
                FROM public.worker
                WHERE workeruuid = ${parentId}
            );
          `
        )[0].count,
      ),
    };
  },
  tags() {
    return [];
  },
};
