import { sql } from "@/datasources/postgres";
import type { LanguageResolvers, Name } from "@/schema";

export const Language: LanguageResolvers = {
  async name(parent, _, ctx) {
    const [name] = await sql<[Name?]>`
      SELECT
          t.languagetranslationid AS id,
          s.systaguuid AS language_id,
          t.languagetranslationvalue AS value
      FROM public.languagetranslations AS t
      INNER JOIN public.systag AS s
          ON t.languagetranslationtypeid = s.systagid
      WHERE
          t.languagetranslationmasterid = ${parent.name_id}
          AND t.languagetranslationtypeid = ${ctx.languageTypeId};
    `;

    if (!name) {
      const [fallback] = await sql<[Name]>`
        SELECT
            m.languagemasterid AS id,
            s.systaguuid AS language_id,
            m.languagemastersource AS value
        FROM public.languagemaster AS m
        INNER JOIN public.systag AS s
            ON m.languagemastersourcelanguagetypeid = s.systagid
        WHERE m.languagemasterid = ${parent.name_id};
      `;

      return fallback;
    }

    return name;
  },
};
