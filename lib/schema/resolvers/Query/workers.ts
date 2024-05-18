import { sql } from "@/datasources/postgres";
import type { QueryResolvers, Worker } from "@/schema";

export const workers: NonNullable<QueryResolvers["workers"]> = async (
  _,
  args,
  __,
) => {
  return await sql<Worker[]>`
    SELECT
        w.workerinstanceuuid AS id,
        l.systaguuid AS language_id,
        u.workerfullname AS name
    FROM public.workerinstance AS w
    INNER JOIN public.systag AS l
        ON w.workerinstancelanguageid = l.systagid
    INNER JOIN public.worker AS u
        ON w.workerinstanceworkerid = u.workerid
    WHERE
        w.workerinstancecustomerid = (
            SELECT customerid
            FROM public.customer
            WHERE customeruuid = ${args.customerId}
        )
        ${
          args.options?.active
            ? sql`AND (
                      w.workerinstanceenddate IS NULL
                      OR w.workerinstanceenddate > now()
                  )`
            : sql``
        }
        ${
          args.options?.site
            ? sql`AND w.workerinstancesiteid = (
                      SELECT locationid
                      FROM public.location
                      WHERE locationuuid = ${args.options.site}
                  )`
            : sql``
        }
  `;
};
