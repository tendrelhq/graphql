import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { GraphQLError } from "graphql";

export const createUser: NonNullable<MutationResolvers["createUser"]> = async (
  _,
  { input },
  ctx,
) => {
  const [user] = await sql<[{ id: string }?]>`
      INSERT INTO public.worker (
          workerusername,
          workerfullname,
          workerlanguageid,
          workerstartdate,
          workerenddate
      ) VALUES (
          ${input.username ?? null},
          ${input.name},
          (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.language_id}
          ),
          ${new Date()},
          ${input.active ? null : new Date()}
      )
      ON CONFLICT (workerusername) DO NOTHING
      RETURNING workeruuid AS id;
  `;

  if (!user) {
    // This implies ON CONFLICT DO NOTHING hit, meaning a user already exists
    // for the given username.
    throw new GraphQLError(
      "That username already exists. Please try another.",
      {
        extensions: {
          code: "user_identifier_exists",
        },
      },
    );
  }

  return ctx.orm.user.byId.load(user.id);
};
