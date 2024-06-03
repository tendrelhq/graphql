import z from "myzod";
import postgres from "postgres";

import type { Request } from "express";
import makeLanguageLoader from "./language";
import makeLocationLoader from "./location";
import makeNameLoader from "./name";
import makeOrganizationLoader from "./organization";
import makeTagLoader from "./tag";
import makeUserLoader from "./user";
import makeWorkerLoader from "./worker";

if (process.env.DATABASE_URL) {
  const url = new URL(process.env.DATABASE_URL);
  process.env.DB_USERNAME = url.username;
  process.env.DB_PASSWORD = url.password;
  process.env.DB_HOST = url.host;
  process.env.DB_PORT = url.port;
  process.env.DB_NAME = url.pathname.substring(1);
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
  database: DB_NAME,
  max: DB_MAX_CONNECTIONS,
});

export function orm(req: Request) {
  return {
    language: makeLanguageLoader(req),
    location: makeLocationLoader(req),
    name: makeNameLoader(req),
    organization: makeOrganizationLoader(req),
    tag: makeTagLoader(req),
    user: makeUserLoader(req),
    worker: makeWorkerLoader(req),
  };
}

export type ORM = ReturnType<typeof orm>;
