import type { ID, ResolversTypes } from "@/schema";
import { decodeGlobalId, type GlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { sql, unionAll } from "./postgres";

export function makeAuditableLoader(_req: Request) {
  return new DataLoader<ID, ResolversTypes["Auditable"] | undefined>(
    async keys => {
      const entities = keys.map(decodeGlobalId);
      const byUnderlyingType = entities.reduce((acc, { type, ...ids }) => {
        if (!acc.has(type)) acc.set(type, []);
        acc.get(type)?.push(ids);
        return acc;
      }, new Map<string, Omit<GlobalId, "type">[]>());

      const qs = [...byUnderlyingType.entries()].flatMap(([type, ids]) =>
        match(type)
          .with(
            "workresult",
            () => sql`
                SELECT
                    id AS _key,
                    'Auditable' AS "__typename",
                    encode(('workresult:' || id || ':auditable')::bytea, 'base64') AS id,
                    workresultforaudit AS auditable
                FROM public.workresult
                WHERE id IN ${sql(ids.map(i => i.id))}
            `,
          )
          .with(
            "worktemplate",
            () => sql`
                SELECT
                    id AS _key,
                    'Auditable' AS "__typename",
                    encode(('worktemplate:' || id || ':auditable')::bytea, 'base64') AS id,
                    worktemplateisauditable AS auditable
                FROM public.worktemplate
                WHERE id IN ${sql(ids.map(i => i.id))}
            `,
          )
          .otherwise(() => []),
      );

      if (!qs.length) return entities.map(() => undefined);

      type X = WithKey<ResolversTypes["Auditable"]>;
      const xs = await sql<X[]>`${unionAll(qs)}`;
      return entities.map(e => xs.find(x => e.id === x._key));
    },
  );
}
