import { join, sql } from "@/datasources/postgres";
import type { ChecklistAggregateResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { map } from "@/util";
import { Temporal } from "@js-temporal/polyfill";

export const ChecklistAggregate: ChecklistAggregateResolvers = {
  async assignedTo(_, args) {
    const { type, id } = decodeGlobalId(args.parent);
    // TODO: switch on parent type

    const assignees = args.assignees.map(e => decodeGlobalId(e).id);
    const [{ count }] = await sql<[{ count: number }]>`
        SELECT count(*)
        FROM public.workresultinstance
        INNER JOIN public.workresult
            ON
                workresultinstanceworkresultid = workresultid
                AND workresultentitytypeid = 850
                AND workresultisprimary
        WHERE
            workresultinstancecustomerid IN (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${id}
            )
            AND workresultinstancevalue IN (
                SELECT workerinstanceid::text
                FROM public.workerinstance
                WHERE id IN ${sql(assignees)}
            )
    `;

    return { count: count };
  },
  async dueOn(_, args) {
    const { type, id } = decodeGlobalId(args.parent);
    console.log("parent", { type, id });
    // TODO: switch on parent type

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
          throw "invariant violated";
        }
      }
    });

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
          throw "invariant violated";
        }
      }
    });

    if (!after && !before) return { count: 0 };

    const [{ count }] = await sql<[{ count: number }]>`
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
                  ? [
                      sql`workinstancetargetstartdate > ${after.toString({ calendarName: "never", timeZoneName: "never" })}`,
                    ]
                  : []),
                ...(before
                  ? [
                      sql`workinstancetargetstartdate < ${before.toString({ calendarName: "never", timeZoneName: "never" })}`,
                    ]
                  : []),
              ],
              sql`AND`,
            )}
    `;

    return { count: count };
  },
};
