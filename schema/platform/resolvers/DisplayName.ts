import type { DisplayNameResolvers } from "@/schema";

export const DisplayName: DisplayNameResolvers = {
  name(parent, _, ctx) {
    return ctx.orm.dynamicString.load(parent.id);
  },
  value(parent, _, ctx) {
    return ctx.orm.dynamicString.load(parent.id);
  },
};
