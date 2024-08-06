import type { GraphQLScalarType } from "graphql";

// biome-ignore lint/complexity/noBannedTypes: FIXME
export type Context = {
  //
};

export type TypedGraphQLScalarType<TInternal, TExternal> = GraphQLScalarType<
  TInternal,
  TExternal
> & {
  extensions: {
    codegenScalarType: string | { input: string; output: string };
  };
};
