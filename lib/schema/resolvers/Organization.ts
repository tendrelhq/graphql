import { sql } from "@/datasources/postgres";
import type {
  EnabledLanguage,
  Location,
  OrganizationResolvers,
  PageInfo,
  Worker,
} from "@/schema";
import { type WithKey, decodeGlobalId } from "@/util";

export const Organization: OrganizationResolvers = {
  async name(parent, _, ctx) {
    return ctx.orm.name.load(parent.nameId as string);
  },
  async languages(root, args, ctx) {
    const { first, last } = args;
    const parentId = decodeGlobalId(root.id as string).id;
    const after = args.after ? decodeGlobalId(args.after).id : null;
    const before = args.before ? decodeGlobalId(args.before).id : null;

    const rows = await sql<WithKey<EnabledLanguage>[]>`
      SELECT
          l.customerrequestedlanguageuuid AS _key,
          encode(('enabled-language:' || l.customerrequestedlanguageuuid)::bytea, 'base64') AS id,
          (
              l.customerrequestedlanguageenddate IS null
              OR
              l.customerrequestedlanguageenddate > now()
          ) AS active,
          l.customerrequestedlanguagestartdate::text AS "activatedAt",
          l.customerrequestedlanguageenddate::text AS "deactivatedAt",
          s.systaguuid AS "languageId",
          (l.customerrequestedlanguagelanguageid = o.customerlanguagetypeid) AS primary
      FROM public.customerrequestedlanguage AS l
      INNER JOIN public.customer AS o
          ON l.customerrequestedlanguagecustomerid = o.customerid
      INNER JOIN public.systag AS s
          ON l.customerrequestedlanguagelanguageid = s.systagid
      WHERE
          o.customeruuid = ${parentId}
          ${
            after
              ? sql`
          AND l.customerrequestedlanguageid > (
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
          AND l.customerrequestedlanguageid < (
              SELECT customerrequestedlanguageid
              FROM public.customerrequestedlanguage
              WHERE customerrequestedlanguageuuid = ${before}
          )
              `
              : sql``
          }
      ORDER BY l.customerrequestedlanguageid ${last ? sql`DESC` : sql`ASC`}
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
                  FROM public.customerrequestedlanguage
                  WHERE
                      customerrequestedlanguagecustomerid = (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${parentId}
                      )
                      AND customerrequestedlanguageid > (
                          SELECT customerrequestedlanguageid
                          FROM public.customerrequestedlanguage
                          WHERE customerrequestedlanguageuuid = ${endCursor?._key ?? null}
                      )
                  ORDER BY customerrequestedlanguageid ${last ? sql`DESC` : sql`ASC`}

              )
          ) AS "hasNextPage",
          (
              EXISTS (
                  SELECT 1
                  FROM public.customerrequestedlanguage
                  WHERE
                      customerrequestedlanguagecustomerid = (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${parentId}
                      )
                      AND customerrequestedlanguageid < (
                          SELECT customerrequestedlanguageid
                          FROM public.customerrequestedlanguage
                          WHERE customerrequestedlanguageuuid = ${startCursor?._key ?? null}
                      )
                  ORDER BY customerrequestedlanguageid ${last ? sql`DESC` : sql`ASC`}

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
  async locations(root, args, ctx) {
    const { first, last } = args;
    const parentId = decodeGlobalId(root.id as string).id;
    const after = args.after ? decodeGlobalId(args.after).id : null;
    const before = args.before ? decodeGlobalId(args.before).id : null;

    const rows = await sql<WithKey<Location>[]>`
      SELECT
          l.locationuuid AS _key,
          encode(('location:' || l.locationuuid)::bytea, 'base64') AS id,
          (l.locationenddate IS null OR l.locationenddate > now()) AS active,
          l.locationstartdate::text AS "activatedAt",
          l.locationenddate::text AS "deactivatedAt",
          encode(('name:' || n.languagemasteruuid)::bytea, 'base64') AS "nameId",
          encode(('location:' || p.locationuuid)::bytea, 'base64') AS "parentId",
          l.locationscanid AS "scanCode",
          encode(('location:' || s.locationuuid)::bytea, 'base64') AS "siteId"
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
              WHERE customeruuid = ${parentId}
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
      ORDER BY l.locationid ${last ? sql`DESC` : sql`ASC`}
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
                          WHERE locationuuid = ${endCursor?._key ?? null}
                      )
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
                          WHERE locationuuid = ${startCursor?._key ?? null}
                      )
                  ORDER BY locationid ${last ? sql`DESC` : sql`ASC`}

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
  async workers(root, args, ctx) {
    const { first, last } = args;
    const parentId = decodeGlobalId(root.id as string).id;
    const after = args.after ? decodeGlobalId(args.after).id : null;
    const before = args.before ? decodeGlobalId(args.before).id : null;

    const rows = await sql<WithKey<Worker>[]>`
      SELECT
          w.workerinstanceuuid AS _key,
          encode(('worker:' || w.workerinstanceuuid)::bytea, 'base64') AS id,
          (w.workerinstanceenddate IS null OR w.workerinstanceenddate > now()) AS active,
          w.workerinstancestartdate::text AS "activatedAt",
          w.workerinstanceenddate::text AS "deactivatedAt",
          l.systaguuid AS "languageId",
          r.systaguuid AS "roleId",
          w.workerinstancescanid AS "scanCode",
          encode(('user:' || u.workeruuid)::bytea, 'base64') AS "userId"
      FROM public.workerinstance AS w
      INNER JOIN public.systag AS l
          ON w.workerinstancelanguageid = l.systagid
      INNER JOIN public.systag AS r
          ON w.workerinstanceuserroleid = r.systagid
      INNER JOIN public.worker AS u
          ON w.workerinstanceworkerid = u.workerid
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
                      workerinstancecustomerid = (
                          SELECT customerid
                          FROM public.customer
                          WHERE customeruuid = ${parentId}
                      )
                      AND workerinstanceid > (
                          SELECT workerinstanceid
                          FROM public.workerinstance
                          WHERE workerinstanceuuid = ${endCursor?._key ?? null}
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
                          WHERE workerinstanceuuid = ${startCursor?._key ?? null}
                      )
                  ORDER BY workerinstanceid ${last ? sql`DESC` : sql`ASC`}

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
};
