import type { ID, Tag } from "@/schema";
import Dataloader from "dataloader";
import type { Request } from "express";
import { GraphQLError } from "graphql/error";
import { sql } from "./postgres";

export default (_: Request) =>
  new Dataloader<ID, Tag>(async keys => {
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
      (acc, row) => acc.set(row.id, row),
      new Map<ID, Tag>(),
    );

    return keys.map(
      key =>
        byKey.get(key) ??
        new GraphQLError(`No Tag for key '${key}'`, {
          extensions: {
            code: "NOT_FOUND",
          },
        }),
    );
  });
