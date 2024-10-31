import { join, sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";
import { match } from "ts-pattern";
import { copyFromWorkInstance } from "./copyFrom";

export const setStatus: NonNullable<MutationResolvers["setStatus"]> = async (
  _,
  { entity, parent, input },
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
        return "Complete";
      default: {
        const _: never = input;
        throw "invariant violated";
      }
    }
  })();

  const result = await match(type)
    .with("workinstance", () => {
      const updates = {
        workinstancestatusid: sql`inputs.status`,
        workinstancemodifieddate: sql`now()`,
        workinstancestartdate: match(targetStatus)
          .with("In Progress", () => sql`now()`)
          .otherwise(() => sql`NULL`),
        workinstancecompleteddate: match(targetStatus)
          .with("Complete", () => sql`now()`)
          .otherwise(() => sql`NULL`),
      };

      const columns = [
        "workinstancemodifieddate" as const,
        "workinstancestatusid" as const,
        ...match(targetStatus)
          .with("Open", () => [
            "workinstancestartdate" as const,
            "workinstancecompleteddate" as const,
          ])
          .with("In Progress", () => [
            "workinstancestartdate" as const,
            "workinstancecompleteddate" as const,
          ])
          .with("Complete", () => ["workinstancecompleteddate" as const])
          .exhaustive(),
      ];

      const filters = [
        sql`id = ${id}`,
        sql`workinstancestatusid IS DISTINCT FROM inputs.status`,
      ];

      return sql.begin(async tx => {
        const r = await tx`
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

        if (targetStatus === "In Progress") {
          // HACK: this is "running the rules engine" for now lmao.
          await copyFromWorkInstance(tx, id, {});
        }

        return r;
      });
    })
    .with("workresultinstance", () => {
      const updates = {
        workresultinstancestatusid: sql`excluded.workresultinstancestatusid`,
        workresultinstancemodifieddate: sql`now()`,
        workresultinstancestartdate: match(targetStatus)
          .with("In Progress", () => sql`now()`)
          .otherwise(() => sql`NULL`),
        workresultinstancecompleteddate: match(targetStatus)
          .with("Complete", () => sql`now()`)
          .otherwise(() => sql`NULL`),
      };

      const columns = [
        "workresultinstancemodifieddate" as const,
        "workresultinstancestatusid" as const,
        ...match(targetStatus)
          .with("Open", () => [
            "workresultinstancestartdate" as const,
            "workresultinstancecompleteddate" as const,
          ])
          .with("In Progress", () => [
            "workresultinstancestartdate" as const,
            "workresultinstancecompleteddate" as const,
          ])
          .with("Complete", () => ["workresultinstancecompleteddate" as const])
          .exhaustive(),
      ];

      if (!suffix?.length) {
        console.warn(`...`);
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
              workresultinstancestatusid
          )
          SELECT
              wr.workresultcustomerid,
              wr.workresultid,
              wi.workinstanceid,
              inputs.status
          FROM
              inputs,
              public.workresult AS wr,
              public.workinstance AS wi
          WHERE
              wi.id = ${id}
              AND wr.id = ${suffix[0]}
          ON CONFLICT (workresultinstanceworkresultid, workresultinstanceworkinstanceid)
          DO UPDATE
              SET ${sql(updates, columns)}
              WHERE wri.workresultinstancestatusid IS DISTINCT FROM excluded.workresultinstancestatusid
      `;
    })
    .exhaustive();

  console.log(
    `Applied ${result.count} update(s) to Entity ${entity} (${type}:${id})`,
  );

  switch (true) {
    case type === "workinstance":
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
    case type === "workresult" || type === "workresultinstance":
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
