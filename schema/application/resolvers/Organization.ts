import { sql } from "@/datasources/postgres";
import type { Checklist, OrganizationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const Organization: Pick<OrganizationResolvers, "checklists"> = {
  async checklists(parent, args) {
    const { first, last } = args;
    const { id: parentId } = decodeGlobalId(parent.id);

    // TODO: Similar thing for workinstances, but right now all we care about
    // are worktemplates.
    const rows = await sql<[{ id: string }]>`
        SELECT encode(('worktemplate:' || id)::bytea, 'base64') AS id
        FROM public.worktemplate
        WHERE
            worktemplatecustomerid = (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${parentId}
            )
        LIMIT ${first ?? last ?? null}
    `;

    return {
      edges: rows.map(row => ({
        cursor: row.id,
        node: row as Checklist,
      })),
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: (
        await sql<[{ count: number }]>`
            SELECT count(*)
            FROM public.worktemplate
            WHERE
                worktemplatecustomerid = (
                    SELECT customerid
                    FROM public.customer
                    WHERE customeruuid = ${parentId}
                );
        `
      )[0].count,
    };
  },
};
