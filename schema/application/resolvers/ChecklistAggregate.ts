import { join, sql } from "@/datasources/postgres";
import type { ChecklistAggregateResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { map } from "@/util";
import { Temporal } from "@js-temporal/polyfill";
import { match } from "ts-pattern";

export const ChecklistAggregate: ChecklistAggregateResolvers = {
  async assignedTo(_, args) {
    const { type, id } = decodeGlobalId(args.parent);

    const assignees = args.assignees.map(e => decodeGlobalId(e).id);

    const [{ count }] = await match(type)
      .with(
        "organization",
        () => sql<[{ count: number }]>`
          SELECT count(*)
          FROM public.workresultinstance AS wri
          INNER JOIN public.workresult AS wr
              ON
                  wri.workresultinstanceworkresultid = wr.workresultid
                  AND wr.workresultentitytypeid = 850
                  AND wr.workresultisprimary
          INNER JOIN public.worktemplatetype AS wtt
              ON wr.workresultworktemplateid = wtt.worktemplatetypeworktemplateid
          INNER JOIN public.systag AS s
              ON wtt.worktemplatetypesystaguuid = s.systaguuid
          WHERE
              s.systagtype = 'Checklist'
              AND workresultinstancecustomerid IN (
                  SELECT c.customerid
                  FROM public.customer AS c
                  WHERE c.customeruuid = ${id}
              )
              AND workresultinstancevalue IN (
                  SELECT w.workerinstanceid::text
                  FROM public.workerinstance AS w
                  WHERE w.workerinstanceuuid IN ${sql(assignees)}
              );
        `,
      )
      .with(
        "worktemplate",
        () => sql<[{ count: number }]>`
          SELECT count(*)
          FROM public.workresultinstance AS wri
          INNER JOIN public.workresult AS wr
              ON
                  wri.workresultinstanceworkresultid = wr.workresultid
                  AND wr.workresultentitytypeid = 850
                  AND wr.workresultisprimary
          INNER JOIN public.worktemplate AS wt
              ON wr.workresultworktemplateid = wt.worktemplateid
          WHERE
              wt.id = ${id}
              AND workresultinstancevalue IN (
                  SELECT w.workerinstanceid::text
                  FROM public.workerinstance AS w
                  WHERE w.workerinstanceuuid IN ${sql(assignees)}
              );
        `,
      )
      .otherwise(() => [{ count: 0 }]);

    return count;
  },
  async dueOn(_, args) {
    const { type, id } = decodeGlobalId(args.parent);

    const before = map(args.input.before, input => {
      switch (true) {
        case "instant" in input:
          return Temporal.Instant.fromEpochMilliseconds(Number(input.instant));
        case "zdt" in input:
          return Temporal.Instant.fromEpochMilliseconds(
            Number(input.zdt.epochMilliseconds),
          ).toZonedDateTimeISO(input.zdt.timeZone);
        default: {
          const _: never = input;
          return null;
        }
      }
    })?.toString({ calendarName: "never", timeZoneName: "never" });

    const after = map(args.input.after, input => {
      switch (true) {
        case "instant" in input:
          return Temporal.Instant.fromEpochMilliseconds(Number(input.instant));
        case "zdt" in input:
          return Temporal.Instant.fromEpochMilliseconds(
            Number(input.zdt.epochMilliseconds),
          ).toZonedDateTimeISO(input.zdt.timeZone);
        default: {
          const _: never = input;
          return null;
        }
      }
    })?.toString({ calendarName: "never", timeZoneName: "never" });

    if (!after && !before) return 0;

    const [{ count }] = await match(type)
      .with(
        "organization",
        () => sql<[{ count: number }]>`
          SELECT count(*)
          FROM public.workinstance
          WHERE
              workinstancecustomerid IN (
                  SELECT customerid
                  FROM public.customer
                  WHERE customeruuid = ${id}
              )
              AND ${join(
                [
                  sql`workinstancetargetstartdate IS NOT null`,
                  ...(after
                    ? [sql`workinstancetargetstartdate > ${after}`]
                    : []),
                  ...(before
                    ? [sql`workinstancetargetstartdate < ${before}`]
                    : []),
                ],
                sql`AND`,
              )}
        `,
      )
      .with(
        "worktemplate",
        () => sql<[{ count: number }]>`
          SELECT count(*)
          FROM public.workinstance
          WHERE
              workinstanceworktemplateid IN (
                  SELECT wt.worktemplateid
                  FROM public.worktemplate AS wt
                  WHERE wt.id = ${id}
              )
              AND ${join(
                [
                  sql`workinstancetargetstartdate IS NOT null`,
                  ...(after
                    ? [sql`workinstancetargetstartdate > ${after}`]
                    : []),
                  ...(before
                    ? [sql`workinstancetargetstartdate < ${before}`]
                    : []),
                ],
                sql`AND`,
              )}
        `,
      )
      .otherwise(() => [{ count: 0 }]);

    return count;
  },
};
