import { EntityNotFound } from "@/errors";
import type { EnabledLanguage } from "@/schema";
import type { WithKey } from "@/util";
import Dataloader from "dataloader";
import type { Request } from "express";
import { sql } from "./postgres";

export default (_: Request) =>
  new Dataloader<string, EnabledLanguage>(async keys => {
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
      (acc, row) => acc.set(row._key as string, row),
      new Map<string, EnabledLanguage>(),
    );

    return keys.map(
      key => byKey.get(key) ?? new EntityNotFound("enabled-language"),
    );
  });
