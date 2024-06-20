import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const createWorker: NonNullable<MutationResolvers["createWorker"]> =
  async (_, { input }, ctx) => {
    const [worker] = await sql<[{ id: string }?]>`
        INSERT INTO public.workerinstance (
            workerinstanceworkerid,
            workerinstanceworkeruuid,
            workerinstancecustomerid,
            workerinstancecustomeruuid,
            workerinstancelanguageid,
            workerinstancelanguageuuid,
            workerinstancestartdate,
            workerinstanceenddate,
            workerinstanceuserroleid,
            workerinstanceuserroleuuid,
            workerinstancescanid
        )
        SELECT
            u.workerid,
            u.workeruuid,
            (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${input.org_id}
            ),
            ${input.org_id},
            (
                SELECT systagid
                FROM public.systag
                WHERE systaguuid = ${input.language_id}
            ),
            ${input.language_id},
            ${new Date()},
            ${input.active ? null : new Date()},
            (
                SELECT systagid
                FROM public.systag
                WHERE systaguuid = ${input.role_id}
            ),
            ${input.role_id},
            ${input.scan_code ?? null}
        FROM public.worker AS u
        WHERE u.workeruuid = ${input.user_id}
        ON CONFLICT DO NOTHING
        RETURNING workerinstanceuuid AS id;
    `;

    if (!worker) {
      // This implies ON CONFLICT DO NOTHING hit.
      // i.e. the worker already exists, so we just need to find it.
      const [worker] = await sql<[{ id: string }?]>`
          SELECT workerinstanceuuid AS id
          FROM public.workerinstance
          INNER JOIN public.worker
              ON workerinstanceworkerid = workerid
          WHERE
              workeruuid = ${input.user_id}
              AND workerinstancecustomerid = (
                  SELECT customerid
                  FROM public.customer
                  WHERE customeruuid = ${input.org_id}
              );
      `;

      if (!worker) throw "must've messed up the unique constraints";
      return ctx.orm.worker.load(worker.id);
    }

    return ctx.orm.worker.load(worker.id);
  };
