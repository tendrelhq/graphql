import type { LanguageResolvers } from "@/schema";

export const Language: LanguageResolvers = {
  async name(parent, _, ctx) {
    return ctx.orm.name.load(parent.nameId as string);
  },
};
