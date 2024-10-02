import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";
import { match } from "ts-pattern";

export const activate: NonNullable<MutationResolvers["activate"]> = async (
  _,
  args,
  ctx,
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
              AND (
                  workresultenddate IS NOT null
                  OR
                  workresultenddate < now()
              )
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
              AND (
                  worktemplateenddate IS NOT null
                  OR
                  worktemplateenddate < now()
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

  return ctx.orm.activatable.load(args.entity);
};
