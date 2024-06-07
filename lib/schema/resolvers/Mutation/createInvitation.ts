import { protect } from "@/auth";
import type { MutationResolvers } from "@/schema";
import { clerkClient } from "@clerk/clerk-sdk-node";

export const createInvitation: NonNullable<
  MutationResolvers["createInvitation"]
> = async (_, { input }, ctx) => {
  await protect({ orgId: input.org_id, userId: ctx.auth.userId }, ["Admin"]);

  // FIXME: This is pretty fucked. But I suppose ok for now.
  // Will be fixed when we (hopefully) integrate with Clerk organizations.
  const i = await clerkClient.invitations.createInvitation({
    emailAddress: input.email_address,
    publicMetadata: {
      needs_sync: "yes",
      tendrel_id: input.worker_id,
    },
  });

  return {
    id: i.id,
    status: i.status,
    email_address: i.emailAddress,
    created_at: new Date(i.createdAt).toISOString(),
    updated_at: new Date(i.updatedAt).toISOString(),
    worker_id: input.worker_id,
  };
};
