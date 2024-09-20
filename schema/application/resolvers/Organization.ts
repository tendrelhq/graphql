import { sql } from "@/datasources/postgres";
import type { Checklist, OrganizationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const Organization: Pick<OrganizationResolvers, "checklists"> = {
  async checklists(parent, args) {
    const { first, last } = args;
    const { id: parentId } = decodeGlobalId(parent.id);

    const rows = await sql<[{ id: string }]>`
        SELECT encode(('worktemplate:' || wt.id)::bytea, 'base64') AS id
        FROM public.worktemplate AS wt
        INNER JOIN public.worktemplatetype AS wtt
            ON wtt.worktemplatetypeworktemplateuuid = wt.id
        INNER JOIN public.systag AS type
            ON wtt.worktemplatetypesystaguuid = type.systaguuid
        WHERE
            wt.worktemplatecustomerid = (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${parentId}
            )
            AND type.systagtype IN ('Checklist')
        ORDER BY worktemplateid ${last ? sql`DESC` : sql`ASC`}
        LIMIT ${first ?? last ?? null}
    `;
    // TODO: For workinstances:
    // const rows = await sql<[{ id: string }]>`
    //     SELECT encode(('workinstance:' || id)::bytea, 'base64') AS id
    //     FROM public.workinstance
    //     WHERE
    //         workinstancecustomerid = (
    //             SELECT customerid
    //             FROM public.customer
    //             WHERE customeruuid = ${parentId}
    //         )
    //     ORDER BY workinstanceid ${last ? sql`DESC` : sql`ASC`}
    //     LIMIT ${first ?? last ?? null}
    // `;

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
