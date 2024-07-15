import { updateName as updateName_ } from "@/datasources/name";
import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const updateName: NonNullable<MutationResolvers['updateName']> = async (
  _,
  { input },
  ctx,
) => {
  // Ensure it exists.
  await ctx.orm.name.load(input);
  // Do the update in a transaction.
  await sql.begin(async sql => updateName_(input, sql));
  // Refetch.
  return ctx.orm.name.clear(input).load(input);
};
