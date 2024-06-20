import { protect } from "@/auth";
import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { clerkClient } from "@clerk/clerk-sdk-node";
import { isClerkAPIResponseError } from "@clerk/shared";
import { GraphQLError } from "graphql";

export const createInvitation: NonNullable<
  MutationResolvers["createInvitation"]
> = async (_, { input }, ctx) => {
  await protect({ orgId: input.org_id, userId: ctx.auth.userId }, ["Admin"]);

  // HACK: This is pretty fucked. But I suppose ok for now.
  // Will be fixed when we (hopefully) integrate with Clerk organizations.
  const i = await clerkClient.invitations
    .createInvitation({
      emailAddress: input.email_address,
      publicMetadata: {
        needs_sync: "yes",
        tendrel_id: input.worker_id,
      },
    })
    .catch(e => {
      if (isClerkAPIResponseError(e)) {
        const ce = e.errors.at(0);
        throw new GraphQLError(ce?.longMessage ?? ce?.message ?? e.message, {
          extensions: {
            code: ce?.code ?? "BAD_REQUEST",
          },
        });
      }

      throw e;
    });

  // HACK: we need workerusername so these guys can log into the mobile app.
  // Doesn't work without it :/
  await sql`
      UPDATE public.worker AS u
      SET
          workerusername = ${input.email_address},
          workermodifieddate = NOW(),
          workermodifiedby = (
              SELECT workerinstanceid
              FROM public.workerinstance
              WHERE
                  workerinstancecustomerid = (
                      SELECT customerid
                      FROM public.customer
                      WHERE customeruuid = ${input.org_id}
                  )
                  AND workerinstanceworkerid = (
                      SELECT workerid
                      FROM public.worker
                      WHERE workeridentityid = ${ctx.auth.userId}
                  )
          )
      FROM public.workerinstance AS w
      WHERE
          u.workerid = w.workerinstanceworkerid
          AND w.workerinstanceuuid = ${input.worker_id};
  `;

  return {
    id: i.id,
    status: i.status,
    email_address: i.emailAddress,
    created_at: new Date(i.createdAt).toISOString(),
    updated_at: new Date(i.updatedAt).toISOString(),
    worker_id: input.worker_id,
  };
};
