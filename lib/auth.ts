import { decodeGlobalId } from "@/schema/system";
import type { Context } from "@/schema/types";
import {
  ClerkExpressRequireAuth,
  type StrictAuthProp,
} from "@clerk/clerk-sdk-node";
import type e from "express";
import type { RequestHandler } from "express";
import { GraphQLError } from "graphql";
import * as jose from "jose";
import { type TxSql, sql } from "./datasources/postgres";

declare global {
  namespace Express {
    interface Request extends StrictAuthProp {}
  }
}

export type Auth = StrictAuthProp["auth"];

export function clerk() {
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
}

// N.B. when JWT_ALG = HS256, JWT_SECRET must be at least 32 bytes!
const ALG = process.env.JWT_ALG ?? "HS256";
const SECRET = new TextEncoder().encode(process.env.JWT_SECRET);

/**
 * Verify the provided *external* security token, generate a short-lived,
 * finely-grained subject token, and then call our /token api to perform the
 * actual token exchange. The client should not be aware that we are performing
 * this multi-step process.
 */
export const login: RequestHandler = async (req, res) => {
  const { userId } = req.auth;

  const op = new jose.SignJWT({ role: "anon" })
    .setProtectedHeader({ alg: ALG, typ: "JWT" })
    .setIssuer(`urn:tendrel:${process.env.STAGE}`)
    .setIssuedAt() // now
    .setSubject(userId);

  try {
    res.json({
      access_token: await op.sign(SECRET),
      issued_token_type: "urn:ietf:params:oauth:token-type:jwt",
      token_type: "Bearer",
    });
  } catch (e) {
    res.status(401).json({
      error: "invalid_request",
      error_description: e instanceof Error ? e.message : undefined,
    });
  }
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
