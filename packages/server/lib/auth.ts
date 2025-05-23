import { decodeGlobalId } from "@/schema/system";
import type { Context } from "@/schema/types";
import {
  ClerkExpressRequireAuth,
  type StrictAuthProp,
} from "@clerk/clerk-sdk-node";
import type e from "express";
import type { RequestHandler } from "express";
import { GraphQLError } from "graphql";
import config from "./config";
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

/**
 * Verify the provided *external* security token, generate a short-lived,
 * finely-grained subject token, and then call our /token api to perform the
 * actual token exchange. The client should not be aware that we are performing
 * this multi-step process.
 */
export const login: RequestHandler = async (req, res) => {
  try {
    const r = await getAccessToken(req.auth.userId);
    const token = await r.json();

    res
      // https://www.rfc-editor.org/rfc/rfc6749#section-5.1
      .setHeader("Cache-Control", "no-store")
      .setHeader("Pragma", "no-cache")
      .status(r.status);

    if (!r.ok) {
      // https://www.rfc-editor.org/rfc/rfc6749#section-5.2
      res.json({
        error: token.code,
        error_description: token.message,
      });
    } else {
      res.json(token);
    }
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal Server Error");
  }
};

const ACCESS_TOKEN_ENDPOINT = new URL("/api/v1/rpc/token", config.base_url);

/**
 * Get an access token for the given `sub`ject. This is always a Clerk user ID
 * at the moment.
 */
export async function getAccessToken(sub: string) {
  const [{ jwt }] = await sql`
    select auth.jwt_sign(
      json_build_object(
        'role', 'anonymous',
        'iss', ${config.jwt_iss}::text,
        'iat', extract(epoch from now()),
        'nbf', extract(epoch from now()) - 30 /* seconds */,
        'exp', extract(epoch from now()) + 30 /* seconds */,
        'sub', ${sub}::text
      )
    ) as jwt;
  `;

  // Same URL in both development and production. In development this assumes
  // that Postgrest is running locally on port 4001, which it will be if you
  // use the docker-compose file.
  return await fetch(ACCESS_TOKEN_ENDPOINT, {
    method: "POST",
    body: JSON.stringify({
      grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
      subject_token: jwt,
      subject_token_type: "urn:ietf:params:oauth:token-type:jwt",
    }),
    headers: {
      Authorization: `Bearer ${jwt}`,
    },
  });
}

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
