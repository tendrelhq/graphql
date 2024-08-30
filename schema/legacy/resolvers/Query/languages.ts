import { sql } from "@/datasources/postgres";
import type { Language, QueryResolvers } from "@/schema";

export const languages: NonNullable<QueryResolvers["languages"]> = async (
  _,
  __,
  ___,
) => {
  return await sql<Language[]>`
    SELECT
        systaguuid AS id,
        systagtype AS code,
        encode(('name:' || languagemasteruuid)::bytea, 'base64') AS "nameId"
    FROM public.systag
    INNER JOIN public.languagemaster
        ON systagnameid = n.languagemasterid
    WHERE systagparentid = 2
    ORDER BY systagorder ASC, systagid ASC;
  `;
};
