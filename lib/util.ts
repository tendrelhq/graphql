import type { SortOrder } from "@/schema";
import { type GlobalId, decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";
import type { Fragment } from "postgres";
import { sql } from "./datasources/postgres";

export function isError<T>(e: T | Error): e is Error {
  return e instanceof Error;
}

export function isValue<T>(v: T | Error): v is T {
  return !isError(v);
}

export function nullish<T>(t: T | null | undefined): t is null | undefined {
  return typeof t === "undefined" || t === null;
}

export class AssertionError extends Error {}

/**
 * Raises an assertion error when the condition does not hold, except in
 * production (and when DISABLE_ASSERTIONS is set) in which case we just log a
 * message instead of throwing.
 */
export function assert(condition: boolean, message = "assertion failed") {
  if (!condition) {
    if (
      // Only fire assertions when in dev/test environments,
      // and only when DISABLE_ASSERTIONS is unset.
      process.env.NODE_ENV !== "production" &&
      typeof process.env.DISABLE_ASSERTIONS === "undefined"
    ) {
      throw new AssertionError(message);
    }

    // Else just log a warning. We don't want to wholly lose our assertions.
    console.debug(`invariant violated: ${message}`);
  }
}

export function assertNonNull<T>(
  value: T | null | undefined,
  message = "Cannot return null for semantically non-nullable field.",
): T {
  if (nullish(value)) {
    throw new Error(message);
  }
  return value;
}

export function assertUnderlyingType(
  expected: string | string[],
  received: string,
) {
  const valid =
    typeof expected === "string"
      ? expected === received
      : expected.some(e => e === received);
  if (!valid) {
    throw new Error(
      `Invalid typename; expected: ${expected}, received: ${received}`,
    );
  }
  return received;
}

export type WithKey<T> = T & { _key: string };

export type PaginationArgs = {
  cursor?: GlobalId | null;
  direction: "forward" | "backward";
  limit: number;
};

type RawPaginationArgs = {
  // forward
  first?: number | null;
  after?: string | null;
  // backward
  last?: number | null;
  before?: string | null;
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
      cursor: map(args.after, decodeGlobalId),
      direction: "forward",
      limit: Math.min(args.first, opts.maxLimit),
    };
  }

  if (args.last) {
    return {
      cursor: map(args.before, decodeGlobalId),
      direction: "backward",
      limit: Math.min(args.last, opts.maxLimit),
    };
  }

  return {
    direction: "forward",
    limit: opts.defaultLimit,
  };
}

export function sortOrder(s: SortOrder): Fragment {
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

export function map<T, R>(
  t: T,
  fn: (t: NonNullable<T>) => R,
): T extends null | undefined ? T : R {
  if (nullish(t)) {
    return t as T extends null | undefined ? T : R;
  }
  return fn(t as NonNullable<T>) as T extends null | undefined ? T : R;
}

type OrElse<R> = () => R;
export function mapOrElse<T, R>(
  t: T,
  fn: (t: NonNullable<T>) => R,
  orElse: R | OrElse<R>,
): R {
  if (nullish(t)) {
    return typeof orElse === "function" ? (orElse as OrElse<R>)() : orElse;
  }
  return fn(t as NonNullable<T>);
}

export function inspect<T>(t: T) {
  console.debug("t =:", t);
  return t;
}

/**
 * Use this function to compare base64 encoded strings for identity.
 */
export function compareBase64(a: string, b: string): boolean {
  return normalizeBase64(a) === normalizeBase64(b);
}

// Postgres inserts newlines after 76 characters. Apparently it's a thing...
const newlinePattern = /\n/g;

/**
 * Use this function to normalize a base64 encoded string, i.e. remove newline
 * characters that are inserted by Postgres (for example) in certain cases.
 *
 * Note that most base64 implementations simply ignore these seemingly erroneous
 * newlines. As such, this function is mainly useful for (printf) debugging.
 */
export function normalizeBase64(s: string) {
  return s.replace(newlinePattern, "");
}
