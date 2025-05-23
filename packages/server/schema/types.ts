import type { Auth } from "@/auth";
import type { Limits } from "@/limits";
import type { ORM } from "@/orm";
import type { PostgrestClient } from "@supabase/postgrest-js";

/** @gqlContext */
export type Context = {
  auth: Auth;
  limits: Limits;
  pgrst: PostgrestClient;
  orm: ORM;
  req: Express.Request;
};

/**
 * Maps to the GraphQL ID type.
 * In practice, they will always be strings. Conceptually they are just an
 * "opaque" (i.e. not human readable) identifier.
 */
export type ID = string | number;
