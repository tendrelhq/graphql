import type { Auth } from "@/auth";
import type { ORM } from "@/datasources/postgres";

export type Context = {
  auth: Auth;
  orm: ORM;
};
