import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { GraphQLError } from "graphql";

export const disableLanguage: NonNullable<
  MutationResolvers["disableLanguage"]
> = async (_, { orgId, languageId }, __) => {
  await sql.begin(async sql => {
    const check = await sql`
        SELECT 1
        FROM public.customer
        WHERE
            customeruuid = ${orgId}
            AND customerlanguagetypeid = (
                SELECT systagid
                FROM public.systag
                WHERE systaguuid = ${languageId}
            );
    `;

    // Disallow disabling an organization's primary language.
    if (check.length) {
      throw new GraphQLError("Cannot disable primary language", {
        extensions: {
          code: "BAD_REQUEST",
          hint: "Try changing your primary language first",
        },
      });
    }

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
  });

  return true; // FIXME: should return an Activated/ActivationState
};
