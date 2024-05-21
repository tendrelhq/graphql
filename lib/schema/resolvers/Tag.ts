import type { TagResolvers } from "@/schema";

export const Tag: TagResolvers = {
  name(parent, _, ctx) {
    return ctx.orm.name.load({
      id: parent.name_id as string,
      language_id: ctx.user.language_id as string,
    });
  },
  parent(parent, _, ctx) {
    if (parent.parent_id) {
      return ctx.orm.tag.load(parent.parent_id as string);
    }
  },
};
