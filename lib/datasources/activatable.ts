import type { ID, ResolversTypes } from "@/schema";
import { decodeGlobalId, type GlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { sql, unionAll } from "./postgres";

export function makeActiveLoader(_req: Request) {
  return new DataLoader<ID, ResolversTypes["Active"] | undefined>(
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
                (
                  WITH cte AS (
                      SELECT
                          wr.id AS _key,
                          (
                              wr.workresultenddate IS NULL
                              OR wr.workresultenddate > now()
                          ) AS active,
                          wr.workresultstartdate,
                          wr.workresultenddate
                      FROM public.workresult AS wr
                      WHERE wr.id IN ${sql(ids.map(i => i.id))}
                  )

                  SELECT
                      _key,
                      active,
                      jsonb_build_object(
                          '__typename',
                          'Instant',
                          'epochMilliseconds',
                          (extract(epoch from workresultstartdate) * 1000)::text
                      ) AS "updatedAt"
                  FROM cte
                  WHERE active = true
                  UNION ALL
                  SELECT
                      _key,
                      active,
                      jsonb_build_object(
                          '__typename',
                          'Instant',
                          'epochMilliseconds',
                          (extract(epoch from workresultenddate) * 1000)::text
                      ) AS "updatedAt"
                  FROM cte
                  WHERE active = false
                )
            `,
          )
          .with(
            "workresultinstance",
            () => sql`
                (
                  WITH cte AS (
                      SELECT
                          (wi.id || ':' || wr.id) AS _key,
                          (
                              wr.workresultenddate IS null
                              OR wr.workresultenddate > now()
                          ) AS active,
                          wr.workresultstartdate,
                          wr.workresultenddate
                      FROM public.workinstance AS wi
                      INNER JOIN public.workresult AS wr
                          ON wi.workinstanceworktemplateid = wr.workresultworktemplateid
                      WHERE
                          (wi.id, wr.id) IN ${sql(ids.map(i => sql([i.id, i.suffix?.at(0) ?? ""])))}
                  )

                  SELECT
                      _key,
                      active,
                      jsonb_build_object(
                          '__typename',
                          'Instant',
                          'epochMilliseconds',
                          (extract(epoch from workresultstartdate) * 1000)::text
                      ) AS "updatedAt"
                  FROM cte
                  WHERE active = true
                  UNION ALL
                  SELECT
                      _key,
                      active,
                      jsonb_build_object(
                          '__typename',
                          'Instant',
                          'epochMilliseconds',
                          (extract(epoch from workresultenddate) * 1000)::text
                      ) AS "updatedAt"
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
                          (
                              worktemplateenddate IS NULL
                              OR worktemplateenddate > now()
                          ) AS active,
                          worktemplatestartdate,
                          worktemplateenddate
                      FROM public.worktemplate
                      WHERE id IN ${sql(ids.map(i => i.id))}
                  )

                  SELECT
                      _key,
                      active,
                      jsonb_build_object(
                          '__typename',
                          'Instant',
                          'epochMilliseconds',
                          (extract(epoch from worktemplatestartdate) * 1000)::text
                      ) AS "updatedAt"
                  FROM cte
                  WHERE active = true
                  UNION ALL
                  SELECT
                      _key,
                      active,
                      jsonb_build_object(
                          '__typename',
                          'Instant',
                          'epochMilliseconds',
                          (extract(epoch from worktemplateenddate) * 1000)::text
                      ) AS "updatedAt"
                  FROM cte
                  WHERE active = false
                )
            `,
          )
          .otherwise(() => []),
      );

      if (!qs.length) return entities.map(() => undefined);

      type X = WithKey<ResolversTypes["Active"]>;
      const xs = await sql<X[]>`${unionAll(qs)}`;
      return entities.map(e => {
        const key = [e.id, ...(e.suffix ?? [])].join(":");
        return xs.find(x => x._key === key);
      });
    },
  );
}
