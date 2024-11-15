import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { GraphQLError } from "graphql";

export const createUser: NonNullable<MutationResolvers["createUser"]> = async (
  _,
  { input },
  ctx,
) => {
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
