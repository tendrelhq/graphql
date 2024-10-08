import { sql } from "@/datasources/postgres";
import type { AssigneeResolvers, ResolversTypes } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { match } from "ts-pattern";

export const Assignee: AssigneeResolvers = {
  async assignedAt(parent, _, ctx) {
    const { type, id } = decodeGlobalId(parent.id);
    console.log({ type, id });
    const [row] = await match(type)
      .with(
        "workresultinstance",
        () => sql<[ResolversTypes["Temporal"]]>`
            SELECT
                'Instant' AS "__typename",
                (extract(epoch from coalesce(workresultinstancestartdate, workresultinstancecreateddate)) * 1000)::text AS "epochMilliseconds"
            FROM public.workresultinstance
            WHERE id = ${id}
        `,
      )
      .otherwise(() => Promise.reject("invariant violated"));
    return row;
  },
  async assignedTo(parent, _, ctx) {
    const { type, id } = decodeGlobalId(parent.id);
    const [row] = await match(type)
      .with(
        "workresultinstance",
        () => sql<[ResolversTypes["Assignable"]]>`
            SELECT
                'Worker' AS "__typename",
                encode(('worker:' || w.workerinstanceuuid)::bytea, 'base64') AS id
            FROM public.workresultinstance AS wri
            INNER JOIN public.workerinstance AS w
                ON wri.workresultinstancevalue::bigint = w.workerinstanceid
            WHERE wri.workresultinstanceuuid = ${id}
        `,
      )
      .otherwise(() => Promise.reject("invariant violated"));
    return row;
  },
};
