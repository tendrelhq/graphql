import { sql } from "@/datasources/postgres";
import type { ActivationStatus, WorkerResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const Worker: WorkerResolvers = {
  async active(parent) {
    const { id } = decodeGlobalId(parent.id);
    const [row] = await sql<[ActivationStatus]>`
      SELECT
          (
              workerinstanceenddate IS null
              OR
              workerinstanceenddate > now()
          ) AS active,
          workerinstancestartdate::text AS "activatedAt",
          workerinstanceenddate::text AS "deactivatedAt"
      FROM public.workerinstance
      WHERE workerinstanceuuid = ${id};
    `;
    return row;
  },
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
