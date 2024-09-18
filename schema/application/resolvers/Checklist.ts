import { sql } from "@/datasources/postgres";
import type {
  Assignee,
  Auditable,
  ChecklistItem,
  ChecklistResolvers,
  Description,
  DisplayName,
  ResolversTypes,
} from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { match } from "ts-pattern";

export const Checklist: ChecklistResolvers = {
  async active(parent, _, ctx) {
    // biome-ignore lint/suspicious/noExplicitAny:
    return (await ctx.orm.activatable.load(parent.id)) as any;
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
            SELECT encode(('workresultinstance:' || wri.id)::bytea, 'base64') AS id
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
  async auditable(parent, _, ctx) {
    return (await ctx.orm.auditable.load(parent.id)) as Auditable;
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
                encode(('workresultinstance:' || wri.id)::bytea, 'base64') AS id
            FROM public.workresultinstance AS wri
            INNER JOIN public.workinstance AS wi
                ON wri.workresultinstanceworkinstanceid = wi.workinstanceid
            WHERE
                wi.id = ${id}
                AND ${
                  afterId
                    ? sql`wi.workinstanceid > (
                        SELECT workinstanceid
                        FROM public.workinstance
                        WHERE id = ${afterId}
                    )`
                    : sql`true`
                }
                AND ${
                  beforeId
                    ? sql`wi.workinstanceid < (
                        SELECT workinstanceid
                        FROM public.workinstance
                        WHERE id = ${beforeId}
                    )`
                    : sql`true`
                }
            ORDER BY wi.workinstanceid ${last ? sql`DESC` : sql`ASC`}
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
                AND ${
                  afterId
                    ? sql`wt.worktemplateid > (
                        SELECT worktemplateid
                        FROM public.worktemplate
                        WHERE id = ${afterId}
                    )`
                    : sql`true`
                }
                AND ${
                  beforeId
                    ? sql`wt.worktemplateid < (
                        SELECT worktemplateid
                        FROM public.worktemplate
                        WHERE id = ${beforeId}
                    )`
                    : sql`true`
                }
            ORDER BY wt.worktemplateid ${last ? sql`DESC` : sql`ASC`}
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
              FROM public.workresultinstance
              WHERE
                  workresultinstanceworkinstanceid = (
                      SELECT workinstanceid
                      FROM public.workinstance
                      WHERE id = ${id}
                  )
          `,
        )
        .with(
          "worktemplate",
          () => sql<[{ count: number }]>`
              SELECT count(*)
              FROM public.workresult
              WHERE
                  workresultworktemplateid = (
                      SELECT worktemplateid
                      FROM public.worktemplate
                      WHERE id = ${id}
                  )
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
    return (await ctx.orm.displayName.load(parent.id)) as DisplayName;
  },
  async required(parent, _, ctx) {
    return await ctx.orm.requirement.load(parent.id);
  },
  schedule() {
    return undefined;
  },
  async sop(parent, _, ctx) {
    return await ctx.orm.sop.load(parent.id);
  },
  async status(parent, _, ctx) {
    // biome-ignore lint/suspicious/noExplicitAny:
    return (await ctx.orm.status.load(parent.id)) as any;
  },
};
