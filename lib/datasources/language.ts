import { NotFoundError } from "@/errors";
import type { Language } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

export default () =>
  new Dataloader<string, Language>(async keys => {
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

    return keys.map(key => byId.get(key) ?? new NotFoundError(key, "language"));
  });
