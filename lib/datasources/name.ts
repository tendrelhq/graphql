import { EntityNotFound } from "@/errors";
import type { Component, Name, NameMetadata, UpdateNameInput } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import Dataloader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { type SQL, sql, unionAll } from "./postgres";

export function makeDisplayNameLoader(req: Request) {
  return new Dataloader<string, Component>(async keys => {
    const entities = keys.map(decodeGlobalId);
    const byUnderlyingType = entities.reduce((acc, { type, id }) => {
      if (!acc.has(type)) acc.set(type, []);
      acc.get(type)?.push(id);
      return acc;
    }, new Map<string, string[]>());

    const qs = [...byUnderlyingType.entries()].flatMap(([type, ids]) =>
      match(type)
        .with(
          "workinstance",
          () => sql`
              SELECT
                  wi.id AS _key,
                  encode(('name:' || languagemasteruuid)::bytea, 'base64') AS id
              FROM public.workinstance AS wi
              INNER JOIN public.worktemplate AS wt
                  ON wi.workinstanceworktemplateid = wt.worktemplateid
              INNER JOIN public.languagemaster
                  ON worktemplatenameid = languagemasterid
              WHERE wi.id IN ${sql(ids)}
          `,
        )
        .with(
          "worktemplate",
          () => sql`
              SELECT
                  id AS _key,
                  encode(('name:' || languagemasteruuid)::bytea, 'base64') AS id
              FROM public.worktemplate
              INNER JOIN public.languagemaster
                  ON worktemplatenameid = languagemasterid
              WHERE id IN ${sql(ids)}
          `,
        )
        .with(
          "workresult",
          () => sql`
              SELECT
                  id AS _key,
                  encode(('name:' || languagemasteruuid)::bytea, 'base64') AS id
              FROM public.workresult
              INNER JOIN public.languagemaster
                  ON workresultlanguagemasterid = languagemasterid
              WHERE id IN ${sql(ids)}
          `,
        )
        .with(
          "workresultinstance",
          () => sql`
              SELECT
                  wri.id AS _key,
                  encode(('name:' || languagemasteruuid)::bytea, 'base64') AS id
              FROM public.workresultinstance AS wri
              INNER JOIN public.workresult AS wr
                  ON wri.workresultinstanceworkresultid = wr.workresultid
              INNER JOIN public.languagemaster AS lm
                  ON wr.workresultlanguagemasterid = lm.languagemasterid
              WHERE wri.id IN ${sql(ids)}
          `,
        )
        .otherwise(() => []),
    );

    if (!qs.length) return entities.map(() => new EntityNotFound("name"));

    const xs = await sql<[WithKey<Component>]>`${unionAll(qs)}`;
    return entities.map(
      e => xs.find(x => e.id === x._key) ?? new EntityNotFound("name"),
    );
  });
}

export function makeNameLoader(req: Request) {
  return new Dataloader<string, Name, string>(
    async keys => {
      const rows = await sql<WithKey<Name>[]>`
        SELECT
            m.languagemasteruuid AS _key,
            encode(('name:' || m.languagemasteruuid)::bytea, 'base64') AS id,
            coalesce(t.languagetranslationvalue, m.languagemastersource) AS value,
            coalesce(tl.systaguuid, ml.systaguuid) AS "languageId"
        FROM public.languagemaster AS m
        INNER JOIN public.systag AS ml
            ON m.languagemastersourcelanguagetypeid = ml.systagid
        LEFT JOIN public.languagetranslations AS t
            ON
                m.languagemasterid = t.languagetranslationmasterid
                AND t.languagetranslationtypeid = (
                    SELECT systagid
                    FROM public.systag
                    WHERE
                        systagparentid = 2
                        AND systagtype = ${req.i18n.language}
                )
        LEFT JOIN public.systag AS tl
            ON t.languagetranslationtypeid = tl.systagid
        WHERE m.languagemasteruuid IN ${sql(keys)};
      `;

      const byId = rows.reduce(
        (acc, val) => acc.set(val._key, val),
        new Map<string, Name>(),
      );

      return keys.map(key => byId.get(key) ?? new EntityNotFound("name"));
    },
    {
      cacheKeyFn: key => `${key}:${req.i18n.language}`,
    },
  );
}

export async function updateName(input: UpdateNameInput, sql: SQL) {
  const { id } = decodeGlobalId(input.id);
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
              WHERE languagemasteruuid = ${id}
          )
          AND languagetranslationtypeid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.languageId}
          );
  `;

  // Attempt to update the master as well, but only do so if the languages
  // match.
  await sql`
      UPDATE public.languagemaster
      SET
          languagemastermodifieddate = NOW(),
          languagemastersource = ${input.value},
          languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'
      WHERE
          languagemasteruuid = ${id}
          AND languagemastersourcelanguagetypeid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.languageId}
          );
  `;
}

export function makeNameMetadataLoader(_: Request) {
  return new Dataloader<string, NameMetadata>(async keys => {
    const rows = await sql<WithKey<NameMetadata>[]>`
        SELECT
            m.languagemasteruuid AS _key,
            encode(('name:' || m.languagemasteruuid)::bytea, 'base64') AS "nameId",
            m.languagemastersource AS "sourceText",
            l.systaguuid AS "sourceLanguageId",
            m.languagemastertranslationtime::text AS "translatedAt"
        FROM public.languagemaster AS m
        INNER JOIN public.systag AS l
            ON m.languagemastersourcelanguagetypeid = l.systagid
        WHERE m.languagemasteruuid IN ${sql(keys)};
    `;

    const byId = rows.reduce(
      (acc, row) => acc.set(row._key, row),
      new Map<string, NameMetadata>(),
    );

    return keys.map(
      key => byId.get(key) ?? new EntityNotFound("name-metadata"),
    );
  });
}
