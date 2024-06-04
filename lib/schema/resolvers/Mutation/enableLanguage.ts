import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const enableLanguage: NonNullable<MutationResolvers['enableLanguage']> =
  async (_, { orgId, languageId }, ctx) => {
    await sql`
        INSERT INTO public.customerrequestedlanguage (
            customerrequestedlanguagecustomerid,
            customerrequestedlanguagelanguageid,
            customerrequestedlanguagestartdate,
            customerrequestedlanguageenddate
        )
        VALUES (
            (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${orgId}
            ),
            (
                SELECT systagid
                FROM public.systag
                WHERE systaguuid = ${languageId}
            ),
            NOW(),
            NULL
        )
        ON CONFLICT
            (customerrequestedlanguagecustomerid, customerrequestedlanguagelanguageid)
        DO UPDATE
            SET
                customerrequestedlanguagestartdate = NOW(),
                customerrequestedlanguageenddate = NULL,
                customerrequestedlanguagemodifieddate = NOW();
    `;

    return true;
  };
