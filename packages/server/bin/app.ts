import "dotenv/config";

import http from "node:http";
import * as auth from "@/auth";
import { orm } from "@/datasources/postgres";
import i18n from "@/i18n";
import { Limits } from "@/limits";
import type { Context } from "@/schema";
import { schema } from "@/schema/final";
import upload from "@/upload";
import { map } from "@/util";
import { ApolloServer } from "@apollo/server";
import { expressMiddleware } from "@apollo/server/express4";
import { ApolloServerPluginDrainHttpServer } from "@apollo/server/plugin/drainHttpServer";
import { PostgrestClient } from "@supabase/postgrest-js";
import cors from "cors";
import express from "express";
import { GraphQLError } from "graphql";
import morgan from "morgan";

if (process.argv.some(arg => arg === "--healthcheck")) {
  const r = await fetch("http://localhost:4000/live");
  process.exit(r.ok ? 0 : 1);
}

console.log(`NODE_ENV=${process.env.NODE_ENV}`);
if (process.env.NODE_ENV === "development") {
  console.debug("--------------------");
  console.debug(
    map(process.env, env => {
      const lines = [];
      for (const [key, value] of Object.entries(env)) {
        if (key !== "NODE_ENV") {
          lines.push(`${key}=${value}`);
        }
      }
      return lines.sort((a, b) => a.localeCompare(b)).join("\n");
    }),
  );
}

const app = express();
const httpServer = http.createServer(app);

const server = new ApolloServer<Context>({
  schema,
  introspection: true,
  formatError: (formattedError, error) => {
    console.warn(error);
    return formattedError;
  },
  plugins: [ApolloServerPluginDrainHttpServer({ httpServer })],
  nodeEnv: "production",
});

await server.start();

app.use(
  morgan("common"),
  cors({
    // for w3c trace context propagation
    allowedHeaders: "*",
  }),
);

app.use((req, _, next) => {
  if (process.env.DEBUG_HEADERS) {
    console.log(JSON.stringify(req.headers, null, 2));
  }
  next();
});

if (process.env.NODE_ENV === "development") {
  const swaggerUi = await import("swagger-ui-express");
  app.use(
    "/docs",
    swaggerUi.serve,
    swaggerUi.setup(null, {
      swaggerOptions: {
        url: "http://localhost/api/v1",
      },
    }),
  );
}

app.get("/live", (_, res) => res.send());

app.post(
  "/login",
  auth.clerk(), // Temporary.
  express.json(),
  auth.login,
);

app.post("/upload", auth.clerk(), express.json(), upload.POST);

app.use(
  "/",
  auth.clerk(),
  i18n.accept(),
  express.json(),
  expressMiddleware(server, {
    async context({ req }) {
      if (!req.auth.userId && process.env.NODE_ENV !== "development") {
        throw new GraphQLError("Unauthenticated", {
          extensions: {
            hint: "Please sign in",
          },
        });
      }
      return {
        auth: req.auth,
        limits: new Limits(),
        // PostgREST runs alongside graphql, i.e. in the same ECS cluster. We
        // can hit it over localhost to avoid nginx. This also works in the
        // default developer setup since *everything* is localhost.
        pgrst: new PostgrestClient("http://localhost:4001", {
          async fetch(...args) {
            const token = await auth
              .getAccessToken(req.auth.userId)
              .then(r => r.json())
              .then(r => r.access_token);
            const init = {
              ...(args[1] ?? {}),
              headers: {
                ...(args[1]?.headers ?? {}),
                Authorization: `Bearer ${token}`,
              },
            };
            return fetch(args[0], init);
          },
        }),
        orm: orm(req),
        req,
      } satisfies Context;
    },
  }),
);

const port = Number(process.env.PORT ?? 4000);
await new Promise<void>(resolve => httpServer.listen({ port }, resolve));

console.log(`Server ready at 0.0.0.0:${port}`);
