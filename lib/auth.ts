import {
  ClerkExpressWithAuth,
  type StrictAuthProp,
} from "@clerk/clerk-sdk-node";
import type e from "express";
import { sql } from "./datasources/postgres";
import { decodeGlobalId } from "./util";

declare global {
  namespace Express {
    interface Request extends StrictAuthProp {}
  }
}

export type Auth = StrictAuthProp["auth"];

export default {
  clerk() {
    // In development it is nice to be able to use graphiql to help write your
    // queries. The tendrel console explorer is pretty janky so one day this
    // won't be necessary, but we'll add this little backdoor in until then.
    // Note that this won't work (easily) once Clerk organizations and roles
    // enter the fold.
    //
    // tl;dr if you set the 'x-tendrel-user' header to a Clerk user id, we will
    // use that as the authenticated identity
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
  const rows = await sql`
      SELECT 1
      FROM public.workerinstance AS w
      INNER JOIN public.systag AS s
          ON w.workerinstanceuserroleid = s.systagid
      WHERE
          w.workerinstancecustomerid = (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${decodeGlobalId(orgId).id}
          )
          AND w.workerinstanceworkerid = (
              SELECT workerid
              FROM public.worker
              WHERE workeridentityid = ${userId}
          )
          AND s.systagtype IN (${sql(allowed)});
  `;

  return rows.length > 0;
}
