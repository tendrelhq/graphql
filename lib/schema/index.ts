import type { Auth } from "@/auth";
import type { ORM } from "@/datasources/postgres";

export * from "./__generated__/resolvers.generated";
export * from "./__generated__/typeDefs.generated";
export * from "./__generated__/types.generated";

type User = {
  id: string;
  language_id: string;
};

export type Context = {
  auth: Auth;
  user: User;
  orm: ORM;
};
