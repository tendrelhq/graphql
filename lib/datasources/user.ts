import { NotFoundError } from "@/errors";
import type { User } from "@/schema";
import Dataloader from "dataloader";
import type { Request } from "express";
import { sql } from "./postgres";

function selectUsers(
  key: "workeridentityid" | "workeruuid",
  keys: readonly string[],
) {
  return sql<(User & { key: string })[]>`
    SELECT
        u.${sql(key)} AS key,
        u.workeruuid AS id,
        (u.workerenddate IS NULL OR u.workerenddate > now()) AS active,
        u.workerstartdate::text AS activated_at,
        u.workerenddate::text AS deactivated_at,
        u.workeridentityid AS authentication_identity_id,
        a.systaguuid AS authentication_provider_id,
        l.systaguuid AS language_id,
        u.workerfirstname AS "firstName",
        u.workerlastname AS "lastName",
        COALESCE(u.workerfullname, u.workergeneratedname) AS "displayName"
    FROM public.worker AS u
    LEFT JOIN public.systag AS a
        ON u.workeridentitysystemid = a.systagid
    INNER JOIN public.systag AS l
        ON u.workerlanguageid = l.systagid
    WHERE u.${sql(key)} IN ${sql(keys)};
  `;
}

export default (_: Request) => {
  return {
    byId: new Dataloader<string, User>(async keys => {
      const rows = await selectUsers("workeruuid", keys);
      const byKey = rows.reduce(
        (acc, row) => acc.set(row.id as string, row),
        new Map<string, User>(),
      );

      return keys.map(key => byKey.get(key) ?? new NotFoundError(key, "user"));
    }),
    byIdentityId: new Dataloader<string, User>(async keys => {
      const rows = await selectUsers("workeridentityid", keys);
      const byKey = rows.reduce(
        (acc, row) => acc.set(row.key as string, row),
        new Map<string, User>(),
      );

      return keys.map(key => byKey.get(key) ?? new NotFoundError(key, "user"));
    }),
  };
};
