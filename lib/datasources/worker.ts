import { EntityNotFound } from "@/errors";
import type { Worker } from "@/schema";
import type { WithKey } from "@/util";
import Dataloader from "dataloader";
import type { Request } from "express";
import { sql } from "./postgres";

export default (_: Request) =>
  new Dataloader<string, Worker>(async keys => {
    const rows = await sql<WithKey<Worker>[]>`
        SELECT
            w.workerinstanceuuid AS _key,
            encode(('worker:' || w.workerinstanceuuid)::bytea, 'base64') AS id,
            w.workerinstanceid AS _hack_numeric_id,
            (w.workerinstanceenddate IS null OR w.workerinstanceenddate > now()) AS active,
            w.workerinstancestartdate::text AS "activatedAt",
            w.workerinstanceenddate::text AS "deactivatedAt",
            l.systaguuid AS "languageId",
            r.systaguuid AS "roleId",
            w.workerinstancescanid AS "scanCode",
            encode(('user:' || u.workeruuid)::bytea, 'base64') AS "userId"
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
      (acc, row) => acc.set(row._key as string, row),
      new Map<string, Worker>(),
    );

    return keys.map(key => byKey.get(key) ?? new EntityNotFound("worker"));
  });
