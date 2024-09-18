import type { Component } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { join, sql } from "./postgres";

export function makeDescriptionLoader(_req: Request) {
  return new DataLoader<string, Component | undefined>(async keys => {
    const entities = keys.map(decodeGlobalId);
    const byUnderlyingType = entities.reduce((acc, { type, id }) => {
      if (!acc.has(type)) acc.set(type, []);
      acc.get(type)?.push(id);
      return acc;
    }, new Map<string, string[]>());

    const xs = await sql<[WithKey<Component>]>`${join(
      [...byUnderlyingType.entries()].flatMap(([type, ids]) =>
        match(type)
          .with(
            "workinstance",
            () => sql`
                SELECT
                    wi.id AS _key,
                    encode(('workinstance:' || wi.id || ':description')::bytea, 'base64') AS id
                FROM public.workinstance AS wi
                INNER JOIN public.worktemplate AS wt
                    ON wi.workinstanceworktemplateid = wt.worktemplateid
                    AND wt.worktemplatedescriptionid IS NOT NULL
                WHERE wi.id IN ${sql(ids)}
            `,
          )
          .with(
            "worktemplate",
            () => sql`
                SELECT
                    id AS _key,
                    encode(('worktemplate:' || id || ':description')::bytea, 'base64') AS id
                FROM public.worktemplate
                WHERE
                    id IN ${sql(ids)}
                    AND worktemplatedescriptionid IS NOT NULL
            `,
          )
          .otherwise(() => []),
      ),
      sql`UNION ALL`,
    )}`;

    return entities.map(e => xs.find(row => row._key === e.id));
  });
}
