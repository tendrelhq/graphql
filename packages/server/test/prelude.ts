import { getAccessToken, setCurrentIdentity } from "@/auth";
import type { TxSql } from "@/datasources/postgres";
import { Limits } from "@/limits";
import { makeRequestLoaders } from "@/orm";
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
import type { Faker } from "@faker-js/faker";
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
  ctx: Context,
  schema: GraphQLSchema,
  query: DocumentNode<R, V>,
  ...[variables]: V extends Record<string, never> ? [] : [V]
) {
  const result = await graphql({
    contextValue: ctx,
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
    orm: makeRequestLoaders(DEFAULT_REQUEST as any),
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

export async function assertTaskParentIs(t: Task, p: Location) {
  const tp = await t.parent();
  assert(
    p._type === tp?._type && p._id === tp?._id,
    `Expect Task to have parent '${p._id}' but got '${tp?._id}'`,
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

  static fromTypeId(type: "organization", id: string) {
    return new Customer({ id: encodeGlobalId({ type, id }) });
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

export async function createDefaultCustomer(
  args: {
    faker: Faker;
    seed: number;
  },
  ctx: Context,
  sql: TxSql,
): Promise<Customer> {
  await setCurrentIdentity(sql, ctx);

  // The procedure below logs so much shit.
  await sql`set local client_min_messages to warning`;
  const rows = await sql`
    call public.crud_customer_create(
      create_customername := ${args.seed.toString()},
      create_sitename := '',
      create_customeruuid := null,
      create_customerbillingid := ${args.faker.string.uuid()},
      create_customerbillingsystemid := '0033c894-fb1b-4994-be36-4792090f260b',
      -- create_customerbillingsystemid := (
      --     select systaguuid
      --     from public.systag
      --     where systagparentid = 959 and systagtype = 'Test'
      -- ),
      create_adminfirstname := '',
      create_adminlastname := '',
      create_adminemailaddress := '',
      create_adminphonenumber := '',
      create_adminidentityid := ${ctx.auth.userId},
      create_adminidentitysystemuuid := '0c1e3a50-ed4c-4469-95bd-e091104ae9d5',
      -- create_adminidentitysystemuuid := (
      --     select systaguuid
      --     from public.systag
      --     where systagparentid = 914 and systagtype = 'Clerk'
      -- ),
      create_adminuuid := null,
      create_siteuuid := null,
      create_timezone := ${args.faker.location.timeZone()},
      create_languagetypeuuids := array['7ebd10ee-5018-4e11-9525-80ab5c6aebee','c3f18dd6-bfc5-4ba5-b3c1-bb09e2a749a9'],
      -- create_languagetypeuuids := (
      --     select array_agg(systaguuid)
      --     from public.systag
      --     where systagparentid = 2 and systagtype in ('en', 'es')
      -- ),
      create_modifiedby := 895 -- cheers! -rugg
    );
  `;

  const customerId = assertNonNull(
    rows.at(0)?.create_customeruuid,
    "customer create failed 😠",
  );

  return Customer.fromTypeId("organization", customerId);
}
