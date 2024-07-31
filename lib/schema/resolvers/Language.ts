import type { LanguageResolvers, Name } from "@/schema";
import { decodeGlobalId } from "@/util";

export const Language: LanguageResolvers = {
  async name(parent, _, ctx) {
    try {
      return ctx.orm.name.load(decodeGlobalId(parent.nameId).id);
    } catch (e) {
      return ctx.orm.name.load(parent.nameId as string);
    }
  },
};
