import type { ID, ResolversTypes } from "@/schema";
import { type GlobalId, decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { sql, unionAll } from "./postgres";

function buildTemporalFragment(from: string) {
  return sql`(
      SELECT jsonb_build_object(
          '__typename',
          'ZonedDateTime',
          'epochMilliseconds',
          (extract(epoch from ${sql(from)}) * 1000)::text,
          'timeZone',
          tz
      )
      WHERE ${sql(from)} IS NOT null
  )`;
}

export function makeStatusLoader(_req: Request) {
  return new DataLoader<ID, ResolversTypes["ChecklistStatus"] | undefined>(
    async keys => {
      const entities = keys.map(decodeGlobalId);
      const byUnderlyingType = entities.reduce((acc, { type, ...ids }) => {
        if (!acc.has(type)) acc.set(type, []);
        acc.get(type)?.push(ids);
        return acc;
      }, new Map<string, Omit<GlobalId, "type">[]>());

      const qs = [...byUnderlyingType.entries()].flatMap(([type, ids]) =>
        match(type)
          .with(
            "workinstance",
            () => sql`
              (
                WITH cte AS (
                    SELECT
                        wi.id AS _key,
                        CASE WHEN s.systagtype = 'Open' THEN 'ChecklistOpen'
                             WHEN s.systagtype = 'In Progress' THEN 'ChecklistInProgress'
                             ELSE 'ChecklistClosed'
                        END AS type,
                        wi.workinstancecreateddate AS opened_at,
                        wi.workinstancestartdate AS in_progress_at,
                        CASE WHEN s.systagtype = 'Cancelled' THEN jsonb_build_object('code', 'cancel')
                             ELSE null
                        END AS closed_because,
                        wi.workinstancecompleteddate AS closed_at,
                        wi.workinstancetargetstartdate AS due_at,
                        wi.workinstancetimezone AS tz
                    FROM public.workinstance AS wi
                    INNER JOIN public.systag AS s
                        ON wi.workinstancestatusid = s.systagid
                    WHERE wi.id IN ${sql(ids.map(i => i.id))}
                )

                SELECT
                    _key,
                    type AS "__typename",
                    ${buildTemporalFragment("due_at")}::json AS "dueAt",
                    ${buildTemporalFragment("opened_at")}::json AS "openedAt",
                    null::json AS "inProgressAt",
                    null::json AS "closedAt",
                    null::json AS "closedBecause"
                FROM cte
                WHERE type = 'ChecklistOpen'
                UNION ALL
                SELECT
                    _key,
                    type AS "__typename",
                    ${buildTemporalFragment("due_at")}::json AS "dueAt",
                    ${buildTemporalFragment("opened_at")}::json AS "openedAt",
                    ${buildTemporalFragment("in_progress_at")}::json AS "inProgressAt",
                    null::json AS "closedAt",
                    null::json AS "closedBecause"
                FROM cte
                WHERE type = 'ChecklistInProgress'
                UNION ALL
                SELECT
                    _key,
                    type AS "__typename",
                    ${buildTemporalFragment("due_at")}::json AS "dueAt",
                    ${buildTemporalFragment("opened_at")}::json AS "openedAt",
                    ${buildTemporalFragment("in_progress_at")}::json AS "inProgressAt",
                    ${buildTemporalFragment("closed_at")}::json AS "closedAt",
                    closed_because::json AS "closedBecause"
                FROM cte
                WHERE type = 'ChecklistClosed'
              )
            `,
          )
          .with(
            "workresultinstance",
            () => sql`
              (
                WITH cte AS (
                    SELECT
                        (wi.id || ':' || wr.id) AS _key,
                        CASE WHEN s.systagtype = 'Open' THEN 'ChecklistOpen'
                             WHEN s.systagtype = 'In Progress' THEN 'ChecklistInProgress'
                             ELSE 'ChecklistClosed'
                        END AS type,
                        wri.workresultinstancecreateddate AS opened_at,
                        wri.workresultinstancestartdate AS in_progress_at,
                        wri.workresultinstancecompleteddate AS closed_at,
                        null::timestamp AS due_at,
                        wi.workinstancetimezone AS tz
                    FROM public.workresultinstance AS wri
                    INNER JOIN public.workinstance AS wi
                        ON wri.workresultinstanceworkinstanceid = wi.workinstanceid
                    INNER JOIN public.workresult AS wr
                        ON wri.workresultinstanceworkresultid = wr.workresultid
                    INNER JOIN public.systag AS s
                        ON wri.workresultinstancestatusid = s.systagid
                    WHERE
                        (wi.id, wr.id) IN ${sql(ids.map(i => sql([i.id, i.suffix?.at(0) ?? ""])))}
                )

                SELECT
                    _key,
                    type AS "__typename",
                    null::json AS "dueAt",
                    ${buildTemporalFragment("opened_at")}::json AS "openedAt",
                    null::json AS "inProgressAt",
                    null::json AS "closedAt",
                    null::json AS "closedBecause"
                FROM cte
                WHERE type = 'ChecklistOpen'
                UNION ALL
                SELECT
                    _key,
                    type AS "__typename",
                    null::json AS "dueAt",
                    ${buildTemporalFragment("opened_at")}::json AS "openedAt",
                    ${buildTemporalFragment("in_progress_at")}::json AS "inProgressAt",
                    null::json AS "closedAt",
                    null::json AS "closedBecause"
                FROM cte
                WHERE type = 'ChecklistInProgress'
                UNION ALL
                SELECT
                    _key,
                    type AS "__typename",
                    null::json AS "dueAt",
                    ${buildTemporalFragment("opened_at")}::json AS "openedAt",
                    ${buildTemporalFragment("in_progress_at")}::json AS "inProgressAt",
                    ${buildTemporalFragment("closed_at")}::json AS "closedAt",
                    null::json AS "closedBecause"
                FROM cte
                WHERE type = 'ChecklistClosed'
              )
            `,
          )
          .otherwise(() => []),
      );

      if (!qs.length) return entities.map(() => undefined);

      type X = WithKey<ResolversTypes["ChecklistStatus"]>;
      const xs = await sql<X[]>`${unionAll(qs)}`;
      return entities.map(e => {
        const key = [e.id, ...(e.suffix ?? [])].join(":");
        return xs.find(x => x._key === key);
      });
    },
  );
}
