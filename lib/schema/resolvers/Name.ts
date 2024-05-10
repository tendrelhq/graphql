import { sql } from "@/datasources/postgres";
import type {
  Language,
  NameResolvers,
} from "./../__generated__/types.generated";
export const Name: NameResolvers = {
  async language(parent) {
    console.log(
      "typeof parent.language_id =:",
      typeof parent.language_id,
      parent.language_id,
    );
    const [language] = await sql<[Language]>`
      SELECT
          systaguuid AS id,
          systagtype AS code,
          systagnameid AS name_id
      FROM public.systag
      WHERE ${
        Number.isNaN(Number(parent.language_id))
          ? sql`systaguuid = ${parent.language_id}`
          : sql`systagid = ${parent.language_id}`
      };
    `;
    return language;
  },
};
