import { NotFoundError } from "@/errors";
import type { User } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

export default () => {
  return {
    byId: new Dataloader<string, User>(async keys => {
      const rows = await sql<User[]>`
        SELECT
            u.workeruuid AS id,
            (u.workerenddate IS NULL OR u.workerenddate > now()) AS active,
            l.systaguuid AS language_id,
            u.workerfullname AS name
        FROM public.worker AS u
        INNER JOIN public.systag AS l
            ON u.workerlanguageid = l.systagid
        WHERE u.workeruuid IN ${sql(keys)};
      `;

      const byKey = rows.reduce(
        (acc, row) => acc.set(row.id as string, row),
        new Map<string, User>(),
      );

      return keys.map(key => byKey.get(key) ?? new NotFoundError(key, "user"));
    }),
    byIdentityId: new Dataloader<string, User>(async keys => {
      const rows = await sql<(User & { key: string })[]>`
        SELECT
            u.workeridentityid AS key,
            u.workeruuid AS id,
            (u.workerenddate IS NULL OR u.workerenddate > now()) AS active,
            l.systaguuid AS language_id,
            u.workerfullname AS name
        FROM public.worker AS u
        INNER JOIN public.systag AS l
            ON u.workerlanguageid = l.systagid
        WHERE u.workeridentityid IN ${sql(keys)};
      `;

      console.debug(JSON.stringify(rows));

      const byKey = rows.reduce(
        (acc, row) => acc.set(row.key as string, row),
        new Map<string, User>(),
      );

      console.debug(JSON.stringify(byKey));

      return keys.map(key => byKey.get(key) ?? new NotFoundError(key, "user"));
    }),
  };
};
