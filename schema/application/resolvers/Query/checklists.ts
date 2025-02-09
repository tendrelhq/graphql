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

type Parent = {
  id: string;
  type: "organization" | "workinstance" | "worktemplate";
};

export const checklists: NonNullable<QueryResolvers["checklists"]> = async (
  _,
  args,
) => {
  const parent = decodeGlobalId(args.parent);
  if (
    parent.type !== "organization" &&
    parent.type !== "workinstance" &&
    parent.type !== "worktemplate"
  ) {
    throw new GraphQLError(
      `Type '${parent.type}' is an invalid parent type for type 'Checklist'`,
      {
        extensions: {
          code: "TYPE_ERROR",
        },
      },
    );
  }

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
    return astQuery(forwardArgs, parent as Parent);
  }

  return ecsQuery(forwardArgs, parent as Parent);
};

type Args = {
  f: Pick<QuerychecklistsArgs, "withActive" | "withName" | "withStatus">;
  p: PaginationArgs;
  s: Pick<QuerychecklistsArgs, "sortBy">;
};

/**
 * When a query does NOT include any ECS filters, we interpret it as an AST-only
 * query, i.e. only look for worktemplates.
 */
function isAstQuery({ f }: Args) {
  return nullish(f.withStatus) || f.withStatus.length === 0;
}

async function astQuery(args: Args, parent: Parent) {
  if (parent.type !== "organization") {
    throw new GraphQLError(
      `Type '${parent.type}' is an invalid parent type for type 'Checklist'`,
      {
        extensions: {
          code: "TYPE_ERROR",
        },
      },
    );
  }

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

  const [{ count }] = await sql<[{ count: bigint }]>`
    SELECT count(*)
    FROM public.worktemplate AS node
    ${buildAstJoinFragments(args, parent)}
    WHERE ${buildAstFilterFragments(args, parent)}
  `;

  return { edges, pageInfo, totalCount: Number(count) };
}

function buildAstJoinFragments(_args: Args, _parent: Parent) {
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

function buildAstSortFragments({ s }: Args, _parent: Parent) {
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

function buildAstPaginationFragments({ p, s }: Args, _parent: Parent) {
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

async function ecsQuery(args: Args, parent: Parent) {
  const edges = await sql<ChecklistEdge[]>`
    WITH
        ${args.p.cursor ? sql`cursor AS ${buildEcsCursor(args.p.cursor.id)},` : sql``}
        nodes AS (
            SELECT encode(('workinstance:' || node.id)::bytea, 'base64') AS id
            FROM public.workinstance AS node
            ${buildEcsJoinFragments(args, parent)}
            WHERE ${join(
              [
                buildEcsFilterFragments(args, parent),
                ...buildEcsPaginationFragments(args, parent),
              ],
              sql`AND`,
            )}
            ORDER BY ${buildEcsSortFragments(args, parent)}
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

  const [{ count }] = await sql<[{ count: bigint }]>`
    SELECT count(*)
    FROM public.workinstance AS node
    ${buildEcsJoinFragments(args, parent)}
    WHERE ${buildEcsFilterFragments(args, parent)}
  `;

  return { edges, pageInfo, totalCount: Number(count) };
}

function buildEcsCursor(cursor: string) {
  return sql`(
      SELECT
          workinstanceid,
          workinstancecompleteddate,
          workinstancemodifieddate,
          workinstancestartdate,
          workinstancestatusid,
          workinstancetargetstartdate,
          workinstanceworktemplateid
      FROM public.workinstance
      WHERE id = ${cursor}
  )`;
}

function buildEcsJoinFragments({ f, s }: Args, _parent: Parent): Fragment {
  const fs: Fragment[] = [];

  // Type checking.
  fs.push(
    sql`INNER JOIN public.worktemplate AS ast
        ON node.workinstanceworktemplateid = ast.worktemplateid
    `,
    sql`INNER JOIN public.worktemplatetype AS type_check
        ON ast.id = type_check.worktemplatetypeworktemplateuuid
    `,
    sql`INNER JOIN public.systag AS type_check_t
        ON
            type_check.worktemplatetypesystaguuid = type_check_t.systaguuid
            AND type_check_t.systagtype = 'Checklist'
    `,
  );

  // We always join this in as it will be used as the default sort order.
  fs.push(
    sql`INNER JOIN public.languagemaster AS name
        ON ast.worktemplatenameid = name.languagemasterid
    `,
  );

  if (nullish(f.withStatus) === false || s.sortBy?.find(s => !!s.status)) {
    fs.push(
      sql`INNER JOIN public.systag AS status
          ON node.workinstancestatusid = status.systagid
      `,
    );
  }

  return join(fs, sql``);
}

function buildEcsFilterFragments({ f }: Args, parent: Parent): Fragment {
  const fs: Fragment[] = [];

  switch (parent.type) {
    case "organization": {
      fs.push(
        sql`node.workinstancecustomerid IN (
            SELECT customerid
            FROM public.customer
            WHERE customeruuid = ${parent.id}
        )`,
      );
      break;
    }
    case "workinstance": {
      fs.push(
        sql`(
            node.workinstancepreviousid IS NOT null
            AND node.workinstancepreviousid IN (
                SELECT workinstanceid
                FROM public.workinstance
                WHERE id = ${parent.id}
            )
        )`,
      );
      break;
    }
    case "worktemplate": {
      fs.push(sql`ast.id = ${parent.id}`);
      break;
    }
    default: {
      const _: never = parent.type;
      break;
    }
  }

  fs.push(
    sql`EXISTS (
        SELECT 1
        FROM public.worktemplatetype
        INNER JOIN public.systag
            ON worktemplatetypesystaguuid = systaguuid
        WHERE
            worktemplatetypeworktemplateuuid = ast.id
            AND systagtype = 'Checklist'
    )`,
  );

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
    // NOTE: for now we are simply excluding Cancelleds entirely.
    // Perhaps one day we will include them.
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

  return join(fs, sql`AND`);
}

function buildEcsPaginationFragments(
  { f, p, s }: Args,
  _parent: Parent,
): Fragment[] {
  if (!p.cursor) {
    return [];
  }

  if (p.cursor.type !== "workinstance") {
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

  // Note that when we spread this into the final query, we are in a WHERE
  // clause in which the individual clauses are ANDed together.
  if (s.sortBy?.length === 2) {
    if (f.withStatus?.length === 1) {
      switch (f.withStatus[0]) {
        case "open":
          return [
            sql`(name.languagemastersource, node.workinstancetargetstartdate) ${cmp} (
                SELECT
                    languagemastersource,
                    cursor.workinstancetargetstartdate
                FROM cursor
                INNER JOIN public.worktemplate AS wt
                    ON cursor.workinstanceworktemplateid = wt.worktemplateid
                INNER JOIN public.languagemaster
                    ON wt.worktemplatenameid = languagemasterid
            )`,
          ];
        case "inProgress":
          return [
            sql`(name.languagemastersource, node.workinstancestartdate) ${cmp} (
                SELECT
                    languagemastersource,
                    cursor.workinstancestartdate
                FROM cursor
                INNER JOIN public.worktemplate AS wt
                    ON cursor.workinstanceworktemplateid = wt.worktemplateid
                INNER JOIN public.languagemaster
                    ON wt.worktemplatenameid = languagemasterid
            )`,
          ];
        case "closed":
          return [
            sql`(name.languagemastersource, node.workinstancecompleteddate) ${cmp} (
                SELECT
                    languagemastersource,
                    cursor.workinstancecompleteddate
                FROM cursor
                INNER JOIN public.worktemplate AS wt
                    ON cursor.workinstanceworktemplateid = wt.worktemplateid
                INNER JOIN public.languagemaster
                    ON wt.worktemplatenameid = languagemasterid
            )`,
          ];
      }
    }

    return [
      sql`(name.languagemastersource, status.systagorder) ${cmp} (
          SELECT
              languagemastersource,
              systagorder
          FROM cursor
          INNER JOIN public.worktemplate AS wt
              ON cursor.workinstanceworktemplateid = wt.worktemplateid
          INNER JOIN public.languagemaster
              ON wt.worktemplatenameid = languagemasterid
          INNER JOIN public.systag
              ON cursor.workinstancestatusid = systagid
      )`,
    ];
  }

  const sortByName = s.sortBy?.find(s => !!s.name);
  if (sortByName) {
    return [
      sql`(name.languagemastersource, node.workinstanceid) ${cmp} (
          SELECT
              languagemastersource,
              cursor.workinstanceid
          FROM cursor
          INNER JOIN public.worktemplate AS wt
              ON cursor.workinstanceworktemplateid = wt.worktemplateid
          INNER JOIN public.languagemaster
              ON wt.worktemplatenameid = languagemasterid
      )`,
    ];
  }

  const sortByStatus = s.sortBy?.find(s => !!s.status);
  if (sortByStatus) {
    if (f.withStatus?.length === 1) {
      const comp = sortByStatus.status === "desc" ? cmpInv : cmp;
      switch (f.withStatus[0]) {
        case "open":
          return [
            // Why all this weird looking mumbo jumbo? Try it for yourself;
            //  SELECT
            //    now() > null AS gt,
            //    now() < null AS lt,
            //    now() = null AS eq,
            //    now() != null AS ne
            sql`(
                (
                    (
                        node.workinstancetargetstartdate IS null
                        OR EXISTS (
                            SELECT 1
                            FROM cursor
                            WHERE workinstancetargetstartdate IS null
                        )
                    )
                    AND (node.workinstancetargetstartdate IS null, node.workinstanceid) ${comp} (
                        SELECT
                            workinstancetargetstartdate IS null,
                            workinstanceid
                        FROM cursor
                    )
                )
                OR
                (
                    node.workinstancetargetstartdate IS NOT null
                    AND EXISTS (SELECT 1 FROM cursor WHERE workinstancetargetstartdate IS NOT null)
                    AND (node.workinstancetargetstartdate, node.workinstanceid) ${comp} (
                        SELECT
                            workinstancetargetstartdate,
                            workinstanceid
                        FROM cursor
                    )
                )
            )`,
          ];
        case "inProgress":
          // workinstancestartdate is semantically non-null in this context.
          return [
            sql`(node.workinstancestartdate, node.workinstanceid) ${comp} (
                SELECT workinstancestartdate, workinstanceid
                FROM public.workinstance
                WHERE id = ${p.cursor.id}
            )`,
          ];
        case "closed":
          // workinstancecompleteddate is semantically non-null in this context.
          return [
            sql`(node.workinstancecompleteddate, node.workinstanceid) ${comp} (
                SELECT workinstancecompleteddate, workinstanceid
                FROM cursor
            )`,
          ];
      }
    }

    return [
      sql`(status.systagorder, node.workinstanceid) ${cmpInv} (
          SELECT systagorder, workinstanceid
          FROM cursor
          INNER JOIN public.systag
              ON workinstancestatusid = systagid
      )`,
    ];
  }

  // The default is to sort by workinstancemodifieddate DESC
  return [
    sql`(node.workinstancemodifieddate, node.workinstanceid) ${cmpInv} (
        SELECT workinstancemodifieddate, workinstanceid
        FROM cursor
    )`,
  ];
}

function buildEcsSortFragments({ f, s }: Args, _parent: Parent): Fragment {
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
  // - If no other conditions apply, we order by workinstancemodifieddate DESC,
  //   i.e. most recently modified first
  const exprs = s.sortBy?.map(s => {
    const order = sortOrder(s.name ?? s.status);
    switch (true) {
      case "name" in s:
        return sql`name.languagemastersource ${order}`;
      case "status" in s: {
        if (f.withStatus?.length === 1) {
          switch (f.withStatus[0]) {
            case "open":
              return sql`node.workinstancetargetstartdate ${order} NULLS FIRST`;
            case "inProgress":
              return sql`node.workinstancestartdate ${order} NULLS LAST`;
            case "closed":
              return sql`node.workinstancecompleteddate ${order} NULLS LAST`;
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
      ...(exprs?.length ? exprs : [sql`node.workinstancemodifieddate DESC`]),
      // In any case, we provide a tie breaker.
      sql`node.workinstanceid DESC`,
    ],
    sql`,`,
  );
}
