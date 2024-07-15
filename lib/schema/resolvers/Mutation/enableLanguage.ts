import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const enableLanguage: NonNullable<MutationResolvers['enableLanguage']> = async (_, { orgId, languageId }, ctx) => {
  await sql.begin(async sql => {
    // This is basically an "upsert". When first enabling a language, no such
    // record will exist and thus the INSERT will take. A record *will exist*
    // in the event that we are *re-enabling* a language, and in such case the
    // CONFLICT clause will fire and ensure that the necessary updates are
    // made to re-enable the language.
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

    // Set a flag to trigger the translation service.
    await sql`
        UPDATE public.languagemaster
        SET languagemasterstatus = 'NEEDS_TRANSLATION'
        WHERE
            languagemastercustomerid = (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${orgId}
            );
    `;
  });

  return true; // FIXME: should return an Activated/ActivationState
};
