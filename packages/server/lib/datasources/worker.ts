import type { Worker } from "@/schema";
import type { WithKey } from "@/util";
import Dataloader from "dataloader";
import type { Request } from "express";
import { GraphQLError } from "graphql/error";
import { sql } from "./postgres";

export default (_: Request) =>
  new Dataloader<string, Worker>(async keys => {
    const rows = await sql<WithKey<Worker>[]>`
        SELECT
            w.workerinstanceuuid AS _key,
            encode(('worker:' || w.workerinstanceuuid)::bytea, 'base64') AS id,
            w.workerinstanceid AS _hack_numeric_id,
            coalesce(u.workerfullname, u.workergeneratedname) AS "displayName",
            u.workerfirstname AS "firstName",
            u.workerlastname AS "lastName",
            l.systaguuid AS "languageId",
            encode(('organization:' || o.customeruuid)::bytea, 'base64') AS "organizationId",
            r.systaguuid AS "roleId",
            w.workerinstancescanid AS "scanCode",
            encode(('user:' || u.workeruuid)::bytea, 'base64') AS "userId"
        FROM public.workerinstance AS w
        INNER JOIN public.customer AS o
            ON w.workerinstancecustomerid = o.customerid
        INNER JOIN public.systag AS l
            ON w.workerinstancelanguageid = l.systagid
        INNER JOIN public.systag AS r
            ON w.workerinstanceuserroleid = r.systagid
        INNER JOIN public.worker AS u
            ON w.workerinstanceworkerid = u.workerid
        WHERE w.workerinstanceuuid IN ${sql(keys)};
    `;

    const byKey = rows.reduce(
      (acc, row) => acc.set(row._key, row),
      new Map<string, Worker>(),
    );

    return keys.map(
      key =>
        byKey.get(key) ??
        new GraphQLError(`No Worker for key '${key}'`, {
          extensions: {
            code: "NOT_FOUND",
          },
        }),
    );
  });
