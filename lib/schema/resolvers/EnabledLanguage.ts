import type { EnabledLanguageResolvers } from "@/schema";

export const EnabledLanguage: EnabledLanguageResolvers = {
  async language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.languageId as string);
  },
};
