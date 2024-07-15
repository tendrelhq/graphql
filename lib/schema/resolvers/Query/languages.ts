import { sql } from "@/datasources/postgres";
import type { Language, QueryResolvers } from "@/schema";

export const languages: NonNullable<QueryResolvers['languages']> = async (
  _,
  __,
  ___,
) => {
  return await sql<Language[]>`
    SELECT
        s.systaguuid AS id,
        s.systagtype AS code,
        n.languagemasteruuid AS name_id
    FROM public.systag AS s
    INNER JOIN public.languagemaster AS n
        ON s.systagnameid = n.languagemasterid
    WHERE s.systagparentid = 2;
  `;
};
