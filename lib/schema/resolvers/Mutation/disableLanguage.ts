import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const disableLanguage: NonNullable<
  MutationResolvers["disableLanguage"]
> = async (_, { orgId, languageId }, __) => {
  await sql`
      UPDATE public.customerrequestedlanguage
      SET
          customerrequestedlanguageenddate = NOW(),
          customerrequestedlanguagemodifieddate = NOW()
      WHERE
          customerrequestedlanguagecustomerid = (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${orgId}
          )
          AND customerrequestedlanguagelanguageid = (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${languageId}
          );
  `;

  return true;
};
