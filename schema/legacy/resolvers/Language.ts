import type { LanguageResolvers, Name } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const Language: LanguageResolvers = {
  async name(parent, _, ctx) {
    return ctx.orm.name.load(decodeGlobalId(parent.nameId).id);
  },
};
