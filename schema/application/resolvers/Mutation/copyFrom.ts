import { sql } from "@/datasources/postgres";
import type {
  ChecklistEdge,
  Context,
  CopyFromOptions,
  MutationResolvers,
} from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import type { FieldInput } from "@/schema/system/component";
import { Task, applyEdits$fragment } from "@/schema/system/component/task";
import type { WithKey } from "@/util";
import { GraphQLError } from "graphql";
import type { TransactionSql } from "postgres";
import { match } from "ts-pattern";

export const copyFrom: NonNullable<MutationResolvers["copyFrom"]> = async (
  _,
  { entity, options },
  ctx,
) => {
  const { type, id } = decodeGlobalId(entity);
  const result = await match(type)
    .with("workinstance", () =>
      sql.begin(tx => copyFromWorkInstance(tx, id, options, ctx)),
    )
    .with("worktemplate", () =>
      sql.begin(tx => copyFromWorkTemplate(tx, id, options, ctx)),
    )
    .otherwise(() => {
      console.debug(
        `The type of the lhs of the copy operation is invalid. Got: '${type}'. Expected one of: ['worktemplate']`,
      );
      throw new GraphQLError("Entity cannot be copied", {
        extensions: {
          code: "E_NOT_COPYABLE",
        },
      });
    });
  return {
    edge: {
      cursor: result.id,
      node: {
        __typename: "Checklist",
        id: result.id,
      },
    } as ChecklistEdge,
  };
};

// TODO: We could extend the `options` here to include things like:
// - copying over result statuses, values
// - ...?
/**
 * Creates a new workinstance from an existing workinstance.
 * Currently, this is purely a templated-based copy.
 *
 * `options.chain` allows for controlling how the new instance is (potentially)
 * inserted into an existing chain. There are three options:
 * (1) `branch` creates a new branch beneath the originator, no previous is set
 * (2) `continue` effectively appends the new instance to the existing chain,
 *      meaning previous is set
 * (3) `undefined` creates a new chain, i.e. the new instance's originator is
 *      set to itself
 *
 * In practice, audits and remediations typically `continue` the chain, as their
 * existence is a result of some action (or insight) on the previous.
 * The "respawn" case typically creates a new `branch`, since there is no real
 * correlation between the previous and the new instance.
 */
export async function copyFromWorkInstance(
  tx: TransactionSql,
  id: string,
  options: CopyFromOptions & { chain?: "branch" | "continue" },
  ctx: Context,
): Promise<Task> {
  const [row] = await tx<[{ id: string }]>`
      SELECT wt.id
      FROM public.workinstance AS wi
      INNER JOIN public.worktemplate AS wt
          ON wi.workinstanceworktemplateid = wt.worktemplateid
      WHERE wi.id = ${id};
  `;
  // For now, we just do a template-based copy:
  return copyFromWorkTemplate(
    tx,
    row.id,
    {
      ...options,
      previous: id,
    },
    ctx,
  );
}

type CopyFromWorkTemplateOptions = {
  /**
   * The chain strategy to use.
   * - branch: create a new sub-chain beneath the originator
   * - continue: create a new leaf node beneath the previous
   * - default: create an entirely new chain, i.e. originator set to itself
   */
  chain?: "branch" | "continue";
  /**
   * Specifies the "previous instance" for the newly instantiated. Canonically,
   * previous is used in conjunction with originator to identify chains.
   * Irrespective of chains, previous conveys a notion of causality i.e. this
   * instance came about as a result of this instance. As such, it is not
   * _theoretically_ incorrect to specify previous _without_ a chain strategy.
   */
  previous?: string;
  /**
   * Instruct the engine to carry over any "assignments" from ancestors in the
   * chain. By default, this carries over the previous's assignments (if it
   * exists) else the originator's assignments (if it exists) else the default
   * assignment strategy (which is the current identity).
   */
  carryOverAssignments?: boolean;
  /**
   * Override a field's initial value (i.e. workresultinstancevalue). By default
   * initial values are inherited from workresultdefaultvalue. This allows for,
   * e.g. in the MFT case, overriding the start or end time when transitioning
   * between tasks.
   */
  fieldOverrides?: FieldInput[] | null;
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

// TODO: need to use real frequency for target start date
export async function copyFromWorkTemplate(
  tx: TransactionSql,
  id: string,
  options: CopyFromOptions & CopyFromWorkTemplateOptions,
  ctx: Context,
): Promise<Task> {
  if (options.carryOverAssignments) {
    console.warn(
      "copyFrom: `carryOverAssignments` requested but not yet implemented",
    );
  }

  const [row] = await tx<[WithKey<{ _key_uuid: string; id: string }>?]>`
      INSERT INTO public.workinstance (
          workinstancecustomerid,
          workinstancesiteid,
          workinstanceoriginatorworkinstanceid,
          workinstancepreviousid,
          workinstancesoplink,
          workinstancestartdate,
          workinstancetargetstartdate,
          workinstancestatusid,
          workinstancetypeid,
          workinstanceworktemplateid,
          workinstancetimezone
      )
      SELECT
          worktemplatecustomerid,
          worktemplatesiteid,
          ${options.chain ? sql`previous.workinstanceoriginatorworkinstanceid` : null},
          previous.workinstanceid,
          worktemplatesoplink,
          ${match(options.withStatus)
            .with("open", () => null)
            .with("inProgress", () => sql`now()`)
            .with("closed", () => sql`now()`)
            .with(undefined, () => null)
            .exhaustive()},
          now(), -- TODO: this should use real frequency
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
      INNER JOIN public.location
          ON worktemplatesiteid = locationid
      LEFT JOIN public.workinstance AS previous
          ON previous.id = ${options.previous ?? null}
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

  console.debug(
    `Created Entity ${row.id.replace(/\n/g, "")} (workinstance:${row._key_uuid})`,
  );

  // We must have an originator, even if it needlessly points right back at us.
  // All hail the datawarehouse :heavy sigh:
  await tx`
      UPDATE public.workinstance
      SET workinstanceoriginatorworkinstanceid = workinstanceid
      WHERE
          workinstanceid = ${row._key}
          AND workinstanceoriginatorworkinstanceid IS null;
  `;

  // Create all workresultinstances, based on workresult.
  const result = await tx`
      INSERT INTO public.workresultinstance (
          workresultinstancecompleteddate,
          workresultinstancecustomerid,
          workresultinstancestartdate,
          workresultinstancevalue,
          workresultinstanceworkinstanceid,
          workresultinstanceworkresultid,
          workresultinstancetimezone
      )
      SELECT
          workinstancecompleteddate,
          worktemplatecustomerid,
          workinstancestartdate,
          workresultdefaultvalue,
          ${row._key}::bigint AS workresultinstanceworkinstanceid,
          workresultid,
          workinstancetimezone
      FROM public.worktemplate
      INNER JOIN public.workresult
          ON
              worktemplateid = workresultworktemplateid
              AND (
                  workresultenddate IS null
                  OR workresultenddate < now()
              )
      INNER JOIN public.workinstance
          ON workinstance.workinstanceid = ${row._key}
      LEFT JOIN public.systag AS entity_type
          ON workresultentitytypeid = systagid
      WHERE worktemplate.id = ${id};
  `;
  console.debug(`Created ${result.count} items.`);

  // Ensure any user-specified overrides are applied.
  if (
    !options.withAssignee?.length &&
    options.carryOverAssignments &&
    options.previous
  ) {
    // This will only carry over the "primary" assignee, which is fine for now
    // as we only really support a single assignee (even though the (graphql)
    // data model allows for multiple). Note that the whole operation is a
    // little tricky as we are potentially operating against two distinct
    // worktemplates: "previous" can, in theory, be an instance of any
    // worktemplate. This is another reason that we cannot blindly carry over
    // all assignees as there could potentially be a mismatch between the two
    // worktemplates and the number of assignees (i.e. workresults). This will
    // eventually be a non-issue when we generalize the concept of "fields": we
    // currently only support lazy *instantiation* of fields; in the future we
    // will also support lazy *definition* (i.e. creating a new workresult on
    // the fly). This is the so-called semi-structured entrypoint, or as I like
    // to call it (which is, of course, completely made up) "structuralization".
    const result = await tx`
        WITH previous AS (
            SELECT nullif(workresultinstancevalue, '') AS value
            FROM public.workresultinstance
            INNER JOIN public.workresult
                ON workresultinstanceworkresultid = workresultid
            WHERE
                workresultinstanceworkinstanceid IN (
                    SELECT workinstanceid
                    FROM public.workinstance
                    WHERE id = ${options.previous}
                )
                AND workresulttypeid = 848
                AND workresultentitytypeid = 850
                AND workresultisprimary = true
            LIMIT 1
        )

        UPDATE public.workresultinstance AS t
        SET workresultinstancevalue = previous.value
        FROM previous
        WHERE
            previous.value IS NOT null
            AND t.workresultinstanceworkinstanceid = ${row._key}
            AND t.workresultinstanceworkresultid IN (
                SELECT workresultid
                FROM public.workresult
                INNER JOIN public.worktemplate
                    ON workresultworktemplateid = worktemplateid
                WHERE
                    worktemplate.id = ${id}
                    AND workresulttypeid = 848
                    AND workresultentitytypeid = 850
                    AND workresultisprimary = true
                LIMIT 1
            )
    `;

    console.log(
      `Carried over ${result.count} assignments from the previous instance`,
    );
  }

  if (options.withAssignee) {
    const result = await tx`
        UPDATE public.workresultinstance AS t
        SET workresultinstancevalue = s.value
        FROM (
            SELECT workerinstanceid::text
            FROM public.workinstance
            WHERE workerinstanceuuid IN ${sql(
              options.withAssignee.map(e => {
                const { type, id } = decodeGlobalId(e);
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
                return id;
              }),
            )}
        ) s
        WHERE
            t.workresultinstanceworkinstanceid = ${row._key}
            AND t.workresultinstanceworkresultid IN (
                SELECT workresultid
                FROM public.workresult
                INNER JOIN public.worktemplate
                    ON workresultworktemplateid = worktemplateid
                WHERE
                    worktemplate.id = ${id}
                    AND workresulttypeid = 848
                    AND workresultentitytypeid = 850
                    AND workresultisprimary = true
                LIMIT 1
            )
    `;
    console.log(`Created ${result.count} assignments for the new instance`);

    if (options.carryOverAssignments) {
      console.warn(
        "WARNING: `carryOverAssignments` used along with `withAssignee`",
        "Note that `withAssignee` takes precedence over that option.",
        "You should expect that the carried over assignments have been overwritten.",
      );
    }
  }

  const t = new Task(row, ctx);

  if (options.fieldOverrides?.length) {
    const edits = applyEdits$fragment(t, options.fieldOverrides);
    if (edits) {
      const result = await tx`${edits}`;
      console.log(`Applied ${result.count} field-level edits.`);
    }
  }

  return new Task(row, ctx);
}
