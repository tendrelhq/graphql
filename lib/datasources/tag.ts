import { NotFoundError } from "@/errors";
import type { Context, Tag } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

export default (ctx: Omit<Context, "orm">) =>
  new Dataloader<string, Tag>(async keys => {
    const rows = await sql<Tag[]>`
        SELECT
            s.systaguuid AS id,
            n.languagemasteruuid AS name_id,
            p.systaguuid AS parent_id,
            s.systagtype AS type
        FROM public.systag AS s
        INNER JOIN public.languagemaster AS n
            ON s.systagnameid = n.languagemasterid
        LEFT JOIN public.systag AS p
            ON s.systagparentid = p.systagid
        WHERE s.systaguuid IN ${sql(keys)};
    `;

    const byKey = rows.reduce(
      (acc, row) => acc.set(row.id as string, row),
      new Map<string, Tag>(),
    );

    return keys.map(key => byKey.get(key) ?? new NotFoundError(key, "tag"));
  });
