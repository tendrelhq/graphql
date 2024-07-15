import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const acceptInvitation: NonNullable<MutationResolvers['acceptInvitation']> = async (_, { input }, ctx) => {
  await sql`
        UPDATE public.worker AS u
        SET
            workeridentitysystemid = 915, -- Clerk
            workeridentitysystemuuid = (
                SELECT systaguuid
                FROM systag
                WHERE systagid = 915
            ),
            workeridentityid = ${input.authentication_identity_id},
            workermodifieddate = NOW()
        FROM public.workerinstance AS w
        WHERE
            u.workerid = w.workerinstanceworkerid
            AND w.workerinstanceuuid = ${input.worker_id};
    `;
  return ctx.orm.worker.load(input.worker_id);
};
