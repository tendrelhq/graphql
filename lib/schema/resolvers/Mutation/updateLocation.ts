import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const updateLocation: NonNullable<MutationResolvers['updateLocation']> =
  async (_, { input }, ctx) => {
    const existing = await ctx.orm.location.load(input.id);
    await sql.begin(async sql => {
      // `child_id` implies a translation. When given, update the specified
      // translation with the new value.
      if (input.name) {
        const changes = await sql<{ n: number }[]>`
            UPDATE public.languagetranslations
            SET
                languagetranslationvalue = ${input.name.value},
                languagetranslationmodifieddate = NOW()
            WHERE
                languagetranslationmasterid = (
                    SELECT languagemasterid
                    FROM public.languagemaster
                    WHERE languagemasteruuid = ${input.name.id}
                )
                AND languagetranslationtypeid = (
                    SELECT systagid
                    FROM public.systag
                    WHERE systaguuid = ${input.name.language_id}
                )
            RETURNING 1 AS n;
        `;

        if (!changes.length) {
          await sql`
              UPDATE public.languagemaster
              SET
                  languagemastersource = ${input.name.value},
                  languagemastersourcelanguagetypeid = (
                      SELECT systagid
                      FROM public.systag
                      WHERE systaguuid = ${input.name.language_id}
                  ),
                  languagemastermodifieddate = NOW()
              WHERE languagemasteruuid = ${input.name.id};
          `;
        }
      }

      await sql`
          UPDATE public.location
          SET
              locationscanid = ${input.scan_code ?? null},
              locationmodifieddate = NOW()
          WHERE locationuuid = ${existing.id};
      `;
    });
    return ctx.orm.location.clear(input.id).load(input.id);
  };
