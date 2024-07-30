import type { TagResolvers } from "@/schema";

export const Tag: TagResolvers = {
  async name(parent, _, ctx) {
    return ctx.orm.name.load(parent.nameId as string);
  },
  parent(parent, _, ctx) {
    if (parent.parentId) {
      return ctx.orm.tag.load(parent.parentId as string);
    }
  },
};
