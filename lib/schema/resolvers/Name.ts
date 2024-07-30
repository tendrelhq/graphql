import type { NameResolvers } from "@/schema";
import { decodeGlobalId } from "@/util";

export const Name: NameResolvers = {
  async language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.languageId as string);
  },
  async metadata(parent, _, ctx) {
    return ctx.orm.nameMetadata.load(decodeGlobalId(parent.id).id);
  },
};
