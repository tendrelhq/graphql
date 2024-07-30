import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/util";

export const updateWorker: NonNullable<
  MutationResolvers["updateWorker"]
> = async (_, { input }, ctx) => {
  const { id } = decodeGlobalId(input.id);
  const rows = await sql`
      UPDATE public.workerinstance
      SET
          workerinstancelanguageuuid = ${input.languageId},
          workerinstancelanguageid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.languageId}
          ),
          workerinstancemodifieddate = NOW(),
          workerinstancescanid = ${input.scanCode ?? null},
          workerinstanceuserroleuuid = ${input.roleId},
          workerinstanceuserroleid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.roleId}
          )
      WHERE workerinstanceuuid = ${id}
      RETURNING 1;
  `;

  if (!rows.length) {
    throw new Error("Failed to update worker");
  }

  return ctx.orm.worker.clear(id).load(id);
};
