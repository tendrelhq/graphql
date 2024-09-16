import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import {
  createUser,
  createUserHelper,
} from "@/schema/legacy/resolvers/Mutation/createUser.ts";
import { GraphQLError } from "graphql";

export const signUp: NonNullable<MutationResolvers["signUp"]> = async (
  _,
  { input },
  ctx,
) => {
  const [existingUser] = await sql<[{ id: string }?]>`
      SELECT workeruuid as id FROM public.worker
      WHERE workeridentityid=${input.identityId}
    `;

  if (existingUser) {
    return ctx.orm.user.byId.load(existingUser.id);
  }

  return await createUserHelper(input, ctx);
};
