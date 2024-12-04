import type { ID } from "grats";
import type { Query } from "../root";
import type { Component } from "../system/component";
import type { Connection } from "../system/pagination";
import type { Context } from "../types";

/**
 * Identifies an Entity as being "trackable".
 * What exactly this means depends on the type underlying said entity and is
 * entirely user defined.
 *
 * @gqlInterface
 */
export interface Trackable extends Component {
  /**
   * @gqlField
   * @killsParentOnException
   */
  id: ID;

  /**
   * Entrypoint into the "tracking system" for a given Entity. Note that while
   * many types admit to being trackable, this does not mean that all entities
   * of those types will be trackable. For example, `Location`s admit to being
   * trackable, but are only trackable (in practice) when the user has
   * explicitly configured them to be so.
   *
   * @gqlField
   */
  trackable?: TrackingSystem;
}

/**
 * Identifies the current (or "active") state of a trackable Entity, as well as
 * the various legal state transitions that one can perform on said Entity.
 *
 * @gqlType
 */
export type TrackingSystem = {
  /**
   * The current (or "active") state of the trackable Entity.
   * It is perfectly valid for a trackable Entity to not be in *any* state, in
   * which case it is entirely implementation defined as to the semantic meaning
   * of such an "unknown" state. For example, this might indicate to an
   * application that the Entity is "idle".
   *
   * @gqlField
   */
  active?: string;
  /** @gqlField */
  transitions: string[];
};

/** @gqlField */
export async function trackable(
  _: Query,
  ctx: Context,
): Promise<Connection<Trackable>> {
  return {
    edges: [],
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: 0,
  };
}
