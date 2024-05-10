import type { ORM } from "@/datasources/postgres";

export * from "./__generated__/resolvers.generated";
export * from "./__generated__/typeDefs.generated";
export * from "./__generated__/types.generated";

export type Context = {
  authScope?: string;
  languageTypeId: number;
  orm: ORM;
};
