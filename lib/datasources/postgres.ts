import type { Request } from "express";
import z from "myzod";
import postgres, { type Fragment } from "postgres";
import { makeActiveLoader } from "./activatable";
import makeAttachmentLoader from "./attachment";
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

const { DB_MAX_CONNECTIONS, DB_STATEMENT_TIMEOUT } = z
  .object({
    DB_MAX_CONNECTIONS: z.number({ coerce: true }).default(3),
    DB_STATEMENT_TIMEOUT: z.number({ coerce: true }).default(10),
  })
  .parse(process.env, { allowUnknown: true });

export const sql = postgres({
  max: DB_MAX_CONNECTIONS,
  // TODO: this is probably a good idea...
  // connection: {
  //   statement_timeout: DB_STATEMENT_TIMEOUT * 1000, // milliseconds
  // },
});

export type SQL = typeof sql;
export type TxSQL = Parameters<Parameters<typeof sql.begin>[1]>[0];

/**
 * Like Array.prototype.join but for sql.Fragments.
 */
export function join(xs: readonly Fragment[], d: Fragment) {
  return xs.reduce((acc, x, i) => sql`${acc} ${i ? sql`${d} ${x}` : x}`, sql``);
}

/**
 * Type predicate for whether to include a user input in a dynamic update
 * clause. Note that we only check for `undefined`, and not `null`, because we
 * say that `null` indicates we want to set the underlying database column to
 * NULL.
 */
export function shouldUpdate<T>(input?: T, existing?: T): input is T {
  return typeof input !== "undefined" && input !== existing;
}

export function unionAll(xs: readonly Fragment[]) {
  return join(xs, sql`UNION ALL`);
}

export function orm(req: Request) {
  return {
    active: makeActiveLoader(req),
    attachment: makeAttachmentLoader(req),
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
