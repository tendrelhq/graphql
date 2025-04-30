import type { Int } from "grats";

/** @gqlType */
export type PageInfo = {
  /** @gqlField */
  startCursor?: string;
  /** @gqlField */
  endCursor?: string;
  /** @gqlField */
  hasNextPage: boolean;
  /** @gqlField */
  hasPreviousPage: boolean;
};

/** @gqlType */
export type Connection<T> = {
  /** @gqlField */
  edges: Edge<T>[];
  /** @gqlField */
  pageInfo: PageInfo;
  /** @gqlField */
  totalCount: Int;
};

/** @gqlType */
export type Edge<T> = {
  /** @gqlField */
  cursor: string;
  /** @gqlField */
  node: T;
};
