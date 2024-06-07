import type { WorkerResolvers } from "@/schema";

export const Worker: WorkerResolvers = {
  invitation(parent, _, ctx) {
    if (parent.invitation_id) {
      return ctx.orm.invitation.byId.load(parent.invitation_id as string);
    }
    return null;
  },
  language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.language_id as string);
  },
  role(parent, _, ctx) {
    return ctx.orm.tag.load(parent.role_id as string);
  },
  tags() {
    return [];
  },
  user(parent, _, ctx) {
    return ctx.orm.user.byId.load(parent.user_id as string);
  },
};
