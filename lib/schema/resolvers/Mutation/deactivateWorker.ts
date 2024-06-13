import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const deactivateWorker: NonNullable<
  MutationResolvers["deactivateWorker"]
> = async (_, { id }, ctx) => {
  await sql`
      UPDATE public.workerinstance
      SET
          workerinstanceenddate = NOW(),
          workerinstancemodifieddate = NOW()
      WHERE workerinstanceuuid = ${id};
  `;

  return ctx.orm.worker.clear(id).load(id);
};
