import { user } from "@/datasources/postgres";
import type { TagResolvers } from "@/schema";

export const Tag: TagResolvers = {
  async name(parent, _, ctx) {
    const u = await user.byIdentityId.load(ctx.auth.userId);
    return ctx.orm.name.load({
      id: parent.name_id as string,
      language_id: u.language_id as string,
    });
  },
  parent(parent, _, ctx) {
    if (parent.parent_id) {
      return ctx.orm.tag.load(parent.parent_id as string);
    }
  },
};
