import type { Trackable } from "@/schema/platform/tracking";
import type { Mutation } from "@/schema/root";
import type { Component } from "@/schema/system/component";
import type { Overridable } from "@/schema/system/overridable";
import type { Timestamp } from "@/schema/system/temporal";
import type { Context } from "@/schema/types";
import type { ID } from "grats";
import { decodeGlobalId } from "..";
import type { Refetchable } from "../node";
import type { Connection } from "../pagination";
import type { DisplayName, Named } from "./name";

export type TaskConstructorArgs = {
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
    args: TaskConstructorArgs,
    private ctx: Context,
  ) {
    this.id = args.id;
    // Private.
    const { type, id } = decodeGlobalId(args.id);
    this._type = type;
    this._id = id;
  }

  /** @gqlField */
  async displayName(): Promise<DisplayName> {
    return await this.ctx.orm.displayName.load(this.id);
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

// FIXME: I don't know if this is right. What is crucial here is that the
// payload that we return after successfully performing this mutation is enough
// to trigger a re-render in a client. In the MFT case, this is the top-level
// trackable Task (template). It follows then that the mutation should be given
// an `id` that points to this top-level Trackable, such that we can refetch the
// necessary data after performing a transition. `startTask` - I think - makes
// sense as a low-level api (similar to setStatus). However, it is too low level
// for our usecase right now as it would force the client to perform the
// mutation *and then* refetch the top-level Trackable (synchronously!). Bad.
export async function startTask(_: Mutation, id: ID, ctx: Context) {
  return Promise.reject();
}
