import { assertAuthenticated } from "@/auth";
import type { LocationResolvers, Name } from "@/schema";

export const Location: LocationResolvers = {
  async name(parent, _, ctx) {
    assertAuthenticated(ctx);
    return ctx.orm.name.load({
      id: parent.name_id as string,
      language_id: ctx.user.language_id,
    });
  },
};
