import type { ID, ResolversTypes } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { sql, unionAll } from "./postgres";

export function makeAuditableLoader(_req: Request) {
  return new DataLoader<ID, ResolversTypes["Auditable"] | undefined>(
    async keys => {
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
                    'Auditable' AS "__typename",
                    encode(('workresult:' || id || ':auditable')::bytea, 'base64') AS id,
                    workresultforaudit AS auditable
                FROM public.workresult
                WHERE id IN ${sql(ids)}
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
                WHERE id IN ${sql(ids)}
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
