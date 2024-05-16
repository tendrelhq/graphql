import { sql } from "@/datasources/postgres";
import type { Context } from "@/schema";
import type { JwtPayload } from "@clerk/types";
import type { NextFunction, Request, Response } from "express";
import { GraphQLError } from "graphql";
import jwt, { JsonWebTokenError } from "jsonwebtoken";

declare global {
  namespace Express {
    interface Request {
      token?: JwtPayload;
      "x-tendrel-user": Context["user"];
    }
  }
}

export default {
  jwt() {
    return async (req: Request, res: Response, next: NextFunction) => {
      const bearer = req.headers.authorization;

      try {
        if (bearer) {
          req.token = jwt.verify(
            bearer,
            // biome-ignore lint/style/noNonNullAssertion:
            process.env.CLERK_PUBLIC_KEY!,
          ) as JwtPayload;
        }

        if (req.token) {
          const [user] = await sql<[{ id: string; language_id: string }?]>`
            SELECT
                u.workeruuid AS id,
                l.systaguuid AS language_id
            FROM public.worker AS u
            INNER JOIN public.systag AS l
                ON u.workerlanguageid = l.systagid
            WHERE workeridentityid = ${req.token.sub};
          `;

          if (!user) {
            return res.status(404).send("User does not exist");
          }

          req["x-tendrel-user"] = user;
        }
      } catch (e) {
        if (
          e instanceof JsonWebTokenError ||
          (e instanceof GraphQLError && e.extensions.code === 401)
        ) {
          return res.status(401).send(e.message);
        }

        return next(e);
      }

      return next();
    };
  },
};

type AuthenticatedContext = Context & { user: NonNullable<Context["user"]> };

export function assertAuthenticated(
  ctx: Omit<Context, "orm">,
): asserts ctx is AuthenticatedContext {
  if (!ctx.user) {
    throw new GraphQLError("Unauthenticated", {
      extensions: {
        code: 401,
      },
    });
  }
}
