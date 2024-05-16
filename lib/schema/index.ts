import type { ORM } from "@/datasources/postgres";
import type { JwtPayload } from "@clerk/types";

export * from "./__generated__/resolvers.generated";
export * from "./__generated__/typeDefs.generated";
export * from "./__generated__/types.generated";

type User = {
  id: string;
  language_id: string;
};

export type Context = {
  token?: JwtPayload;
  user?: User;
  orm: ORM;
};
