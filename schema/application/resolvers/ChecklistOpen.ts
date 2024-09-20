import { sql } from "@/datasources/postgres";
import type { ChecklistOpenResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { match } from "ts-pattern";

export const ChecklistOpen: ChecklistOpenResolvers = {
  async openedAt(parent) {
    const { type, id } = decodeGlobalId(parent.id);
    const [{ epochMilliseconds }] = await match(type)
      .with(
        "workinstance",
        () => sql<[{ epochMilliseconds: string }]>`
            SELECT workinstancecreateddate::text AS "epochMilliseconds"
            FROM public.workinstance
            WHERE id = ${id}
        `,
      )
      .with(
        "workresultinstance",
        () => sql<[{ epochMilliseconds: string }]>`
            SELECT workresultinstancecreateddate::text AS "epochMilliseconds"
            FROM public.workresultinstance
            WHERE id = ${id}
        `,
      )
      .otherwise(() => Promise.reject("invariant violated"));

    return { __typename: "Instant", epochMilliseconds };
  },
};
