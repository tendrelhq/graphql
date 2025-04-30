import type { Organization } from "@/schema";
import type { WithKey } from "@/util";
import Dataloader from "dataloader";
import type { Request } from "express";
import { GraphQLError } from "graphql/error";
import { sql } from "./postgres";

export default (_: Request) =>
  new Dataloader<string, Organization>(async keys => {
    const rows = await sql<WithKey<Organization>[]>`
        SELECT
            o.customeruuid AS _key,
            encode(('organization:' || o.customeruuid)::bytea, 'base64') AS id,
            (o.customerenddate IS NULL OR o.customerenddate > NOW()) AS active,
            o.customerstartdate AS "activatedAt",
            o.customerenddate AS "deactivatedAt",
            o.customerexternalid AS "billingId",
            bt.systagtype AS "billingType",
            (o.customerexternalid IS NOT NULL AND bt.systagtype = 'Stripe') AS "isPaying",
            encode(('name:' || n.languagemasteruuid)::bytea, 'base64') AS "nameId"
        FROM public.customer AS o
        INNER JOIN public.languagemaster AS n
            ON o.customernamelanguagemasterid = n.languagemasterid
        LEFT JOIN public.systag as bt
            ON o.customerexternalsystemid = bt.systagid
        WHERE o.customeruuid IN ${sql(keys)};
    `;

    const byId = rows.reduce(
      (acc, row) => acc.set(row._key, row),
      new Map<string, Organization>(),
    );

    return keys.map(
      key =>
        byId.get(key) ??
        new GraphQLError(`No Customer for key '${key}'`, {
          extensions: {
            code: "NOT_FOUND",
          },
        }),
    );
  });
