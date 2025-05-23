import type { QueryResolvers } from "@/schema";

export const user: NonNullable<QueryResolvers["user"]> = async (_, __, ctx) => {
  return ctx.orm.user.byIdentityId.load(ctx.auth.userId);
};
