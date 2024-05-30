import { sql } from "@/datasources/postgres";
import type { Language, QueryResolvers } from "@/schema";

export const languages: NonNullable<QueryResolvers['languages']> = async (
  _,
  __,
  ___,
) => {
  return await sql<Language[]>`
    SELECT
        systaguuid AS id,
        systagtype AS code,
        systagnameid AS name_id
    FROM public.systag
    WHERE
        systagparentid = 2
        AND systagtype IN ('en', 'es');
  `;
};
