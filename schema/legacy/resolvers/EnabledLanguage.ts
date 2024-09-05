import { sql } from "@/datasources/postgres";
import type { ActivationStatus, EnabledLanguageResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const EnabledLanguage: EnabledLanguageResolvers = {
  async active(parent) {
    const { id } = decodeGlobalId(parent.id);

    const [row] = await sql<[ActivationStatus]>`
      SELECT
          (
              customerrequestedlanguageenddate IS null
              OR
              customerrequestedlanguageenddate > now()
          ) AS active,
          customerrequestedlanguagestartdate::text AS "activatedAt",
          customerrequestedlanguageenddate::text AS "deactivatedAt"
      FROM public.customerrequestedlanguage
      WHERE customerrequestedlanguageuuid = ${id};
    `;

    return row;
  },
  async language(parent, _, ctx) {
    return ctx.orm.language.byId.load(parent.languageId as string);
  },
};
