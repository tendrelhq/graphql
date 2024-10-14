import { sql } from "@/datasources/postgres";
import type { Context, ID, MutationResolvers, ResolversTypes } from "@/schema";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";

export const assign: NonNullable<MutationResolvers["assign"]> = async (
  _,
  { entity, to },
  ctx,
) => {
  const { type, id } = decodeGlobalId(entity);
  console.log("entity", { type, id });

  switch (type) {
    case "workinstance":
      return assignWorkInstance(id, to, ctx);
    // case "worktemplate":
    //   return assignWorkTemplate(id, to, ctx);
  }

  throw new GraphQLError("Entity cannot be assigned", {
    extensions: {
      code: "E_NOT_ASSIGNABLE",
    },
  });
};

async function assignWorkInstance(entity: string, to: ID, _ctx: Context) {
  // Assigning a workinstance is straightforward. We just want to update the
  // workresultinstance for the "primary worker" to the entity (Worker) we've
  // been given.

  // First though we must check that we actually did get a Worker as part of the
  // operation.
  const { type, id } = decodeGlobalId(to);
  console.log("to", { type, id });
  if (type !== "worker") {
    throw new GraphQLError("Entity cannot be assigned", {
      extensions: {
        code: "E_NOT_ASSIGNABLE",
      },
    });
  }

  // Now we upsert the workresultinstance. On conflict (i.e. the workinstance is
  // already assigned) we do nothing and subsequently return an error indicating
  // that the entity has already been assigned.
  const result = await sql`
      WITH entity AS (
          SELECT
              wi.workinstanceid,
              wi.workinstancecustomerid,
              wi.workinstanceworktemplateid
          FROM public.workinstance AS wi
          WHERE
              wi.id = ${entity}
      ),

      ast AS (
          SELECT wr.workresultid
          FROM public.workresult AS wr
          INNER JOIN public.worktemplate AS wt
              ON wr.workresultworktemplateid = wt.worktemplateid
          WHERE
              wt.worktemplateid IN (
                  SELECT workinstanceworktemplateid
                  FROM entity
              )
              AND
              wr.workresulttypeid IN (
                  SELECT systagid
                  FROM public.systag
                  WHERE
                      systagparentid = 699
                      AND
                      systagtype = 'Entity'
              )
              AND
              wr.workresultentitytypeid IN (
                  SELECT systagid
                  FROM public.systag
                  WHERE
                      systagparentid = 849
                      AND
                      systagtype = 'Worker'
              )
              AND
              wr.workresultisprimary = true
      ),

      other AS (
          SELECT w.workerinstanceid
          FROM public.workerinstance AS w
          WHERE w.workerinstanceuuid = ${id}
      ),

      delta AS (
          INSERT INTO public.workresultinstance AS wri (
              workresultinstancecustomerid,
              workresultinstanceworkinstanceid,
              workresultinstanceworkresultid,
              workresultinstancevalue
          )
          SELECT
              entity.workinstancecustomerid,
              entity.workinstanceid,
              ast.workresultid,
              other.workerinstanceid::text
          FROM entity, ast, other
          ON CONFLICT
              (workresultinstanceworkinstanceid, workresultinstanceworkresultid)
          DO UPDATE
              SET
                  workresultinstancevalue = excluded.workresultinstancevalue,
                  workresultinstancemodifieddate = now()

              WHERE
                  nullif(wri.workresultinstancevalue, '') IS null
                  OR wri.workresultinstancevalue != excluded.workresultinstancevalue
          RETURNING 1
      )

      SELECT 1
      FROM delta
      UNION ALL
      SELECT 1
      FROM public.workresultinstance AS wri
      WHERE
          wri.workresultinstanceworkinstanceid IN (
              SELECT workinstanceid
              FROM entity
          )
          AND
          wri.workresultinstanceworkresultid IN (
              SELECT workresultid
              FROM ast
          )
          AND
          wri.workresultinstancevalue IN (
              SELECT workerinstanceid::text
              FROM other
          )
  `;

  /*
   * Some notes on the above query:
   * The "delta" CTE is a (potentially) data-modifying CTE. It is also an
   * UPSERT; the ON CONFLICT ... DO UPDATE makes it so. It will INSERT when
   * there is no such workresultinstance for the given
   * (workinstanceid,workresultid) conflict target. The UPDATE action is further
   * restricted such that "re-assigning" an entity raises an error.
   *
   * The subsequent SELECT ... UNION ALL ... SELECT satisfies the api constraint
   * that "assigning an already assigned entity to the same entity" is a no-op.
   * This works because all statements see the same snapshot of the underlying
   * tables, so the "delta" cte may or may not contain any rows *but these rows
   * will NOT be seen by the final SELECT*. The final SELECT looks for the no-op
   * case, which is an existing Assignee (workresultinstance) for the given Worker.
   */

  if (!result.length) {
    throw new GraphQLError("Entity already assigned", {
      extensions: {
        code: "E_ASSIGN_CONFLICT",
      },
    });
  }

  if (result.length === 2) {
    throw "invariant violated";
  }

  return {
    entity: {
      __typename: "Checklist",
      id: encodeGlobalId({ type: "workinstance", id: entity }),
    },
    assignedTo: {
      __typename: "Worker",
      id: to,
    },
  } as ResolversTypes["AssignmentPayload"];
}

async function assignWorkTemplate(
  entity: string,
  to: ID,
  ctx: Context,
): Promise<ResolversTypes["AssignmentPayload"]> {
  throw "not implemented";
  // return {
  //   entity: {
  //     __typename: "Checklist",
  //     id: encodeGlobalId({ type: "workinstance", id: "" }),
  //   },
  //   assignedTo: {
  //     __typename: "Worker",
  //     id: to,
  //   },
  // } as ResolversTypes["AssignmentPayload"];
}
