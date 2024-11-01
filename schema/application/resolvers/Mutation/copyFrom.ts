import { sql } from "@/datasources/postgres";
import type {
  ChecklistEdge,
  CopyFromOptions,
  CopyFromPayload,
  MutationResolvers,
} from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { type WithKey, map } from "@/util";
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
/**
 * Creates a new workinstance from an existing workinstance.
 * Currently, this is purely a templated-based copy.
 *
 * When true, `options.chain` causes the current chain to continue, i.e. we set
 * the new workinstance's previousid to the id of the workinstance being copied.
 * Otherwise, a new (beneath the originator) is started.
 */
export async function copyFromWorkInstance(
  tx: TransactionSql,
  id: string,
  options: CopyFromOptions & { chain?: boolean },
): Promise<CopyFromPayload> {
  const [row] = await tx<
    [{ id: string; originator: string; previous: string }]
  >`
      SELECT
          wt.id,
          wi.workinstanceoriginatorworkinstanceid AS originator,
          wi.workinstanceid AS previous
      FROM public.workinstance AS wi
      INNER JOIN public.worktemplate AS wt
          ON wi.workinstanceworktemplateid = wt.worktemplateid
      WHERE wi.id = ${id};
  `;
  // For now, we just do a template-based copy:
  return copyFromWorkTemplate(tx, row.id, {
    ...options,
    originator: row.originator,
    previous: options.chain ? row.previous : undefined,
  });
}

type TemplateChainOptions =
  | {
      originator?: string;
    }
  | {
      originator: string;
      previous: string;
    };

/**
 * Creates a new workinstance from a worktemplate. This is a "full
 * instantiation", i.e. we create a workinstance AND all workresultinstances
 * as specified by the underlying workresults.
 *
 * `options.originator` and `options.previous` can be used to insert a
 * workinstance into an existing chain. When an originator is not specified, the
 * result is a brand new originator "token" (as Keller likes to call them).
 */
export async function copyFromWorkTemplate(
  tx: TransactionSql,
  id: string,
  options: CopyFromOptions & TemplateChainOptions,
): Promise<CopyFromPayload> {
  const [row] = await tx<[WithKey<{ _key_uuid: string; id: string }>?]>`
      INSERT INTO public.workinstance (
          workinstancecustomerid,
          workinstancesiteid,
          workinstanceoriginatorworkinstanceid,
          workinstancepreviousid,
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
          ${options.originator ?? null}::bigint,
          ${"previous" in options ? options.previous : null}::bigint,
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
      WHERE
          worktemplate.id = ${id}
          AND (
              worktemplateenddate IS null
              OR worktemplateenddate > now()
          )
      RETURNING
          workinstance.workinstanceid AS "_key",
          workinstance.id AS "_key_uuid",
          encode(('workinstance:' || workinstance.id)::bytea, 'base64') AS id
  `;

  if (!row) {
    throw new GraphQLError(
      "Cannot copy a Checklist that is inactive. Activate the Checklist and then try again.",
      {
        extensions: {
          code: "E_NOT_COPYABLE",
        },
      },
    );
  }

  console.debug(`Created Entity ${row.id} (workinstance:${row._key_uuid})`);

  // We must have an originator, even if it needlessly points right back at us.
  // All hail the datawarehouse :heavy sigh:
  await tx`
      UPDATE public.workinstance
      SET workinstanceoriginatorworkinstanceid = workinstanceid
      WHERE
          workinstanceid = ${row._key}
          AND workinstanceoriginatorworkinstanceid IS null;
  `;

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
      FROM public.worktemplate
      INNER JOIN public.workresult
          ON
              worktemplateid = workresultworktemplateid
              AND (
                  workresultenddate IS null
                  OR workresultenddate < now()
              )
      INNER JOIN public.location
          ON worktemplatesiteid = locationid
      INNER JOIN public.workinstance
          ON workinstance.workinstanceid = ${row._key}
      LEFT JOIN public.systag AS entity_type
          ON workresultentitytypeid = systagid
      WHERE worktemplate.id = ${id};
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
