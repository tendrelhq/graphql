import { decodeGlobalId } from "@/schema/system";
import {
  ClerkExpressRequireAuth,
  type StrictAuthProp,
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
    // In development it is nice to be able to use graphiql to help write your
    // queries. The default `devenv` will spin up a ruru[^1] graphiql endpoint
    // that you can use from your browser: http://localhost:1337.
    //
    // [^1]: https://github.com/graphile/crystal/tree/main/grafast/ruru
    //
    // tl;dr if you set the 'x-tendrel-user' header to a Clerk user id, we will
    // use that as the authenticated identity
    return (req: e.Request, res: e.Response, next: e.NextFunction) => {
      if (process.env.NODE_ENV === "development") {
        const userId = req.headers["x-tendrel-user"];
        console.log(`Backdoor hack engaged? ${userId}`);
        if (userId) {
          req.auth = {
            userId: userId as string,
          } as Auth;

          return next();
        }
      }

      ClerkExpressRequireAuth()(req, res, err => {
        if (err instanceof Error) {
          // @ts-ignore
          err.statusCode = 401;
        }

        next(err);
      });
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
