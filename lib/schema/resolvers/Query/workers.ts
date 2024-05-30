import { sql } from "@/datasources/postgres";
import type { QueryResolvers, Worker } from "@/schema";

export const workers: NonNullable<QueryResolvers['workers']> = async (
  _,
  args,
  __,
) => {
  return await sql<Worker[]>`
    SELECT
        w.workerinstanceuuid AS id,
        (w.workerinstanceenddate IS NULL OR w.workerinstanceenddate > now()) AS active,
        w.workerinstancestartdate::text AS activated_at,
        w.workerinstanceenddate::text AS deactivated_at,
        l.systaguuid AS language_id,
        r.systaguuid AS role_id,
        w.workerinstancescanid AS scan_code,
        u.workeruuid AS user_id
    FROM public.workerinstance AS w
    INNER JOIN public.systag AS l
        ON w.workerinstancelanguageid = l.systagid
    INNER JOIN public.systag AS r
        ON w.workerinstanceuserroleid = r.systagid
    LEFT JOIN public.worker AS u
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
