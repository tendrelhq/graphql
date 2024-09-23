import type { ChecklistStatus } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { WithKey } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import { match } from "ts-pattern";
import { sql, unionAll } from "./postgres";

type Status = {
  __typename: NonNullable<ChecklistStatus["__typename"]>;
} & {
  id: string;
};

export function makeStatusLoader(_req: Request) {
  return new DataLoader<string, Status | undefined>(async keys => {
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
                  CASE WHEN systagtype = 'Open' THEN 'ChecklistOpen'
                       WHEN systagtype = 'In Progress' THEN 'ChecklistInProgress'
                       ELSE 'ChecklistClosed'
                  END AS "__typename",
                  encode(('workinstance:' || id || ':status')::bytea, 'base64') AS id
              FROM public.workinstance
              INNER JOIN public.systag
                  ON workinstancestatusid = systagid
              WHERE id IN ${sql(ids)}
          `,
        )
        .with(
          "workresultinstance",
          () => sql`
              SELECT
                  id AS _key,
                  CASE WHEN systagtype = 'Open' THEN 'ChecklistOpen'
                       WHEN systagtype = 'In Progress' THEN 'ChecklistInProgress'
                       ELSE 'ChecklistClosed'
                  END AS "__typename",
                  encode(('workresultinstance:' || id || ':status')::bytea, 'base64') AS id
              FROM public.workresultinstance
              INNER JOIN public.systag
                  ON workresultinstancestatusid = systagid
              WHERE id IN ${sql(ids)}
          `,
        )
        .otherwise(() => []),
    );

    if (!qs.length) return entities.map(() => undefined);

    const xs = await sql<WithKey<Status>[]>`${unionAll(qs)}`;
    return entities.map(e => xs.find(x => e.id === x._key));
  });
}
