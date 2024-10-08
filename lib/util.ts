import type { SortOrder } from "@/schema";
import { sql } from "./datasources/postgres";
import { GraphQLError } from "graphql";
import { decodeGlobalId, type GlobalId } from "@/schema/system";

export function isError<T>(e: T | Error): e is Error {
  return e instanceof Error;
}

export function isValue<T>(v: T | Error): v is T {
  return !isError(v);
}

export function nullish<T>(t: T | null | undefined): t is null | undefined {
  return typeof t === "undefined" || t === null;
}

export type WithKey<T> = T & { _key: string };

export type PaginationArgs = {
  cursor?: GlobalId;
  direction: "forward" | "backward";
  limit: number;
};

type RawPaginationArgs = {
  // forward
  first?: number;
  after?: string;
  // backward
  last?: number;
  before?: string;
};

export function buildPaginationArgs(
  args: RawPaginationArgs,
  opts: {
    defaultLimit: number;
    maxLimit: number;
  },
): PaginationArgs {
  validatePaginationArgs(args);

  if (args.first) {
    return {
      cursor: args.after ? decodeGlobalId(args.after) : undefined,
      direction: "forward",
      limit: Math.min(args.first, opts.maxLimit),
    };
  }

  if (args.last) {
    return {
      cursor: args.before ? decodeGlobalId(args.before) : undefined,
      direction: "backward",
      limit: Math.min(args.last, opts.maxLimit),
    };
  }

  return {
    direction: "forward",
    limit: opts.defaultLimit,
  };
}

export function sortOrder(s: SortOrder) {
  switch (s) {
    case "asc":
      return sql`ASC`;
    case "desc":
      return sql`DESC`;
  }
}

export function validatePaginationArgs(args: RawPaginationArgs) {
  if ((args.after && args.before) || (args.first && args.last)) {
    throw new GraphQLError(
      "Invalid pagination arguments. To paginate forward, use the `first` and `after` arguments. To paginate backward, use the `last` and `before` arguments.",
      {
        extensions: {
          code: "BAD_REQUEST",
        },
      },
    );
  }
}
