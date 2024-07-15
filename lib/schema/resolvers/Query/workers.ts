import { sql } from "@/datasources/postgres";
import type { Invitation, QueryResolvers, Worker } from "@/schema";

export const workers: NonNullable<QueryResolvers['workers']> = async (
  _,
  args,
  ctx,
) => {
  const workers = await sql<Worker[]>`
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
          };
  `;

  const invitations = (
    await ctx.orm.invitation.byWorkerId.loadMany(
      workers.map(w => w.id as string),
    )
  ).reduce((acc, inv) => {
    if ("__typename" in inv) {
      return acc.set(inv.worker_id as string, inv);
    }
    return acc;
  }, new Map<string, Invitation>());

  return workers.map(w => ({
    ...w,
    invitation_id: invitations.get(w.id as string)?.id,
  }));
};
