import { EntityNotFound } from "@/errors";
import type { Invitation } from "@/schema";
import {
  type Invitation as ClerkInvitation,
  clerkClient,
} from "@clerk/clerk-sdk-node";
import Dataloader from "dataloader";
import type { Request } from "express";

async function* listInvitations() {
  let done = false;
  let offset = 0;
  if (!done) {
    yield await clerkClient.invitations
      .getInvitationList({
        offset,
        limit: 50,
      })
      .then(({ data, totalCount }) => {
        offset += data.length;
        done = !data.length || offset >= totalCount;
        return data;
      });
  }
}

export default (_: Request) => ({
  byId: new Dataloader<string, Invitation>(async keys => {
    // TODO: this is likely our first case where we want to restrict access at a
    // more granular level (i.e. using the user's role). Probably, we only want
    // invitations to be visible by Admins, and maybe Supervisors? This is,
    // honestly, where Clerk would be massively helpful. Clerk could protect
    // this resource entirely for us using its own permissions system.
    //
    // FIXME: this is, clearly, extremely hacky.
    // Fucking Clerk man. They have a "Retrieve an organization invitation by
    // ID" backend api (key word "organization") but no generic "get invitation
    // by id" api. So... we need to get on Clerk organizations a$ap rocky.
    // Or start storing these things in the database...
    const invitations = new Map<string, ClerkInvitation>();
    for await (const batch of listInvitations()) {
      for (const i of batch) {
        if (keys.includes(i.id)) {
          invitations.set(i.id, i);
        }
      }
    }

    return keys.map(key => {
      const i = invitations.get(key);
      if (i) {
        return {
          __typename: "Invitation" as const,
          id: i.id,
          status: i.status,
          emailAddress: i.emailAddress,
          createdAt: new Date(i.createdAt).toISOString(),
          updatedAt: new Date(i.updatedAt).toISOString(),
          workerId: i.publicMetadata?.tendrel_id as string,
        };
      }
      return new EntityNotFound("invitation");
    });
  }),
  byWorkerId: new Dataloader<string, Invitation>(async keys => {
    const invitations = new Map<string, ClerkInvitation>();
    for await (const batch of listInvitations()) {
      for (const i of batch) {
        if (keys.includes(i.publicMetadata?.tendrel_id as string)) {
          invitations.set(i.publicMetadata?.tendrel_id as string, i);
        }
      }
    }

    return keys.map(key => {
      const i = invitations.get(key);
      if (i) {
        return {
          __typename: "Invitation" as const,
          id: i.id,
          status: i.status,
          emailAddress: i.emailAddress,
          createdAt: new Date(i.createdAt).toISOString(),
          updatedAt: new Date(i.updatedAt).toISOString(),
          workerId: i.publicMetadata?.tendrel_id as string,
        };
      }
      return new EntityNotFound("invitation");
    });
  }),
});
