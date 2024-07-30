import type { LanguageResolvers } from "@/schema";
import { decodeGlobalId } from "@/util";

export const Language: LanguageResolvers = {
  async name(parent, _, ctx) {
    return ctx.orm.name.load(decodeGlobalId(parent.nameId).id);
  },
};
