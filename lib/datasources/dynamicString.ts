import type { DynamicString, ID } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { GraphQLError } from "graphql/error";
import { sql } from "./postgres";

export function makeDynamicStringLoader(req: Request) {
  return new DataLoader<ID, DynamicString>(async keys => {
    const entities = keys.map(k => decodeGlobalId(k).id);
    const rows = await sql<[WithKey<DynamicString>]>`
        SELECT
            languagemasteruuid AS _key,
            encode(('trans:' || coalesce(languagetranslationuuid, languagemasteruuid))::bytea, 'base64') AS id,
            coalesce(t.systagtype, m.systagtype) AS locale,
            coalesce(languagetranslationvalue, languagemastersource) AS value

        FROM public.languagemaster
        INNER JOIN public.systag AS m
            ON languagemastersourcelanguagetypeid = systagid
        LEFT JOIN public.languagetranslations
            ON
                languagemasterid = languagetranslationmasterid
                AND languagetranslationtypeid = (
                    SELECT systagid
                    FROM public.systag
                    WHERE
                        systagparentid = 2
                        AND systagtype = ${req.i18n.language}
                )
        LEFT JOIN public.systag AS t
            ON languagetranslationtypeid = t.systagid
        WHERE languagemasteruuid IN ${sql(entities)};
    `;

    const byId = rows.reduce(
      (acc, row) => acc.set(row._key, row),
      new Map<string, DynamicString>(),
    );

    return entities.map(
      id =>
        byId.get(id) ??
        new GraphQLError(`No DynamicString for key '${id}'`, {
          extensions: {
            code: "NOT_FOUND",
          },
        }),
    );
  });
}
