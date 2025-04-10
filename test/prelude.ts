import { getAccessToken, setCurrentIdentity } from "@/auth";
import { orm, sql } from "@/datasources/postgres";
import { Limits } from "@/limits";
import type { Context, InputMaybe } from "@/schema";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import type { Field } from "@/schema/system/component";
import type { Task } from "@/schema/system/component/task";
import { assert, assertNonNull, assertUnderlyingType, map } from "@/util";
import type { TypedDocumentNode as DocumentNode } from "@graphql-typed-document-node/core";
import { PostgrestClient } from "@supabase/postgrest-js";
import {
  type ExecutionResult,
  type GraphQLSchema,
  graphql,
  print,
} from "graphql";

// biome-ignore lint/suspicious/noExplicitAny:
export async function execute<R, V extends Record<string, any>>(
  schema: GraphQLSchema,
  query: DocumentNode<R, V>,
  ...[variables]: V extends Record<string, never> ? [] : [V]
) {
  const result = await graphql({
    contextValue: await createTestContext(),
    schema,
    source: print(query),
    variableValues: variables,
  });

  return result as ExecutionResult<R>;
}

const DEFAULT_REQUEST = {
  i18n: {
    language: "en",
  },
};

export async function createTestContext(): Promise<Context> {
  return {
    // biome-ignore lint/suspicious/noExplicitAny: i know i know...
    auth: { userId: process.env.X_TENDREL_USER } as any,
    limits: new Limits(),
    // biome-ignore lint/suspicious/noExplicitAny: ...room for improvement...
    orm: orm(DEFAULT_REQUEST as any),
    // biome-ignore lint/suspicious/noExplicitAny: ...but whatever.
    req: DEFAULT_REQUEST as any,
  };
}

let id = 0;

export function testGlobalId() {
  return encodeGlobalId({ type: "__test__", id: (++id).toString() });
}

export const NOW = new Date(1725823905364);

type PaginateQueryOptions<R> = {
  execute(cursor?: string): Promise<ExecutionResult<R>>;
  next(
    result: ExecutionResult<R>,
  ): Partial<{ endCursor?: string | null; hasNextPage?: boolean | null }>;
};

export async function* paginateQuery<R>(opts: PaginateQueryOptions<R>) {
  let cursor: InputMaybe<string> = undefined;
  let done = false;
  while (!done) {
    const result = await opts.execute(cursor);
    yield result;
    const { endCursor, hasNextPage } = opts.next(result);
    // We should be able to handle `null`, even though InputMaybe says
    // otherwise...
    cursor = endCursor as unknown as InputMaybe<string>;
    done = hasNextPage === false;
  }
}

export function findAndEncode(
  op: string,
  type: string,
  logs: { op: string; id: string }[],
  opts?: { skip?: number },
) {
  let count = 0;
  const skip = opts?.skip ?? 0;
  return assertNonNull(
    map(
      logs.find(l => {
        if (l.op.trim() === `+${op}`) {
          return count++ === skip;
        }
        return false;
      }),
      ({ id }) => encodeGlobalId({ type, id }),
    ),
    `setup failed to find ${op} (${type})`,
  );
}

export async function assertTaskIsNamed(
  t: Task,
  displayName: string,
  ctx: Context,
) {
  const n = await t.name(ctx);
  return assert(displayName === (await n.value(ctx)));
}

export function assertNoDiagnostics<
  T extends { diagnostics?: Array<unknown> | null },
>(result?: T | null) {
  assert(!result?.diagnostics?.length);
}

export async function getFieldByName(t: Task, name: string): Promise<Field> {
  const field = await t.field({ byName: name });
  return assertNonNull(field, `no named field ${name}`);
}

/**
 * Set an environment variable for the current scope, and automatically revert
 * it to its original value on (scope) exit.
 *
 * @example
 * ```typescript
 * process.env.MY_VAR = "false";
 * {
 *   using _ = env("MY_VAR", true);
 *   assert(process.env.MY_VAR === "true");
 * }
 * assert(process.env.MY_VAR === "false");
 * ```
 */
export function env(name: string, value?: { toString(): string }) {
  const old = process.env[name];
  process.env[name] = value?.toString();
  return {
    [Symbol.dispose]() {
      process.env[name] = old;
    },
  };
}

export async function setup(ctx: Context) {
  return await sql.begin(async sql => {
    await setCurrentIdentity(sql, ctx);
    return await sql<{ op: string; id: string }[]>`
      select *
      from
          runtime.create_demo(
              customer_name := 'Frozen Tendy Factory',
              admins := (
                  select array_agg(workeruuid)
                  from public.worker
                  where workeridentityid = current_setting('user.id')
              ),
              modified_by := 895
          )
      ;
    `;
  });
}

export async function cleanup(id: string) {
  if (process.env.CI || process.env.SKIP_CLEANUP) {
    console.warn("Skipping cleanup for", id);
    return;
  }
  process.stdout.write("Cleaning up...");

  const decoded = decodeGlobalId(id);
  assertUnderlyingType("organization", decoded.type);

  // HACK: need to add this to the cleanup procedure.
  await sql`
    delete from public.workdescription
    where workdescriptioncustomerid = (
        select customerid
        from public.customer
        where customeruuid = ${decoded.id}
    )
  `;
  const [row] = await sql<[{ ok: string }]>`
    select runtime.destroy_demo(${decoded.id}) as ok;
  `;
  process.stdout.write(row.ok);
}

export const pg = new PostgrestClient("http://localhost/api/v1", {
  async fetch(...args) {
    const ctx = await createTestContext();
    const token = await getAccessToken(ctx.auth.userId)
      .then(r => r.json())
      .then(r => r.access_token);
    if (typeof args[1] === "object") {
      args[1] = {
        ...args[1],
        headers: {
          ...args[1].headers,
          Authorization: `Bearer ${token}`,
        },
      };
    }
    return fetch(...args);
  },
});
