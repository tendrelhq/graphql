import { NotFoundError } from "@/errors";
import type { Language } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

export default () => {
  return {
    byCode: new Dataloader<string, Language>(async keys => {
      const rows = await sql<Language[]>`
        SELECT
            s.systaguuid AS id,
            s.systagtype AS code,
            n.languagemasteruuid AS name_id
        FROM public.systag AS s
        INNER JOIN public.languagemaster AS n
            ON s.systagnameid = n.languagemasterid
        WHERE
            s.systagparentid = 2 -- Language
            AND s.systagtype IN ${sql(keys)};
      `;

      const byId = rows.reduce(
        (acc, row) => acc.set(row.code, row),
        new Map<string, Language>(),
      );

      return keys.map(
        key => byId.get(key) ?? new NotFoundError(key, "language"),
      );
    }),
    byId: new Dataloader<string, Language>(async keys => {
      const rows = await sql<Language[]>`
        SELECT 
            s.systaguuid AS id,
            s.systagtype AS code,
            n.languagemasteruuid AS name_id
        FROM public.systag AS s
        INNER JOIN public.languagemaster AS n
            ON s.systagnameid = n.languagemasterid
        WHERE systaguuid IN ${sql(keys)};
      `;

      const byId = rows.reduce(
        (acc, row) => acc.set(row.id as string, row),
        new Map<string, Language>(),
      );

      return keys.map(
        key => byId.get(key) ?? new NotFoundError(key, "language"),
      );
    }),
  };
};
