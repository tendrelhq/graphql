import { sql } from "@/datasources/postgres";
import type {
  ChecklistEdge,
  CopyFromOptions,
  CopyFromPayload,
  MutationResolvers,
} from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { map } from "@/util";
import { GraphQLError } from "graphql";
import type { TransactionSql } from "postgres";
import { match } from "ts-pattern";

export const copyFrom: NonNullable<MutationResolvers["copyFrom"]> = async (
  _,
  { entity, options },
) => {
  const { type, id } = decodeGlobalId(entity);

  switch (type) {
    case "worktemplate":
      return sql.begin(tx => copyFromWorkTemplate(tx, id, options));
    case "workinstance":
      return sql.begin(tx => copyFromWorkInstance(tx, id, options));
    default: {
      console.debug(
        `The type of the lhs of the copy operation is invalid. Got: '${type}'. Expected one of: ['worktemplate']`,
      );
      throw new GraphQLError("Entity cannot be copied", {
        extensions: {
          code: "E_NOT_COPYABLE",
        },
      });
    }
  }
};

// TODO: We could extend the `options` here to include things like:
// - copying over result statuses, values
// - ...?
export async function copyFromWorkInstance(
  tx: TransactionSql,
  id: string,
  options: CopyFromOptions,
): Promise<CopyFromPayload> {
  const [row] = await tx<[{ id: string }]>`
      SELECT wt.id
      FROM public.workinstance AS wi
      INNER JOIN public.worktemplate AS wt
          ON wi.workinstanceworktemplateid = wt.worktemplateid
      WHERE wi.id = ${id};
  `;
  // For now, we just do a template-based copy:
  return copyFromWorkTemplate(tx, row.id, options);
}

export async function copyFromWorkTemplate(
  tx: TransactionSql,
  id: string,
  options: CopyFromOptions,
): Promise<CopyFromPayload> {
  const [row] = await tx<[{ _key: number; id: string }?]>`
      INSERT INTO public.workinstance (
          workinstancecustomerid,
          workinstancesiteid,
          workinstancesoplink,
          workinstancestartdate,
          workinstancestatusid,
          workinstancetypeid,
          workinstanceworktemplateid,
          workinstancetimezone
      )
      SELECT
          worktemplatecustomerid,
          worktemplatesiteid,
          worktemplatesoplink,
          ${match(options.withStatus)
            .with("open", () => null)
            .with("inProgress", () => sql`now()`)
            .with("closed", () => sql`now()`)
            .with(undefined, () => null)
            .exhaustive()},
          (
              SELECT systagid
              FROM public.systag
              WHERE
                  systagparentid = 705
                  AND systagtype = ${match(options.withStatus)
                    .with("open", () => "Open")
                    .with("inProgress", () => "In Progress")
                    .with("closed", () => "Complete")
                    .with(undefined, () => "Open")
                    .exhaustive()}
          ) AS workinstancestatusid,
          (
              SELECT systagid
              FROM public.systag
              WHERE
                  systagparentid = 691
                  AND systagtype = 'On Demand'
          ) AS workinstancetypeid,
          worktemplateid,
          locationtimezone
      FROM public.worktemplate
      INNER JOIN public.location ON
          worktemplatesiteid = locationid
      WHERE worktemplate.id = ${id}
      RETURNING
          workinstanceid AS "_key",
          encode(('workinstance:' || workinstance.id)::bytea, 'base64') AS id
  `;

  if (!row) {
    console.debug(`No worktemplate exists for the given id '${id}'`);
    throw "invariant violated";
  }

  const result = await tx`
      INSERT INTO public.workresultinstance (
          workresultinstancecompleteddate,
          workresultinstancecustomerid,
          workresultinstancestartdate,
          workresultinstancevalue,
          workresultinstanceworkinstanceid,
          workresultinstanceworkresultid,
          workresultinstancestatusid,
          workresultinstancetimezone
      )
      SELECT
          workinstancecompleteddate,
          worktemplatecustomerid,
          workinstancestartdate,
          (
              SELECT location.locationid::text AS value
              WHERE entity_type.systagtype = 'Location' AND workresultisprimary
              UNION ALL
              SELECT ${
                map(options.withAssignee?.at(0), a => {
                  const { type, id } = decodeGlobalId(a);
                  if (type !== "worker") {
                    console.debug(
                      `Only 'worker's can be assignees at the moment, but got '${type}'`,
                    );
                    throw new GraphQLError("Entity cannot be assigned", {
                      extensions: {
                        code: "E_NOT_ASSIGNABLE",
                      },
                    });
                  }
                  return sql`workerinstanceid
                      FROM public.workerinstance
                      WHERE workerinstanceuuid = ${id}`;
                }) ?? null
              }::text AS value
              WHERE entity_type.systagtype = 'Worker' AND workresultisprimary
              UNION ALL
              SELECT null::text AS value
              WHERE
                  entity_type IS null
                  OR (
                      entity_type IS NOT null
                      AND workresultisprimary = false
                  )
          ) AS workresultinstancevalue,
          ${row._key}::bigint AS workresultinstanceworkinstanceid,
          workresultid,
          (
              SELECT systagid
              FROM public.systag
              WHERE
                  systagparentid = 965
                  AND systagtype = ${match(options.withStatus)
                    .with("open", () => "Open")
                    .with("inProgress", () => "Open")
                    .with("closed", () => "Complete")
                    .with(undefined, () => "Open")
                    .exhaustive()}
          ) AS workresultinstancestatusid,
          locationtimezone
      FROM public.workresult
      INNER JOIN public.worktemplate
          ON workresultworktemplateid = worktemplateid
      INNER JOIN public.location
          ON worktemplatesiteid = locationid
      INNER JOIN public.workinstance
          ON workinstance.workinstanceid = ${row._key}
      LEFT JOIN public.systag AS entity_type
          ON workresultentitytypeid = systagid
      WHERE
          worktemplate.id = ${id}
  `;

  console.debug(`Created ${result.count} items.`);

  return {
    edge: {
      cursor: row.id,
      node: {
        __typename: "Checklist",
        id: row.id,
      },
    } as ChecklistEdge,
  };
}
