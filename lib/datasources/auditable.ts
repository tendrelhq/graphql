import type { Component } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { join, sql } from "./postgres";

export function makeAuditableLoader(_req: Request) {
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
            "workresult",
            () => sql`
                SELECT
                    id AS _key,
                    encode(('workresult:' || id || ':auditable')::bytea, 'base64') AS id
                FROM public.workresult
                WHERE id IN ${sql(ids)}
            `,
          )
          .with(
            "worktemplate",
            () => sql`
                SELECT
                    id AS _key,
                    encode(('worktemplate:' || id || ':auditable')::bytea, 'base64') AS id
                FROM public.worktemplate
                WHERE id IN ${sql(ids)}
            `,
          )
          .otherwise(() => []),
      ),
      sql`UNION ALL`,
    )}`;

    return entities.map(e => xs.find(x => e.id === x._key));
  });
}
