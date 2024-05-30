import { NotFoundError } from "@/errors";
import type { Context, Organization } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

export default (ctx: Omit<Context, "orm">) =>
  new Dataloader<string, Organization>(async keys => {
    const rows = await sql<Organization[]>`
      SELECT
          c.customeruuid AS id,
          (c.customerenddate IS NULL OR c.customerenddate > NOW()) AS active,
          c.customerstartdate AS activated_at,
          c.customerenddate AS deactivated_at,
          n.languagemasteruuid AS name_id
      FROM public.customer AS c
      INNER JOIN public.languagemaster AS n
          ON c.customernamelanguagemasterid = n.languagemasterid
      WHERE c.customeruuid IN ${sql(keys)};
    `;

    const byId = rows.reduce(
      (acc, row) => acc.set(row.id as string, row),
      new Map<string, Organization>(),
    );

    return keys.map(
      key => byId.get(key) ?? new NotFoundError(key, "organization"),
    );
  });
