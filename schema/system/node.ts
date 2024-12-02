import type { ID } from "grats";
import { encodeGlobalId } from ".";

/**
 * Indicates an object that is "refetchable".
 *
 * @gqlInterface Node
 */
export interface Refetchable {
  /** GraphQL typename. */
  readonly __typename: string;

  /**
   * Internal type, which typically maps to the underlying database table name.
   */
  readonly _type: string;

  /**
   * Internal identifier, which typically maps to the underlying database
   * primary key.
   */
  readonly _id: string;
}

/**
 * A globally unique opaque identifier for a node.
 *
 * @see https://graphql.org/learn/global-object-identification/
 *
 * @gqlField
 * @killsParentOnException
 */
export function id(node: Refetchable): ID {
  return encodeGlobalId({
    type: node._type,
    id: node._id,
  });
}
