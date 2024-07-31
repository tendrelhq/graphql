import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/util";

export const deactivateWorker: NonNullable<
  MutationResolvers["deactivateWorker"]
> = async (_, args, ctx) => {
  const { id } = decodeGlobalId(args.id);
  await sql`
      UPDATE public.workerinstance
      SET
          workerinstanceenddate = NOW(),
          workerinstancemodifieddate = NOW()
      WHERE workerinstanceuuid = ${id};
  `;

  return ctx.orm.worker.clear(id).load(id);
};
