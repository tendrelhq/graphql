import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const activateWorker: NonNullable<
  MutationResolvers["activateWorker"]
> = async (_, { id }, ctx) => {
  await sql`
      UPDATE public.workerinstance
      SET
          workerinstancestartdate = NOW(),
          workerinstanceenddate = NULL,
          workerinstancemodifieddate = NOW()
      WHERE workerinstanceuuid = ${id};
  `;

  return ctx.orm.worker.clear(id).load(id);
};
