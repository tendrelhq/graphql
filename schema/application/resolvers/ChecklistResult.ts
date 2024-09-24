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
  auditable(parent, _, ctx) {
    return ctx.orm.auditable.load(parent.id);
  },
  async name(parent, _, ctx) {
    return (await ctx.orm.displayName.load(
      parent.id,
    )) as ResolversTypes["DisplayName"];
  },
  required(parent, _, ctx) {
    return ctx.orm.requirement.load(parent.id);
  },
  status(parent, _, ctx) {
    return ctx.orm.status.load(parent.id);
  },
  async widget(parent) {
    const { type, id } = decodeGlobalId(parent.id);
    const [row] = await match(type)
      .with(
        "workresult",
        () => sql<[ResolversTypes["Widget"]]>`
            WITH cte AS (
                SELECT
                    CASE WHEN t.systagtype = 'Boolean' THEN 'CheckboxWidget'
                         WHEN t.systagtype = 'Clicker' THEN 'ClickerWidget'
                         WHEN t.systagtype = 'Date' THEN 'TemporalWidget'
                         WHEN t.systagtype = 'Duration' THEN 'DurationWidget'
                         WHEN t.systagtype = 'Entity' THEN 'ReferenceWidget'
                         WHEN t.systagtype = 'Geolocation' THEN 'StringWidget'
                         WHEN t.systagtype = 'Number' THEN 'NumberWidget'
                         WHEN t.systagtype = 'Sentiment' THEN 'SentimentWidget'
                         WHEN t.systagtype = 'String' THEN 'StringWidget'
                         WHEN t.systagtype = 'Text' THEN 'MultilineStringWidget'
                         WHEN t.systagtype = 'Time At Task' THEN 'DurationWidget'
                    END AS type,
                    e.systagtype AS reftype,
                    nullif(wr.workresultdefaultvalue, '') AS value,
                    encode(('workresult:' || wr.id || ':' || coalesce(e.systagtype, t.systagtype))::bytea, 'base64') AS id
                FROM public.workresult AS wr
                INNER JOIN public.systag AS t
                    ON wr.workresulttypeid = t.systagid
                LEFT JOIN public.systag AS e
                    ON wr.workresultentitytypeid = e.systagid
                WHERE wr.id = ${id}
            )

            SELECT
                type AS "__typename",
                id,
                value::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'CheckboxWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                value::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'ClickerWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                value::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'DurationWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                value::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'MultilineStringWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                value::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'NumberWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                (
                    SELECT CASE WHEN reftype = 'Location' THEN array['Location']
                                WHEN reftype = 'Worker' THEN array['Worker']
                           END
                ) AS "possibleTypes",
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
                ) AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'ReferenceWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                value::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'SentimentWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                value::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'StringWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                (
                    SELECT row_to_json(t)
                    FROM (
                       VALUES (
                          'Instant',
                          value::text
                       )
                    ) t ("__typename", "epochMilliseconds")
                    WHERE value IS NOT null
                ) AS temporal
            FROM cte
            WHERE type = 'TemporalWidget'
        `,
      )
      .with(
        "workresultinstance",
        () => sql<[ResolversTypes["Widget"]]>`
            WITH cte AS (
                SELECT
                    CASE WHEN t.systagtype = 'Boolean' THEN 'Boolean'
                         WHEN t.systagtype = 'Clicker' THEN 'ClickerWidget'
                         WHEN t.systagtype = 'Date' THEN 'TemporalWidget'
                         WHEN t.systagtype = 'Duration' THEN 'DurationWidget'
                         WHEN t.systagtype = 'Entity' THEN 'ReferenceWidget'
                         WHEN t.systagtype = 'Geolocation' THEN 'StringWidget'
                         WHEN t.systagtype = 'Number' THEN 'NumberWidget'
                         WHEN t.systagtype = 'Sentiment' THEN 'SentimentWidget'
                         WHEN t.systagtype = 'String' THEN 'StringWidget'
                         WHEN t.systagtype = 'Text' THEN 'MultilineStringWidget'
                         WHEN t.systagtype = 'Time At Task' THEN 'DurationWidget'
                    END AS type,
                    e.systagtype AS reftype,
                    nullif(wri.workresultinstancevalue, '') AS value,
                    encode(('workresultinstance:' || wri.id || ':' || coalesce(e.systagtype, t.systagtype))::bytea, 'base64') AS id
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
                type AS "__typename",
                id,
                value::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'CheckboxWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                value::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'ClickerWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                value::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'DurationWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                value::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'MultilineStringWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                value::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'NumberWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                (
                    SELECT CASE WHEN reftype = 'Location' THEN array['Location']
                                WHEN reftype = 'Worker' THEN array['Worker']
                           END
                ) AS "possibleTypes",
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
                ) AS ref,
                null::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'ReferenceWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                value::int AS sentiment,
                null::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'SentimentWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                value::text AS string,
                null::json AS temporal
            FROM cte
            WHERE type = 'StringWidget'
            UNION ALL
            SELECT
                type AS "__typename",
                id,
                null::boolean AS checked,
                null::int AS count,
                null::int AS duration,
                null::text AS text,
                null::int AS number,
                null::text[] AS "possibleTypes",
                null::json AS ref,
                null::int AS sentiment,
                null::text AS string,
                (
                    SELECT row_to_json(t)
                    FROM (
                       VALUES (
                          'Instant',
                          value::text
                       )
                    ) t ("__typename", "epochMilliseconds")
                    WHERE value IS NOT null
                ) AS temporal
            FROM cte
            WHERE type = 'TemporalWidget'
        `,
      )
      .otherwise(() => Promise.reject("invariant violated"));

    if (!row) {
      console.warn({ type, id });
    }
    return row;
  },
};
