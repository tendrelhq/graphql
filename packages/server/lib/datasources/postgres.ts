import postgres, { type Fragment } from "postgres";
import z from "zod";

const { DB_MAX_CONNECTIONS, DB_STATEMENT_TIMEOUT_MS } = z
  .object({
    DB_MAX_CONNECTIONS: z.number({ coerce: true }).default(3),
    DB_STATEMENT_TIMEOUT_MS: z.number({ coerce: true }).default(10_000),
  })
  .parse(process.env);

export const sql = postgres({
  max: DB_MAX_CONNECTIONS,
  connection: {
    // We do some recursive queries and are, in general, not particularly
    // optimized so this is just a last resort to avoid bricking the backend.
    statement_timeout: DB_STATEMENT_TIMEOUT_MS,
  },
  types: {
    bigint: postgres.BigInt,
  },
});

export type Sql = typeof sql;
export type TxSql = Parameters<Parameters<typeof sql.begin>[1]>[0];

/**
 * Like Array.prototype.join but for sql.Fragments.
 */
export function join(xs: readonly Fragment[], d: Fragment) {
  return xs.reduce((acc, x, i) => sql`${acc} ${i ? sql`${d} ${x}` : x}`, sql``);
}

/**
 * Type predicate for whether to include a user input in a dynamic update
 * clause. Note that we only check for `undefined`, and not `null`, because we
 * say that `null` indicates we want to set the underlying database column to
 * NULL.
 */
export function shouldUpdate<T>(input?: T, existing?: T): input is T {
  return typeof input !== "undefined" && input !== existing;
}

export function unionAll(xs: readonly Fragment[]) {
  return join(xs, sql`UNION ALL`);
}
