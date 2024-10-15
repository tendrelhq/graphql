import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";
import { match } from "ts-pattern";
import { copyFromWorkInstance } from "./copyFrom";

export const setStatus: NonNullable<MutationResolvers["setStatus"]> = async (
  _,
  { entity, parent, input },
) => {
  const { type, id } = decodeGlobalId(entity);

  if (
    type !== "workinstance" &&
    type !== "workresult" &&
    type !== "workresultinstance"
  ) {
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
    .with("workinstance", () =>
      sql.begin(async tx => {
        const r0 = await tx`
           WITH inputs AS (
               SELECT systagid AS status
               FROM public.systag
               WHERE
                   systagparentid = 705
                   AND
                   systagtype = ${targetStatus}
           )
      
           UPDATE public.workinstance
           SET
               workinstancestatusid = inputs.status,
               workinstancemodifieddate = now()
           FROM inputs
           WHERE
               id = ${id}
               AND
               workinstancestatusid != inputs.status
        `;

        const r1 = await match(targetStatus)
          .with(
            "Open",
            () => tx`
                UPDATE public.workinstance
                SET
                   workinstancestartdate = null,
                   workinstancecompleteddate = null,
                   workinstancemodifieddate = now()
                WHERE id = ${id}
            `,
          )
          .with(
            "In Progress",
            () => tx`
                UPDATE public.workinstance
                SET
                    workinstancestartdate = now(),
                    workinstancecompleteddate = null,
                    workinstancemodifieddate = now()
                WHERE id = ${id}
            `,
          )
          .with(
            "Complete",
            () => tx`
                UPDATE public.workinstance
                SET
                    workinstancecompleteddate = now(),
                    workinstancemodifieddate = now()
                WHERE id = ${id}
            `,
          )
          .exhaustive();

        if (targetStatus === "In Progress") {
          // HACK: this is "running the rules engine" for now lmao.
          await copyFromWorkInstance(tx, id, {});
        }

        return [r0, r1];
      }),
    )
    .with("workresultinstance", () =>
      sql.begin(tx => [
        tx`
          WITH inputs AS (
              SELECT systagid AS status
              FROM public.systag
              WHERE
                  systagparentid = 965
                  AND
                  systagtype = ${targetStatus}
          )

          UPDATE public.workresultinstance
          SET
              workresultinstancestatusid = inputs.status,
              workresultinstancemodifieddate = now()
          FROM inputs
          WHERE
              workresultinstanceuuid = ${id}
              AND
              workresultinstancestatusid != inputs.status
        `,
      ]),
    )
    .with("workresult", () => {
      if (!parent) {
        throw new GraphQLError(
          "Cannot lazily evaluate AST node without ECS reference",
          {
            extensions: {
              code: "BAD_REQUEST",
            },
          },
        );
      }

      const { type: parentType, id: parentId } = decodeGlobalId(parent);

      if (parentType !== "workinstance") {
        throw new GraphQLError(
          "Invalid ECS reference provided to AST lazy evaluation",
          {
            extensions: {
              code: "E_INVALID_REFERENCE",
            },
          },
        );
      }

      return sql.begin(tx => [
        tx`
          WITH inputs AS (
              SELECT systagid AS status
              FROM public.systag
              WHERE
                  systagparentid = 965
                  AND
                  systagtype = ${targetStatus}
          )

          UPDATE public.workresultinstance
          SET
              workresultinstancestatusid = inputs.status,
              workresultinstancemodifieddate = now()
          FROM inputs
          WHERE
              workresultinstancestatusid != inputs.status
              AND workresultinstanceworkresultid IN (
                  SELECT workresultid
                  FROM public.workresult
                  WHERE id = ${id}
              )
              AND workresultinstanceworkinstanceid IN (
                  SELECT workinstanceid
                  FROM public.workinstance
                  WHERE id = ${parentId}
              )
        `,
      ]);
    })
    .exhaustive();

  const delta = result.reduce((acc, row) => acc + row.count, 0);
  console.log(`Applied ${delta} update(s) to Entity ${entity} (${type}:${id})`);

  switch (true) {
    case type === "workinstance":
      return {
        __typename: "SetChecklistStatusPayload",
        delta,
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
        delta,
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
