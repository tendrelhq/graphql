import { sql } from "@/datasources/postgres";
import type { Trackable } from "@/schema/platform/tracking";
import type { Mutation } from "@/schema/root";
import type { Component } from "@/schema/system/component";
import type { Overridable } from "@/schema/system/overridable";
import type { Timestamp } from "@/schema/system/temporal";
import type { Context } from "@/schema/types";
import { assertNonNull } from "@/util";
import { GraphQLError } from "graphql";
import type { ID } from "grats";
import { match } from "ts-pattern";
import { decodeGlobalId } from "..";
import type { Refetchable } from "../node";
import type { Connection } from "../pagination";
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
export class Task implements Component, Named, Refetchable, Trackable {
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
    const { type, id } = decodeGlobalId(this.id);
    this._type = type;
    this._id = id;
  }

  /** @gqlField */
  async displayName(): Promise<DisplayName> {
    return await this.ctx.orm.displayName.load(this.id);
  }

  async root(): Promise<Task | null> {
    if (this._type !== "workinstance") return null;

    const [row] = await sql<[{ id: ID }?]>`
      SELECT encode(('workinstance:' || og.id)::bytea, 'base64') AS id
      FROM public.workinstance AS wi
      INNER JOIN public.workinstance AS og
          ON wi.workinstanceoriginatorid = og.workinstanceid
      WHERE
          wi.id = ${this._id}
          AND wi.workinstanceid IS DISTINCT FROM wi.workinstanceoriginatorid;
    `;

    // If there is no row, there is no originator. This implies that this Task
    // is the root of the chain, i.e. the originator.
    if (!row) return this;

    return new Task({ id: row.id }, this.ctx);
  }

  /** @gqlField */
  async state(): Promise<TaskState | null> {
    // Only workinstances have statuses.
    if (this._type !== "workinstance") return null;

    const [row] = await sql<
      [
        {
          status: string;
          create_date: string;
          target_start_date?: string;
          ov_target_start_date?: string;
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
          wi.workinstancetargetstartdate AS target_start_date,
          nullif(ov_target.workresultinstancevalue, '')::timestamptz AS ov_target_start_date,
          wi.workinstancestartdate AS start_date,
          nullif(ov_start.workresultinstancevalue, '')::timestamptz AS ov_start_date,
          wi.workinstancecompleteddate AS close_date,
          nullif(ov_close.workresultinstancevalue, '')::timestamptz AS ov_close_date,
          wi.workinstancetimezone AS time_zone
      FROM public.workinstance AS wi
      INNER JOIN public.systag AS wis
          ON wi.workinstancestatusid = wis.systagid
      LEFT JOIN public.workresult AS ov_target_f
          ON
              wi.workinstanceworktemplateid = ov_target_f.workresultworktemplateid
              AND ov_target_f.workresultisprimary = true
              AND ov_target_f.workresulttypeid IN (
                  SELECT systagid
                  FROM public.systag
                  WHERE systagtype = 'Override Target Start Time'
              )
      LEFT JOIN public.workresultinstance AS ov_target
          ON
              wi.workinstanceid = ov_target.workresultinstanceworkinstanceid
              AND ov_target_f.workresultid = ov_target.workresultinstanceworkresultid
      LEFT JOIN public.workresult AS ov_start_f
          ON
              wi.workinstanceworktemplateid = ov_start_f.workresultworktemplateid
              AND ov_start_f.workresultisprimary = true
              AND ov_start_f.workresulttypeid IN (
                  SELECT systagid
                  FROM public.systag
                  WHERE systagtype = 'Override Start Time'
              )
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
                  WHERE systagtype = 'Override Start Time'
              )
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

// FIXME: this might be a confusing name in combination with TaskStateMachine...
// Probably should just name it TaskStatus?
/** @gqlUnion */
export type TaskState = Open | InProgress | Closed;

/** @gqlType */
export type Open = {
  __typename: "Open";

  /** @gqlField */
  dueAt?: Overridable<Timestamp> | null;
  /** @gqlField */
  openedAt: Overridable<Timestamp>;
  /** @gqlField */
  openedBy?: string;
};

/** @gqlType */
export type InProgress = {
  __typename: "InProgress";

  /** @gqlField */
  dueAt?: Overridable<Timestamp> | null;
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
  dueAt?: Overridable<Timestamp> | null;
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

/**
 * Similar to task_fsm's advance method, this method advances a Task through its
 * internal state machine. A Task's state machine has its finite set defined by
 * the variants of the {@link TaskState} union, with a dag of the form:
 * ```
 * Open -> InProgress -> Closed
 * ```
 */
export async function advance(t: Task): Promise<Task> {
  if (t._type !== "workinstance") {
    // Punt on this for now. We can come back to it.
    // This is, at least at present, used solely by the `advance` implementation
    // for StateMachine<Task>.
    throw "not yet implemented - lazy instantiation of a Task";
  }

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
