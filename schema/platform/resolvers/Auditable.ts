import { sql } from "@/datasources/postgres";
import type { AuditableResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { match } from "ts-pattern";

export const Auditable: AuditableResolvers = {
  async auditable(parent) {
    const { type, id } = decodeGlobalId(parent.id);
    const [{ auditable }] = await match(type)
      .with(
        "workresult",
        () => sql<[{ auditable: boolean }]>`
            SELECT workresultforaudit AS auditable
            FROM public.workresult
            WHERE id = ${id}
        `,
      )
      .with(
        "worktemplate",
        () => sql<[{ auditable: boolean }]>`
            SELECT worktemplateisauditable AS auditable
            FROM public.worktemplate
            WHERE id = ${id}
        `,
      )
      .otherwise(() => Promise.reject());
    return auditable;
  },
  async enabled(parent) {
    const { type, id } = decodeGlobalId(parent.id);
    const [{ auditable }] = await match(type)
      .with(
        "workresult",
        () => sql<[{ auditable: boolean }]>`
            SELECT workresultforaudit AS auditable
            FROM public.workresult
            WHERE id = ${id}
        `,
      )
      .with(
        "worktemplate",
        () => sql<[{ auditable: boolean }]>`
            SELECT worktemplateisauditable AS auditable
            FROM public.worktemplate
            WHERE id = ${id}
        `,
      )
      .otherwise(() => Promise.reject());
    return auditable;
  },
};
