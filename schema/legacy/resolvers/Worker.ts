import type { WorkerResolvers } from "@/schema";
import { decodeGlobalId } from "@/util";

export const Worker: Pick<
  WorkerResolvers,
  | "activatedAt"
  | "active"
  | "deactivatedAt"
  | "id"
  | "invitation"
  | "invitationId"
  | "language"
  | "languageId"
  | "role"
  | "roleId"
  | "scanCode"
  | "tags"
  | "user"
  | "userId"
> = {
  invitation(parent, _, ctx) {
    if (parent.invitationId) {
      return ctx.orm.invitation.byId.load(parent.invitationId as string);
    }
    return null;
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
