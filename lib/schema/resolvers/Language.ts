import type { LanguageResolvers } from "@/schema";

export const Language: LanguageResolvers = {
  async name(parent, _, ctx) {
    const u = await ctx.orm.user.byIdentityId.load(ctx.auth.userId);
    return ctx.orm.name.load({
      id: parent.name_id as string,
      language_id: u.language_id as string,
    });
  },
};
