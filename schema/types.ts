import type { Auth } from "@/auth";
import type { ORM } from "@/datasources/postgres";
import type { GraphQLScalarType } from "graphql";

export type Context = {
  auth: Auth;
  orm: ORM;
};

export type TypedGraphQLScalarType<TInternal, TExternal> = GraphQLScalarType<
  TInternal,
  TExternal
> & {
  extensions: {
    codegenScalarType: string | { input: string; output: string };
  };
};
