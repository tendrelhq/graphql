import type { ID, Sop } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { sql, unionAll } from "./postgres";

export function makeSopLoader(_req: Request) {
  return new DataLoader<ID, Sop | undefined>(async keys => {
    const entities = keys.map(decodeGlobalId);
    const byUnderlyingType = entities.reduce((acc, { type, id }) => {
      if (!acc.has(type)) acc.set(type, []);
      acc.get(type)?.push(id);
      return acc;
    }, new Map<string, string[]>());

    const qs = [...byUnderlyingType.entries()].flatMap(([type, ids]) =>
      match(type)
        .with(
          "workresult",
          () => sql`
                SELECT
                    id AS _key,
                    encode(('workresult:' || id || ':sop')::bytea, 'base64') AS id,
                    workresultsoplink AS sop
                FROM public.workresult
                WHERE
                    id IN ${sql(ids)}
                    AND workresultsoplink IS NOT NULL
            `,
        )
        .with(
          "worktemplate",
          () => sql`
                SELECT
                    id AS _key,
                    encode(('worktemplate:' || id || ':sop')::bytea, 'base64') AS id,
                    worktemplatesoplink AS sop
                FROM public.worktemplate
                WHERE
                    id IN ${sql(ids)}
                    AND worktemplatesoplink IS NOT NULL
            `,
        )
        .otherwise(() => []),
    );

    if (!qs.length) return entities.map(() => undefined);

    const xs = await sql<[WithKey<Sop>]>`${unionAll(qs)}`;
    return entities.map(e => xs.find(x => e.id === x._key));
  });
}
