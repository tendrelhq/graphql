import { orm } from "@/datasources/postgres";
import type { Context } from "@/schema";
import { encodeGlobalId } from "@/schema/system";
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

async function createTestContext(): Promise<Context> {
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
