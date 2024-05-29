import { sql } from "@/datasources/postgres";
import type { QueryResolvers, Tag } from "@/schema";

export const roles: NonNullable<QueryResolvers["roles"]> = async (
  _,
  __,
  ___,
) => {
  return await sql<Tag[]>`
    SELECT
        s.systaguuid AS id,
        s.systagtype AS type,
        n.languagemasteruuid AS name_id
    FROM public.systag AS s
    INNER JOIN public.languagemaster AS n
        ON s.systagnameid = n.languagemasterid
    WHERE s.systagparentid = 772;
  `;
};
