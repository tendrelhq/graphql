import type { Activatable } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { sql, unionAll } from "./postgres";

export function makeActivatableLoader(_req: Request) {
  return new DataLoader<string, Activatable | undefined>(async keys => {
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
              (
                WITH cte AS (
                    SELECT
                        wr.id AS _key,
                        encode(('workresult:' || wr.id || ':active')::bytea, 'base64') AS id,
                        (
                            wt.worktemplateenddate IS NULL
                            OR wt.worktemplateenddate > now()
                        ) AS active,
                        wr.workresultstartdate,
                        wr.workresultenddate
                    FROM public.workresult AS wr
                    INNER JOIN public.worktemplate AS wt
                        ON wr.workresultworktemplateid = wt.worktemplateid
                    WHERE wr.id IN ${sql(ids)}
                )

                SELECT _key, id, active, workresultstartdate::text AS "updatedAt"
                FROM cte
                WHERE active = true
                UNION ALL
                SELECT _key, id, active, workresultenddate::text AS "updatedAt"
                FROM cte
                WHERE active = false
              )
          `,
        )
        .with(
          "worktemplate",
          () => sql`
              (
                WITH cte AS (
                    SELECT
                        id AS _key,
                        encode(('worktemplate:' || id || ':active')::bytea, 'base64') AS id,
                        (
                            worktemplateenddate IS NULL
                            OR worktemplateenddate > now()
                        ) AS active,
                        worktemplatestartdate,
                        worktemplateenddate
                    FROM public.worktemplate
                    WHERE id IN ${sql(ids)}
                )

                SELECT _key, id, active, worktemplatestartdate::text AS "updatedAt"
                FROM cte
                WHERE active = true
                UNION ALL
                SELECT _key, id, active, worktemplateenddate::text AS "updatedAt"
                FROM cte
                WHERE active = false
              )
          `,
        )
        .otherwise(() => []),
    );

    if (!qs.length) return entities.map(() => undefined);

    const xs = await sql<
      [WithKey<Omit<Activatable, "updatedAt"> & { updatedAt: string }>]
    >`${unionAll(qs)}`;

    return entities.map(e => {
      const c = xs.find(x => e.id === x._key);
      if (c) {
        return {
          ...c,
          updatedAt: {
            __typename: "Instant" as const,
            epochMilliseconds: c.updatedAt,
          },
        };
      }
      return undefined;
    });
  });
}
