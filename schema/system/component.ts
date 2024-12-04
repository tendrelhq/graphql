import type { ID } from "grats";

/**
 * Components characterize Entities as possessing a particular trait.
 * They are just simple structs, holding all data necessary to model that trait.
 *
 * @gqlInterface
 */
export interface Component {
  __typename: string;

  /**
   * @gqlField
   * @killsParentOnException
   */
  id: ID;
}
