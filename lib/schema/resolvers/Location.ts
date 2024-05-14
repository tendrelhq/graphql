import { assertAuthenticated } from "@/auth";
import { sql } from "@/datasources/postgres";
import type { LocationResolvers, Name } from "@/schema";

export const Location: LocationResolvers = {
  async name(parent, _, ctx) {
    assertAuthenticated(ctx);

    const [name] = await sql<[Name]>`
      SELECT
          COALESCE(t.languagetranslationid, m.languagemasterid) AS id,
          COALESCE(t.languagetranslationtypeid, m.languagemastersourcelanguagetypeid) AS language_id,
          COALESCE(t.languagetranslationvalue, m.languagemastersource) AS value
      FROM public.languagemaster AS m
      LEFT JOIN public.languagetranslations AS t
          ON
              m.languagemasterid = t.languagetranslationmasterid
              AND t.languagetranslationtypeid = ${ctx.user.language}
      WHERE m.languagemasterid = ${parent.name_id};
    `;

    return name;
  },
};
