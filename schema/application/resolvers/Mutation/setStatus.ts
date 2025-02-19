import { join, sql } from "@/datasources/postgres";
import type { MutationResolvers, TemporalInput } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { Temporal } from "@js-temporal/polyfill";
import { GraphQLError } from "graphql";
import { match } from "ts-pattern";
import { copyFromWorkInstance } from "./copyFrom";

function temporalInputToTimestamptz(input: TemporalInput) {
  if (input.zdt) {
    return (
      Temporal.Instant
        //
        .fromEpochMilliseconds(Number(input.zdt.epochMilliseconds))
        .toZonedDateTimeISO(input.zdt.timeZone)
        .toString({ calendarName: "never", timeZoneName: "never" })
    );
  }
  return (
    Temporal.Instant
      //
      .fromEpochMilliseconds(Number(input.instant))
      .toString()
  );
}

export const setStatus: NonNullable<MutationResolvers["setStatus"]> = async (
  _,
  { entity, parent, input },
  ctx,
) => {
  const { type, id, suffix } = decodeGlobalId(entity);

  if (type !== "workinstance" && type !== "workresultinstance") {
    throw new GraphQLError("Entity cannot have its status changed", {
      extensions: {
        code: "E_INVALID_STATE_CHANGE",
      },
    });
  }

  const targetStatus = (() => {
    switch (true) {
      case "open" in input:
        return "Open";
      case "inProgress" in input:
        return "In Progress";
      case "closed" in input:
        return input.closed.because?.code === "cancel"
          ? "Cancelled"
          : "Complete";
      default: {
        const _: never = input;
        throw "invariant violated";
      }
    }
  })();

  const targetDate = temporalInputToTimestamptz(
    (() => {
      if (input.open) return input.open.at;
      if (input.inProgress) return input.inProgress.at;
      return input.closed.at;
    })(),
  );

  const result = await match(type)
    .with("workinstance", () => {
      const updates = {
        workinstancestatusid: sql`inputs.status`,
        workinstancemodifieddate: sql`now()`,
        workinstancemodifiedby: sql`auth.current_identity(workinstancecustomerid, ${ctx.auth.userId})`,
        workinstancestartdate: match(targetStatus)
          .with("In Progress", () => targetDate)
          .with("Open", () => sql`NULL`)
          .otherwise(
            // Coalesce in case where we are going Open -> Complete
            () => sql`coalesce(workinstancestartdate, ${targetDate})`,
          ),
        workinstancecompleteddate: match(targetStatus)
          .with("Cancelled", () => targetDate)
          .with("Complete", () => targetDate)
          .otherwise(() => sql`NULL`),
      };

      const columns = [
        "workinstancemodifieddate" as const,
        "workinstancemodifiedby" as const,
        "workinstancestatusid" as const,
        "workinstancestartdate" as const,
        "workinstancecompleteddate" as const,
      ];

      const filters = [
        sql`id = ${id}`,
        sql`workinstancestatusid IS DISTINCT FROM inputs.status`,
      ];

      return sql.begin(async sql => {
        const r = await sql`
          WITH inputs AS (
              SELECT systagid AS status
              FROM public.systag
              WHERE
                  systagparentid = 705
                  AND systagtype = ${targetStatus}
          )

          UPDATE public.workinstance
          SET ${sql(updates, columns)}
          FROM inputs
          WHERE ${join(filters, sql`AND`)};
        `;

        // HACK: Automatically assign the instance to the currently
        // authenticated identity it is otherwise unassigned.
        if (targetStatus === "In Progress" || targetStatus === "Complete") {
          const result = await sql`
            with cte as (
                select
                    wi.workinstancecustomerid as customerid,
                    wi.workinstanceid,
                    wr.workresultid,
                    auth.current_identity(wi.workinstancecustomerid, ${ctx.auth.userId}) as _modified_by
                from public.workinstance as wi
                inner join public.workresult as wr
                    on wi.workinstanceworktemplateid = wr.workresultworktemplateid
                    and wr.workresulttypeid = 848
                    and wr.workresultentitytypeid = 850
                    and wr.workresultisprimary = true
                where wi.id = ${id}
            )

            update workresultinstance as t
            set workresultinstancevalue = cte._modified_by::text,
                workresultinstancemodifieddate = now(),
                workresultinstancemodifiedby = cte._modified_by
            from cte
            where
                t.workresultinstanceworkinstanceid = cte.workinstanceid
                and t.workresultinstanceworkresultid = cte.workresultid
                and t.workresultinstancevalue is null
          `;
          console.log(`Auto assign? ${!!result.count}`);
        }

        if (targetStatus === "Complete") {
          // Record Time at Task, if it exists.
          const result = await sql`
            INSERT INTO public.workresultinstance AS wri (
                workresultinstancecustomerid,
                workresultinstanceworkresultid,
                workresultinstanceworkinstanceid,
                workresultinstancestatusid,
                workresultinstancestartdate,
                workresultinstancecompleteddate,
                workresultinstancevalue,
                workresultinstancemodifiedby
            )
            SELECT
                wr.workresultcustomerid,
                wr.workresultid,
                wi.workinstanceid,
                status.systagid,
                coalesce(wi.workinstancestartdate, ${targetDate}),
                ${targetDate},
                trunc(
                  extract(epoch from (${targetDate}::timestamptz - coalesce(wi.workinstancestartdate, ${targetDate}::timestamptz))),
                  3
                )::text,
                auth.current_identity(wi.workinstancecustomerid, ${ctx.auth.userId})
            FROM public.workinstance AS wi
            INNER JOIN public.workresult AS wr
                ON wi.workinstanceworktemplateid = wr.workresultworktemplateid
                AND wr.workresulttypeid = 737
            INNER JOIN public.systag AS status
                ON status.systagparentid = 965
                AND status.systagtype = 'Complete'
            WHERE
                wi.id = ${id}
            ON CONFLICT (workresultinstanceworkresultid, workresultinstanceworkinstanceid)
            DO UPDATE
                SET
                    workresultinstancemodifiedby = EXCLUDED.workresultinstancemodifiedby,
                    workresultinstancemodifieddate = now(),
                    workresultinstancestatusid = EXCLUDED.workresultinstancestatusid,
                    workresultinstancestartdate = EXCLUDED.workresultinstancestartdate,
                    workresultinstancecompleteddate = EXCLUDED.workresultinstancecompleteddate,
                    workresultinstancevalue = EXCLUDED.workresultinstancevalue
          `;
          console.debug(`Wrote TAT? ${!!result.count}`);

          // Ensure all results have been instantiated. This is currently a
          // datawarehouse invariant. All hail!
          // Note our usage of `on conflict do nothing` (last line) to "skip"
          // workresultinstances that already exist. Note also that we do not
          // set workresultinstancestatusid as this has semantic meaning. For
          // example in the checklist case status indicates completion.
          const results = await sql`
            insert into public.workresultinstance (
                workresultinstancecustomerid,
                workresultinstanceworkresultid,
                workresultinstanceworkinstanceid,
                workresultinstancestartdate,
                workresultinstancecompleteddate,
                workresultinstancevalue,
                workresultinstancemodifiedby
            )
            select
                wi.workinstancecustomerid,
                wr.workresultid,
                wi.workinstanceid,
                now(),
                now(),
                wr.workresultdefaultvalue,
                auth.current_identity(wi.workinstancecustomerid, ${ctx.auth.userId})
            from public.workinstance as wi
            inner join public.workresult as wr
                on wi.workinstanceworktemplateid = wr.workresultworktemplateid
                and (wr.workresultenddate is null or wr.workresultenddate > now())
            where wi.id = ${id}
            on conflict do nothing
            ;
          `;
          if (results.count) {
            console.debug(
              `Lazily instantiated ${results.count} result(s) for ${entity} (${type}:${id})`,
            );
          }
        }

        if (targetStatus === "In Progress") {
          await sql`select * from auth.set_actor(${ctx.auth.userId}, ${ctx.req.i18n.language})`;
          // This is the "respawn" case: create an entirely new chain of work.
          await copyFromWorkInstance(
            sql,
            id,
            {
              // The options are:,
              chain: undefined,
            },
            ctx,
          );
        }

        return r;
      });
    })
    .with("workresultinstance", () => {
      const targetDate = temporalInputToTimestamptz(
        (() => {
          if (input.open) return input.open.at;
          if (input.inProgress) return input.inProgress.at;
          return input.closed.at;
        })(),
      );

      const updates = {
        workresultinstancestatusid: sql`EXCLUDED.workresultinstancestatusid`,
        workresultinstancemodifieddate: sql`EXCLUDED.workresultinstancemodifieddate`,
        workresultinstancemodifiedby: sql`EXCLUDED.workresultinstancemodifiedby`,
        workresultinstancecompleteddate: sql`EXCLUDED.workresultinstancecompleteddate`,
        workresultinstancestartdate: sql`EXCLUDED.workresultinstancestartdate`,
      };

      const columns = [
        "workresultinstancemodifieddate" as const,
        "workresultinstancemodifiedby" as const,
        "workresultinstancestatusid" as const,
        "workresultinstancestartdate" as const,
        "workresultinstancecompleteddate" as const,
      ];

      if (!suffix?.length) {
        console.warn(
          "Invalid global id for underlying type 'workresultinstance'. Expected it to be of the form `workresultinstance:<workinstanceid>:<workresultid>`, but no <workresultid> was found.",
        );
        throw "invariant violated";
      }

      if (targetStatus === "In Progress") {
        throw new GraphQLError("Invalid status change", {
          extensions: {
            code: "E_INVALID_STATE_CHANGE",
          },
        });
      }

      return sql`
          WITH inputs AS (
              SELECT systagid AS status
              FROM public.systag
              WHERE
                  systagparentid = 965
                  AND
                  systagtype = ${targetStatus}
          )

          INSERT INTO public.workresultinstance AS wri (
              workresultinstancecustomerid,
              workresultinstanceworkresultid,
              workresultinstanceworkinstanceid,
              workresultinstancestatusid,
              workresultinstancestartdate,
              workresultinstancecompleteddate,
              workresultinstancemodifiedby
          )
          SELECT
              wi.workinstancecustomerid,
              wr.workresultid,
              wi.workinstanceid,
              inputs.status,
              ${targetStatus === "Open" ? sql`NULL` : sql`coalesce(wi.workinstancestartdate, ${targetDate})`},
              ${targetStatus === "Open" ? sql`NULL` : targetDate},
              auth.current_identity(wi.workinstancecustomerid, ${ctx.auth.userId})
          FROM
              inputs,
              public.workinstance AS wi,
              public.workresult AS wr
          WHERE
              wi.id = ${id}
              AND wr.id = ${suffix[0]}
          ON CONFLICT (workresultinstanceworkresultid, workresultinstanceworkinstanceid)
          DO UPDATE
              SET ${sql(updates, columns)}
              WHERE wri.workresultinstancestatusid IS DISTINCT FROM EXCLUDED.workresultinstancestatusid
      `;
    })
    .exhaustive();

  console.log(
    `Applied ${result.count} update(s) to Entity ${entity} (${type}:${id})`,
  );

  switch (type) {
    case "workinstance":
      return {
        __typename: "SetChecklistStatusPayload",
        delta: result.count,
        edge: {
          cursor: entity,
          node: {
            __typename: "Checklist",
            id: entity,
            // biome-ignore lint/suspicious/noExplicitAny:
          } as any,
        },
      };
    case "workresultinstance":
      return {
        __typename: "SetChecklistItemStatusPayload",
        delta: result.count,
        edge: {
          cursor: entity,
          node: {
            __typename: "ChecklistResult",
            id: entity,
            // biome-ignore lint/suspicious/noExplicitAny:
          } as any,
        },
        parent: {
          __typename: "Checklist",
          id: parent,
          // biome-ignore lint/suspicious/noExplicitAny:
        } as any,
      };
    default: {
      const _: never = type;
      throw "invariant violated";
    }
  }
};
