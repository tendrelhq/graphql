import { decodeGlobalId } from "@/schema/system";
import type { Context } from "@/schema/types";
import {
  ClerkExpressRequireAuth,
  type StrictAuthProp,
} from "@clerk/clerk-sdk-node";
import type e from "express";
import { GraphQLError } from "graphql";
import { type TxSql, sql } from "./datasources/postgres";

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
  allowed: ("Worker" | "Supervisor" | "Admin")[],
) {
  const rows = await sql`
    select 1
    from public.workerinstance as w
    inner join public.systag as s on w.workerinstanceuserroleid = s.systagid
    where
        w.workerinstancecustomerid = (
            select customerid
            from public.customer
            where customeruuid = ${decodeGlobalId(orgId).id}
        )
        and w.workerinstanceworkerid = (
            select workerid
            from public.worker
            where workeridentityid = ${userId}
        )
        and s.systagtype in (${sql(allowed)});
  `;

  if (!rows.length) {
    throw new GraphQLError("Not authorized", {
      extensions: {
        code: "UNAUTHORIZED",
        hint: "You do not have the necessary permissions to perform this action",
      },
    });
  }
}

export function setCurrentIdentity(sql: TxSql, ctx: Context) {
  return sql`select * from auth.set_actor(${ctx.auth.userId}, ${ctx.req.i18n.language})`;
}
