import { join, sql } from "@/datasources/postgres";
import { nullish, validateParent } from "@/util";
import type { Fragment } from "postgres";
import { match } from "ts-pattern";
import type { QueryResolvers } from "./../../../__generated__/types.generated";

export const checklistAgg: NonNullable<QueryResolvers["checklistAgg"]> = async (
  _parent,
  arg,
  ctx,
) => {
  const parent = validateParent(arg.parent, "organization");
  const conditions: Fragment[] = [];

  if (nullish(arg.withActive) === false) {
    conditions.push(sql`
    (${arg.withActive} = TRUE AND (wt.worktemplateenddate IS NULL OR wt.worktemplateenddate > NOW()))
    OR (${arg.withActive} = FALSE AND wt.worktemplateenddate < NOW())
   `);
  }

  if (arg.withStatus?.length && arg.withStatus.length > 0) {
    conditions.push(
      sql`status.systagtype IN ${sql(
        arg.withStatus.map(e =>
          match(e)
            .with("open", () => "Open")
            .with("inProgress", () => "In Progress")
            .with("closed", () => "Complete")
            .exhaustive(),
        ),
      )}`,
    );
  }

  const whereStatement: Fragment = conditions.length
    ? sql`WHERE ${join(conditions, sql`AND`)}`
    : sql``;

  const count = await sql<{ count: number }[]>`
SELECT COUNT(*) AS count
FROM workinstance wi
         INNER JOIN customer c ON wi.workinstancecustomerid = c.customerid AND customeruuid = ${parent.id}
         INNER JOIN worktemplate wt
                    ON wi.workinstanceworktemplateid = wt.worktemplateid AND wt.worktemplatecustomerid = c.customerid
         INNER JOIN worktemplatetype wtt ON wtt.worktemplatetypeworktemplateuuid = wt.id AND
                                            wtt.worktemplatetypecustomeruuid = c.customeruuid
         INNER JOIN systag type ON type.systaguuid = wtt.worktemplatetypesystaguuid AND type.systagtype = 'Checklist'
         INNER JOIN systag status ON wi.workinstancestatusid = status.systagid
${whereStatement}
`;

  return {
    count: count[0].count,
  };
};
