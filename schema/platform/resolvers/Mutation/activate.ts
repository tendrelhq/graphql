import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";
import { match } from "ts-pattern";

export const activate: NonNullable<MutationResolvers["activate"]> = async (
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
              workresultenddate = null,
              workresultmodifieddate = now()
          WHERE
              id = ${id}
              AND workresultenddate IS NOT null
          RETURNING 1;
      `,
    )
    .with(
      "worktemplate",
      () => sql`
          UPDATE public.worktemplate
          SET
              worktemplateenddate = null,
              worktemplatemodifieddate = now()
          WHERE
              id = ${id}
              AND worktemplateenddate IS NOT null
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
    __typename: "Checklist", // it's the only one right now...
    id: args.entity,
    // biome-ignore lint/suspicious/noExplicitAny:
  } as any;
};
