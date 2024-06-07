import type { NameMetadataResolvers } from "@/schema";

export const NameMetadata: NameMetadataResolvers = {
  async source_language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.source_language_id as string);
  },
};
