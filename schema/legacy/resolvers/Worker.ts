import type { WorkerResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const Worker: WorkerResolvers = {
  invitation(parent, _, ctx) {
    if (parent.invitationId) {
      return ctx.orm.invitation.byId.load(parent.invitationId as string);
    }
  },
  language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.languageId as string);
  },
  role(parent, _, ctx) {
    return ctx.orm.tag.load(parent.roleId as string);
  },
  tags() {
    return [];
  },
  user(parent, _, ctx) {
    return ctx.orm.user.byId.load(decodeGlobalId(parent.userId).id);
  },
};
