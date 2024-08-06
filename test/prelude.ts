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
    schema,
    source: print(query),
    variableValues: variables,
  });

  return result as ExecutionResult<R>;
}
