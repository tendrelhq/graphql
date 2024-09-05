import { EntityNotFound } from "@/errors";
import type { Tag } from "@/schema";
import Dataloader from "dataloader";
import type { Request } from "express";
import { sql } from "./postgres";

export default (_: Request) =>
  new Dataloader<string, Tag>(async keys => {
    const rows = await sql<Tag[]>`
        SELECT
            s.systaguuid AS id,
            encode(('name:' || n.languagemasteruuid)::bytea, 'base64') AS "nameId",
            p.systaguuid AS "parentId",
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

    return keys.map(key => byKey.get(key) ?? new EntityNotFound("tag"));
  });
