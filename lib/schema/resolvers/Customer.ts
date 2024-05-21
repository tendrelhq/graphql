import type { CustomerResolvers } from "@/schema";

export const Customer: CustomerResolvers = {
  async name(parent, _, ctx) {
    return ctx.orm.name.load({
      id: parent.name_id as string,
      language_id: ctx.user.language_id as string,
    });
  },
  async defaultLanguage(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.default_language_id as string);
  },
};
