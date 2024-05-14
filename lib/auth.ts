import { sql } from "@/datasources/postgres";
import type { Context } from "@/schema";
import type { JwtPayload } from "@clerk/types";
import type { NextFunction, Request, Response } from "express";
import { GraphQLError } from "graphql";
import jwt from "jsonwebtoken";

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
    return async (req: Request, _: Response, next: NextFunction) => {
      const auth = req.headers.authorization;

      if (auth) {
        req.token = jwt.verify(
          auth,
          // biome-ignore lint/style/noNonNullAssertion:
          process.env.CLERK_PUBLIC_KEY!,
        ) as JwtPayload;

        if (req.token) {
          const [user] = await sql<[{ id: string; language: number }?]>`
            SELECT
                workeruuid AS id,
                workerlanguageid AS language
            FROM public.worker
            WHERE workerexternalid = ${req.token.sub};
          `;

          if (!user) {
            throw new GraphQLError("Unauthenticated", {
              extensions: {
                code: 401,
              },
            });
          }

          req["x-tendrel-user"] = user;
        }
      }

      next();
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
