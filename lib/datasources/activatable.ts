import type { ID, ResolversTypes } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { sql, unionAll } from "./postgres";

export function makeActivatableLoader(_req: Request) {
  return new DataLoader<ID, ResolversTypes["Activatable"] | undefined>(
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
                (
                  WITH cte AS (
                      SELECT
                          wr.id AS _key,
                          encode(('workresult:' || wr.id || ':active')::bytea, 'base64') AS id,
                          (
                              wr.workresultenddate IS NULL
                              OR wr.workresultenddate > now()
                          ) AS active,
                          wr.workresultstartdate,
                          wr.workresultenddate
                      FROM public.workresult AS wr
                      WHERE wr.id IN ${sql(ids)}
                  )

                  SELECT
                      _key,
                      id,
                      active,
                      (
                          SELECT row_to_json(t)
                          FROM (
                              'Instant' AS "__typename",
                              (extract(epoch from workresultstartdate) * 1000)::text AS "epochMilliseconds"
                          ) t
                      )
                  FROM cte
                  WHERE active = true
                  UNION ALL
                  SELECT
                      _key,
                      id,
                      active,
                      (
                          SELECT row_to_json(t)
                          FROM (
                              'Instant' AS "__typename",
                              (extract(epoch from workresultenddate) * 1000)::text AS "epochMilliseconds"
                          ) t
                      )
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

                  SELECT
                      _key,
                      id,
                      active,
                      (
                          SELECT row_to_json(t)
                          FROM (
                              SELECT
                                  'Instant' AS "__typename",
                                  (extract(epoch from worktemplatestartdate) * 1000)::text AS "epochMilliseconds"
                          ) t
                      ) AS "updatedAt"
                  FROM cte
                  WHERE active = true
                  UNION ALL
                  SELECT
                      _key,
                      id,
                      active,
                      (
                          SELECT row_to_json(t)
                          FROM (
                              SELECT
                                  'Instant' AS "__typename",
                                  (extract(epoch from worktemplateenddate) * 1000)::text AS "epochMilliseconds"
                          ) t
                      ) as "updatedAt"
                  FROM cte
                  WHERE active = false
                )
            `,
          )
          .otherwise(() => []),
      );

      if (!qs.length) return entities.map(() => undefined);

      type X = WithKey<ResolversTypes["Activatable"]>;
      const xs = await sql<X[]>`${unionAll(qs)}`;
      return entities.map(e => xs.find(x => e.id === x._key));
    },
  );
}
