import { sql } from "@/datasources/postgres";
import type { Trackable } from "@/schema/platform/tracking";
import type { Component, FieldInput } from "@/schema/system/component";
import type { Overridable } from "@/schema/system/overridable";
import type { Timestamp } from "@/schema/system/temporal";
import type { Context } from "@/schema/types";
import { assertNonNull } from "@/util";
import type { ID } from "grats";
import type { Fragment } from "postgres";
import { match } from "ts-pattern";
import { decodeGlobalId } from "..";
import type { Refetchable } from "../node";
import type { Connection } from "../pagination";
import { type Assignable, Assignment } from "./assignee";
import type { DisplayName, Named } from "./name";

export type ConstructorArgs = {
  id: ID;
};

/**
 * A system-level component that identifies an Entity as being applicable to
 * tendrel's internal "task processing pipeline". In practice, Tasks most often
 * represent "jobs" performed by humans. However, this need not always be the
 * case.
 *
 * Technically speaking, a Task represents a (1) *named asynchronous process*
 * that (2) exists in one of three states: open, in progress, or closed.
 *
 * @gqlType
 */
export class Task
  implements Assignable, Component, Named, Refetchable, Trackable
{
  readonly __typename = "Task" as const;
  readonly _type: string;
  readonly _id: string;
  readonly id: ID;

  constructor(
    args: ConstructorArgs,
    private ctx: Context,
  ) {
    // Note that Postgres will sometimes add newlines when we `encode(...)`.
    this.id = args.id.replace(/\n/g, "");
    // Private.
    const g = decodeGlobalId(this.id);
    this._type = g.type;
    this._id = g.id;
  }

  /** @gqlField */
  async displayName(): Promise<DisplayName> {
    return await this.ctx.orm.displayName.load(this.id);
  }

  // TODO: We should probably implement this as a StateMachine<TaskState>?
  /** @gqlField */
  async state(): Promise<TaskState | null> {
    // Only workinstances have statuses.
    if (this._type !== "workinstance") return null;

    // NOTE: the following sql supports start/end date overrides as per the
    // mocks. It does NOT do any bullshit name matching, but requires that you
    // set up the workresults correctly.
    // - workresulttypeid must point at 'Date'
    // - workresultisprimary must be true
    // - workresultorder should be 0 for 'start' and 1 for 'end'
    const [row] = await sql<
      [
        {
          status: string;
          create_date: string;
          start_date?: string;
          ov_start_date?: string;
          close_date?: string;
          ov_close_date?: string;
          time_zone: string;
        }?,
      ]
    >`
      SELECT
          wis.systagtype AS status,
          wi.workinstancecreateddate AS create_date,
          wi.workinstancestartdate AS start_date,
          nullif(ov_start.workresultinstancevalue, '')::timestamptz AS ov_start_date,
          wi.workinstancecompleteddate AS close_date,
          nullif(ov_close.workresultinstancevalue, '')::timestamptz AS ov_close_date,
          wi.workinstancetimezone AS time_zone
      FROM public.workinstance AS wi
      INNER JOIN public.systag AS wis
          ON wi.workinstancestatusid = wis.systagid
      LEFT JOIN public.workresult AS ov_start_f
          ON
              wi.workinstanceworktemplateid = ov_start_f.workresultworktemplateid
              AND ov_start_f.workresultisprimary = true
              AND ov_start_f.workresulttypeid IN (
                  SELECT systagid
                  FROM public.systag
                  WHERE systagtype = 'Date'
              )
              AND ov_start_f.workresultorder = 0
      LEFT JOIN public.workresultinstance AS ov_start
          ON
              wi.workinstanceid = ov_start.workresultinstanceworkinstanceid
              AND ov_start_f.workresultid = ov_start.workresultinstanceworkresultid
      LEFT JOIN public.workresult AS ov_close_f
          ON
              wi.workinstanceworktemplateid = ov_close_f.workresultworktemplateid
              AND ov_close_f.workresultisprimary = true
              AND ov_close_f.workresulttypeid IN (
                  SELECT systagid
                  FROM public.systag
                  WHERE systagtype = 'Date'
              )
              AND ov_close_f.workresultorder = 1
      LEFT JOIN public.workresultinstance AS ov_close
          ON
              wi.workinstanceid = ov_close.workresultinstanceworkinstanceid
              AND ov_close_f.workresultid = ov_close.workresultinstanceworkresultid
      WHERE wi.id = ${this._id};
    `;

    if (!row) {
      console.warn(`No TaskState for ${this}... which is odd?`);
      return null;
    }

    return match(row.status)
      .with(
        "Open",
        () =>
          ({
            __typename: "Open" as const,
            openedAt: {
              override: null,
              value: {
                epochMilliseconds: row.create_date,
                timeZone: row.time_zone,
              },
            },
          }) satisfies Open,
      )
      .with(
        "In Progress",
        () =>
          ({
            __typename: "InProgress",
            openedAt: {
              override: null,
              value: {
                epochMilliseconds: row.create_date,
                timeZone: row.time_zone,
              },
            },
            inProgressAt: {
              override:
                row.start_date && row.ov_start_date
                  ? {
                      previousValue: {
                        epochMilliseconds: row.start_date,
                        timeZone: row.time_zone,
                      },
                    }
                  : null,
              value: {
                epochMilliseconds: assertNonNull(
                  row.ov_start_date ?? row.start_date,
                  `Task ${this}, in state 'In Progress', has no start date`,
                ),
                timeZone: row.time_zone,
              },
            },
          }) satisfies InProgress,
      )
      .with(
        "Cancelled",
        () =>
          ({
            __typename: "Closed",
            openedAt: {
              override: null,
              value: {
                epochMilliseconds: row.create_date,
                timeZone: row.time_zone,
              },
            },
            inProgressAt: row.start_date
              ? {
                  override: row.ov_start_date
                    ? {
                        previousValue: {
                          epochMilliseconds: row.start_date,
                          timeZone: row.time_zone,
                        },
                      }
                    : null,
                  value: {
                    epochMilliseconds: row.ov_start_date ?? row.start_date,
                    timeZone: row.time_zone,
                  },
                }
              : null,
            closedAt: {
              override:
                row.close_date && row.ov_close_date
                  ? {
                      previousValue: {
                        epochMilliseconds: row.close_date,
                        timeZone: row.time_zone,
                      },
                    }
                  : null,
              value: {
                epochMilliseconds: assertNonNull(
                  row.ov_close_date ?? row.close_date,
                  `Task ${this}, in state 'Cancelled', has no close date`,
                ),
                timeZone: row.time_zone,
              },
            },
          }) satisfies Closed,
      )
      .with(
        "Complete",
        () =>
          ({
            __typename: "Closed",
            openedAt: {
              override: null,
              value: {
                epochMilliseconds: row.create_date,
                timeZone: row.time_zone,
              },
            },
            inProgressAt: row.start_date
              ? {
                  override: row.ov_start_date
                    ? {
                        previousValue: {
                          epochMilliseconds: row.start_date,
                          timeZone: row.time_zone,
                        },
                      }
                    : null,
                  value: {
                    epochMilliseconds: row.ov_start_date ?? row.start_date,
                    timeZone: row.time_zone,
                  },
                }
              : null,
            closedAt: {
              override:
                row.close_date && row.ov_close_date
                  ? {
                      previousValue: {
                        epochMilliseconds: row.close_date,
                        timeZone: row.time_zone,
                      },
                    }
                  : null,
              value: {
                epochMilliseconds: assertNonNull(
                  row.ov_close_date ?? row.close_date,
                  `Task ${this}, in state 'Closed', has no close date`,
                ),
                timeZone: row.time_zone,
              },
            },
          }) satisfies Closed,
      )
      .otherwise(s => {
        console.warn(`Unknown TaskState type '${s}'`);
        return null;
      });
  }

  /**
   * Entrypoint into the "tracking system(s)" for the given Task.
   * At the moment, sub-task tracking is not supported and therefore `null` will
   * always be returned for this field.
   *
   * @gqlField
   */
  async tracking(): Promise<Connection<Trackable> | null> {
    return null;
  }

  toString() {
    return `'${this.id}' (${this._type}:${this._id})`;
  }
}

/**
 * {@link Assignment} connection for the given Task.
 * There is no limit on the number of assignments per task.
 *
 * @gqlField
 */
export async function assignees(
  t: Task,
  ctx: Context,
): Promise<Connection<Assignment> | null> {
  // Only workinstances can be assigned.
  if (t._type !== "workinstance") return null;

  const rows = await sql<{ id: string; entity: string }[]>`
    SELECT encode(('workresultinstance:' || wi.id || ':' || wr.id)::bytea, 'base64') AS id
    FROM public.workinstance AS wi
    INNER JOIN public.workresultinstance AS wri
        ON wi.workinstanceid = wri.workresultinstanceworkinstanceid
    INNER JOIN public.workresult AS wr
        ON
            wri.workresultinstanceworkresultid = wr.workresultid
            AND wr.workresultisprimary = true
            AND wr.workresulttypeid = 848
            AND wr.workresultentitytypeid = 850
    WHERE wi.id = ${t._id}
  `;

  return {
    edges: rows.map(row => ({
      cursor: row.id,
      // FIXME: this may not be ideal as it introduces a chance for interleaving
      // to put us an illegal state, i.e. the above query runs and it finds a
      // match then another session unassigns (the same row) _and then_ the
      // resolver in Assigment runs and finds that the row that we told it would
      // be there is no longer there!
      node: new Assignment(row, ctx),
    })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: rows.count,
  };
}

// FIXME: this might be a confusing name in combination with TaskStateMachine...
// Probably should just name it TaskStatus?
/** @gqlUnion */
export type TaskState = Open | InProgress | Closed;

/** @gqlType */
export type Open = {
  __typename: "Open";

  /** @gqlField */
  openedAt: Overridable<Timestamp>;
  /** @gqlField */
  openedBy?: string;
};

/** @gqlType */
export type InProgress = {
  __typename: "InProgress";

  /** @gqlField */
  openedAt: Overridable<Timestamp>;
  /** @gqlField */
  openedBy?: string | null;
  /** @gqlField */
  inProgressAt: Overridable<Timestamp>;
  /** @gqlField */
  inProgressBy?: string | null;
};

/** @gqlType */
export type Closed = {
  __typename: "Closed";

  /** @gqlField */
  openedAt: Overridable<Timestamp>;
  /** @gqlField */
  openedBy?: string | null;
  /** @gqlField */
  inProgressAt?: Overridable<Timestamp> | null;
  /** @gqlField */
  inProgressBy?: string | null;
  /** @gqlField */
  closedAt: Overridable<Timestamp>;
  /** @gqlField */
  closedBecause?: string | null;
  /** @gqlField */
  closedBy?: string;
};

/** @gqlInput */
export type TaskInput = {
  id: ID;
  overrides?: FieldInput[] | null;
  // TODO: for photos
  // attachments?: Attachment[] | null;
};

/**
 * Similar to task_fsm's advance method, this method advances a Task through its
 * internal state machine. A Task's state machine has its finite set defined by
 * the variants of the {@link TaskState} union, with a dag of the form:
 * ```
 * Open -> InProgress -> Closed
 * ```
 */
export async function advance(
  t: Task,
  opts?: Omit<TaskInput, "id"> | null,
): Promise<Task> {
  if (t._type !== "workinstance") {
    // Punt on this for now. We can come back to it.
    // This is, at least at present, used solely by the `advance` implementation
    // for StateMachine<Task>.
    throw "not yet implemented - lazy instantiation of a Task";
  }

  console.log("advance_task overrides", opts?.overrides);

  // As before, we assume this is the "stop task" flow.
  await sql`
    UPDATE public.workinstance
    SET
        workinstancestatusid = 710,
        workinstancecompleteddate = now(),
        workinstancemodifieddate = now()
        -- TODO: workinstancemodifiedby
    WHERE id = ${t._id};
  `;

  return t;
}

/**
 * The purpose of this function is to abstract the process of applying
 * field-level edits to a Task (i.e. a workinstance's workresultinstances).
 *
 * - This is an UPSERT operation; it will create workresultinstances if necessary.
 * - This operation does not affect field-level status.
 */
export function applyEdits$fragment(
  t: Task,
  edits: FieldInput[],
): Fragment | undefined {
  if (t._type !== "workinstance") {
    console.warn(`WARNING: cannot applyEdits to a '${t._type}'`);
    return;
  }

  if (!edits.length) return;

  const edits_ = edits.flatMap(e => {
    const { type, id, suffix } = decodeGlobalId(e.field);
    switch (type) {
      case "workresult": {
        return [[id, valueInputToSql(e.value), valueInputTypeToSql(e.value)]];
      }
      case "workresultinstance": {
        return [
          [
            assertNonNull(suffix?.at(0)),
            valueInputToSql(e.value),
            valueInputTypeToSql(e.value),
          ],
        ];
      }
      default: {
        console.warn(`Underlying type '${type}' not expected in this context.`);
        return [];
      }
    }
  });

  return sql`
    WITH edits (field, value, type) AS (
        VALUES ${sql(edits_ as string[][])}
    )

    INSERT INTO public.workresultinstance AS t (
        workresultinstancecustomerid,
        workresultinstanceworkinstanceid,
        workresultinstanceworkresultid,
        workresultinstancetimezone,
        workresultinstancevalue
    )
    SELECT
        wi.workinstancecustomerid,
        wi.workinstanceid,
        wr.workresultid,
        wi.workinstancetimezone,
        coalesce(
          nullif(edits.value, ''),
          wr.workresultdefaultvalue
        )
    FROM edits
    INNER JOIN public.workinstance AS wi
        ON wi.id = ${t._id}
    INNER JOIN public.workresult AS wr
        ON edits.field = wr.id
           AND wi.workinstanceworktemplateid = wr.workresultworktemplateid
    INNER JOIN public.systag AS wrt
        ON edits.type = wrt.systagtype
           AND wrt.systagparentid = 699
    ON CONFLICT
        (workresultinstanceworkinstanceid, workresultinstanceworkresultid)
    DO UPDATE
        SET workresultinstancevalue = EXCLUDED.workresultinstancevalue,
            workresultinstancemodifieddate = now()
        WHERE
            t.workresultinstancevalue IS DISTINCT FROM EXCLUDED.workresultinstancevalue
    RETURNING 1
  `;
}

export function valueInputToSql(value?: FieldInput["value"]): string | null {
  if (!value) return null;
  switch (true) {
    case "boolean" in value:
      return value.boolean ? "true" : "false";
    case "id" in value:
      return value.id;
    case "integer" in value:
      return value.integer.toString();
    case "decimal" in value:
      return value.decimal.toString();
    case "string" in value:
      return value.string;
    case "duration" in value:
      return value.duration;
    case "timestamp" in value: {
      const t = Date.parse(value.timestamp);
      if (Number.isNaN(t)) {
        console.warn(
          `Discarding invalid ValueInput timestamp '${value.timestamp}'`,
        );
        return null;
      }
      return new Date(t).toISOString();
    }
    default: {
      const _: never = value;
      console.warn(`Unhandled input variant: ${JSON.stringify(value)}`);
      return null;
    }
  }
}

export function valueInputTypeToSql(
  value?: FieldInput["value"],
): string | null {
  if (!value) return null;
  switch (true) {
    case "boolean" in value:
      return "Boolean";
    case "id" in value:
      return value.id;
    case "integer" in value:
      return "Number";
    case "decimal" in value:
      return "Number";
    case "string" in value:
      return "String";
    case "duration" in value:
      return "Duration";
    case "timestamp" in value:
      return "Date";
    default: {
      const _: never = value;
      console.warn(`Unhandled input variant: ${JSON.stringify(value)}`);
      return null;
    }
  }
}

// shortmess=ctaOToClF
//   c - don't give ins-completion-menu messages
//   t - truncate file message if too long
//   a - all of the shorthands (l,m,r,w)
//   O - message for reading overwrites any previous message
//   T - truncate other messages if too long
//   o - overwrite message for writing a file
//   C - don't give messages while scanning for ins-completion items
//   l - "999L" instead of "999 lines"
//   F - don't give the file info when editing a file
