import { NotFoundError } from "@/errors";
import type { Context, Tag } from "@/schema";
import Dataloader from "dataloader";
import { sql } from "./postgres";

export default (ctx: Omit<Context, "orm">) =>
  new Dataloader<string, Tag>(async keys => {
    const rows = await sql<Tag[]>`
        SELECT
            s.systaguuid AS id,
            s.systagnameid AS name_id,
            p.systaguuid AS parent_id,
            s.systagtype AS type
        FROM public.systag AS s
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
