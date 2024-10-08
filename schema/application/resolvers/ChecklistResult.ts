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
    // Note that currently we treat the following as "unknown":
    // - Calculated
    // - Clicker (deprecated; use widget type)
    // - Geolocation
    // - List
    // - Payload
    // - Photo
    // - Sentiment (deprecated; use widget type)
    // - Time at Task (deprecated; use widget type)
    //
    // Unknown types are eventually dropped.
    const [row] = await sql<[ResolversTypes["Widget"]]>`
        WITH cte AS (
        ${match(type)
          .with(
            "workresult",
            () => sql`
            SELECT
                CASE WHEN dt.systagtype = 'Boolean' THEN 'CheckboxWidget'
                     WHEN dt.systagtype = 'Clicker' THEN 'NumberWidget'
                     WHEN dt.systagtype = 'Date' THEN 'TemporalWidget'
                     WHEN dt.systagtype = 'Duration' THEN 'DurationWidget'
                     WHEN dt.systagtype = 'Entity' THEN 'ReferenceWidget'
                     WHEN dt.systagtype = 'Number' THEN 'NumberWidget'
                     WHEN dt.systagtype = 'Sentiment' THEN 'NumberWidget'
                     WHEN dt.systagtype = 'String' THEN 'StringWidget'
                     WHEN dt.systagtype = 'Text' THEN 'StringWidget'
                     WHEN dt.systagtype = 'Time At Task' THEN 'DurationWidget'
                     ELSE 'Unknown'
                END AS data_type,
                rt.systagtype AS ref_type,
                CASE WHEN wt.custagtype = 'Clicker' THEN 'ClickerWidget'
                     WHEN wt.custagtype = 'Sentiment' THEN 'SentimentWidget'
                     WHEN wt.custagtype = 'Text' THEN 'MultilineStringWidget'
                     ELSE null
                END AS widget_type,
                nullif(wr.workresultdefaultvalue, '') AS raw_value,
                encode(('workresult:' || wr.id || ':' || coalesce(rt.systagtype, dt.systagtype))::bytea, 'base64') AS id
            FROM public.workresult AS wr
            INNER JOIN public.systag AS dt
                ON wr.workresulttypeid = dt.systagid
            LEFT JOIN public.systag AS rt
                ON wr.workresultentitytypeid = rt.systagid
            LEFT JOIN public.custag AS wt
                ON wr.workresultwidgetid = wt.custagid
            WHERE wr.id = ${id}
            `,
          )
          .with(
            "workresultinstance",
            () => sql`
            SELECT
                CASE WHEN dt.systagtype = 'Boolean' THEN 'CheckboxWidget'
                     WHEN dt.systagtype = 'Clicker' THEN 'NumberWidget'
                     WHEN dt.systagtype = 'Date' THEN 'TemporalWidget'
                     WHEN dt.systagtype = 'Duration' THEN 'DurationWidget'
                     WHEN dt.systagtype = 'Entity' THEN 'ReferenceWidget'
                     WHEN dt.systagtype = 'Number' THEN 'NumberWidget'
                     WHEN dt.systagtype = 'Sentiment' THEN 'NumberWidget'
                     WHEN dt.systagtype = 'String' THEN 'StringWidget'
                     WHEN dt.systagtype = 'Text' THEN 'StringWidget'
                     WHEN dt.systagtype = 'Time At Task' THEN 'DurationWidget'
                     ELSE 'Unknown'
                END AS data_type,
                rt.systagtype AS ref_type,
                CASE WHEN wt.custagtype = 'Clicker' THEN 'ClickerWidget'
                     WHEN wt.custagtype = 'Sentiment' THEN 'SentimentWidget'
                     WHEN wt.custagtype = 'Text' THEN 'MultilineStringWidget'
                     ELSE null
                END AS widget_type,
                nullif(wri.workresultinstancevalue, '') AS raw_value,
                encode(('workresultinstance:' || wri.workresultinstanceuuid || ':' || coalesce(rt.systagtype, dt.systagtype))::bytea, 'base64') AS id
            FROM public.workresultinstance AS wri
            INNER JOIN public.workresult AS wr
                ON wri.workresultinstanceworkresultid = wr.workresultid
            INNER JOIN public.systag AS dt
                ON wr.workresulttypeid = dt.systagid
            LEFT JOIN public.systag AS rt
                ON wr.workresultentitytypeid = rt.systagid
            LEFT JOIN public.custag AS wt
                ON wr.workresultwidgetid = wt.custagid
            WHERE wri.workresultinstanceuuid = ${id}
            `,
          )
          .otherwise(() => {
            throw "invariant violated";
          })}
        )

        SELECT
            coalesce(widget_type, data_type) AS "__typename",
            id,
            raw_value::boolean AS checked,
            null::int AS duration,
            null::int AS number,
            null::text[] AS "possibleTypes",
            null::json AS ref,
            null::text AS string,
            null::json AS temporal
        FROM cte
        WHERE data_type = 'CheckboxWidget'
        UNION ALL
        SELECT
            coalesce(widget_type, data_type) AS "__typename",
            id,
            null::boolean AS checked,
            raw_value::int AS duration,
            null::int AS number,
            null::text[] AS "possibleTypes",
            null::json AS ref,
            null::text AS string,
            null::json AS temporal
        FROM cte
        WHERE data_type = 'DurationWidget'
        UNION ALL
        SELECT
            coalesce(widget_type, data_type) AS "__typename",
            id,
            null::boolean AS checked,
            null::int AS duration,
            raw_value::int AS number,
            null::text[] AS "possibleTypes",
            null::json AS ref,
            null::text AS string,
            null::json AS temporal
        FROM cte
        WHERE data_type = 'NumberWidget'
        UNION ALL
        SELECT
            coalesce(widget_type, data_type) AS "__typename",
            id,
            null::boolean AS checked,
            null::int AS duration,
            null::int AS number,
            array[ref_type]::text[] AS "possibleTypes",
            (
                SELECT row_to_json(ref)
                FROM (
                    SELECT
                        'Location' AS "__typename",
                        encode(('location:' || l.locationuuid)::bytea, 'base64') AS id
                    FROM public.location AS l
                    WHERE
                        cte.ref_type = 'Location'
                        AND cte.raw_value::bigint = l.locationid
                    UNION ALL
                    SELECT
                        'Worker' AS "__typename",
                        encode(('worker:' || w.workerinstanceuuid)::bytea, 'base64') AS id
                    FROM public.workerinstance AS w
                    WHERE
                        cte.ref_type = 'Worker'
                        AND cte.raw_value::bigint = w.workerinstanceid
                ) ref
            ) AS ref,
            null::text AS string,
            null::json AS temporal
        FROM cte
        WHERE data_type = 'ReferenceWidget'
        UNION ALL
        SELECT
            coalesce(widget_type, data_type) AS "__typename",
            id,
            null::boolean AS checked,
            null::int AS duration,
            null::int AS number,
            null::text[] AS "possibleTypes",
            null::json AS ref,
            raw_value::text AS string,
            null::json AS temporal
        FROM cte
        WHERE data_type = 'StringWidget'
        UNION ALL
        SELECT
            coalesce(widget_type, data_type) AS "__typename",
            id,
            null::boolean AS checked,
            null::int AS duration,
            null::int AS number,
            null::text[] AS "possibleTypes",
            null::json AS ref,
            null::text AS string,
            (
                SELECT row_to_json(t)
                FROM (
                    SELECT
                        'Instant' AS "__typename",
                        raw_value::text AS "epochMilliseconds"
                ) t
                WHERE raw_value IS NOT null
            ) AS temporal
        FROM cte
        WHERE data_type = 'TemporalWidget'
    `;

    if (!row) {
      console.warn({ type, id });
    }

    return row;
  },
};
