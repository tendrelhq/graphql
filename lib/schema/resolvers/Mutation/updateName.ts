import { updateName as updateName_ } from "@/datasources/name";
import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/util";

export const updateName: NonNullable<MutationResolvers["updateName"]> = async (
  _,
  { input },
  ctx,
) => {
  const { id } = decodeGlobalId(input.id);
  // Ensure it exists.
  await ctx.orm.name.load(id);
  // Do the update in a transaction.
  await sql.begin(async sql => updateName_(input, sql));
  // Refetch.
  return ctx.orm.name.clear(id).load(id);
};
