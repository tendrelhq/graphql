import { sql } from "@/datasources/postgres";
import type { Trackable } from "@/schema/platform/tracking";
import type { Mutation } from "@/schema/root";
import type { Component } from "@/schema/system/component";
import type { Overridable } from "@/schema/system/overridable";
import type { Timestamp } from "@/schema/system/temporal";
import type { Context } from "@/schema/types";
import { GraphQLError } from "graphql";
import type { ID } from "grats";
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
  async state(): Promise<TaskState> {
    return {
      __typename: "Open",
      openedAt: {
        override: null,
        value: {
          value: new Date().toLocaleString(),
        },
      },
    };
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
  dueAt?: string;
  /** @gqlField */
  openedAt: Overridable<Timestamp>;
  /** @gqlField */
  openedBy?: string;
};

/** @gqlType */
export type InProgress = {
  __typename: "InProgress";

  /** @gqlField */
  dueAt?: string;
  /** @gqlField */
  openedAt: string;
  /** @gqlField */
  openedBy?: string;
  /** @gqlField */
  inProgressAt: string;
  /** @gqlField */
  inProgressBy?: string;
};

/** @gqlType */
export type Closed = {
  __typename: "Closed";

  /** @gqlField */
  dueAt?: string;
  /** @gqlField */
  openedAt: string;
  /** @gqlField */
  openedBy?: string;
  /** @gqlField */
  inProgressAt?: string;
  /** @gqlField */
  inProgressBy?: string;
  /** @gqlField */
  closedAt: string;
  /** @gqlField */
  closedBecause?: string;
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
    SET workinstancestatusid = 710
    WHERE id = ${t._id};
  `;

  return t;
}
