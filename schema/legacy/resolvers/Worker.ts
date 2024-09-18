import { sql } from "@/datasources/postgres";
import { EntityNotFound } from "@/errors";
import type { ActivationStatus, WorkerResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const Worker: WorkerResolvers = {
  async _hack_numeric_id(parent, _, ctx) {
    const hack = await ctx.orm.worker.load(decodeGlobalId(parent.id).id);
    return hack._hack_numeric_id;
  },
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
  async displayName(parent, _, ctx) {
    const hack = await ctx.orm.worker.load(decodeGlobalId(parent.id).id);
    return hack.displayName;
  },
  async firstName(parent, _, ctx) {
    const hack = await ctx.orm.worker.load(decodeGlobalId(parent.id).id);
    return hack.firstName;
  },
  async lastName(parent, _, ctx) {
    const hack = await ctx.orm.worker.load(decodeGlobalId(parent.id).id);
    return hack.lastName;
  },
  async language(parent, _, ctx) {
    const hack = await ctx.orm.worker.load(decodeGlobalId(parent.id).id);
    return ctx.orm.language.byId.load(hack.languageId as string);
  },
  async role(parent, _, ctx) {
    const hack = await ctx.orm.worker.load(decodeGlobalId(parent.id).id);
    return ctx.orm.tag.load(hack.roleId as string);
  },
  async scanCode(parent, _, ctx) {
    const hack = await ctx.orm.worker.load(decodeGlobalId(parent.id).id);
    return hack.scanCode;
  },
  tags() {
    return [];
  },
  async user(parent, _, ctx) {
    const hack = await ctx.orm.worker.load(decodeGlobalId(parent.id).id);
    return ctx.orm.user.byId.load(decodeGlobalId(hack.userId).id);
  },
};
