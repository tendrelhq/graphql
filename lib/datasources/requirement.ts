import type { ID } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { sql, unionAll } from "./postgres";

type Required = { required: boolean };

export function makeRequirementLoader(_req: Request) {
  return new DataLoader<ID, boolean | undefined>(async keys => {
    const entities = keys.map(decodeGlobalId);
    const byUnderlyingType = entities.reduce((acc, { type, id }) => {
      if (!acc.has(type)) acc.set(type, []);
      acc.get(type)?.push(id);
      return acc;
    }, new Map<string, string[]>());

    const qs = [...byUnderlyingType.entries()].flatMap(([type, ids]) =>
      match(type)
        .with(
          "workinstance",
          () => sql`
                SELECT
                    id AS _key,
                    false AS required
                FROM public.workinstance
                WHERE id IN ${sql(ids)}
            `,
        )
        .with(
          "workresult",
          () => sql`
                SELECT
                    id AS _key,
                    workresultisrequired AS required
                FROM public.workresult
                WHERE id IN ${sql(ids)}
            `,
        )
        .with(
          "workresultinstance",
          () => sql`
                SELECT
                    wri.id AS _key,
                    wr.workresultisrequired AS required
                FROM public.workresultinstance AS wri
                INNER JOIN public.workresult AS wr
                    ON wri.workresultinstanceworkresultid = wr.workresultid
                WHERE wri.id IN ${sql(ids)}
            `,
        )
        .with(
          "worktemplate",
          () => sql`
                SELECT
                    id AS _key,
                    false AS required
                FROM public.worktemplate
                WHERE id IN ${sql(ids)}
            `,
        )
        .otherwise(() => []),
    );

    if (!qs.length) return entities.map(() => undefined);

    const xs = await sql<WithKey<Required>[]>`${unionAll(qs)}`;
    return entities.map(e => xs.find(x => e.id === x._key)?.required);
  });
}
