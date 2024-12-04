import type { Auth } from "@/auth";
import type { ORM } from "@/datasources/postgres";

export type Context = {
  auth: Auth;
  orm: ORM;
  req: Express.Request;
};

/**
 * Maps to the GraphQL ID type.
 * In practice, they will always be strings. Conceptually they are just an
 * "opaque" (i.e. not human readable) identifier.
 */
export type ID = string | number;
