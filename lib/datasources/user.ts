import { NotFoundError } from "@/errors";
import Dataloader from "dataloader";
import { sql } from "./postgres";

type User = {
  id: string;
  language_id: string;
};

export default () => {
  return {
    byId: new Dataloader<string, User>(async keys => {
      const rows = await sql<User[]>`
        SELECT
            u.workeruuid AS id,
            l.systaguuid AS language_id
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
            l.systaguuid AS language_id
        FROM public.worker AS u
        INNER JOIN public.systag AS l
            ON u.workerlanguageid = l.systagid
        WHERE u.workeridentityid IN ${sql(keys)};
      `;

      const byKey = rows.reduce(
        (acc, row) => acc.set(row.key as string, row),
        new Map<string, User>(),
      );

      return keys.map(key => byKey.get(key) ?? new NotFoundError(key, "user"));
    }),
  };
};
