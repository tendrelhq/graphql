import type { TagResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const Tag: TagResolvers = {
  async name(parent, _, ctx) {
    return ctx.orm.name.load(decodeGlobalId(parent.nameId).id);
  },
  parent(parent, _, ctx) {
    if (parent.parentId) {
      return ctx.orm.tag.load(parent.parentId);
    }
  },
};
