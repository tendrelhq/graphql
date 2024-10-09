import { join, sql } from "@/datasources/postgres";
import type {
  ChecklistEdge,
  PageInfo,
  QueryResolvers,
  QuerychecklistsArgs,
} from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import {
  type PaginationArgs,
  buildPaginationArgs,
  nullish,
  sortOrder,
} from "@/util";
import { GraphQLError } from "graphql";
import type { Fragment } from "postgres";
import { match } from "ts-pattern";

type ParentType = "organization" | "workinstance";
type Row = { __typename: "Checklist"; id: string };

export const checklists: NonNullable<QueryResolvers["checklists"]> = async (
  _,
  args,
) => {
  const { id: parentId, type: parentType } = decodeGlobalId(args.parent);

  if (parentType !== "organization" && parentType !== "workinstance") {
    throw new GraphQLError(
      `Type '${parentType}' is an invalid parent type for type 'Checklist'`,
      {
        extensions: {
          code: "TYPE_ERROR",
        },
      },
    );
  }

  // Reconstruct the object but with a type assertion on `type`.
  const parent = { id: parentId, type: parentType as ParentType };
  const paginationArgs = buildPaginationArgs(args, {
    defaultLimit: Number(process.env.DEFAULT_PAGINATION_LIMIT ?? 20),
    maxLimit: Number(process.env.MAX_PAGINATION_LIMIT ?? 20),
  });
  const forwardArgs: Args = {
    f: args,
    p: {
      ...paginationArgs,
      // N+1 to obviate the need for a separate PageInfo query.
      limit: paginationArgs.limit + 1,
    },
    s: args,
  };

  if (isAstQuery(forwardArgs)) {
    return astQuery(forwardArgs, parent);
  }

  const result = await sql.begin(async tx => {
    const rows = await tx<Row[]>`${edges(forwardArgs, parent)}`;

    // FIXME: ideally this would all go in a single query.
    // Note that this is NOT the same as rows.length! It is the total count of
    // rows that *could* be returned, e.g. if you were to paginate through the
    // entire list.
    const totalCount = await count(forwardArgs, parent);

    // TODO: revisit the graphql cursor connection specification and check the
    // logic for forward vs reverse pagination.
    const hasNext = Boolean(args.first && rows.length > paginationArgs.limit);
    const hasPrev = Boolean(args.last && rows.length > paginationArgs.limit);
    // Recall that we N+1 the original limit to obviate the need for a separate
    // PageInfo query.
    if (rows.length > paginationArgs.limit) rows.pop();

    return {
      edges: rows,
      hasNextPage: hasNext,
      hasPreviousPage: hasPrev,
      totalCount,
    };
  });

  return {
    edges: result.edges.map(node => ({
      cursor: node.id,
      // biome-ignore lint/suspicious/noExplicitAny:
      node: node as any,
    })),
    pageInfo: {
      startCursor: result.edges.at(0)?.id,
      endCursor: result.edges.at(-1)?.id,
      hasNextPage: result.hasNextPage,
      hasPreviousPage: result.hasPreviousPage,
    },
    totalCount: result.totalCount,
  };
};

type Args = {
  f: Pick<QuerychecklistsArgs, "withActive" | "withName" | "withStatus">;
  p: PaginationArgs;
  s: Pick<QuerychecklistsArgs, "sortBy">;
};

type Parent = {
  id: string;
  type: ParentType;
};

/**
 * When a query does NOT include any ECS filters, we interpret it as an AST-only
 * query, i.e. only look for worktemplates.
 */
function isAstQuery({ f }: Args) {
  return nullish(f.withStatus) || f.withStatus.length === 0;
}

async function astQuery(args: Args, parent: Parent) {
  const edges = await sql<ChecklistEdge[]>`
    WITH nodes AS (
        SELECT encode(('worktemplate:' || node.id)::bytea, 'base64') AS id
        FROM public.worktemplate AS node
        ${buildAstJoinFragments(args, parent)}
        WHERE ${join(
          [
            buildAstFilterFragments(args, parent),
            ...buildAstPaginationFragments(args, parent),
          ],
          sql`AND`,
        )}
        ORDER BY ${buildAstSortFragments(args, parent)}
        LIMIT ${args.p.limit}
    )

    SELECT
        id AS cursor,
        jsonb_build_object('__typename', 'Checklist', 'id', id) AS node
    FROM nodes
  `;

  // recall: n+1
  const n1 = edges.length >= args.p.limit ? edges.pop() : false;
  const hasNext = args.p.direction === "forward" && !!n1;
  const hasPrev = args.p.direction === "backward" && !!n1;

  const pageInfo: PageInfo = {
    startCursor: edges.at(0)?.cursor,
    endCursor: edges.at(-1)?.cursor,
    hasNextPage: hasNext,
    hasPreviousPage: hasPrev,
  };

  const [{ count }] = await sql<[{ count: number }]>`
    SELECT count(*)
    FROM public.worktemplate AS node
    ${buildAstJoinFragments(args, parent)}
    WHERE ${buildAstFilterFragments(args, parent)}
  `;

  return { edges, pageInfo, totalCount: count };
}

function buildAstJoinFragments(args: Args, parent: Parent) {
  const fs: Fragment[] = [
    // We always join in the Name component. We use as the default sort order if
    // no other sort orders are specified.
    sql`INNER JOIN public.languagemaster AS name ON node.worktemplatenameid = name.languagemasterid`,
  ];
  return join(fs, sql`AND`);
}

function buildAstFilterFragments(args: Args, parent: Parent) {
  const fs: Fragment[] = [
    sql`node.worktemplatecustomerid IN (
        SELECT customerid
        FROM public.customer
        WHERE customeruuid = ${parent.id}
    )`,
    sql`EXISTS (
        SELECT 1
        FROM public.worktemplatetype
        INNER JOIN public.systag
            ON worktemplatetypesystaguuid = systaguuid
        WHERE
            worktemplatetypeworktemplateuuid = node.id
            AND
            systagtype = 'Checklist'
    )`,
  ];

  if (nullish(args.f.withActive) === false) {
    fs.push(
      args.f.withActive
        ? sql`(
              node.worktemplateenddate IS null
              OR
              node.worktemplateenddate > now()
          )`
        : sql`(
            node.worktemplateenddate IS NOT null
            AND
            node.worktemplateenddate < now()
        )`,
    );
  }

  if (args.f.withName?.length) {
    fs.push(
      sql`name.languagemastersource ILIKE '%' || ${args.f.withName} || '%'`,
    );
  }

  return join(fs, sql`AND`);
}

function buildAstSortFragments({ s }: Args, parent: Parent) {
  const fs: Fragment[] = [];

  const sortByName = s.sortBy?.find(s => !!s.name);
  if (sortByName) {
    fs.push(
      sql`lower(name.languagemastersource) ${sortOrder(sortByName.name)}`,
    );
  }

  fs.push(
    sql`node.worktemplatemodifieddate DESC`, // newest first
  );

  return join(fs, sql`,`);
}

function buildAstPaginationFragments({ p, s }: Args, parent: Parent) {
  if (!p.cursor) {
    return [];
  }

  if (p.cursor.type !== "worktemplate") {
    throw new GraphQLError(
      `Type '${p.cursor.type}' is an invalid cursor type for type 'Checklist'`,
      {
        extensions: {
          code: "TYPE_ERROR",
        },
      },
    );
  }

  const cmp = match(p.direction)
    .with("forward", () => sql`>`)
    .with("backward", () => sql`<`)
    .exhaustive();
  const cmpInv = match(p.direction)
    .with("forward", () => sql`<`)
    .with("backward", () => sql`>`)
    .exhaustive();

  // Note that we must account for our ordering fragments here as well!
  // Luckily, the only one we have right now is on Name.
  const sortByName = s.sortBy?.find(s => !!s.name);
  if (sortByName) {
    return [
      sql`(lower(name.languagemastersource), node.worktemplatemodifieddate) ${cmp} (
          SELECT
              lower(languagemastersource),
              worktemplatemodifieddate
          FROM public.worktemplate
          INNER JOIN public.languagemaster
              ON worktemplatenameid = languagemasterid
          WHERE id = ${p.cursor.id}
      )`,
    ];
  }

  return [
    sql`(node.worktemplatemodifieddate) ${cmpInv} (
        SELECT worktemplatemodifieddate
        FROM public.worktemplate
        WHERE id = ${p.cursor.id}
    )`,
  ];
}

async function count(args: Args, parent: Parent) {
  switch (parent.type) {
    // TODO: rename...
    case "organization": {
      const [{ count }] = await sql<[{ count: number }]>`
          SELECT count(*)
          FROM public.workinstance AS e
          ${buildJoinFragments(args, parent)}
          WHERE ${join(
            [
              sql`e.workinstancecustomerid IN (
                  SELECT customerid
                  FROM public.customer
                  WHERE customeruuid = ${parent.id}
              )`,
              ...buildFilterFragments(args, parent),
            ],
            sql`AND`,
          )}
      `;
      return count;
    }
    case "workinstance": {
      const [{ count }] = await sql<[{ count: number }]>`
          SELECT count(*)
          FROM public.workinstance AS e
          ${buildJoinFragments(args, parent)}
          WHERE ${join(
            [
              sql`(
                  e.workinstancepreviousid IS NOT null
                  AND
                  e.workinstancepreviousid IN (
                      SELECT workinstanceid
                      FROM public.workinstance
                      WHERE id = ${parent.id}
                  )
              )`,
              ...buildFilterFragments(args, parent),
            ],
            sql`AND`,
          )}
      `;
      return count;
    }
  }
}

// TODO: This should ideally LEFT JOIN workinstance and then coalesce the output
// IDs. The idea being IF there are instances, return those. Otherwise, we
// return the AST node (i.e. worktemplate) which can still be used by the
// frontend to *create* an ECS node on the fly (at least for On Demands).
function edges(args: Args, parent: Parent) {
  // FIXME: This doesn't actually build an Edge, but rather a Node.
  // Ideally it would build a full Edge, but we'd need to inspect the
  // GraphQLResolveInfo to see what we should actually grab.
  switch (parent.type) {
    // TODO: rename...
    case "organization": {
      return sql`
          SELECT
              'Checklist' AS "__typename",
              encode(('workinstance:' || e.id)::bytea, 'base64') AS id
          FROM public.workinstance AS e
          ${buildJoinFragments(args, parent)}
          WHERE ${join(
            [
              sql`e.workinstancecustomerid IN (
                  SELECT customerid
                  FROM public.customer
                  WHERE customeruuid = ${parent.id}
              )`,
              ...buildFilterFragments(args, parent),
              ...[buildPaginationFragment(args, parent)].filter(f => !!f),
            ],
            sql`AND`,
          )}
          ORDER BY ${buildOrderByFragment(args, parent)}
          LIMIT ${args.p.limit}
      `;
    }
    case "workinstance":
      return sql`
          SELECT
              'Checklist' AS "__typename",
              encode(('workinstance:' || e.id)::bytea, 'base64') AS id
          FROM public.workinstance AS e
          ${buildJoinFragments(args, parent)}
          WHERE ${join(
            [
              sql`(
                  e.workinstancepreviousid IS NOT null
                  AND
                  e.workinstancepreviousid IN (
                      SELECT workinstanceid
                      FROM public.workinstance
                      WHERE id = ${parent.id}
                  )
              )`,
              ...buildFilterFragments(args, parent),
              ...[buildPaginationFragment(args, parent)].filter(f => !!f),
            ],
            sql`AND`,
          )}
          ORDER BY ${buildOrderByFragment(args, parent)}
          LIMIT ${args.p.limit}
      `;
  }
}

function buildJoinFragments({ f, s }: Args, _: Parent) {
  const fs = [
    sql`INNER JOIN public.worktemplate AS ast
            ON e.workinstanceworktemplateid = ast.worktemplateid`,
    // TODO: This should coalesce with languagetranslations using req.i18n
    sql`INNER JOIN public.languagemaster AS name
            ON ast.worktemplatenameid = name.languagemasterid`,
    // This is used by the filter fragment when the user constructs an ECS query
    // of the form query(..., In<:StatusState>).
    s.sortBy?.find(s => !!s.status) || f.withStatus?.length
      ? sql`INNER JOIN public.systag AS status
                ON e.workinstancestatusid = status.systagid`
      : null,
  ];
  return fs.filter(f => !!f);
}

function buildFilterFragments({ f }: Args, _: Parent) {
  const fs = [];

  if (!process.env.__HACK_IGNORE_TEMPLATE_TYPE_FOR_TESTING) {
    fs.push(
      sql`EXISTS (
          SELECT 1
          FROM public.worktemplatetype
          INNER JOIN public.systag
              ON worktemplatetypesystaguuid = systaguuid
          WHERE
              worktemplatetypeworktemplateuuid = ast.id
              AND
              systagtype = 'Checklist'
      )`,
    );
  }

  if (nullish(f.withActive) === false) {
    if (f.withActive) {
      fs.push(
        sql`(ast.worktemplateenddate IS null OR ast.worktemplateenddate > now())`,
      );
    } else {
      fs.push(
        sql`(ast.worktemplateenddate IS NOT null AND ast.worktemplateenddate < now())`,
      );
    }
  }

  if (f.withName) {
    fs.push(
      sql`name.languagemastersource ILIKE '%' || ${f.withName}::text || '%'`,
    );
  }

  if (f.withStatus?.length) {
    fs.push(
      sql`status.systagtype IN ${sql(
        f.withStatus.map(e =>
          match(e)
            .with("open", () => "Open")
            .with("inProgress", () => "In Progress")
            .with("closed", () => "Complete")
            .exhaustive(),
        ),
      )}`,
    );
  }

  return fs;
}

function buildPaginationFragment({ f, p, s }: Args, _: Parent) {
  console.log("cursor?", p.cursor);
  if (!p.cursor) {
    return null; // not paginated
  }

  // FIXME: Although this could in theory be a worktemplate, if that were the
  // case in practice we would have thrown a TYPE_ERROR in the top-level
  // resolver.
  if (p.cursor.type !== "workinstance" && p.cursor.type !== "worktemplate") {
    throw new GraphQLError(
      `Type '${p.cursor.type}' is an invalid cursor type for type 'Checklist'`,
      {
        extensions: {
          code: "TYPE_ERROR",
        },
      },
    );
  }

  const { direction } = p;
  function comparator(invert?: boolean) {
    switch (direction) {
      case "forward":
        return invert ? sql`<` : sql`>`;
      case "backward":
        return invert ? sql`>` : sql`<`;
    }
  }

  // Note that when we spread this into the final query, we are in a WHERE
  // clause in which the individual clauses are ANDed together.
  if (s.sortBy?.length === 2) {
    if (f.withStatus?.length === 1) {
      switch (f.withStatus[0]) {
        case "open":
          return sql`(name.languagemastersource, e.workinstancetargetstartdate) ${comparator()} (
              SELECT
                  languagemastersource,
                  workinstancetargetstartdate
              FROM public.workinstance AS wi
              INNER JOIN public.worktemplate AS wt
                  ON wi.workinstanceworktemplateid = wt.worktemplateid
              INNER JOIN public.languagemaster
                  ON wt.worktemplatenameid = languagemasterid
              WHERE wi.id = ${p.cursor.id}
          )`;
        case "inProgress":
          return sql`(name.languagemastersource, e.workinstancestartdate) ${comparator()} (
              SELECT
                  languagemastersource,
                  workinstancestartdate
              FROM public.workinstance AS wi
              INNER JOIN public.worktemplate AS wt
                  ON wi.workinstanceworktemplateid = wt.worktemplateid
              INNER JOIN public.languagemaster
                  ON wt.worktemplatenameid = languagemasterid
              WHERE wi.id = ${p.cursor.id}
          )`;
        case "closed":
          return sql`(name.languagemastersource, e.workinstancecompleteddate) ${comparator()} (
              SELECT
                  languagemastersource,
                  workinstancecompleteddate
              FROM public.workinstance AS wi
              INNER JOIN public.worktemplate AS wt
                  ON wi.workinstanceworktemplateid = wt.worktemplateid
              INNER JOIN public.languagemaster
                  ON wt.worktemplatenameid = languagemasterid
              WHERE wi.id = ${p.cursor.id}
          )`;
      }
    }

    return sql`(name.languagemastersource, status.systagorder) ${comparator()} (
        SELECT
            languagemastersource,
            systagorder
        FROM public.workinstance AS wi
        INNER JOIN public.worktemplate AS wt
            ON wi.workinstanceworktemplateid = wt.worktemplateid
        INNER JOIN public.languagemaster
            ON wt.worktemplatenameid = languagemasterid
        INNER JOIN public.systag
            ON wi.workinstancestatusid = systagid
        WHERE wi.id = ${p.cursor.id}
    )`;
  }

  const sortByName = s.sortBy?.find(s => !!s.name);
  if (sortByName) {
    return sql`(name.languagemastersource) ${comparator()} (
        SELECT languagemastersource
        FROM public.workinstance AS wi
        INNER JOIN public.worktemplate AS wt
            ON wi.workinstanceworktemplateid = wt.worktemplateid
        INNER JOIN public.languagemaster
            ON wt.worktemplatenameid = languagemasterid
        WHERE wi.id = ${p.cursor.id}
    )`;
  }

  const sortByStatus = s.sortBy?.find(s => !!s.status);
  if (sortByStatus) {
    if (f.withStatus?.length === 1) {
      const comp = comparator(sortByStatus.status === "desc");
      switch (f.withStatus[0]) {
        case "open":
          return sql`(e.workinstancetargetstartdate, workinstanceid) ${comp} (
              SELECT workinstancetargetstartdate, workinstanceid
              FROM public.workinstance
              WHERE id = ${p.cursor.id}
          )`;
        case "inProgress":
          return sql`(e.workinstancestartdate, e.workinstanceid) ${comp} (
              SELECT workinstancestartdate, workinstanceid
              FROM public.workinstance
              WHERE id = ${p.cursor.id}
          )`;
        case "closed":
          return sql`(e.workinstancecompleteddate, e.workinstanceid) ${comp} (
              SELECT workinstancecompleteddate, workinstanceid
              FROM public.workinstance
              WHERE id = ${p.cursor.id}
          )`;
      }
    }

    return sql`(status.systagorder, e.workinstanceid) ${comparator()} (
        SELECT systagorder, workinstanceid
        FROM public.workinstance
        INNER JOIN public.systag
            ON workinstancestatusid = systagid
        WHERE id = ${p.cursor.id}
    )`;
  }

  // The default is to sort by workinstancecreateddate DESC
  return sql`(e.workinstancecreateddate, e.workinstanceid) ${comparator(true)} (
      SELECT workinstancecreateddate, workinstanceid
      FROM public.workinstance
      WHERE id = ${p.cursor.id}
  )`;
}

function buildOrderByFragment({ f, s }: Args, _: Parent) {
  // Our ordering requirements are as follows:
  // - both `sortByName` and `sortByStatus`; see below.
  // - `sortByStatus` is affected by the `withStatus` filter.
  //    - if `withStatus` specifies a single filter, then we sort by the
  //      relevant timestamp associated with that status:
  //        open: workinstancetargetstartdate, NULLS FIRST (i.e. On Demands first)
  //        inprogress: workinstancestartdate
  //        closed: workinstancecompleteddate
  //    - otherwise: systagorder
  // - `sortByName`: languagemastersource
  // - If no other conditions apply, we order by workinstancecreateddate DESC,
  //   i.e. newest first.
  const exprs = s.sortBy?.map(s => {
    const order = sortOrder(s.name ?? s.status);
    switch (true) {
      case "name" in s:
        return sql`name.languagemastersource ${order}`;
      case "status" in s: {
        if (f.withStatus?.length === 1) {
          switch (f.withStatus[0]) {
            case "open":
              return sql`e.workinstancetargetstartdate ${order} NULLS FIRST`;
            case "inProgress":
              return sql`e.workinstancestartdate ${order} NULLS LAST`;
            case "closed":
              return sql`e.workinstancecompleteddate ${order} NULLS LAST`;
          }
        }

        return sql`status.systagorder ${order}`;
      }
      default: {
        const _: never = s;
        throw "invariant violated";
      }
    }
  });

  return join(
    [
      ...(exprs ?? [sql`e.workinstancecreateddate DESC`]),
      // In any case, we provide a tie breaker.
      sql`e.workinstanceid DESC`,
    ],
    sql`,`,
  );
}
