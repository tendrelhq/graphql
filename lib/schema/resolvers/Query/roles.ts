import { sql } from "@/datasources/postgres";
import type { QueryResolvers, Tag } from "@/schema";

export const roles: NonNullable<QueryResolvers["roles"]> = async (
  _,
  __,
  ___,
) => {
  return await sql<Tag[]>`
    SELECT
        systaguuid AS id,
        systagtype AS type,
        systagnameid AS name_id
    FROM public.systag
    WHERE systagparentid = 772;
  `;
};
