import { sql } from "@/datasources/postgres";
import type { Checklist, OrganizationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const Organization: Pick<OrganizationResolvers, "checklists"> = {
  async checklists(parent, args) {
    const { id: parentId } = decodeGlobalId(parent.id);

    const rows = await sql<[{ id: string }]>`
        SELECT encode(('workinstance:' || id)::bytea, 'base64') AS id
        FROM public.workinstance
        WHERE
            workinstancecustomerid = (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${parentId}
            )
        UNION ALL
        SELECT encode(('worktemplate:' || id)::bytea, 'base64') AS id
        FROM public.worktemplate
        WHERE
            worktemplatecustomerid = (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${parentId}
            )
        LIMIT ${args.first ?? null}
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
      totalCount: rows.length,
    };
  },
};
