import type { UserResolvers } from "@/schema";

export const User: UserResolvers = {
  language(parent, _, ctx) {
    return ctx.orm.language.load(parent.language_id as string);
  },
  name(parent, _, ctx) {
    return ctx.orm.name.load({
      id: parent.name_id as string,
      language_id: ctx.user.language_id,
    });
  },
  tags() {
    return [];
  },
};
