import { sql } from "@/datasources/postgres";
import type { EnabledLanguage, MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";

export const disableLanguage: NonNullable<
  MutationResolvers["disableLanguage"]
> = async (_, { languageId, ...args }, ctx) => {
  const { id: orgId } = decodeGlobalId(args.orgId);

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

  const [e] = await sql<[EnabledLanguage]>`
    SELECT
        encode(('enabled-language:' || customerrequestedlanguageuuid)::bytea, 'base64') AS id,
        (
            customerrequestedlanguageenddate IS null
            OR
            customerrequestedlanguageenddate > now()
        ) AS active,
        customerrequestedlanguagestartdate::text AS "activatedAt",
        customerrequestedlanguageenddate::text AS "deactivatedAt",
        ${languageId} AS "languageId",
        (customerrequestedlanguagelanguageid = customerlanguagetypeid) AS primary
    FROM public.customerrequestedlanguage
    INNER JOIN public.customer
        ON customerrequestedlanguagecustomerid = customerid
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
        )
    LIMIT 1;
  `;

  return {
    cursor: e.id.toString(),
    node: e,
  };
};
