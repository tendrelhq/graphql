import type { ID, Language } from "@/schema";
import Dataloader from "dataloader";
import type { Request } from "express";
import { GraphQLError } from "graphql/error";
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

      return keys.map(
        key =>
          byId.get(key) ??
          new GraphQLError(`No Language for key '${key}'`, {
            extensions: {
              code: "NOT_FOUND",
            },
          }),
      );
    }),
    byId: new Dataloader<ID, Language>(async keys => {
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
        (acc, row) => acc.set(row.id, row),
        new Map<ID, Language>(),
      );

      return keys.map(
        key =>
          byId.get(key) ??
          new GraphQLError(`No Language for key '${key}'`, {
            extensions: {
              code: "NOT_FOUND",
            },
          }),
      );
    }),
  };
};
