import { sql } from "@/datasources/postgres";
import { EntityNotFound } from "@/errors";
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
  async auth(parent, _, ctx) {
    const user = await ctx.orm.user.byId.load(decodeGlobalId(parent.userId).id);
    try {
      const invitation = await ctx.orm.invitation.byWorkerId.load(
        parent.id as string,
      );
      return {
        // There is an invitaton, but it has been accepted and properly
        // propagated to workeridentityid.
        canLogin:
          typeof user.authenticationIdentityId === "string" &&
          invitation.status === "accepted",
        invitation,
      };
    } catch (e) {
      if (e instanceof EntityNotFound) {
        // There is no invitation. This doesn't mean that the user can't login
        // though...
        return {
          canLogin: typeof user.authenticationIdentityId === "string",
        };
      }
      throw e;
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
