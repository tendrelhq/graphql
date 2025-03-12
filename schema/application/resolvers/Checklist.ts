import { join, sql } from "@/datasources/postgres";
import type {
  Assignee,
  ChecklistResolvers,
  Description,
  PageInfo,
  ResolversTypes,
} from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { Task, attachments } from "@/schema/system/component/task";
import { buildPaginationArgs } from "@/util";
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

    const count = await match(type)
      .with(
        "workinstance",
        () => sql<[{ count: bigint }]>`
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
      .then(([row]) => row.count);

    return {
      edges: rows.map(row => ({ cursor: row.id, node: row as Assignee })),
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: Number(count),
    };
  },
  async attachments(parent, args, ctx) {
    const t = new Task({ id: parent.id as string }, ctx);
    return await attachments(t, ctx, args);
  },
  auditable(parent, _, ctx) {
    return ctx.orm.auditable.load(parent.id);
  },
  async chain(parent) {
    const { type, id } = decodeGlobalId(parent.id);

    if (type !== "workinstance") {
      // Only instances participate in chains.
      return;
    }

    const [chain] = await sql<[{ prev?: string; root?: string }]>`
      SELECT
          encode(('workinstance:' || prev.id)::bytea, 'base64') AS "prev",
          encode(('workinstance:' || root.id)::bytea, 'base64') AS "root"
      FROM public.workinstance AS node
      LEFT JOIN public.workinstance AS root
          ON node.workinstanceoriginatorworkinstanceid = root.workinstanceid
      LEFT JOIN public.workinstance AS prev
          ON node.workinstancepreviousid = prev.workinstanceid
      WHERE node.id = ${id}
    `;

    return {
      prev: chain.prev
        ? ({
            __typename: "Checklist",
            id: chain.prev,
            // biome-ignore lint/suspicious/noExplicitAny: defer to Checklist
          } as any)
        : undefined,
      root: chain.root
        ? ({
            __typename: "Checklist",
            id: chain.root,
            // biome-ignore lint/suspicious/noExplicitAny: defer to Checklist
          } as any)
        : undefined,
    };
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
  async draft(parent) {
    const { type, id } = decodeGlobalId(parent.id);
    if (type === "worktemplate") {
      const [row] = await sql<[{ draft: boolean }]>`
        select worktemplatedraft as draft
        from public.worktemplate
        where id = ${id}
      `;
      return row.draft;
    }
    // Only templates can be in the draft state.
    return false;
  },
  async items(parent, args) {
    const { type: parentType, id: parentId } = decodeGlobalId(parent.id);

    const { cursor, direction, limit } = buildPaginationArgs(args, {
      defaultLimit: Number(process.env.DEFAULT_ITEMS_PAGINATION_LIMIT ?? 250),
      maxLimit: Number(process.env.MAX_ITEMS_PAGINATION_LIMIT ?? 250),
    });

    // Our (default) order clause specifies:
    // 1. workresultorder ASC
    // 2. workresultid ASC
    const cmp = direction === "forward" ? sql`>` : sql`<`;

    const rows = await match(parentType)
      .with(
        "workinstance",
        () => sql<{ __typename: "ChecklistResult"; id: string }[]>`
            ${
              cursor?.suffix?.length
                ? sql`
            WITH cursor AS (
                SELECT
                    workresultorder AS order,
                    workresultid AS id
                FROM public.workresult
                WHERE id = ${cursor.suffix[0]}
            )
                `
                : sql``
            }
            SELECT
                'ChecklistResult' AS "__typename",
                encode(('workresultinstance:' || wi.id || ':' || wr.id)::bytea, 'base64') AS id
            FROM public.workinstance AS wi
            ${cursor?.suffix?.length ? sql`INNER JOIN cursor ON true` : sql``}
            INNER JOIN public.workresultinstance AS wri
                ON wi.workinstanceid = wri.workresultinstanceworkinstanceid
            INNER JOIN public.workresult AS wr
                ON wri.workresultinstanceworkresultid = wr.workresultid
                AND wr.workresultdeleted = false
                AND wr.workresultisprimary = false
            WHERE ${join(
              [
                sql`wi.id = ${parentId}`,
                ...(args.withDraft ? [] : [sql`wr.workresultdraft = false`]),
                ...(cursor
                  ? [
                      sql`(wr.workresultorder, wr.workresultid) ${cmp} (cursor.order, cursor.id)`,
                    ]
                  : []),
                ...match(args.withActive)
                  .with(true, () => [
                    sql`(
                        wr.workresultenddate IS null
                        OR wr.workresultenddate > now()
                    )`,
                  ])
                  .with(false, () => [
                    sql`(
                        wr.workresultenddate IS NOT null
                        AND wr.workresultenddate < now()
                    )`,
                  ])
                  .otherwise(() => []),
              ],
              sql`AND`,
            )}
            ORDER BY wr.workresultorder ${direction === "forward" ? sql`ASC` : sql`DESC`},
                     wr.workresultid ${direction === "forward" ? sql`ASC` : sql`DESC`}
            LIMIT ${limit + 1};
        `,
      )
      .with(
        "worktemplate",
        () => sql<{ __typename: "ChecklistResult"; id: string }[]>`
            ${
              cursor
                ? sql`
            WITH cursor AS (
                SELECT
                    workresultorder AS order,
                    workresultid AS id
                FROM public.workresult
                WHERE id = ${cursor.id}
            )
                `
                : sql``
            }
            SELECT
                'ChecklistResult' AS "__typename",
                encode(('workresult:' || wr.id)::bytea, 'base64') AS id
            FROM public.worktemplate AS wt
            ${cursor ? sql`INNER JOIN cursor ON true` : sql``}
            INNER JOIN public.workresult AS wr
                ON wt.worktemplateid = wr.workresultworktemplateid
                AND wr.workresultdeleted = false
                AND wr.workresultdraft = ${args.withDraft ?? false}
                AND wr.workresultisprimary = false
            WHERE ${join(
              [
                sql`wt.id = ${parentId}`,
                ...(cursor
                  ? [
                      sql`(wr.workresultorder, wr.workresultid) ${cmp} (cursor.order, cursor.id)`,
                    ]
                  : []),
                ...match(args.withActive)
                  .with(true, () => [
                    sql`(
                        wr.workresultenddate IS null
                        OR wr.workresultenddate > now()
                    )`,
                  ])
                  .with(false, () => [
                    sql`(
                        wr.workresultenddate IS NOT null
                        AND wr.workresultenddate < now()
                    )`,
                  ])
                  .otherwise(() => []),
              ],
              sql`AND`,
            )}
            ORDER BY wr.workresultorder ${direction === "forward" ? sql`ASC` : sql`DESC`},
                     wr.workresultid ${direction === "forward" ? sql`ASC` : sql`DESC`}
            LIMIT ${limit + 1};
        `,
      )
      .otherwise(() => Promise.reject("invariant violated"));

    const n1 = rows.length > limit ? rows.pop() : undefined;
    const hasNext = direction === "forward" && !!n1;
    const hasPrev = direction === "backward" && !!n1;

    const edges = rows.map(row => ({
      cursor: row.id as string,
      // biome-ignore lint/suspicious/noExplicitAny: defer to Checklist[Result]
      node: row as any,
    }));

    const pageInfo: PageInfo = {
      startCursor: edges.at(0)?.cursor,
      endCursor: edges.at(-1)?.cursor,
      hasNextPage: hasNext,
      hasPreviousPage: hasPrev,
    };

    const [{ count }] = await match(parentType)
      .with(
        "workinstance",
        () => sql<[{ count: bigint }]>`
            SELECT count(*)
            FROM public.workresult AS wr
            WHERE
                wr.workresultworktemplateid IN (
                    SELECT workinstanceworktemplateid
                    FROM public.workinstance
                    WHERE id = ${parentId}
                )
                AND wr.workresultdeleted = false
                AND wr.workresultdraft = ${args.withDraft ?? false}
                AND wr.workresultisprimary = false
                ${match(args.withActive)
                  .with(
                    true,
                    () => sql`AND (
                        wr.workresultenddate IS null
                        OR wr.workresultenddate > now()
                    )`,
                  )
                  .with(
                    false,
                    () => sql`AND (
                        wr.workresultenddate IS NOT null
                        AND wr.workresultenddate < now()
                    )`,
                  )
                  .otherwise(() => sql``)}
        `,
      )
      .with(
        "worktemplate",
        () => sql<[{ count: bigint }]>`
            SELECT count(*)
            FROM public.workresult AS wr
            WHERE
                wr.workresultworktemplateid IN (
                    SELECT worktemplateid
                    FROM public.worktemplate
                    WHERE id = ${parentId}
                )
                AND wr.workresultdeleted = false
                AND wr.workresultdraft = ${args.withDraft ?? false}
                AND wr.workresultisprimary = false
                ${match(args.withActive)
                  .with(
                    true,
                    () => sql`AND (
                        wr.workresultenddate IS null
                        OR wr.workresultenddate > now()
                    )`,
                  )
                  .with(
                    false,
                    () => sql`AND (
                        wr.workresultenddate IS NOT null
                        AND wr.workresultenddate < now()
                    )`,
                  )
                  .otherwise(() => sql``)}
        `,
      )
      .otherwise(() => Promise.reject("invariant violated"));

    return {
      edges,
      pageInfo,
      totalCount: Number(count),
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
            WHERE c.id = ${id}
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
