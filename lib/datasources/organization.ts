import { NotFoundError } from "@/errors";
import type { Context, Organization } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

export default (ctx: Omit<Context, "orm">) =>
  new Dataloader<string, Organization>(async keys => {
    const rows = await sql<Organization[]>`
        SELECT
            o.customeruuid AS id,
            (o.customerenddate IS NULL OR o.customerenddate > NOW()) AS active,
            o.customerstartdate AS activated_at,
            o.customerenddate AS deactivated_at,
            (
                SELECT o.customerexternalid
                FROM public.systag AS s
                WHERE
                    o.customerexternalsystemid IS NOT NULL
                    AND s.systagid = o.customerexternalsystemid
                    AND s.systagtype = 'Stripe'
            ) AS billing_id,
            n.languagemasteruuid AS name_id
        FROM public.customer AS o
        INNER JOIN public.languagemaster AS n
            ON o.customernamelanguagemasterid = n.languagemasterid
        WHERE o.customeruuid IN ${sql(keys)};
    `;

    const byId = rows.reduce(
      (acc, row) => acc.set(row.id as string, row),
      new Map<string, Organization>(),
    );

    return keys.map(
      key => byId.get(key) ?? new NotFoundError(key, "organization"),
    );
  });
