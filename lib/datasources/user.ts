import type { User } from "@/schema";
import type { WithKey } from "@/util";
import Dataloader from "dataloader";
import type { Request } from "express";
import { sql } from "./postgres";
import { GraphQLError } from "graphql/error";

function selectUsers(
  key: "workeridentityid" | "workeruuid",
  keys: readonly string[],
) {
  return sql<WithKey<User>[]>`
    SELECT
        u.${sql(key)} AS _key,
        encode(('user:' || u.workeruuid)::bytea, 'base64') AS id,
        (u.workerenddate IS NULL OR u.workerenddate > now()) AS active,
        u.workerstartdate::text AS "activatedAt",
        u.workerenddate::text AS "deactivatedAt",
        u.workeridentityid AS "authenticationIdentityId",
        a.systaguuid AS "authenticationProviderId",
        l.systaguuid AS "languageId",
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
        (acc, row) => acc.set(row._key, row),
        new Map(),
      );

      return keys.map(
        key =>
          byKey.get(key) ??
          new GraphQLError(`No User for key '${key}'`, {
            extensions: {
              code: "NOT_FOUND",
            },
          }),
      );
    }),
    byIdentityId: new Dataloader<string, User>(async keys => {
      const rows = await selectUsers("workeridentityid", keys);
      const byKey = rows.reduce(
        (acc, row) => acc.set(row._key, row),
        new Map(),
      );

      return keys.map(
        key =>
          byKey.get(key) ??
          new GraphQLError(`No User for key '${key}'`, {
            extensions: {
              code: "NOT_FOUND",
            },
          }),
      );
    }),
  };
};
