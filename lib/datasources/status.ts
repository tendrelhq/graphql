import type { ID, ResolversTypes } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { sql, unionAll } from "./postgres";

export function makeStatusLoader(_req: Request) {
  return new DataLoader<ID, ResolversTypes["ChecklistStatus"] | undefined>(
    async keys => {
      const entities = keys.map(decodeGlobalId);
      const byUnderlyingType = entities.reduce((acc, { type, id }) => {
        if (!acc.has(type)) acc.set(type, []);
        acc.get(type)?.push(id);
        return acc;
      }, new Map<string, string[]>());

      const qs = [...byUnderlyingType.entries()].flatMap(([type, ids]) =>
        match(type)
          .with(
            "workinstance",
            () => sql`
                WITH cte AS (
                    SELECT
                        wi.id AS _key,
                        encode(('workinstance:' || wi.id || ':status')::bytea, 'base64') AS id,
                        CASE WHEN s.systagtype = 'Open' THEN 'ChecklistOpen'
                             WHEN s.systagtype = 'In Progress' THEN 'ChecklistInProgress'
                             ELSE 'ChecklistClosed'
                        END AS type,
                        wi.workinstancecreateddate AS opendate,
                        wi.workinstancestartdate AS startdate,
                        wi.workinstancecompleteddate AS closeddate,
                        wi.workinstancetargetstartdate AS duedate,
                        wi.workinstancetimezone AS tz
                    FROM public.workinstance AS wi
                    INNER JOIN public.systag AS s
                        ON wi.workinstancestatusid = s.systagid
                    WHERE wi.id IN ${sql(ids)}
                )

                SELECT
                    _key,
                    type AS "__typename",
                    id,
                    (
                        SELECT row_to_json(t)
                        FROM (
                            SELECT
                                'ZonedDateTime' AS "__typename",
                                (extract(epoch from duedate) * 1000)::text AS "epochMilliseconds",
                                tz AS "timeZone"
                            WHERE duedate IS NOT null
                        ) t
                    ) AS "dueAt",
                    (
                        SELECT row_to_json(t)
                        FROM (
                            SELECT
                                'ZonedDateTime' AS "__typename",
                                (extract(epoch from opendate) * 1000)::text AS "epochMilliseconds",
                                tz AS "timeZone"
                        ) t
                    ) AS "openedAt",
                    null::json AS "inProgressAt",
                    null::json AS "closedAt"
                FROM cte
                WHERE type = 'ChecklistOpen'
                UNION ALL
                SELECT
                    _key,
                    type AS "__typename",
                    id,
                    (
                        SELECT row_to_json(t)
                        FROM (
                            SELECT
                                'ZonedDateTime' AS "__typename",
                                (extract(epoch from duedate) * 1000)::text AS "epochMilliseconds",
                                tz AS "timeZone"
                            WHERE duedate IS NOT null
                        ) t
                    ) AS "dueAt",
                    null::json AS "openedAt",
                    (
                        SELECT row_to_json(t)
                        FROM (
                            SELECT
                                'ZonedDateTime' AS "__typename",
                                (extract(epoch from startdate) * 1000)::text AS "epochMilliseconds",
                                tz AS "timeZone"
                        ) t
                    ) AS "inProgressAt",
                    null::json AS "closedAt"
                FROM cte
                WHERE type = 'ChecklistInProgress'
                UNION ALL
                SELECT
                    _key,
                    type AS "__typename",
                    id,
                    (
                        SELECT row_to_json(t)
                        FROM (
                            SELECT
                                'ZonedDateTime' AS "__typename",
                                (extract(epoch from duedate) * 1000)::text AS "epochMilliseconds",
                                tz AS "timeZone"
                            WHERE duedate IS NOT null
                        ) t
                    ) AS "dueAt",
                    null::json AS "openedAt",
                    null::json AS "inProgressAt",
                    (
                        SELECT row_to_json(t)
                        FROM (
                            SELECT
                                'ZonedDateTime' AS "__typename",
                                (extract(epoch from closeddate) * 1000)::text AS "epochMilliseconds",
                                tz AS "timeZone"
                        ) t
                    ) AS "closedAt"
                FROM cte
                WHERE type = 'ChecklistClosed'
            `,
          )
          .with(
            "workresultinstance",
            () => sql`
                WITH cte AS (
                    SELECT
                        wri.workresultinstanceuuid AS _key,
                        encode(('workresultinstance:' || wri.workresultinstanceuuid || ':status')::bytea, 'base64') AS id,
                        CASE WHEN s.systagtype = 'Open' THEN 'ChecklistOpen'
                             WHEN s.systagtype = 'In Progress' THEN 'ChecklistInProgress'
                             ELSE 'ChecklistClosed'
                        END AS type,
                        wri.workresultinstancecreateddate AS opendate,
                        wri.workresultinstancestartdate AS startdate,
                        wri.workresultinstancecompleteddate AS closeddate,
                        null::timestamp AS duedate,
                        wi.workinstancetimezone AS tz
                    FROM public.workresultinstance AS wri
                    INNER JOIN public.workinstance AS wi
                        ON wri.workresultinstanceworkinstanceid = wi.workinstanceid
                    INNER JOIN public.systag AS s
                        ON wri.workresultinstancestatusid = s.systagid
                    WHERE wri.workresultinstanceuuid IN ${sql(ids)}
                )

                SELECT
                    _key,
                    type AS "__typename",
                    id,
                    null::json AS "dueAt",
                    (
                        SELECT row_to_json(t)
                        FROM (
                            SELECT
                                'ZonedDateTime' AS "__typename",
                                (extract(epoch from opendate) * 1000)::text AS "epochMilliseconds",
                                tz AS "timeZone"
                        ) t
                    ) AS "openedAt",
                    null::json AS "inProgressAt",
                    null::json AS "closedAt"
                FROM cte
                WHERE type = 'ChecklistOpen'
                UNION ALL
                SELECT
                    _key,
                    type AS "__typename",
                    id,
                    null::json AS "dueAt",
                    null::json AS "openedAt",
                    (
                        SELECT row_to_json(t)
                        FROM (
                            SELECT
                                'ZonedDateTime' AS "__typename",
                                (extract(epoch from startdate) * 1000)::text AS "epochMilliseconds",
                                tz AS "timeZone"
                        ) t
                    ) AS "inProgressAt",
                    null::json AS "closedAt"
                FROM cte
                WHERE type = 'ChecklistInProgress'
                UNION ALL
                SELECT
                    _key,
                    type AS "__typename",
                    id,
                    null::json AS "dueAt",
                    null::json AS "openedAt",
                    null::json AS "inProgressAt",
                    (
                        SELECT row_to_json(t)
                        FROM (
                            SELECT
                                'ZonedDateTime' AS "__typename",
                                (extract(epoch from closeddate) * 1000)::text AS "epochMilliseconds",
                                tz AS "timeZone"
                        ) t
                    ) AS "closedAt"
                FROM cte
                WHERE type = 'ChecklistClosed'
            `,
          )
          .otherwise(() => []),
      );

      if (!qs.length) return entities.map(() => undefined);

      type X = WithKey<ResolversTypes["ChecklistStatus"]>;
      const xs = await sql<X[]>`${unionAll(qs)}`;
      return entities.map(e => xs.find(x => e.id === x._key));
    },
  );
}
