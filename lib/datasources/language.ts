import { assertAuthenticated } from "@/auth";
import type { Context, Language } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

export default (ctx: Omit<Context, "orm">) =>
  new Dataloader<string, Language>(async keys => {
    assertAuthenticated(ctx);

    const rows = await sql<Language[]>`
      SELECT 
          systaguuid AS id,
          systagtype AS code,
          systagnameid AS name_id
      FROM public.systag
      WHERE systaguuid IN ${sql(keys)};
    `;

    const byId = rows.reduce(
      (acc, row) => acc.set(row.id as string, row),
      new Map<string, Language>(),
    );

    return keys.map(key => byId.get(key) ?? new Error(`${key} does not exist`));
  });
