import { sql } from "@/datasources/postgres";
import type { ActivationStatus, WorkerResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const Worker: WorkerResolvers = {
  async _hack_numeric_id(parent, _, ctx) {
    const hack = await ctx.orm.worker.load(decodeGlobalId(parent.id).id);
    return Number(hack._hack_numeric_id); // this is a bigint
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
    const invitation = await ctx.orm.invitation.byWorkerId.load(parent.id);
    if (invitation) {
      return {
        canLogin:
          typeof user.authenticationIdentityId === "string" &&
          invitation.status === "accepted",
        invitation,
      };
    }
    // There is no invitation. This doesn't mean that the user can't login
    // though...
    return {
      canLogin: typeof user.authenticationIdentityId === "string",
    };
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
    return ctx.orm.language.byId.load(hack.languageId);
  },
  async role(parent, _, ctx) {
    const hack = await ctx.orm.worker.load(decodeGlobalId(parent.id).id);
    return ctx.orm.tag.load(hack.roleId);
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
