import { protect } from "@/auth";
import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { clerkClient } from "@clerk/clerk-sdk-node";
import { isClerkAPIResponseError } from "@clerk/shared";
import { GraphQLError } from "graphql";

export const createInvitation: NonNullable<
  MutationResolvers["createInvitation"]
> = async (_, { input }, ctx) => {
  if (
    !(await protect({ orgId: input.orgId, userId: ctx.auth.userId }, ["Admin"]))
  ) {
    throw new GraphQLError("Not authorized", {
      extensions: {
        code: "UNAUTHORIZED",
        hint: "You do not have the necessary permissions to perform this action",
      },
    });
  }

  // HACK: This is pretty fucked. But I suppose ok for now.
  // Will be fixed when we (hopefully) integrate with Clerk organizations.
  const i = await clerkClient.invitations
    .createInvitation({
      ignoreExisting: true,
      emailAddress: input.emailAddress,
      publicMetadata: {
        tendrel_id: input.workerId,
      },
      redirectUrl: input.redirectUrl,
    })
    .catch(e => {
      if (isClerkAPIResponseError(e)) {
        const match = e.errors.find(e => e.code === "form_identifier_exists");
        if (match?.meta?.paramName === "email_address") {
          throw new GraphQLError("unique_constraint_violation", {
            extensions: {
              code: "email_address_taken",
            },
          });
        }
        console.log(e);
      }
      throw e;
    });

  ctx.orm.invitation.byWorkerId.prime(decodeGlobalId(input.workerId).id, {
    id: i.id,
    status: i.status,
    emailAddress: i.emailAddress,
    createdAt: new Date(i.createdAt).toISOString(),
    updatedAt: new Date(i.updatedAt).toISOString(),
    workerId: input.workerId,
  });

  // HACK: we need workerusername so these guys can log into the mobile app.
  // Doesn't work without it :/
  await sql`
      UPDATE public.worker AS u
      SET
          workerusername = ${input.emailAddress},
          workermodifieddate = NOW(),
          workermodifiedby = (
              SELECT workerinstanceid
              FROM public.workerinstance
              WHERE
                  workerinstancecustomerid = (
                      SELECT customerid
                      FROM public.customer
                      WHERE customeruuid = ${input.orgId}
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
          AND w.workerinstanceuuid = ${decodeGlobalId(input.workerId).id}
          AND u.workerusername IS DISTINCT FROM ${input.emailAddress}
  `;

  return ctx.orm.worker.load(decodeGlobalId(input.workerId).id);
};
