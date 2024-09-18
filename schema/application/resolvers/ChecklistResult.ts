import { sql } from "@/datasources/postgres";
import type { ChecklistResultResolvers, ResolversTypes } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { match } from "ts-pattern";

export const ChecklistResult: ChecklistResultResolvers = {
  assignees() {
    return {
      edges: [],
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: 0,
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
  // async auditable(parent, _, ctx) {
  //   return (await ctx.orm.auditable.load(parent.id)) as any;
  // },
  async name(parent, _, ctx) {
    // biome-ignore lint/suspicious/noExplicitAny:
    return (await ctx.orm.displayName.load(parent.id)) as any;
  },
  // async required(parent, _, ctx) {
  //   return await ctx.orm.requirement.load(parent.id);
  // },
  async status(parent, _, ctx) {
    // biome-ignore lint/suspicious/noExplicitAny:
    return (await ctx.orm.status.load(parent.id)) as any;
  },
  async value(parent) {
    const { type, id } = decodeGlobalId(parent.id);
    const [row] = await match(type)
      .with(
        "workresult",
        // TODO:
        // 1 │ Boolean
        // 2 │ Date
        // 3 │ Entity
        // 4 │ Number
        // 5 │ String
        // 6 │ Time At Task
        () => sql<[ResolversTypes["ChecklistResultValue"]]>`
            WITH cte AS (
                SELECT
                    CASE WHEN t.systagtype = 'Boolean' THEN 'Flag'
                         WHEN t.systagtype = 'Date' THEN 'Register'
                         WHEN t.systagtype = 'Entity' THEN 'Reference'
                         WHEN t.systagtype = 'Number' THEN 'Counter'
                         WHEN t.systagtype = 'String' THEN 'Register'
                         WHEN t.systagtype = 'Time At Task' THEN 'Counter'
                    END AS type,
                    e.systagtype AS reftype,
                    nullif(wr.workresultdefaultvalue, '') AS value
                FROM public.workresult AS wr
                INNER JOIN public.systag AS t
                    ON wr.workresulttypeid = t.systagid
                LEFT JOIN public.systag AS e
                    ON wr.workresultentitytypeid = e.systagid
                WHERE wr.id = ${id}
            )

            SELECT
                'Counter' AS "__typename",
                value::bigint AS count,
                null::boolean AS enabled,
                null::text AS binary,
                null::json AS ref
            FROM cte
            WHERE type = 'Counter'
            UNION ALL
            SELECT
                'Flag' AS "__typename",
                null AS count,
                value::boolean AS enabled,
                null AS binary,
                null AS ref
            FROM cte
            WHERE type = 'Flag'
            UNION ALL
            SELECT
                'Register' AS "__typename",
                null AS count,
                null AS enabled,
                value::text AS binary,
                null AS ref
            FROM cte
            WHERE type = 'Register'
            UNION ALL
            SELECT
                'Reference' AS "__typename",
                null AS count,
                null AS enabled,
                null AS binary,
                (
                    SELECT row_to_json(ref)
                    FROM (
                        SELECT
                            'Location' AS "__typename",
                            encode(('location:' || l.locationuuid)::bytea, 'base64') AS id
                        FROM public.location AS l
                        WHERE
                            cte.reftype = 'Location'
                            AND cte.value::bigint = l.locationid
                        UNION ALL
                        SELECT
                            'Worker' AS "__typename",
                            encode(('worker:' || w.workerinstanceuuid)::bytea, 'base64') AS id
                        FROM public.workerinstance AS w
                        WHERE
                            cte.reftype = 'Worker'
                            AND cte.value::bigint = w.workerinstanceid
                    ) ref
                ) AS ref
            FROM cte
            WHERE type = 'Reference'
        `,
      )
      .with(
        "workresultinstance",
        () => sql<[ResolversTypes["ChecklistResultValue"]]>`
            WITH cte AS (
                SELECT
                    CASE WHEN t.systagtype = 'Boolean' THEN 'Flag'
                         WHEN t.systagtype = 'Date' THEN 'Register'
                         WHEN t.systagtype = 'Entity' THEN 'Reference'
                         WHEN t.systagtype = 'Number' THEN 'Counter'
                         WHEN t.systagtype = 'String' THEN 'Register'
                         WHEN t.systagtype = 'Time At Task' THEN 'Counter'
                    END AS type,
                    e.systagtype AS reftype,
                    nullif(wri.workresultinstancevalue, '') AS value
                FROM public.workresultinstance AS wri
                INNER JOIN public.workresult AS wr
                    ON wri.workresultinstanceworkresultid = wr.workresultid
                INNER JOIN public.systag AS t
                    ON wr.workresulttypeid = t.systagid
                LEFT JOIN public.systag AS e
                    ON wr.workresultentitytypeid = e.systagid
                WHERE wri.id = ${id}
            )

            SELECT
                'Counter' AS "__typename",
                value::bigint AS count,
                null::boolean AS enabled,
                null::text AS binary,
                null::json AS ref
            FROM cte
            WHERE type = 'Counter'
            UNION ALL
            SELECT
                'Flag' AS "__typename",
                null AS count,
                value::boolean AS enabled,
                null AS binary,
                null AS ref
            FROM cte
            WHERE type = 'Flag'
            UNION ALL
            SELECT
                'Register' AS "__typename",
                null AS count,
                null AS enabled,
                value::text AS binary,
                null AS ref
            FROM cte
            WHERE type = 'Register'
            UNION ALL
            SELECT
                'Reference' AS "__typename",
                null AS count,
                null AS enabled,
                null AS binary,
                (
                    SELECT row_to_json(ref)
                    FROM (
                        SELECT
                            'Location' AS "__typename",
                            encode(('location:' || l.locationuuid)::bytea, 'base64') AS id
                        FROM public.location AS l
                        WHERE
                            cte.reftype = 'Location'
                            AND cte.value::bigint = l.locationid
                        UNION ALL
                        SELECT
                            'Worker' AS "__typename",
                            encode(('worker:' || w.workerinstanceuuid)::bytea, 'base64') AS id
                        FROM public.workerinstance AS w
                        WHERE
                            cte.reftype = 'Worker'
                            AND cte.value::bigint = w.workerinstanceid
                    ) ref
                ) AS ref
            FROM cte
            WHERE type = 'Reference'
        `,
      )
      .otherwise(() => Promise.reject("invariant violated"));

    if (!row) {
      console.warn({ type, id });
    }
    return row;
  },
};
