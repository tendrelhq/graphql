import { sql } from "@/datasources/postgres";
import type { ID } from "grats";
import type { Mutation, Query } from "../root";
import type { Component } from "../system/component";
import type { Task } from "../system/component/task";
import type { Connection } from "../system/pagination";
import type { Context } from "../types";
import { Location } from "./archetype/location";

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
   * Entrypoint into the "tracking system(s)" for a given Entity. Note that while
   * many types admit to being trackable, this does not mean that all in fact are
   * in practice. In order for an Entity to be trackable, it must be explicitly
   * configured as such.
   *
   * @gqlField
   */
  tracking(): Promise<Connection<Trackable> | null>;
}

// TODO:
// - add a "parent" argument to identify the root
// - add filter arguments to narrow down the underlying type of the trackables
//   that we return, e.g. withArchetype: ["Location"]
// - add pagination arguments
// - utilize `info` for optimizations
/** @gqlField */
export async function trackables(
  _: Query,
  ctx: Context,
): Promise<Connection<Trackable>> {
  // Only Locations are trackable at the moment.
  // All "trackable" locations have a special location type: Trackable.

  const nodes = await sql<Trackable[]>`
    SELECT
        'Location' AS "__typename",
        encode(('location:' || l.locationuuid)::bytea, 'base64') AS id
    FROM public.location AS l
    INNER JOIN public.custag AS c
        ON l.locationcategoryid = c.custagid
    INNER JOIN public.systag AS s
        ON c.custagsystagid = s.systagid
    WHERE
        l.locationcustomerid = ${90}
        AND s.systagtype = 'Trackable'
  `;

  return {
    edges: nodes.map(node => ({
      cursor: node.id,
      node: new Location(node.id, ctx),
    })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: nodes.length,
  };
}

/** @gqlInput */
export type TransitionInput = {
  into: ID;
  payload?: string;
};

/** @gqlType */
export type TransitionResult = {
  /** @gqlField */
  trackable: Trackable;
};

/** @gqlField */
export async function transition(
  _: Mutation,
  input: TransitionInput,
  ctx: Context,
): Promise<TransitionResult> {
  return Promise.reject();
}
