import type { ID, Int } from "grats";
import type { Location } from "../platform/archetype/location";
import type { Connection, PageInfo } from "./pagination";

export type ConstructorArgs<T> = {
  root: ID;
  active?: T | null;
  transitions?: Connection<T> | null;
};

/**
 * Where applicable, Entities can have an associated StateMachine that defines
 * their current ("active") state in addition to possible next states that they
 * can "transition into". Typically, an end user does not need to be aware of
 * this state machine as Tendrel's internal engine maintains the machine and
 * associated states for a given Entity. However, in some cases it can be useful
 * to surface this information in userland such that a user can interact
 * directly with the underlying state machine.
 *
 * @gqlType
 */
export type StateMachine<T> = {
  /** @gqlField */
  hash: string;
  /** @gqlField */
  active: T | null;
  /** @gqlField */
  transitions: Transitions<T> | null;
};

/** @gqlType */
export type Transitions<T> = {
  /** @gqlField */
  edges: Transition<T>[];
  /** @gqlField */
  pageInfo: PageInfo;
  /** @gqlField */
  totalCount: Int;
};

/** @gqlType */
export type Transition<T> = {
  /** @gqlField */
  id: ID;
  /** @gqlField */
  cursor: string;
  /** @gqlField */
  node: T;
  /** @gqlField */
  target?: Location | null;
};
