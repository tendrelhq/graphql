import { NotFoundError } from "@/errors";
import type { Name, NameMetadata } from "@/schema";
import Dataloader from "dataloader";
import type { Request } from "express";
import { sql } from "./postgres";

type Key = { id: string; language_id: string };

export function makeNameLoader(_: Request) {
  return new Dataloader<Key, Name, string>(
    async keys => {
      return await Promise.all(
        keys.map(async k => {
          const [name] = await sql<[Name?]>`
              SELECT
                  m.languagemasteruuid AS id,
                  COALESCE(t.languagetranslationvalue, m.languagemastersource) AS value,
                  COALESCE(tl.systaguuid, ml.systaguuid) AS language_id
              FROM public.languagemaster AS m
              INNER JOIN public.systag AS ml
                  ON m.languagemastersourcelanguagetypeid = ml.systagid
              LEFT JOIN public.languagetranslations AS t
                  ON
                      m.languagemasterid = t.languagetranslationmasterid
                      AND t.languagetranslationtypeid = (
                          SELECT systagid
                          FROM public.systag
                          WHERE systaguuid = ${k.language_id}
                      )
              LEFT JOIN public.systag AS tl
                  ON t.languagetranslationtypeid = tl.systagid
              WHERE m.languagemasteruuid = ${k.id};
          `;
          return name ?? new NotFoundError(`${k.id}:${k.language_id}`, "name");
        }),
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
