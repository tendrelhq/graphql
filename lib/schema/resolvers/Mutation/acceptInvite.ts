import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const acceptInvite: NonNullable<MutationResolvers["acceptInvite"]> =
  async (_, { input }, ctx) => {
    const w = await ctx.orm.worker.load(input.id);
    await sql`
        UPDATE public.worker
        SET
            workeridentitysystemid = 915, -- Clerk
            workeridentityid = ${input.authentication_identity},
            workermodifieddate = NOW()
        WHERE workeruuid = ${w.user_id};
    `;
    // FIXME: should return a Worker?
    return ctx.orm.user.byId
      .clear(w.user_id as string)
      .load(w.user_id as string);
  };
