import { NotFoundError } from "@/errors";
import type { Name, NameMetadata, UpdateNameInput } from "@/schema";
import Dataloader from "dataloader";
import type { Request } from "express";
import { type SQL, sql } from "./postgres";

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

export async function updateName(input: UpdateNameInput, sql: SQL) {
  // Update the language specific translation.
  await sql`
      UPDATE public.languagetranslations
      SET
          languagetranslationvalue = ${input.value},
          languagetranslationmodifieddate = NOW()
      WHERE
          languagetranslationmasterid = (
              SELECT languagemasterid
              FROM public.languagemaster
              WHERE languagemasteruuid = ${input.id}
          )
          AND languagetranslationtypeid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.language_id}
          );
  `;

  // Attempt to update the master as well, but only do so if the given name
  // matches the master, i.e. same language_id.
  await sql`
      UPDATE public.languagemaster
      SET
          languagemastermodifieddate = NOW(),
          languagemastersource = ${input.value},
          languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'
      WHERE
          languagemasteruuid = ${input.id}
          AND languagemastersource = ${input.value}
          AND languagemastersourcelanguagetypeid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.language_id}
          );
  `;
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
