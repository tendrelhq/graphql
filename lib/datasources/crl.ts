import type { EnabledLanguage, ID } from "@/schema";
import type { WithKey } from "@/util";
import Dataloader from "dataloader";
import type { Request } from "express";
import { GraphQLError } from "graphql/error";
import { sql } from "./postgres";

export default (_: Request) =>
  new Dataloader<ID, EnabledLanguage>(async keys => {
    const rows = await sql<WithKey<EnabledLanguage>[]>`
        SELECT
            customerrequestedlanguageuuid AS _key,
            encode(('enabled-language:' || customerrequestedlanguageuuid)::bytea, 'base64') AS id,
            systaguuid AS "languageId",
            (customerrequestedlanguagelanguageid = customerlanguagetypeid) AS "primary"
        FROM public.customerrequestedlanguage
        INNER JOIN public.customer
            ON customerrequestedlanguagecustomerid = customerid
        INNER JOIN public.systag
            ON customerrequestedlanguagelanguageid = systagid
        WHERE customerrequestedlanguageuuid IN ${sql(keys)};
    `;

    const byKey = rows.reduce(
      (acc, row) => acc.set(row._key, row),
      new Map<ID, EnabledLanguage>(),
    );

    return keys.map(
      key =>
        byKey.get(key) ??
        new GraphQLError(`No CRL with id '${key}'`, {
          extensions: {
            code: "NOT_FOUND",
          },
        }),
    );
  });
