import type { QueryResolvers } from "@/schema";

export const name: NonNullable<QueryResolvers["name"]> = async (
  _,
  { id },
  ctx,
) => {
  const u = await ctx.orm.user.byIdentityId.load(ctx.auth.userId);
  return ctx.orm.name.load({
    id,
    language_id: u.language_id as string,
  });
};
