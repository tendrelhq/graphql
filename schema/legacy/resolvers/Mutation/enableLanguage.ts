import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";

export const enableLanguage: NonNullable<
  MutationResolvers["enableLanguage"]
> = async (_, { languageId, ...args }, ctx) => {
  const { id: orgId } = decodeGlobalId(args.orgId);

  const [key] = await sql.begin(async sql => {
    // This is basically an "upsert". When first enabling a language, no such
    // record will exist and thus the INSERT will take. A record *will exist*
    // in the event that we are *re-enabling* a language, and in such case the
    // CONFLICT clause will fire and ensure that the necessary updates are
    // made to re-enable the language.
    // biome-ignore lint/complexity/noBannedTypes:
    const [key] = await sql<[WithKey<{}>]>`
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
            now(),
            null
        )
        ON CONFLICT
            (customerrequestedlanguagecustomerid, customerrequestedlanguagelanguageid)
        DO UPDATE
            SET
                customerrequestedlanguagestartdate = now(),
                customerrequestedlanguageenddate = null,
                customerrequestedlanguagemodifieddate = now()
        RETURNING customerrequestedlanguageuuid AS _key;
    `;

    // FIXME: This is bad. This scales linearly with the count of
    // languagemasters.
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

    return [key];
  });

  const row = await ctx.orm.crl.load(key._key);

  return {
    cursor: row.id.toString(),
    node: row,
  };
};
