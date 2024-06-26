import type { NameResolvers } from "@/schema";

export const Name: NameResolvers = {
  async language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.language_id as string);
  },
  async metadata(parent, _, ctx) {
    return ctx.orm.nameMetadata.load(parent.id as string);
  },
};
