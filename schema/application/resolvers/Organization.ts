import { sql } from "@/datasources/postgres";
import type {
  Checklist,
  ChecklistSearchOptions,
  OrganizationResolvers,
} from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { match } from "ts-pattern";

export const Organization: Pick<OrganizationResolvers, "checklists"> = {
  async checklists(parent, args) {
    const { id: parentId } = decodeGlobalId(parent.id);
    const rows = await execute(parentId, args, args.search);
    const underlyingType = args.search?.status?.length
      ? "workinstance"
      : "worktemplate";

    return {
      edges: rows.map(row => ({
        cursor: row.id,
        node: row as Checklist,
      })),
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: (underlyingType === "workinstance"
        ? await sql<[{ count: number }]>`
            SELECT count(wi.*)
            FROM public.workinstance AS wi
            INNER JOIN public.worktemplate AS wt
                ON wi.workinstanceworktemplateid = wt.worktemplateid
            INNER JOIN public.worktemplatetype AS wtt
                ON wt.id = wtt.worktemplatetypeworktemplateuuid
            INNER JOIN public.systag AS tt
                ON wtt.worktemplatetypesystaguuid = tt.systaguuid
            INNER JOIN public.systag AS wst
                ON wi.workinstancestatusid = wst.systagid
            WHERE
                wi.workinstancecustomerid = (
                    SELECT customerid
                    FROM public.customer
                    WHERE customeruuid = ${parentId}
                )
                AND tt.systagtype IN ('Checklist')
                AND ${
                  args.search?.active
                    ? sql`(
                        wt.worktemplateenddate IS null
                        OR
                        wt.worktemplateenddate > now()
                    )`
                    : sql`TRUE`
                }
                AND ${
                  args.search?.status?.length
                    ? sql`wst.systagtype IN ${sql(
                        args.search.status.map(e =>
                          match(e)
                            .with("open", () => "Open")
                            .with("inProgress", () => "In Progress")
                            .with("closed", () => "Complete")
                            .exhaustive(),
                        ),
                      )}`
                    : sql`TRUE`
                }
        `
        : await sql<[{ count: number }]>`
            SELECT count(wt.*)
            FROM public.worktemplate AS wt
            INNER JOIN public.worktemplatetype AS wtt
                ON wtt.worktemplatetypeworktemplateuuid = wt.id
            INNER JOIN public.systag AS tt
                ON wtt.worktemplatetypesystaguuid = tt.systaguuid
            WHERE
                wt.worktemplatecustomerid = (
                    SELECT customerid
                    FROM public.customer
                    WHERE customeruuid = ${parentId}
                )
                AND tt.systagtype IN ('Checklist')
                AND ${
                  args.search?.active
                    ? sql`(
                        wt.worktemplateenddate IS null
                        OR
                        wt.worktemplateenddate > now()
                    )`
                    : sql`TRUE`
                }
        `)[0].count,
    };
  },
};

function execute(
  parent: string,
  pagination: {
    first?: number;
    last?: number;
    before?: string;
    after?: string;
  },
  search?: ChecklistSearchOptions,
) {
  const { first, last } = pagination;
  if (search?.status?.length) {
    return sql<{ id: string }[]>`
        SELECT encode(('workinstance:' || wi.id)::bytea, 'base64') AS id
        FROM public.workinstance AS wi
        INNER JOIN public.worktemplate AS wt
            ON wi.workinstanceworktemplateid = wt.worktemplateid
        INNER JOIN public.worktemplatetype AS wtt
            ON wt.id = wtt.worktemplatetypeworktemplateuuid
        INNER JOIN public.systag AS tt
            ON wtt.worktemplatetypesystaguuid = tt.systaguuid
        INNER JOIN public.systag AS wst
            ON wi.workinstancestatusid = wst.systagid
        INNER JOIN public.languagemaster AS dn
            ON wt.worktemplatenameid = dn.languagemasterid
        WHERE
            wi.workinstancecustomerid = (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${parent}
            )
            AND tt.systagtype IN ('Checklist')
            AND ${
              search?.active
                ? sql`(
                    wt.worktemplateenddate IS null
                    OR
                    wt.worktemplateenddate > now()
                )`
                : sql`TRUE`
            }
            AND ${
              search?.displayName?.length
                ? sql`
                    dn.languagemastersource ILIKE '%' || ${search.displayName}::text || '%'
                `
                : sql`TRUE`
            }
            AND wst.systagtype IN ${sql(
              search.status.map(e =>
                match(e)
                  .with("open", () => "Open")
                  .with("inProgress", () => "In Progress")
                  .with("closed", () => "Complete")
                  .exhaustive(),
              ),
            )}
        ORDER BY wi.workinstanceid ${last ? sql`DESC` : sql`ASC`}
        LIMIT ${first ?? last ?? null}
    `;
  }

  return sql<{ id: string }[]>`
      SELECT encode(('worktemplate:' || wt.id)::bytea, 'base64') AS id
      FROM public.worktemplate AS wt
      INNER JOIN public.worktemplatetype AS wtt
          ON wtt.worktemplatetypeworktemplateuuid = wt.id
      INNER JOIN public.systag AS type
          ON wtt.worktemplatetypesystaguuid = type.systaguuid
      INNER JOIN public.languagemaster AS dn
          ON wt.worktemplatenameid = dn.languagemasterid
      WHERE
          wt.worktemplatecustomerid = (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${parent}
          )
          AND type.systagtype IN ('Checklist')
          AND ${
            search?.active
              ? sql`(
                  wt.worktemplateenddate IS null
                  OR
                  wt.worktemplateenddate > now()
              )`
              : sql`TRUE`
          }
          AND ${
            search?.displayName?.length
              ? sql`dn.languagemastersource ILIKE '%' || ${search.displayName}::text || '%'`
              : sql`TRUE`
          }
      ORDER BY wt.worktemplateid ${last ? sql`DESC` : sql`ASC`}
      LIMIT ${first ?? last ?? null}
  `;
}
