import z from "myzod";
import postgres, { type Fragment } from "postgres";

import type { Request } from "express";
import { makeActiveLoader } from "./activatable";
import { makeAuditableLoader } from "./auditable";
import makeCustomerRequestedLanguageLoader from "./crl";
import { makeDescriptionLoader } from "./description";
import { makeDynamicStringLoader } from "./dynamicString";
import makeInvitationLoader from "./invitation";
import makeLanguageLoader from "./language";
import makeLocationLoader from "./location";
import {
  makeDisplayNameLoader,
  makeNameLoader,
  makeNameMetadataLoader,
} from "./name";
import makeOrganizationLoader from "./organization";
import { makeRequirementLoader } from "./requirement";
import { makeSopLoader } from "./sop";
import { makeStatusLoader } from "./status";
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
  DB_STATEMENT_TIMEOUT,
} = z
  .object({
    DB_HOST: z.string(),
    DB_PORT: z.number({ coerce: true }),
    DB_USERNAME: z.string(),
    DB_PASSWORD: z.string(),
    DB_NAME: z.string(),
    DB_MAX_CONNECTIONS: z.number({ coerce: true }).default(3),
    DB_STATEMENT_TIMEOUT: z.number({ coerce: true }).default(10),
  })
  .parse(process.env, { allowUnknown: true });

export const sql = postgres({
  username: DB_USERNAME,
  password: DB_PASSWORD,
  host: DB_HOST,
  port: DB_PORT,
  database: DB_NAME,
  max: DB_MAX_CONNECTIONS,
  // TODO: this is probably a good idea...
  // connection: {
  //   statement_timeout: DB_STATEMENT_TIMEOUT * 1000, // milliseconds
  // },
});

export type SQL = typeof sql;
export type TxSQL = Parameters<Parameters<typeof sql.begin>[1]>[0];

export function join(xs: readonly Fragment[], d: Fragment) {
  return xs.reduce((acc, x, i) => sql`${acc} ${i ? sql`${d} ${x}` : x}`, sql``);
}

export function unionAll(xs: readonly Fragment[]) {
  return join(xs, sql`UNION ALL`);
}

export function orm(req: Request) {
  return {
    active: makeActiveLoader(req),
    auditable: makeAuditableLoader(req),
    crl: makeCustomerRequestedLanguageLoader(req),
    description: makeDescriptionLoader(req),
    displayName: makeDisplayNameLoader(req),
    dynamicString: makeDynamicStringLoader(req),
    invitation: makeInvitationLoader(req),
    language: makeLanguageLoader(req),
    location: makeLocationLoader(req),
    name: makeNameLoader(req),
    nameMetadata: makeNameMetadataLoader(req),
    organization: makeOrganizationLoader(req),
    requirement: makeRequirementLoader(req),
    sop: makeSopLoader(req),
    status: makeStatusLoader(req),
    tag: makeTagLoader(req),
    user: makeUserLoader(req),
    worker: makeWorkerLoader(req),
  };
}

export type ORM = ReturnType<typeof orm>;
