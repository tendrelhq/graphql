import { EntityNotFound } from "@/errors";
import type { Language } from "@/schema";
import Dataloader from "dataloader";
import type { Request } from "express";
import { sql } from "./postgres";

export default (_: Request) => {
  return {
    byCode: new Dataloader<string, Language>(async keys => {
      const rows = await sql<Language[]>`
        SELECT
            s.systaguuid AS id,
            s.systagtype AS code,
            encode(('name:' || n.languagemasteruuid)::bytea, 'base64') AS "nameId"
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

      return keys.map(key => byId.get(key) ?? new EntityNotFound("language"));
    }),
    byId: new Dataloader<string, Language>(async keys => {
      const rows = await sql<Language[]>`
        SELECT 
            s.systaguuid AS id,
            s.systagtype AS code,
            encode(('name:' || n.languagemasteruuid)::bytea, 'base64') AS "nameId"
        FROM public.systag AS s
        INNER JOIN public.languagemaster AS n
            ON s.systagnameid = n.languagemasterid
        WHERE systaguuid IN ${sql(keys)};
      `;

      const byId = rows.reduce(
        (acc, row) => acc.set(row.id as string, row),
        new Map<string, Language>(),
      );

      return keys.map(key => byId.get(key) ?? new EntityNotFound("language"));
    }),
  };
};
