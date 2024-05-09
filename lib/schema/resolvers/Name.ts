import sql from "@/datasources/postgres";
import type {
  Language,
  NameResolvers,
} from "./../__generated__/types.generated";
export const Name: NameResolvers = {
  async language(parent) {
    const [language] = await sql<[Language]>`
      SELECT
          systaguuid AS id,
          systagtype AS code,
          systagnameid AS name_id
      FROM public.systag
      WHERE systaguuid = ${parent.language_id};
    `;
    return language;
  },
};

