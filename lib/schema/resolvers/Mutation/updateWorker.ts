import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const updateWorker: NonNullable<MutationResolvers["updateWorker"]> =
  async (_, { input }, ctx) => {
    const existing = await ctx.orm.worker.load(input.id);
    await sql`
      UPDATE public.workerinstance
      SET
          workerinstancestartdate = ${input.activated_at ?? null},
          workerinstanceenddate = ${input.deactivated_at ?? null},
          workerinstancelanguageid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.language_id}
          ),
          workerinstanceuserroleuuid = ${input.role_id},
          workerinstancescanid = ${input.scan_code ?? null},
          -- Garbage. To be removed.
          workerinstanceuserroleid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.role_id}
          )
      WHERE workerinstanceuuid = ${existing.id};
    `;
    return ctx.orm.worker.clear(input.id).load(input.id);
  };
