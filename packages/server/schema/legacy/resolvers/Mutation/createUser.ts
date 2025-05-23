import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { clerkClient } from "@clerk/clerk-sdk-node";
import { GraphQLError } from "graphql";

declare global {
  interface UserPublicMetadata {
    tendrel_id?: string | null;
  }
}

/**
 * This is really the "signUp" flow. It should be called after the User first
 * signs up via Clerk and before they are redirected to the main experience,
 * i.e. they should have a Clerk account and nothing else.
 */
export const createUser: NonNullable<MutationResolvers["createUser"]> = async (
  _,
  { input },
  ctx,
) => {
  const user = await clerkClient.users.getUser(input.identityId);
  if (user.publicMetadata.tendrel_id) {
    const { type, id } = decodeGlobalId(user.publicMetadata.tendrel_id);
    if (type !== "worker") {
      throw "invariant violated";
    }

    // This is the post-signup effect prior to the user "officially" accepting
    // their invitation. Meaning: we expect a public.workerinstance to exist.
    // FIXME: We probably don't need to have both this and the acceptInvitation
    // apis, consider this one should be renamed "signUp". You can signUp two
    // ways: on your own via the console and customer onboarding, or via an
    // invitation. For now, we'll keep both. I do like the greeting ux we use
    // for the invitation stuff, but really that should be a custom sign-up
    // component.
    const [row] = await sql<[{ id: string }?]>`
        SELECT workeruuid AS id
        FROM public.workerinstance
        INNER JOIN public.worker
            ON workerinstanceworkerid = workerid
        WHERE workerinstanceuuid = ${id}
    `;

    if (!row) {
      // Presumably this would happen in a cross-stage situation. Like the
      // invitation was created in beta, and then the user tried to sign in to
      // test to accept the invitation, except there would be no workerinstance
      // for that invitation (because it was created in beta).
      throw new Error(
        "Invalid state: invitation pending for non-existent Worker",
      );
    }

    // All good. Everything will have been created already.
    return ctx.orm.user.byId.load(row.id);
  }

  await sql`
      INSERT INTO public.worker (
          workeridentityid,
          workerusername,
          workerfirstname,
          workerlastname,
          workerfullname,
          workerlanguageid,
          workerstartdate,
          workerenddate,
          workeridentitysystemid,
          workeridentitysystemuuid
      ) VALUES (
          ${input.identityId},
          ${input.username ?? null},
          ${input.firstName},
          ${input.lastName},
          ${input.displayName ?? `${input.firstName} ${input.lastName}`},
          (
              SELECT systagid
              FROM public.systag
              WHERE systagparentid = 2
              AND systagtype = ${ctx.req.i18n.language}
          ),
          ${new Date()},
          ${input.active ? null : new Date()},
          915, -- Clerk
          (
              SELECT systaguuid
              FROM systag
              WHERE systagid = 915
          )
      )
      ON CONFLICT DO NOTHING
  `;

  // If ON CONFLICT DO NOTHING hit, and it happened for some unique constraint
  // other than workeridentityid, this will throw a NOT_FOUND error:
  try {
    return await ctx.orm.user.byIdentityId.load(input.identityId);
  } catch (e) {
    // ON CONFLICT DO NOTHING hit for a constraint violation other than
    // workeridentityid.
    //
    // workerusername is the only other unique constraint that _could_ hit:
    throw new GraphQLError(
      "That username already exists. Please try another.",
      {
        extensions: {
          code: "user_identifier_exists",
        },
      },
    );
  }
};
