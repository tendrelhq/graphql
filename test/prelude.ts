import { orm } from "@/datasources/postgres";
import { Limits } from "@/limits";
import type { Context, InputMaybe } from "@/schema";
import { encodeGlobalId } from "@/schema/system";
import type { Field } from "@/schema/system/component";
import type { Task } from "@/schema/system/component/task";
import { assert, assertNonNull, map } from "@/util";
import type { TypedDocumentNode as DocumentNode } from "@graphql-typed-document-node/core";
import {
  type ExecutionResult,
  type GraphQLSchema,
  graphql,
  print,
} from "graphql";

// biome-ignore lint/suspicious/noExplicitAny:
export async function execute<R, V extends Record<any, any>>(
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
) {
  return assertNonNull(
    map(
      logs.find(l => l.op.trim() === `+${op}`),
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
  const dn = await t.displayName();
  const n = await dn.name(ctx);
  return n.value === displayName;
}

export function assertNoDiagnostics<T, R extends { __typename?: T }>(
  result?: R | null,
) {
  assert(result?.__typename !== "Diagnostic");
}

export async function getFieldByName(t: Task, name: string): Promise<Field> {
  const field = await t.field({ byName: { value: name } });
  return assertNonNull(field, `no named field ${name}`);
}

export function env(name: string, value?: { toString(): string }) {
  const old = process.env[name];
  process.env[name] = value?.toString();
  return {
    [Symbol.dispose]() {
      process.env[name] = old;
    },
  };
}
