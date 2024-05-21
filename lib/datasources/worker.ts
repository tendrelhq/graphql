import { NotFoundError } from "@/errors";
import type { Context, Worker } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

export default (ctx: Omit<Context, "orm">) =>
  new Dataloader<string, Worker>(async keys => {
    const rows = await sql<Worker[]>`
        SELECT
            w.workerinstanceuuid AS id,
            (w.workerinstanceenddate IS NULL OR w.workerinstanceenddate > now()) AS active,
            w.workerinstancestartdate::text AS activated_at,
            w.workerinstanceenddate::text AS deactivated_at,
            l.systaguuid AS language_id,
            u.workeruuid AS user_id
        FROM public.workerinstance AS w
        INNER JOIN public.systag AS l
            ON w.workerinstancelanguageid = l.systagid
        WHERE w.workerinstanceuuid IN ${sql(keys)};
      `;

    const byKey = rows.reduce(
      (acc, row) => acc.set(row.id as string, row),
      new Map<string, Worker>(),
    );

    return keys.map(key => byKey.get(key) ?? new NotFoundError(key, "worker"));
  });
