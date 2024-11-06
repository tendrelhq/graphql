import { join, sql } from "@/datasources/postgres";
import type {
  ChecklistResultResolvers,
  PageInfo,
  ResolversTypes,
} from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { buildPaginationArgs } from "@/util";
import { match } from "ts-pattern";

export const ChecklistResult: ChecklistResultResolvers = {
  active(parent, _, ctx) {
    return ctx.orm.active.load(parent.id);
  },
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
  async attachments(parent, args) {
    const { type, id, suffix } = decodeGlobalId(parent.id);

    if (type !== "workresultinstance") {
      return {
        edges: [],
        pageInfo: {
          hasNextPage: false,
          hasPreviousPage: false,
        },
        totalCount: 0,
      };
    }

    if (!suffix?.length) {
      /*
       * Remember our global id format here is:
       * workresultinstance:<workinstance.id>:<workresult.id>
       *                id: ^^^^^^^^^^^^^^^^^
       *                           suffix[0]: ^^^^^^^^^^^^^^^
       */
      throw "invariant violated";
    }

    const { cursor, direction, limit } = buildPaginationArgs(args, {
      defaultLimit: Number(
        process.env.DEFAULT_ATTACHMENT_PAGINATION_LIMIT ?? 20,
      ),
      maxLimit: Number(process.env.MAX_ATTACHMENT_PAGINATION_LIMIT ?? 20),
    });

    // Our (default) order clause specifies:
    // 1. workpictureinstancemodifieddate DESC
    // 2. workpictureinstanceid DESC
    // So, forward => < implies "recently modified first"
    const cmp = direction === "forward" ? sql`<` : sql`>`;

    // We are operating at the instance level here.
    const rows = await sql<{ id: string }[]>`
      ${
        cursor
          ? sql`
      WITH cursor AS (
          SELECT
              workpictureinstanceid AS id,
              workpictureinstancemodifieddate AS updated_at
          FROM public.workpictureinstance
          WHERE workpictureinstanceuuid = ${cursor.id}
      )`
          : sql``
      }
      SELECT
          encode(('workpictureinstance:' || wpi.workpictureinstanceuuid)::bytea, 'base64') AS id
      FROM public.workpictureinstance AS wpi
      INNER JOIN public.workinstance AS wi
          ON wpi.workpictureinstanceworkinstanceid = workinstanceid
      INNER JOIN public.workresultinstance AS wri
          ON wpi.workpictureinstanceworkresultinstanceid = wri.workresultinstanceid
      INNER JOIN public.workresult AS wr
          ON wri.workresultinstanceworkresultid = wr.workresultid
      ${cursor ? sql`INNER JOIN cursor ON true` : sql``}
      WHERE ${join(
        [
          ...(cursor
            ? [
                sql`(wpi.workpictureinstancemodifieddate, wpi.workpictureinstanceid) ${cmp} (cursor.updated_at, cursor.id)`,
              ]
            : []),
          sql`wi.id = ${id}`,
          sql`wr.id = ${suffix[0]}`,
        ],
        sql`AND`,
      )}
      ORDER BY
          wpi.workpictureinstancemodifieddate DESC,
          wpi.workpictureinstanceid DESC
      LIMIT ${limit + 1};
    `;

    const edges = rows.map(row => ({
      cursor: row.id as string,
      // biome-ignore lint/suspicious/noExplicitAny: defer to Attachment
      node: row as any,
    }));

    const n1 = edges.length >= limit + 1 ? edges.pop() : undefined;

    const pageInfo: PageInfo = {
      startCursor: edges.at(0)?.cursor,
      endCursor: edges.at(-1)?.cursor,
      hasNextPage: direction === "forward" && !!n1,
      hasPreviousPage: direction === "backward" && !!n1,
    };

    const [{ count }] = await sql`
      SELECT count(*)
      FROM public.workpictureinstance AS wpi
      INNER JOIN public.workinstance AS wi
          ON wpi.workpictureinstanceworkinstanceid = workinstanceid
      INNER JOIN public.workresultinstance AS wri
          ON wpi.workpictureinstanceworkresultinstanceid = wri.workresultinstanceid
      INNER JOIN public.workresult AS wr
          ON wri.workresultinstanceworkresultid = wr.workresultid
      WHERE
          wi.id = ${id}
          AND wr.id = ${suffix[0]}
    `;

    return {
      edges,
      pageInfo,
      totalCount: count,
    };
  },
  auditable(parent, _, ctx) {
    return ctx.orm.auditable.load(parent.id);
  },
  async order(parent) {
    const { id, type, suffix } = decodeGlobalId(parent.id);

    switch (type) {
      case "workresult": {
        const [row] = await sql<[{ order: number }]>`
            SELECT workresultorder AS order
            FROM public.workresult
            WHERE id = ${id}
        `;
        return row.order;
      }
      case "workresultinstance": {
        if (!suffix?.length) {
          console.warn(
            "Invalid global id for underlying type 'workresultinstance'. Expected it to be of the form `workresultinstance:<workinstanceid>:<workresultid>`, but no <workresultid> was found.",
          );
          throw "invariant violated";
        }
        const [row] = await sql<[{ order: number }]>`
            SELECT workresultorder AS order
            FROM public.workresult
            WHERE id = ${suffix[0]}
        `;
        return row.order;
      }
    }

    throw "invariant violated";
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
    const { type, id, suffix } = decodeGlobalId(parent.id);
    // Note that currently we treat the following as "unknown":
    // - Calculated
    // - Geolocation
    // - List
    // - Payload
    // - Photo
    //
    // Unknown types are eventually dropped.
    //
    // The following "Result Type"s are deprecated in favor of widget types:
    // - Clicker -> Number (deprecated; use widget type)
    // - Sentiment -> Number (deprecated; use widget type)
    // - Text -> String (deprecated; use widget type)
    // - Time at Task -> Duration (deprecated; use widget type)
    const [row] = await sql<[ResolversTypes["Widget"]]>`
        WITH cte AS (
        ${match(type)
          .with(
            "workresult",
            () => sql`
              SELECT
                  CASE WHEN dt.systagtype = 'Boolean' THEN 'BooleanWidget'
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
                       WHEN wt.custagtype = 'Checkbox' THEN 'CheckboxWidget'
                       WHEN wt.custagtype = 'Section' THEN 'SectionWidget'
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
                  CASE WHEN dt.systagtype = 'Boolean' THEN 'BooleanWidget'
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
                       WHEN wt.custagtype = 'Checkbox' THEN 'CheckboxWidget'
                       WHEN wt.custagtype = 'Section' THEN 'SectionWidget'
                       ELSE null
                  END AS widget_type,
                  nullif(wri.workresultinstancevalue, '') AS raw_value,
                  encode(('workresultinstance:' || wi.id || ':' || wr.id || ':' || coalesce(rt.systagtype, dt.systagtype))::bytea, 'base64') AS id
              FROM public.workinstance AS wi
              INNER JOIN public.workresult AS wr
                  ON wi.workinstanceworktemplateid = wr.workresultworktemplateid
              LEFT JOIN public.workresultinstance AS wri
                  ON wi.workinstanceid = wri.workresultinstanceworkinstanceid
                  AND wr.workresultid = wri.workresultinstanceworkresultid
              INNER JOIN public.systag AS dt
                  ON wr.workresulttypeid = dt.systagid
              LEFT JOIN public.systag AS rt
                  ON wr.workresultentitytypeid = rt.systagid
              LEFT JOIN public.custag AS wt
                  ON wr.workresultwidgetid = wt.custagid
              WHERE
                  wi.id = ${id}
                  AND wr.id = ${suffix?.at(0) ?? null}
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
            null::decimal AS duration,
            null::int AS number,
            null::text[] AS "possibleTypes",
            null::json AS ref,
            null::text AS string,
            null::json AS temporal
        FROM cte
        WHERE data_type = 'BooleanWidget'
        UNION ALL
        SELECT
            coalesce(widget_type, data_type) AS "__typename",
            id,
            null::boolean AS checked,
            raw_value::decimal AS duration,
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
            null::decimal AS duration,
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
            null::decimal AS duration,
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
            null::decimal AS duration,
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
            null::decimal AS duration,
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
