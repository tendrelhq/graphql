import type { Trackable } from "@/schema/platform/tracking";
import type { Component } from "@/schema/system/component";
import type { Overridable } from "@/schema/system/overridable";
import type { Timestamp } from "@/schema/system/temporal";
import type { Context } from "@/schema/types";
import type { ID } from "grats";
import type { Connection } from "../pagination";
import { DisplayName, type Named } from "./name";

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
export class Task implements Component, Named, Trackable {
  readonly __typename = "Task" as const;

  constructor(
    /**
     * @gqlField
     * @killsParentOnException
     */
    readonly id: ID,

    /** @internal */
    readonly nameId: ID,
  ) {}

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

/** @gqlField */
export async function displayName(t: Task, ctx: Context): Promise<DisplayName> {
  return new DisplayName(t.nameId);
}

/** @gqlField */
export async function state(t: Task, ctx: Context): Promise<TaskState | null> {
  return Promise.reject("not yet implemented");
}

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
