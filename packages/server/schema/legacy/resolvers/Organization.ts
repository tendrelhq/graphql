import { sql } from "@/datasources/postgres";
import type { OrganizationResolvers, PageInfo } from "@/schema";
import { Location } from "@/schema/platform/archetype/location";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import type { ID } from "grats";
import { match } from "ts-pattern";

export const Organization: OrganizationResolvers = {
  async me(parent, _, ctx) {
    const [row] = await sql<[{ id: string }]>`
      SELECT workerinstanceuuid AS id
      FROM public.workerinstance
      WHERE
          workerinstancecustomerid = (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${decodeGlobalId(parent.id).id}
          )
          AND workerinstanceworkerid = (
              SELECT workerid
              FROM public.worker
              WHERE workeridentityid = ${ctx.auth.userId}
          );
    `;
    return ctx.orm.worker.load(row.id);
  },
  async name(parent, _, ctx) {
    return ctx.orm.name.load(decodeGlobalId(parent.nameId).id);
  },
  async languages(root, args, ctx) {
    const { first, last } = args;
    const parentId = decodeGlobalId(root.id).id;
    const after = args.after ? decodeGlobalId(args.after).id : null;
    const before = args.before ? decodeGlobalId(args.before).id : null;

    // biome-ignore lint/complexity/noBannedTypes:
    const keys = await sql<WithKey<{}>[]>`
      WITH cursor AS (
          SELECT
              systagorder,
              customerrequestedlanguageid
          FROM public.customerrequestedlanguage
          INNER JOIN public.systag
              ON customerrequestedlanguagelanguageid = systagid
          WHERE customerrequestedlanguageuuid = ${after ?? before}
      )

      SELECT customerrequestedlanguageuuid AS _key
      FROM public.customerrequestedlanguage
      INNER JOIN public.customer
          ON customerrequestedlanguagecustomerid = customerid
      INNER JOIN public.systag
          ON customerrequestedlanguagelanguageid = systagid
      WHERE
          customeruuid = ${parentId}
          AND ${after ? sql`(systagorder, customerrequestedlanguageid) > (SELECT * FROM cursor)` : sql`TRUE`}
          AND ${before ? sql`(systagorder, customerrequestedlanguageid) < (SELECT * FROM cursor)` : sql`TRUE`}
          AND ${match(args.search?.primary)
            .with(
              true,
              () =>
                sql`customerrequestedlanguagelanguageid = customerlanguagetypeid`,
            )
            .with(
              false,
              () =>
                sql`customerrequestedlanguagelanguageid != customerlanguagetypeid`,
            )
            .otherwise(() => sql`TRUE`)}
          AND ${match(args.search?.active)
            .with(
              true,
              () =>
                sql`(customerrequestedlanguageenddate IS null OR customerrequestedlanguageenddate > now())`,
            )
            .with(
              false,
              () =>
                sql`(customerrequestedlanguageenddate IS NOT null AND customerrequestedlanguageenddate < now())`,
            )
            .otherwise(() => sql`TRUE`)}
      ORDER BY
          systagorder ${last ? sql`DESC` : sql`ASC`},
          customerrequestedlanguageid ${last ? sql`DESC` : sql`ASC`}
      LIMIT ${first ?? last ?? null};
    `;

    const [{ hasNextPage, hasPreviousPage }] = await sql<
      [Pick<PageInfo, "hasNextPage" | "hasPreviousPage">]
    >`
      SELECT
          (
              EXISTS (
                  WITH cursor AS (
                      SELECT
                          systagorder,
                          customerrequestedlanguageid
                      FROM public.customerrequestedlanguage
                      INNER JOIN public.systag
                          ON customerrequestedlanguagelanguageid = systagid
                      WHERE customerrequestedlanguageuuid = ${keys.at(-1)?._key ?? null}
                  )

                  SELECT 1
                  FROM public.customerrequestedlanguage
                  INNER JOIN public.customer
                      ON customerrequestedlanguagecustomerid = customerid
                  INNER JOIN public.systag
                      ON customerrequestedlanguagelanguageid = systagid
                  WHERE
                      customeruuid = ${parentId}
                      AND (systagorder, customerrequestedlanguageid) > (SELECT * FROM cursor)
                      AND ${match(args.search?.primary)
                        .with(
                          true,
                          () =>
                            sql`customerrequestedlanguagelanguageid = customerlanguagetypeid`,
                        )
                        .with(
                          false,
                          () =>
                            sql`customerrequestedlanguagelanguageid != customerlanguagetypeid`,
                        )
                        .otherwise(() => sql`TRUE`)}
                      AND ${match(args.search?.active)
                        .with(
                          true,
                          () =>
                            sql`(customerrequestedlanguageenddate IS null OR customerrequestedlanguageenddate > now())`,
                        )
                        .with(
                          false,
                          () =>
                            sql`(customerrequestedlanguageenddate IS NOT null AND customerrequestedlanguageenddate < now())`,
                        )
                        .otherwise(() => sql`TRUE`)}
                  ORDER BY
                      systagorder ${last ? sql`DESC` : sql`ASC`},
                      customerrequestedlanguageid ${last ? sql`DESC` : sql`ASC`}

              )
          ) AS "hasNextPage",
          (
              EXISTS (
                  WITH cursor AS (
                      SELECT
                          systagorder,
                          customerrequestedlanguageid
                      FROM public.customerrequestedlanguage
                      INNER JOIN public.systag
                          ON customerrequestedlanguagelanguageid = systagid
                      WHERE customerrequestedlanguageuuid = ${keys.at(0)?._key ?? null}
                  )

                  SELECT 1
                  FROM public.customerrequestedlanguage
                  INNER JOIN public.customer
                      ON customerrequestedlanguagecustomerid = customerid
                  INNER JOIN public.systag
                      ON customerrequestedlanguagelanguageid = systagid
                  WHERE
                      customeruuid = ${parentId}
                      AND (systagorder, customerrequestedlanguageid) < (SELECT * FROM cursor)
                      AND ${match(args.search?.primary)
                        .with(
                          true,
                          () =>
                            sql`customerrequestedlanguagelanguageid = customerlanguagetypeid`,
                        )
                        .with(
                          false,
                          () =>
                            sql`customerrequestedlanguagelanguageid != customerlanguagetypeid`,
                        )
                        .otherwise(() => sql`TRUE`)}
                      AND ${match(args.search?.active)
                        .with(
                          true,
                          () =>
                            sql`(customerrequestedlanguageenddate IS null OR customerrequestedlanguageenddate > now())`,
                        )
                        .with(
                          false,
                          () =>
                            sql`(customerrequestedlanguageenddate IS NOT null AND customerrequestedlanguageenddate < now())`,
                        )
                        .otherwise(() => sql`TRUE`)}
                  ORDER BY
                      systagorder ${last ? sql`DESC` : sql`ASC`},
                      customerrequestedlanguageid ${last ? sql`DESC` : sql`ASC`}

              )
          ) AS "hasPreviousPage"
    `;

    const rows = await ctx.orm.crl.loadMany(keys.map(e => e._key));
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
          cursor: row.id.toString(),
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
          FROM public.customerrequestedlanguage
          WHERE customerrequestedlanguagecustomerid = (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${parentId}
        );`
        )[0].count,
      ),
    };
  },
  async locations(root, args, ctx) {
    const { first, last } = args;
    const parentId = decodeGlobalId(root.id).id;
    const after = args.after ? decodeGlobalId(args.after).id : null;
    const before = args.before ? decodeGlobalId(args.before).id : null;

    const rows = await sql<WithKey<{ id: ID }>[]>`
      SELECT
          locationuuid AS _key,
          encode(('location:' || locationuuid)::bytea, 'base64') as id
      FROM public.location
      WHERE
          locationcustomerid = (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${parentId}
          )
          ${
            after
              ? sql`
          AND locationid > (
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
          AND locationid < (
              SELECT locationid
              FROM public.location
              WHERE locationuuid = ${before}
          )
              `
              : sql``
          }
          AND ${match(args.search?.active)
            .with(
              true,
              () => sql`(locationenddate IS null OR locationenddate > now())`,
            )
            .with(
              false,
              () =>
                sql`(locationenddate IS NOT null AND locationenddate < now())`,
            )
            .otherwise(() => sql`TRUE`)}
          AND ${match(args.search?.isSite)
            .with(true, () => sql`locationistop = TRUE`)
            .with(false, () => sql`locationistop = FALSE`)
            .otherwise(() => sql`TRUE`)}
      ORDER BY locationid ${last ? sql`DESC` : sql`ASC`}
      LIMIT ${first ?? last ?? null};
    `;

    const [{ hasNextPage, hasPreviousPage }] = await sql<
      [Pick<PageInfo, "hasNextPage" | "hasPreviousPage">]
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
                          WHERE customeruuid = ${parentId}
                      )
                      AND locationid > (
                          SELECT locationid
                          FROM public.location
                          WHERE locationuuid = ${rows.at(-1)?._key ?? null}
                      )
                      AND ${match(args.search?.active)
                        .with(
                          true,
                          () =>
                            sql`(locationenddate IS null OR locationenddate > now())`,
                        )
                        .with(
                          false,
                          () =>
                            sql`(locationenddate IS NOT null AND locationenddate < now())`,
                        )
                        .otherwise(() => sql`TRUE`)}
                      AND ${match(args.search?.isSite)
                        .with(true, () => sql`locationistop = TRUE`)
                        .with(false, () => sql`locationistop = FALSE`)
                        .otherwise(() => sql`TRUE`)}
                  ORDER BY locationid ${last ? sql`DESC` : sql`ASC`}

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
                          WHERE customeruuid = ${parentId}
                      )
                      AND locationid < (
                          SELECT locationid
                          FROM public.location
                          WHERE locationuuid = ${rows.at(1)?._key ?? null}
                      )
                      AND ${match(args.search?.active)
                        .with(
                          true,
                          () =>
                            sql`(locationenddate IS null OR locationenddate > now())`,
                        )
                        .with(
                          false,
                          () =>
                            sql`(locationenddate IS NOT null AND locationenddate < now())`,
                        )
                        .otherwise(() => sql`TRUE`)}
                      AND ${match(args.search?.isSite)
                        .with(true, () => sql`locationistop = TRUE`)
                        .with(false, () => sql`locationistop = FALSE`)
                        .otherwise(() => sql`TRUE`)}
                  ORDER BY locationid ${last ? sql`DESC` : sql`ASC`}

              )
          ) AS "hasPreviousPage"
    `;

    const startCursor = rows.at(0);
    const endCursor = rows.at(-1);

    return {
      edges: rows.map(row => ({
        cursor: row.id.toString(),
        // biome-ignore lint/suspicious/noExplicitAny: temporary during migration
        node: new Location(row) as any,
      })),
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
          FROM public.location
          WHERE
              locationcustomerid = (
                  SELECT customerid
                  FROM public.customer
                  WHERE customeruuid = ${parentId}
              )
              AND ${match(args.search?.active)
                .with(
                  true,
                  () =>
                    sql`(locationenddate IS null OR locationenddate > now())`,
                )
                .with(
                  false,
                  () =>
                    sql`(locationenddate IS NOT null AND locationenddate < now())`,
                )
                .otherwise(() => sql`TRUE`)}
              AND ${match(args.search?.isSite)
                .with(true, () => sql`locationistop = TRUE`)
                .with(false, () => sql`locationistop = FALSE`)
                .otherwise(() => sql`TRUE`)};
        `
        )[0].count,
      ),
    };
  },
  async workers(root, args, ctx) {
    const { first, last } = args;
    const parentId = decodeGlobalId(root.id).id;
    const after = args.after ? decodeGlobalId(args.after).id : null;
    const before = args.before ? decodeGlobalId(args.before).id : null;

    // biome-ignore lint/complexity/noBannedTypes:
    const keys = await sql<WithKey<{}>[]>`
        SELECT workerinstanceuuid AS _key
        FROM public.workerinstance
        INNER JOIN public.worker
            ON workerinstanceworkerid = workerid
        WHERE
            workerinstancecustomerid = (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${parentId}
            )
            ${
              after
                ? sql`
            AND (workerfullname, workerinstanceid) > (
                SELECT
                    workerfullname,
                    workerinstanceid
                FROM public.workerinstance
                INNER JOIN public.worker
                    ON workerinstanceworkerid = workerid
                WHERE workerinstanceuuid = ${after}
            )
                `
                : sql``
            }
            ${
              before
                ? sql`
            AND (workerfullname, workerinstanceid) < (
                SELECT
                    workerfullname,
                    workerinstanceid
                FROM public.workerinstance
                INNER JOIN public.worker
                    ON workerinstanceworkerid = workerid
                WHERE workerinstanceuuid = ${before}
            )
                `
                : sql``
            }
            AND ${match(args.search?.active)
              .with(
                true,
                () =>
                  sql`(workerinstanceenddate IS null OR workerinstanceenddate > now())`,
              )
              .with(
                false,
                () =>
                  sql`(workerinstanceenddate IS NOT null AND workerinstanceenddate < now())`,
              )
              .otherwise(() => sql`TRUE`)}
            AND ${
              args.search?.user?.displayName?.length
                ? sql`workerfullname ILIKE '%' || ${args.search.user.displayName}::text || '%'`
                : sql`TRUE`
            }
        ORDER BY
            workerfullname ${last ? sql`DESC` : sql`ASC`},
            workerinstanceid ${last ? sql`DESC` : sql`ASC`}
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
                  INNER JOIN public.worker
                      ON workerinstanceworkerid = workerid
                  WHERE
                      workerinstancecustomerid = (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${parentId}
                      )
                      AND (workerfullname, workerinstanceid) > (
                          SELECT
                              workerfullname,
                              workerinstanceid
                          FROM public.workerinstance
                          INNER JOIN public.worker
                              ON workerinstanceworkerid = workerid
                          WHERE workerinstanceuuid = ${keys.at(-1)?._key ?? null}
                      )
                      AND ${match(args.search?.active)
                        .with(
                          true,
                          () =>
                            sql`(workerinstanceenddate IS null OR workerinstanceenddate > now())`,
                        )
                        .with(
                          false,
                          () =>
                            sql`(workerinstanceenddate IS NOT null AND workerinstanceenddate < now())`,
                        )
                        .otherwise(() => sql`TRUE`)}
                      AND ${
                        args.search?.user?.displayName?.length
                          ? sql`workerfullname ILIKE '%' || ${args.search.user.displayName}::text || '%'`
                          : sql`TRUE`
                      }
                  ORDER BY
                      workerfullname ${last ? sql`DESC` : sql`ASC`},
                      workerinstanceid ${last ? sql`DESC` : sql`ASC`}
              )
          ) AS "hasNextPage",
          (
              EXISTS (
                  SELECT 1
                  FROM public.workerinstance
                  INNER JOIN public.worker
                      ON workerinstanceworkerid = workerid
                  WHERE
                      workerinstancecustomerid = (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${parentId}
                      )
                      AND (workerfullname, workerinstanceid) < (
                          SELECT
                              workerfullname,
                              workerinstanceid
                          FROM public.workerinstance
                          INNER JOIN public.worker
                              ON workerinstanceworkerid = workerid
                          WHERE workerinstanceuuid = ${keys.at(0)?._key ?? null}
                      )
                      AND ${match(args.search?.active)
                        .with(
                          true,
                          () =>
                            sql`(workerinstanceenddate IS null OR workerinstanceenddate > now())`,
                        )
                        .with(
                          false,
                          () =>
                            sql`(workerinstanceenddate IS NOT null AND workerinstanceenddate < now())`,
                        )
                        .otherwise(() => sql`TRUE`)}
                      AND ${
                        args.search?.user?.displayName?.length
                          ? sql`workerfullname ILIKE '%' || ${args.search.user.displayName}::text || '%'`
                          : sql`TRUE`
                      }
                  ORDER BY
                      workerfullname ${last ? sql`DESC` : sql`ASC`},
                      workerinstanceid ${last ? sql`DESC` : sql`ASC`}
              )
          ) AS "hasPreviousPage"
    `;

    const rows = await ctx.orm.worker.loadMany(keys.map(e => e._key));
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
          cursor: row.id.toString(),
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
          INNER JOIN public.worker
              ON workerinstanceworkerid = workerid
          WHERE
              workerinstancecustomerid = (
                  SELECT customerid
                  FROM public.customer
                  WHERE customeruuid = ${parentId}
              )
              AND ${match(args.search?.active)
                .with(
                  true,
                  () =>
                    sql`(workerinstanceenddate IS null OR workerinstanceenddate > now())`,
                )
                .with(
                  false,
                  () =>
                    sql`(workerinstanceenddate IS NOT null AND workerinstanceenddate < now())`,
                )
                .otherwise(() => sql`TRUE`)}
              AND ${
                args.search?.user?.displayName?.length
                  ? sql`workerfullname ILIKE '%' || ${args.search.user.displayName}::text || '%'`
                  : sql`TRUE`
              };
        `
        )[0].count,
      ),
    };
  },
};
