import { match } from "@formatjs/intl-localematcher";
import type e from "express";
import Negotiator from "negotiator";

declare global {
  namespace Express {
    interface Request {
      i18n: {
        language: string;
      };
    }
  }
}

export default {
  accept() {
    return async (req: e.Request, res: e.Response, next: e.NextFunction) => {
      const n = new Negotiator(req);
      const languages = n.languages();
      req.i18n = {
        language:
          languages[0] === "*" ? "en" : match(languages, ["en", "es"], "en"),
      };
      next();
    };
  },
};
