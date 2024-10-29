import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";
import { match } from "ts-pattern";

export const deactivate: NonNullable<MutationResolvers["deactivate"]> = async (
  _,
  args,
) => {
  const { type, id } = decodeGlobalId(args.entity);

  const result = await match(type)
    .with(
      "workresult",
      () => sql`
          UPDATE public.workresult
          SET
              workresultenddate = now(),
              workresultmodifieddate = now()
          WHERE
              id = ${id}
              AND (
                  workresultenddate IS null
                  OR workresultenddate > now()
              )
          RETURNING 1;
      `,
    )
    .with(
      "worktemplate",
      () => sql`
          UPDATE public.worktemplate
          SET
              worktemplateenddate = now(),
              worktemplatemodifieddate = now()
          WHERE
              id = ${id}
              AND (
                  worktemplateenddate IS null
                  OR worktemplateenddate > now()
              )
          RETURNING 1;
      `,
    )
    .otherwise(() =>
      Promise.reject(
        new GraphQLError("Entity is not Activatable", {
          extensions: {
            code: "BAD_REQUEST",
          },
        }),
      ),
    );

  console.log(
    `Applied ${result.length} update(s) to Entity ${args.entity} (${type}:${id})`,
  );

  return {
    __typename: type === "workresult" ? "ChecklistResult" : "Checklist",
    id: args.entity,
    // biome-ignore lint/suspicious/noExplicitAny:
  } as any;
};
