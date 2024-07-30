import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/util";

export const updateUser: NonNullable<MutationResolvers["updateUser"]> = async (
  _,
  { input },
  ctx,
) => {
  const { id } = decodeGlobalId(input.id);
  const rows = await sql`
      UPDATE public.worker
      SET
          workerfirstname = ${input.firstName},
          workerlastname = ${input.lastName},
          workerfullname = ${input.displayName ?? null},
          workerlanguageid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.languageId}
          ),
          workermodifieddate = NOW()
      WHERE workeruuid = ${id}
      RETURNING 1;
  `;

  if (!rows.length) {
    throw new Error("Failed to update user");
  }

  return ctx.orm.user.byId.load(id);
};
