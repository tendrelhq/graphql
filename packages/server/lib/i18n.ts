import { match } from "@formatjs/intl-localematcher";
import type e from "express";
import Negotiator from "negotiator";
import { sql } from "./datasources/postgres";

declare global {
  namespace Express {
    interface Request {
      i18n: {
        language: string;
        // timezone?: string;
      };
    }
  }
}

export async function getAvailableLanguages() {
  const rows = await sql<{ code: string }[]>`
    select systagtype as code
    from public.systag
    where systagparentid = 2
      and (
        systagenddate is null
        or systagenddate > now()
      )
    order by systagorder, systagid
  `;
  return rows.map(row => row.code);
}

export async function getUserLanguage(req: e.Request) {
  const [row] = await sql<[{ code: string }?]>`
    select systagtype as code
    from public.worker
    inner join public.systag
      on workerlanguagetypeid = systagid
    where workeridentityid = ${req.auth.userId}
  `;
  return row?.code ?? "en";
}

export default {
  accept() {
    return async (req: e.Request, _: e.Response, next: e.NextFunction) => {
      const n = new Negotiator(req);
      const availableLanguages = await getAvailableLanguages();
      const defaultLanguage = await getUserLanguage(req);
      const languages = n.languages();
      req.i18n = {
        language:
          languages[0] === "*"
            ? defaultLanguage
            : match(languages, availableLanguages, defaultLanguage),
        // timezone: "utc",
      };
      next();
    };
  },
};
