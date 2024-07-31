import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/util";

export const activateWorker: NonNullable<
  MutationResolvers["activateWorker"]
> = async (_, args, ctx) => {
  const { id } = decodeGlobalId(args.id);
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
