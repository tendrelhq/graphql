import {
  ClerkExpressWithAuth,
  type StrictAuthProp,
  clerkClient,
} from "@clerk/clerk-sdk-node";
import type e from "express";
import { sql } from "./datasources/postgres";

declare global {
  namespace Express {
    interface Request extends StrictAuthProp {}
  }
}

export type Auth = StrictAuthProp["auth"];

export default {
  clerk() {
    const clerkMiddleware = ClerkExpressWithAuth();
    return async (req: e.Request, res: e.Response, next: e.NextFunction) => {
      if (process.env.NODE_ENV === "development") {
        const userId = req.headers["x-tendrel-user"];
        if (userId) {
          req.auth = {
            userId: userId as string,
          } as Auth;

          return next();
        }
      }

      clerkMiddleware(req, res, next);
    };
  },
};

export async function protect(
  { orgId, userId }: { orgId: string; userId: string },
  allowed: string[],
) {
  const rows = await sql<{ type: string }[]>`
      SELECT s.systagtype
      FROM public.workerinstance AS w
      INNER JOIN public.systag AS s
          ON w.workerinstanceuserroleid = s.systagid
      WHERE
          w.workerinstancecustomerid = (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${orgId}
          )
          AND w.workerinstanceworkerid = (
              SELECT workerid
              FROM public.worker
              WHERE workeridentityid = ${userId}
          );
  `;

  return rows.some(r => allowed.includes(r.type));
}
