import { mapOrElse } from "@/util";
import type { Request } from "express";
import { makeActiveLoader } from "./datasources/activatable";
import { makeAuditableLoader } from "./datasources/auditable";
import makeCustomerRequestedLanguageLoader from "./datasources/crl";
import { makeDescriptionLoader } from "./datasources/description";
import { makeDynamicStringLoader } from "./datasources/dynamicString";
import makeInvitationLoader from "./datasources/invitation";
import makeLanguageLoader from "./datasources/language";
import makeLocationLoader from "./datasources/location";
import {
  makeDisplayNameLoader,
  makeNameLoader,
  makeNameMetadataLoader,
} from "./datasources/name";
import makeOrganizationLoader from "./datasources/organization";
import { makeRequirementLoader } from "./datasources/requirement";
import makePresignedUrlLoader from "./datasources/s3";
import { makeSopLoader } from "./datasources/sop";
import { makeStatusLoader } from "./datasources/status";
import makeTagLoader from "./datasources/tag";
import makeUserLoader from "./datasources/user";
import makeWorkerLoader from "./datasources/worker";

const DEFAULT_PRESIGNED_URL_EXPIRES_IN = 60 * 60 * 24; // 24 hours

export function makeRequestLoaders(req: Request) {
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
    // out of place but whatever
    s3: makePresignedUrlLoader(req, {
      expiresIn: mapOrElse(
        process.env.PRESIGNED_URL_EXPIRES_IN,
        Number.parseInt,
        DEFAULT_PRESIGNED_URL_EXPIRES_IN,
      ),
    }),
  };
}

export type ORM = ReturnType<typeof makeRequestLoaders>;
