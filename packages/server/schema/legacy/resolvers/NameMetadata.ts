import type { NameMetadataResolvers } from "@/schema";

export const NameMetadata: NameMetadataResolvers = {
  async sourceLanguage(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.sourceLanguageId);
  },
};
