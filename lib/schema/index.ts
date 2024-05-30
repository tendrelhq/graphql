import type { Auth } from "@/auth";
import type { ORM } from "@/datasources/postgres";
import type { User } from "./__generated__/types.generated";

export * from "./__generated__/resolvers.generated";
export * from "./__generated__/typeDefs.generated";
export * from "./__generated__/types.generated";

export type Context = {
  auth: Auth;
  orm: ORM;
};
