import { sql } from "@/datasources/postgres";
import type { Context, CreateUserInput, MutationResolvers } from "@/schema";
import { GraphQLError } from "graphql";

export const createUser: NonNullable<MutationResolvers["createUser"]> = async (
  _,
  { input },
  ctx,
) => {
  return await createUserHelper(input, ctx);
};

export async function createUserHelper(input: CreateUserInput, ctx: Context) {
  const [user] = await sql<[{ id: string }?]>`
      INSERT INTO public.worker (
          workeridentityid,
          workerusername,
          workerfirstname,
          workerlastname,
          workerfullname,
          workerlanguageid,
          workerstartdate,
          workerenddate,
          workeridentitysystemid,
          workeridentitysystemuuid
      ) VALUES (
          ${input.identityId},
          ${input.username ?? null},
          ${input.firstName},
          ${input.lastName},
          ${input.displayName ?? `${input.firstName} ${input.lastName}`},
          (
              SELECT systagid
              FROM public.systag
              WHERE systagparentid = 2
              AND systagtype = ${input.language}
          ),
          ${new Date()},
          ${input.active ? null : new Date()},
          915, -- Clerk
          (
              SELECT systaguuid
              FROM systag
              WHERE systagid = 915
          )
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
}
