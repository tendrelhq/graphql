import { sql } from "@/datasources/postgres";
import type {
  Assignee,
  ChecklistItem,
  ChecklistResolvers,
  Description,
  ResolversTypes,
} from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { match } from "ts-pattern";

export const Checklist: ChecklistResolvers = {
  active(parent, _, ctx) {
    return ctx.orm.active.load(parent.id);
  },
  async assignees(parent, args) {
    const { first, last } = args;
    const { type, id } = decodeGlobalId(parent.id);
    const { id: after } = args.after
      ? decodeGlobalId(args.after)
      : { id: undefined };
    const { id: before } = args.before
      ? decodeGlobalId(args.before)
      : { id: undefined };

    const rows = await match(type)
      .with(
        "workinstance",
        () => sql<{ id: string }[]>`
            SELECT encode(('workresultinstance:' || wri.workresultinstanceuuid)::bytea, 'base64') AS id
            FROM public.workresultinstance AS wri
            INNER JOIN public.workresult AS wr
                ON wri.workresultinstanceworkresultid = wr.workresultid
            WHERE
                wri.workresultinstanceworkinstanceid = (
                    SELECT workinstanceid
                    FROM public.workinstance
                    WHERE id = ${id}
                )
                AND ${
                  after
                    ? sql`wri.workresultinstanceid > (
                        SELECT workresultinstanceid
                        FROM public.workresultinstance
                        WHERE id = ${after}
                    )`
                    : sql`true`
                }
                AND ${
                  before
                    ? sql`wri.workresultinstanceid < (
                        SELECT workresultinstanceid
                        FROM public.workresultinstance
                        WHERE id = ${before}
                    )`
                    : sql`true`
                }
                AND nullif(wri.workresultinstancevalue, '') IS NOT null
                AND wr.workresulttypeid = 848
                AND wr.workresultentitytypeid = 850
                AND wr.workresultisprimary = true
            ORDER BY wri.workresultinstanceid ${last ? sql`DESC` : sql`ASC`}
            LIMIT ${first ?? last ?? null};
        `,
      )
      .otherwise(() => Promise.resolve([]));

    return {
      edges: rows.map(row => ({ cursor: row.id, node: row as Assignee })),
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: await match(type)
        .with(
          "workinstance",
          () => sql<[{ count: number }]>`
              SELECT count(*)
              FROM public.workresultinstance
              INNER JOIN public.workresult
                  ON workresultinstanceworkresultid = workresultid
              WHERE
                  workresultinstanceworkinstanceid = (
                      SELECT workinstanceid
                      FROM public.workinstance
                      WHERE id = ${id}
                  )
                  AND nullif(workresultinstancevalue, '') IS NOT null
                  AND workresulttypeid = 848
                  AND workresultentitytypeid = 850
                  AND workresultisprimary = true
          `,
        )
        .otherwise(() => Promise.resolve([{ count: 0 }]))
        .then(([row]) => row.count),
    };
  },
  attachments() {
    return {
      edges: [],
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: 0,
    };
  },
  auditable(parent, _, ctx) {
    return ctx.orm.auditable.load(parent.id);
  },
  children() {
    return {
      edges: [],
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: 0,
    };
  },
  async description(parent, _, ctx) {
    return (await ctx.orm.description.load(parent.id)) as Description;
  },
  async items(parent, args, ctx) {
    const { first, last } = args;
    const { id, type } = decodeGlobalId(parent.id);
    const { id: afterId } = args.after
      ? decodeGlobalId(args.after)
      : { id: null };
    const { id: beforeId } = args.before
      ? decodeGlobalId(args.before)
      : { id: null };

    const rows = await match(type)
      .with(
        "workinstance",
        () => sql<{ __typename: "ChecklistResult"; id: string }[]>`
            SELECT
                'ChecklistResult' AS "__typename",
                coalesce(
                    encode(('workresultinstance:' || wri.workresultinstanceuuid)::bytea, 'base64'),
                    encode(('workresult:' || wr.id)::bytea, 'base64')
                ) AS id
            FROM public.workresult AS wr
            LEFT JOIN public.workresultinstance AS wri
                ON wr.workresultid = wri.workresultinstanceworkresultid
            WHERE
                wr.workresultworktemplateid IN (
                    SELECT workinstanceworktemplateid
                    FROM public.workinstance
                    WHERE id = ${id}
                )
                AND
                wr.workresultisprimary = false
            ORDER BY wr.workresultorder ${last ? sql`DESC` : sql`ASC`},
                     wr.workresultid ${last ? sql`DESC` : sql`ASC`}
            LIMIT ${first ?? last ?? null};
        `,
      )
      .with(
        "worktemplate",
        () => sql<{ __typename: "ChecklistResult"; id: string }[]>`
            SELECT
                'ChecklistResult' AS "__typename",
                encode(('workresult:' || wr.id)::bytea, 'base64') AS id
            FROM public.workresult AS wr
            INNER JOIN public.worktemplate AS wt
                ON wr.workresultworktemplateid = wt.worktemplateid
            WHERE
                wt.id = ${id}
                AND
                workresultisprimary = false
            ORDER BY wr.workresultorder ${last ? sql`DESC` : sql`ASC`},
                     wr.workresultid ${last ? sql`DESC` : sql`ASC`}
            LIMIT ${first ?? last ?? null};
        `,
      )
      .otherwise(() => Promise.reject("invariant violated"));

    return {
      edges: rows.map(row => ({ cursor: row.id, node: row as ChecklistItem })),
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: await match(type)
        .with(
          "workinstance",
          () => sql<[{ count: number }]>`
              SELECT count(*)
              FROM public.workresult
              WHERE
                  workresultworktemplateid IN (
                      SELECT workinstanceworktemplateid
                      FROM public.workinstance
                      WHERE id = ${id}
                  )
                  AND
                  workresultisprimary = false
          `,
        )
        .with(
          "worktemplate",
          () => sql<[{ count: number }]>`
              SELECT count(*)
              FROM public.workresult
              WHERE
                  workresultworktemplateid IN (
                      SELECT worktemplateid
                      FROM public.worktemplate
                      WHERE id = ${id}
                  )
                  AND
                  workresultisprimary = false
          `,
        )
        .otherwise(() => Promise.reject("invariant violated"))
        .then(([row]) => row.count),
    };
  },
  async metadata(parent) {
    const { type, id } = decodeGlobalId(parent.id);

    const [row] = await match(type)
      .with(
        "workinstance",
        () => sql<[ResolversTypes["Temporal"]]>`
            SELECT
                'Instant' AS "__typename",
                (extract(epoch from workinstancemodifieddate) * 1000)::text AS "epochMilliseconds"
            FROM public.workinstance
            WHERE id = ${id}
        `,
      )
      .with(
        "worktemplate",
        () => sql<[ResolversTypes["Temporal"]]>`
            SELECT
                'Instant' AS "__typename",
                (extract(epoch from worktemplatemodifieddate) * 1000)::text AS "epochMilliseconds"
            FROM public.worktemplate
            WHERE id = ${id}
        `,
      )
      .otherwise(() => Promise.reject("invariant violated"));

    return { updatedAt: row };
  },
  async name(parent, _, ctx) {
    return (await ctx.orm.displayName.load(
      parent.id,
    )) as ResolversTypes["DisplayName"];
  },
  async parent(parent) {
    const { type, id } = decodeGlobalId(parent.id);
    const [row] = await match(type)
      .with(
        "workinstance",
        () => sql<[{ id: string }?]>`
            SELECT
                'Checklist' AS "__typename",
                encode(('workinstance:' || p.id)::bytea, 'base64') AS id
            FROM public.workinstance AS c
            INNER JOIN public.workinstance AS p
                ON c.workinstancepreviousid = p.workinstanceid
            WHERE
                c.id = ${id}
        `,
      )
      .otherwise(() => []);
    // biome-ignore lint/suspicious/noExplicitAny:
    return row as any;
  },
  required(parent, _, ctx) {
    return ctx.orm.requirement.load(parent.id);
  },
  schedule() {
    return undefined;
  },
  sop(parent, _, ctx) {
    return ctx.orm.sop.load(parent.id);
  },
  status(parent, _, ctx) {
    return ctx.orm.status.load(parent.id);
  },
};
