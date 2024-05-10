import type { Context } from "@/schema";
import z from "myzod";
import postgres from "postgres";
import makeCustomerLoader from "./customer";

if (process.env.DATABASE_URL) {
  const url = process.env.DATABASE_URL.split("://")[1];
  const [credential, endpoint] = url.split("@");
  const [username, password] = credential.split(":");
  const [host, rest] = endpoint.split(":");
  const [port, dbname] = rest.split("/");
  process.env.DB_USERNAME = username;
  process.env.DB_PASSWORD = password;
  process.env.DB_HOST = host;
  process.env.DB_PORT = port;
  process.env.DB_NAME = dbname;
}

const {
  DB_HOST,
  DB_PORT,
  DB_USERNAME,
  DB_PASSWORD,
  DB_NAME,
  DB_MAX_CONNECTIONS,
} = z
  .object({
    DB_HOST: z.string(),
    DB_PORT: z.number({ coerce: true }),
    DB_USERNAME: z.string(),
    DB_PASSWORD: z.string(),
    DB_NAME: z.string(),
    DB_MAX_CONNECTIONS: z.number({ coerce: true }).default(3),
  })
  .parse(process.env, { allowUnknown: true });

export const sql = postgres({
  username: DB_USERNAME,
  password: DB_PASSWORD,
  host: DB_HOST,
  port: DB_PORT,
  db: DB_NAME,
  max: DB_MAX_CONNECTIONS,
});

export function orm(ctx: Omit<Context, "orm">) {
  return {
    customer: makeCustomerLoader(ctx),
  };
}

export type ORM = ReturnType<typeof orm>;
