import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const acceptInvite: NonNullable<MutationResolvers['acceptInvite']> = async (_, { input }, ctx) => {
  await sql`
UPDATE public.worker
SET
    workeridentityid = ${input.authentication_identity}
    workermodifieddate = NOW()
WHERE workeruuid = ${input.id};
`;
  return ctx.orm.user.byId.clear(input.id).load(input.id);
};
