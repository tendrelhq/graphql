import sql from "@/datasources/postgres";
import type {
  CustomerResolvers,
  Language,
  Name,
} from "./../__generated__/types.generated";
export const Customer: CustomerResolvers = {
  async name(parent, _, ctx) {
    const [name] = await sql<[Name]>`
      SELECT
          COALESCE(t.languagetranslationid, m.languagemasterid) AS id,
          COALESCE(t.languagetranslationtypeid, m.languagemastersourcelanguagetypeid) AS language_id,
          COALESCE(t.languagetranslationvalue, m.languagemastersource) AS value
      FROM public.languagemaster AS m
      LEFT JOIN public.languagetranslations AS t
          ON
              m.languagemasterid = t.languagetranslationmasterid
              AND t.languagetranslationtypeid = ${ctx.languageTypeId}
      WHERE m.languagemasterid = ${parent.name_id};
    `;

    if (!name) {
      const [fallback] = await sql<[Name]>`
        SELECT
            customeruuid AS id,
            customerlanguagetypeid AS language_id,
            customername AS value
        FROM public.customer
        WHERE customeruuid = ${parent.id};
      `;

      return fallback;
    }

    return name;
  },
  async defaultLanguage(parent) {
    const [language] = await sql<[Language]>`
      SELECT 
          systaguuid AS id,
          systagtype AS code,
          systagnameid AS name_id
      FROM public.systag
      WHERE systaguuid = ${parent.default_language_id};
    `;
    return language;
  },
};

