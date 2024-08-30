import { sql } from "@/datasources/postgres";
import type { OrganizationResolvers, PageInfo } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import { match } from "ts-pattern";

export const Organization: OrganizationResolvers = {
  async name(parent, _, ctx) {
    return ctx.orm.name.load(decodeGlobalId(parent.nameId).id);
  },
  async languages(root, args, ctx) {
    const { first, last } = args;
    const parentId = decodeGlobalId(root.id as string).id;
    const after = args.after ? decodeGlobalId(args.after).id : null;
    const before = args.before ? decodeGlobalId(args.before).id : null;

    // biome-ignore lint/complexity/noBannedTypes:
    const keys = await sql<WithKey<{}>[]>`
      SELECT customerrequestedlanguageuuid AS _key
      FROM public.customerrequestedlanguage
      INNER JOIN public.customer
          ON customerrequestedlanguagecustomerid = customerid
      WHERE
          customeruuid = ${parentId}
          ${
            after
              ? sql`
          AND customerrequestedlanguageid > (
              SELECT customerrequestedlanguageid
              FROM public.customerrequestedlanguage
              WHERE customerrequestedlanguageuuid = ${after}
          )
              `
              : sql``
          }
          ${
            before
              ? sql`
          AND customerrequestedlanguageid < (
              SELECT customerrequestedlanguageid
              FROM public.customerrequestedlanguage
              WHERE customerrequestedlanguageuuid = ${before}
          )
              `
              : sql``
          }
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
      ORDER BY customerrequestedlanguageid ${last ? sql`DESC` : sql`ASC`}
      LIMIT ${first ?? last ?? null};
    `;

    const [{ hasNextPage, hasPreviousPage }] = await sql<
      [Pick<PageInfo, "hasNextPage" | "hasPreviousPage">]
    >`
      SELECT
          (
              EXISTS (
                  SELECT 1
                  FROM public.customerrequestedlanguage
                  INNER JOIN public.customer
                      ON customerrequestedlanguagecustomerid = customerid
                  WHERE
                      customeruuid = ${parentId}
                      AND customerrequestedlanguageid > (
                          SELECT customerrequestedlanguageid
                          FROM public.customerrequestedlanguage
                          WHERE customerrequestedlanguageuuid = ${keys.at(-1)?._key ?? null}
                      )
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
                            sql`customerrequestedlanguageenddate IS null OR customerrequestedlanguageenddate > now()`,
                        )
                        .with(
                          false,
                          () =>
                            sql`customerrequestedlanguageenddate IS NOT null AND customerrequestedlanguageenddate < now()`,
                        )
                        .otherwise(() => sql`TRUE`)}
                  ORDER BY customerrequestedlanguageid ${last ? sql`DESC` : sql`ASC`}

              )
          ) AS "hasNextPage",
          (
              EXISTS (
                  SELECT 1
                  FROM public.customerrequestedlanguage
                  INNER JOIN public.customer
                      ON customerrequestedlanguagecustomerid = customerid
                  WHERE
                      customeruuid = ${parentId}
                      AND customerrequestedlanguageid < (
                          SELECT customerrequestedlanguageid
                          FROM public.customerrequestedlanguage
                          WHERE customerrequestedlanguageuuid = ${keys.at(0)?._key ?? null}
                      )
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
                            sql`customerrequestedlanguageenddate IS null OR customerrequestedlanguageenddate > now()`,
                        )
                        .with(
                          false,
                          () =>
                            sql`customerrequestedlanguageenddate IS NOT null AND customerrequestedlanguageenddate < now()`,
                        )
                        .otherwise(() => sql`TRUE`)}
                  ORDER BY customerrequestedlanguageid ${last ? sql`DESC` : sql`ASC`}

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
    };
  },
  async locations(root, args, ctx) {
    const { first, last } = args;
    const parentId = decodeGlobalId(root.id as string).id;
    const after = args.after ? decodeGlobalId(args.after).id : null;
    const before = args.before ? decodeGlobalId(args.before).id : null;

    // biome-ignore lint/complexity/noBannedTypes:
    const keys = await sql<WithKey<{}>[]>`
      SELECT locationuuid AS _key
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
                          WHERE locationuuid = ${keys.at(-1)?._key ?? null}
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
                          WHERE locationuuid = ${keys.at(1)?._key ?? null}
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

    const rows = await ctx.orm.location.loadMany(keys.map(e => e._key));
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
    };
  },
  async workers(root, args, ctx) {
    const { first, last } = args;
    const parentId = decodeGlobalId(root.id as string).id;
    const after = args.after ? decodeGlobalId(args.after).id : null;
    const before = args.before ? decodeGlobalId(args.before).id : null;

    // biome-ignore lint/complexity/noBannedTypes:
    const keys = await sql<WithKey<{}>[]>`
        SELECT w.workerinstanceuuid AS _key
        FROM public.workerinstance AS w
        WHERE
            w.workerinstancecustomerid = (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${parentId}
            )
            ${
              after
                ? sql`
            AND w.workerinstanceid > (
                SELECT workerinstanceid
                FROM public.workerinstance
                WHERE workerinstanceuuid = ${after}
            )
                `
                : sql``
            }
            ${
              before
                ? sql`
            AND w.workerinstanceid < (
                SELECT workerinstanceid
                FROM public.workerinstance
                WHERE workerinstanceuuid = ${before}
            )
                `
                : sql``
            }
        ORDER BY workerinstanceid ${last ? sql`DESC` : sql`ASC`}
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
                      workerinstancecustomerid = (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${parentId}
                      )
                      AND workerinstanceid > (
                          SELECT workerinstanceid
                          FROM public.workerinstance
                          WHERE workerinstanceuuid = ${keys.at(-1)?._key ?? null}
                      )
                  ORDER BY workerinstanceid ${last ? sql`DESC` : sql`ASC`}

              )
          ) AS "hasNextPage",
          (
              EXISTS (
                  SELECT 1
                  FROM public.workerinstance
                  WHERE
                      workerinstancecustomerid = (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${parentId}
                      )
                      AND workerinstanceid < (
                          SELECT workerinstanceid
                          FROM public.workerinstance
                          WHERE workerinstanceuuid = ${keys.at(0)?._key ?? null}
                      )
                  ORDER BY workerinstanceid ${last ? sql`DESC` : sql`ASC`}

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
    };
  },
};
