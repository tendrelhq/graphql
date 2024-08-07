export type * from "./types";
export type * from "./__generated__/types.generated";
export * from "./__generated__/typeDefs.generated";
export * from "./__generated__/resolvers.generated";

import { resolvers as generatedResolvers } from "./__generated__/resolvers.generated";
import type { Resolvers } from "./__generated__/types.generated";
import { Component } from "./system/resolvers/Component";

export const resolvers: Resolvers = {
  ...generatedResolvers,
  Component: Component,
};
