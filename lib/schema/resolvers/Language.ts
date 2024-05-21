import type { LanguageResolvers } from "@/schema";

export const Language: LanguageResolvers = {
  async name(parent, _, ctx) {
    return ctx.orm.name.load({
      id: parent.name_id as string,
      language_id: ctx.user.language_id as string,
    });
  },
};
