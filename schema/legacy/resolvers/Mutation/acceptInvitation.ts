import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { clerkClient } from "@clerk/clerk-sdk-node";
import { GraphQLError } from "graphql";

export const acceptInvitation: NonNullable<
  MutationResolvers["acceptInvitation"]
> = async (_, { input }, ctx) => {
  const { id: workerId } = decodeGlobalId(input.workerId);

  if (process.env.NODE_ENV === "development") {
    // simulate some latency
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  const user = await clerkClient.users.getUser(input.authenticationIdentityId);
  const emailAddress = user.primaryEmailAddress?.emailAddress;

  // This is required during Clerk sign-up, so we expect this to never throw.
  if (!emailAddress) {
    console.warn(
      `Clerk user ${user.id} does not have a primary email address? Suspicious.`,
    );
    throw "invariant violated";
  }

  // Note that we must set `workerusername` in order for this worker to be able
  // to login to the mobile app. Don't ask me why :/
  const rows = await sql`
      UPDATE public.worker AS u
      SET
          workerusername = ${emailAddress},
          workeridentitysystemid = 915, -- Clerk
          workeridentitysystemuuid = (
              SELECT systaguuid
              FROM systag
              WHERE systagid = 915
          ),
          workeridentityid = ${input.authenticationIdentityId},
          workermodifieddate = now(),
          workermodifiedby = w.workerinstanceid
      FROM public.workerinstance AS w
      WHERE
          u.workerid = w.workerinstanceworkerid
          AND w.workerinstanceuuid = ${workerId}
  `;

  if (!rows.count) {
    throw new GraphQLError(
      `Cannot accept invitation for non-existent User/Worker combination: ${input.authenticationIdentityId}/${workerId}`,
      {
        extensions: {
          code: "NOT_FOUND",
        },
      },
    );
  }

  await clerkClient.users.updateUserMetadata(input.authenticationIdentityId, {
    publicMetadata: {
      tendrel_id: null,
    },
  });

  return ctx.orm.worker.load(workerId);
};
