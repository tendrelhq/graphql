import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const updateUser: NonNullable<MutationResolvers["updateUser"]> = async (
  _,
  { input },
  ctx,
) => {
  const existing = await ctx.orm.user.byId.load(input.id);
  // note that this is pretty dumb right now, we could be smarter about applying
  // updates at a more granular level...
  // TODO: modifiedby
  await sql`
    UPDATE public.worker
    SET
        workerfullname = ${input.name},
        workerlanguageid = (
            SELECT systagid
            FROM public.systag
            WHERE systaguuid = ${input.language_id}
        ),
        workermodifieddate = NOW()
    WHERE workeruuid = ${existing.id};
  `;
  return ctx.orm.user.byId.clear(input.id).load(input.id);
};
