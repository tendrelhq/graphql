import type { ID } from "@/schema";
import { decodeGlobalId, type GlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { sql, unionAll } from "./postgres";

type Required = { required: boolean };

export function makeRequirementLoader(_req: Request) {
  return new DataLoader<ID, boolean | undefined>(async keys => {
    const entities = keys.map(decodeGlobalId);
    const byUnderlyingType = entities.reduce((acc, { type, ...ids }) => {
      if (!acc.has(type)) acc.set(type, []);
      acc.get(type)?.push(ids);
      return acc;
    }, new Map<string, Omit<GlobalId, "type">[]>());

    const qs = [...byUnderlyingType.entries()].flatMap(([type, ids]) =>
      match(type)
        .with(
          "workinstance",
          () => sql`
                SELECT
                    id AS _key,
                    false AS required
                FROM public.workinstance
                WHERE id IN ${sql(ids.map(i => i.id))}
            `,
        )
        .with(
          "workresult",
          () => sql`
                SELECT
                    id AS _key,
                    workresultisrequired AS required
                FROM public.workresult
                WHERE id IN ${sql(ids.map(i => i.id))}
            `,
        )
        .with(
          "workresultinstance",
          () => sql`
                SELECT
                    (wi.id || ':' || wr.id) AS _key,
                    wr.workresultisrequired AS required
                FROM public.workinstance AS wi
                INNER JOIN public.workresult AS wr
                    ON wi.workinstanceworktemplateid = wr.workresultworktemplateid
                WHERE
                    (wi.id, wr.id) IN ${sql(ids.map(i => sql([i.id, i.suffix?.at(0)!])))}
            `,
        )
        .with(
          "worktemplate",
          () => sql`
                SELECT
                    id AS _key,
                    false AS required
                FROM public.worktemplate
                WHERE id IN ${sql(ids.map(i => i.id))}
            `,
        )
        .otherwise(() => []),
    );

    if (!qs.length) return entities.map(() => undefined);

    const xs = await sql<WithKey<Required>[]>`${unionAll(qs)}`;
    return entities.map(e => {
      const key = [e.id, ...(e.suffix ?? [])].join(":");
      return xs.find(x => x._key === key)?.required;
    });
  });
}
