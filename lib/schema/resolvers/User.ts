import type { UserResolvers } from "@/schema";

export const User: UserResolvers = {
  async authentication_provider(parent, _, ctx) {
    if (!parent.authentication_provider_id) return null;
    return ctx.orm.tag.load(parent.authentication_provider_id as string);
  },
  language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.language_id as string);
  },
  tags() {
    return [];
  },
};
