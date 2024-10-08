import { sql } from "@/datasources/postgres";
import type { Context, ID, MutationResolvers, ResolversTypes } from "@/schema";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";

export const unassign: NonNullable<MutationResolvers["unassign"]> = async (
  _,
  { entity, from },
  ctx,
) => {
  const { type, id } = decodeGlobalId(entity);
  console.log("entity", { type, id });

  switch (type) {
    case "workinstance":
      return unassignWorkInstance(id, from, ctx);
    case "worktemplate":
      return unassignWorkTemplate(id, from, ctx);
  }

  throw new GraphQLError("Entity cannot be (un)assigned", {
    extensions: {
      code: "E_NOT_ASSIGNABLE",
    },
  });
};

async function unassignWorkInstance(entity: string, from: ID, _ctx: Context) {
  const { type, id } = decodeGlobalId(from);
  console.log("from", { type, id });
  if (type !== "worker") {
    throw new GraphQLError("Entity cannot be (un)assigned", {
      extensions: {
        code: "E_NOT_ASSIGNABLE",
      },
    });
  }

  const result = await sql`
      WITH entity AS (
          SELECT
              wi.workinstanceid,
              wi.workinstanceworktemplateid
          FROM public.workinstance AS wi
          WHERE wi.id = ${entity}
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
          UPDATE public.workresultinstance AS wri
          SET
              workresultinstancevalue = null,
              workresultinstancemodifieddate = now()
          FROM entity, ast, other
          WHERE
              workresultinstanceworkinstanceid IN (
                  SELECT workinstanceid
                  FROM entity
              )
              AND
              workresultinstanceworkresultid IN (
                  SELECT workresultid
                  FROM ast
              )
              AND
              wri.workresultinstancevalue IN (
                  SELECT workerinstanceid::text
                  FROM other
              )
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
          wri.workresultinstancevalue IS null
  `;

  if (!result.length) {
    throw new GraphQLError("Entity already (un)assigned", {
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
    unassignedFrom: {
      __typename: "Worker",
      id: from,
    },
  } as ResolversTypes["UnassignmentPayload"];
}

async function unassignWorkTemplate(
  entity: string,
  from: ID,
  _ctx: Context,
): Promise<ResolversTypes["UnassignmentPayload"]> {
  throw "not implemented";
  // return {
  //   entity: {
  //     __typename: "Checklist",
  //     id: encodeGlobalId({ type: "workinstance", id: entity }),
  //   },
  //   unassignedFrom: {
  //     __typename: "Worker",
  //     id: from,
  //   },
  // } as ResolversTypes["UnassignmentPayload"];
}
