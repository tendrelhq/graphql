import { assertAuthenticated } from "@/auth";
import type { Context } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

type User = {
  id: string;
  language_id: string;
};

export default (ctx: Omit<Context, "orm">) => {
  return {
    byId: new Dataloader<string, User>(async keys => {
      assertAuthenticated(ctx);

      const rows = await sql<User[]>`
        SELECT
            u.workeruuid AS id,
            l.systaguuid AS language_id
        FROM public.worker AS u
        INNER JOIN public.systag AS l
            ON u.workerlanguageid = l.systagid
        WHERE u.workeruuid IN ${sql(keys)};
      `;

      const byId = rows.reduce(
        (acc, row) => acc.set(row.id as string, row),
        new Map<string, User>(),
      );

      return keys.map(
        key => byId.get(key) ?? new Error(`${key} does not exist`),
      );
    }),
    byIdentityId: new Dataloader<string, User>(async keys => {
      assertAuthenticated(ctx);

      const rows = await sql<User[]>`
        SELECT
            u.workeruuid AS id,
            l.systaguuid AS language_id
        FROM public.worker AS u
        INNER JOIN public.systag AS l
            ON u.workerlanguageid = l.systagid
        WHERE u.workeridentityid IN ${sql(keys)};
      `;

      const byId = rows.reduce(
        (acc, row) => acc.set(row.id as string, row),
        new Map<string, User>(),
      );

      return keys.map(key => byId.get(key) ?? new Error(`${key} not found`));
    }),
  };
};
