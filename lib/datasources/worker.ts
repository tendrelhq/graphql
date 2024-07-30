import { NotFoundError } from "@/errors";
import type { Worker } from "@/schema";
import Dataloader from "dataloader";
import type { Request } from "express";
import { sql } from "./postgres";

export default (_: Request) =>
  new Dataloader<string, Worker>(async keys => {
    const rows = await sql<Worker[]>`
        SELECT
            w.workerinstanceuuid AS id,
            (w.workerinstanceenddate IS NULL OR w.workerinstanceenddate > now()) AS active,
            w.workerinstancestartdate::text AS "activatedAt",
            w.workerinstanceenddate::text AS "deactivatedAt",
            l.systaguuid AS "languageId",
            r.systaguuid AS "roleId",
            w.workerinstancescanid AS "scanCode",
            u.workeruuid AS "userId"
        FROM public.workerinstance AS w
        INNER JOIN public.systag AS l
            ON w.workerinstancelanguageid = l.systagid
        INNER JOIN public.systag AS r
            ON w.workerinstanceuserroleid = r.systagid
        INNER JOIN public.worker AS u
            ON w.workerinstanceworkerid = u.workerid
        WHERE w.workerinstanceuuid IN ${sql(keys)};
    `;

    const byKey = rows.reduce(
      (acc, row) => acc.set(row.id as string, row),
      new Map<string, Worker>(),
    );

    return keys.map(key => byKey.get(key) ?? new NotFoundError(key, "worker"));
  });
