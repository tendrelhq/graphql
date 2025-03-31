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
import { assert } from "./util";

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

/**
 * Verify the provided *external* security token, generate a short-lived,
 * finely-grained subject token, and then call our /token api to perform the
 * actual token exchange. The client should not be aware that we are performing
 * this multi-step process.
 */
export const login: RequestHandler = async (req, res) => {
  // TODO: Move this elsewhere.
  const ALG = process.env.JWT_ALG ?? "HS256";
  const SECRET = new TextEncoder().encode(process.env.JWT_SECRET);
  // N.B. when JWT_ALG = HS256, JWT_SECRET must be at least 32 bytes!
  if (ALG === "HS256") assert(SECRET.length >= 32, "invalid jwt secret");

  const { userId } = req.auth;

  // TODO: ensure the user exists in the system, effectively making this API a
  // dual login/signup API. For now we will assume that the user has already
  // "signed up" for a Tendrel account, i.e. via the canonical Clerk/console flow.

  const temp = await new jose.SignJWT({ role: "anonymous" })
    .setProtectedHeader({ alg: ALG, typ: "JWT" })
    .setIssuer(`urn:tendrel:${process.env.STAGE}`)
    .setIssuedAt() // now
    .setNotBefore("-5 minutes")
    .setExpirationTime("5 minutes")
    .setSubject(userId)
    .sign(SECRET);

  try {
    // Same URL in both development and production. In development this will hit
    // the nginx proxy running on localhost. In production it will hit the same
    // proxy but running in a separate (ECS) container.
    const token = await fetch("http://localhost/api/v1/rpc/token", {
      method: "POST",
      body: JSON.stringify({
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        subject_token: temp,
        subject_token_type: "urn:ietf:params:oauth:token-type:jwt",
      }),
      headers: {
        Authorization: `Bearer ${temp}`,
      },
    });

    const json = await token.json();

    res
      // https://www.rfc-editor.org/rfc/rfc6749#section-5.1
      .setHeader("Cache-Control", "no-store")
      .setHeader("Pragma", "no-cache")
      .status(token.status);

    if (!token.ok) {
      // https://www.rfc-editor.org/rfc/rfc6749#section-5.2
      res.json({
        error: json.code,
        error_description: json.message,
      });
    } else {
      res.json(json);
    }
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal Server Error");
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
