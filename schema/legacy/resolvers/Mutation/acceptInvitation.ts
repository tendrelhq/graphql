import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { clerkClient } from "@clerk/clerk-sdk-node";

export const acceptInvitation: NonNullable<
  MutationResolvers["acceptInvitation"]
> = async (_, { input }, ctx) => {
  const { id: workerId } = decodeGlobalId(input.workerId);

  if (process.env.NODE_ENV === "development") {
    // simulate some latency
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  // FIXME: potentially unnecessary write
  const rows = await sql`
      UPDATE public.worker AS u
      SET
          workeridentitysystemid = 915, -- Clerk
          workeridentitysystemuuid = (
              SELECT systaguuid
              FROM systag
              WHERE systagid = 915
          ),
          workeridentityid = ${input.authenticationIdentityId},
          workermodifieddate = NOW()
      FROM public.workerinstance AS w
      WHERE
          u.workerid = w.workerinstanceworkerid
          AND w.workerinstanceuuid = ${workerId}
      RETURNING 1;
  `;

  if (!rows.length) {
    throw new Error("Failed to accept invitation");
  }

  await clerkClient.users.updateUserMetadata(input.authenticationIdentityId, {
    publicMetadata: {
      tendrel_id: null,
    },
  });

  return ctx.orm.worker.load(workerId);
};
