import { getAccessToken, setCurrentIdentity } from "@/auth";
import { type TxSql, orm, sql } from "@/datasources/postgres";
import { Limits } from "@/limits";
import type { Context, InputMaybe } from "@/schema";
import {
  Location,
  type ConstructorArgs as LocationConstructorArgs,
} from "@/schema/platform/archetype/location";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import type { Field } from "@/schema/system/component";
import type { Task } from "@/schema/system/component/task";
import {
  assert,
  assertNonNull,
  assertUnderlyingType,
  map,
  normalizeBase64,
} from "@/util";
import type { TypedDocumentNode as DocumentNode } from "@graphql-typed-document-node/core";
import { PostgrestClient } from "@supabase/postgrest-js";
import {
  type ExecutionResult,
  type GraphQLSchema,
  graphql,
  print,
} from "graphql";
import type { ID } from "grats";

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
  const userId = assertNonNull(
    process.env.X_TENDREL_USER,
    "X_TENDREL_USER must be set when running tests",
  );
  return {
    // biome-ignore lint/suspicious/noExplicitAny: i know i know...
    auth: { userId } as any,
    limits: new Limits(),
    pgrst: new PostgrestClient("http://localhost:4001", {
      async fetch(...args) {
        const token = await getAccessToken(userId)
          .then(r => r.json())
          .then(r => r.access_token);
        const init = {
          ...(args[1] ?? {}),
          headers: {
            ...(args[1]?.headers ?? {}),
            Authorization: `Bearer ${token}`,
          },
        };
        return fetch(args[0], init);
      },
    }),
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
  expectedDisplayName: string,
  ctx: Context,
) {
  const actualDisplayName = await t.name(ctx).then(n => n.value(ctx));
  return assert(
    expectedDisplayName === actualDisplayName,
    `Expected Task named '${expectedDisplayName}' but got '${actualDisplayName}'`,
  );
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

export async function createEmptyCustomer(
  args: {
    name: string;
  },
  ctx: Context,
  sql: TxSql,
): Promise<Customer> {
  // FIXME: Use Keller's API.
  // Also, don't be fooled. This does NOT create a "runtime" customer. The
  // function just happens to be in the `runtime` schema :/
  // TODO: What is wrong with engine1.base64_encode??
  const [row] = await sql<[{ id: string }]>`
    select encode(('organization:' || t.id)::bytea, 'base64') as id
    from runtime.create_customer(
      customer_name := ${args.name},
      language_type := ${ctx.req.i18n.language},
      modified_by := 895
    ) as t;
  `;
  return new Customer(row);
}

// TODO: Convert to grats.
export class Customer {
  readonly _id: string;
  readonly id: ID;

  constructor(args: { id: ID }) {
    const { type, id } = decodeGlobalId(args.id);
    assertUnderlyingType("organization", type);
    this._id = id;
    this.id = normalizeBase64(args.id);
  }

  async addLocation(
    args: {
      name: string;
      type: string;
      timezone?: string;
    },
    ctx: Context,
    sql: TxSql,
  ): Promise<Location> {
    // TODO: Replace this with a Keller API.
    const [row] = await sql<[LocationConstructorArgs]>`
      select encode(('location:' || id)::bytea, 'base64') as id
      from legacy0.create_location(
        customer_id := ${this._id},
        language_type := ${ctx.req.i18n.language},
        location_name := ${args.name},
        location_parent_id := null,
        location_timezone := ${args.timezone ?? "utc"},
        location_typename := ${args.type},
        modified_by := 895
      );
    `;
    return new Location(row);
  }

  async addWorker(
    args: {
      identityId: string;
    },
    ctx: Context,
    sql: TxSql,
  ): Promise<void> {
    await sql`
      select count(*)
      from
        public.worker as w,
        legacy0.create_worker(
          customer_id := ${this._id},
          user_id := w.workeruuid,
          user_role := 'Admin',
          modified_by := 895
        )
      where w.workeridentityid = ${args.identityId};
    `;
  }
}
