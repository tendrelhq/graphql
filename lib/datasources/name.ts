import { NotFoundError } from "@/errors";
import type { Name, NameMetadata } from "@/schema";
import Dataloader from "dataloader";
import type { Request } from "express";
import { sql } from "./postgres";

type Key = { id: string; language_id: string };

export function makeNameLoader(_: Request) {
  return new Dataloader<Key, Name, string>(
    async keys => {
      const rows = await sql<Name[]>`
          SELECT
              m.languagemasteruuid AS id,
              COALESCE(tl.systaguuid, ml.systaguuid) AS language_id,
              COALESCE(t.languagetranslationvalue, m.languagemastersource) AS value
          FROM public.languagemaster AS m
          INNER JOIN public.systag AS ml
              ON m.languagemastersourcelanguagetypeid = ml.systagid
          LEFT JOIN public.languagetranslations AS t
              ON m.languagemasterid = t.languagetranslationmasterid
          LEFT JOIN public.systag AS tl
              ON t.languagetranslationtypeid = tl.systagid
          WHERE
              (m.languagemasteruuid, COALESCE(tl.systaguuid, ml.systaguuid)) IN ${sql(
                keys.map(k => sql([k.id, k.language_id])),
              )};
      `;

      const byId = rows.reduce(
        (acc, row) => acc.set(`${row.id}:${row.language_id}`, row),
        new Map<string, Name>(),
      );

      return keys.map(
        key =>
          byId.get(`${key.id}:${key.language_id}`) ??
          new NotFoundError(`${key.id}:${key.language_id}`, "name"),
      );
    },
    {
      cacheKeyFn: key => `${key.id}:${key.language_id}`,
    },
  );
}

export function makeNameMetadataLoader(_: Request) {
  return new Dataloader<string, NameMetadata>(async keys => {
    const rows = await sql<NameMetadata[]>`
        SELECT
            m.languagemasteruuid AS name_id,
            m.languagemastersource AS source_text,
            l.systaguuid AS source_language_id,
            m.languagemastertranslationtime::text AS translated_at
        FROM public.languagemaster AS m
        INNER JOIN public.systag AS l
            ON m.languagemastersourcelanguagetypeid = l.systagid
        WHERE m.languagemasteruuid IN ${sql(keys)};
    `;

    const byId = rows.reduce(
      (acc, row) => acc.set(row.name_id as string, row),
      new Map<string, NameMetadata>(),
    );

    return keys.map(key => byId.get(key) ?? new NotFoundError(key, "name"));
  });
}
