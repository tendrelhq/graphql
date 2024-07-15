import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const updateWorker: NonNullable<MutationResolvers['updateWorker']> = async (_, { input }, ctx) => {
  const existing = await ctx.orm.worker.load(input.id);
  await sql`
      UPDATE public.workerinstance
      SET
          workerinstancelanguageuuid = ${input.language_id},
          workerinstancelanguageid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.language_id}
          ),
          workerinstancemodifieddate = NOW(),
          workerinstancescanid = ${input.scan_code ?? null},
          workerinstanceuserroleuuid = ${input.role_id},
          workerinstanceuserroleid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.role_id}
          )
      WHERE workerinstanceuuid = ${existing.id};
  `;
  return ctx.orm.worker.clear(input.id).load(input.id);
};
