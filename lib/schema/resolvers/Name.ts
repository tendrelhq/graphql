import { assertAuthenticated } from "@/auth";
import type { NameResolvers } from "@/schema";

export const Name: NameResolvers = {
  async language(parent, _, ctx) {
    assertAuthenticated(ctx);
    return ctx.orm.language.load(parent.language_id as string);
  },
};
