import { sql } from "@/datasources/postgres";
import type { Language, NameResolvers } from "@/schema";

export const Name: NameResolvers = {
  async language(parent) {
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
