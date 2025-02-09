import { orm } from "@/datasources/postgres";
import type { Context, InputMaybe } from "@/schema";
import { encodeGlobalId } from "@/schema/system";
import type { PageInfo } from "@/schema/system/pagination";
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

// biome-ignore lint/suspicious/noExplicitAny:
type PaginateQueryOptions<R, V extends Record<any, any>> = {
  execute(cursor?: string): Promise<ExecutionResult<R>>;
  next(
    result: ExecutionResult<R>,
  ): Partial<{ endCursor?: string | null; hasNextPage?: boolean | null }>;
};

// biome-ignore lint/suspicious/noExplicitAny:
export async function* paginateQuery<R, V extends Record<any, any>>(
  opts: PaginateQueryOptions<R, V>,
) {
  let cursor: InputMaybe<string> = undefined;
  let done = false;
  while (!done) {
    const result = await opts.execute(cursor);
    yield result;
    const { endCursor, hasNextPage } = opts.next(result);
    cursor = endCursor as unknown as InputMaybe<string>;
    done = hasNextPage === false;
  }
}
