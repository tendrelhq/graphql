import type { UserResolvers } from "@/schema";

export const User: UserResolvers = {
  language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.language_id as string);
  },
  tags() {
    return [];
  },
};
