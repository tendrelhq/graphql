import "dotenv/config";

import http from "node:http";
import * as auth from "@/auth";
import config from "@/config";
import i18n from "@/i18n";
import { Limits } from "@/limits";
import { makeRequestLoaders } from "@/orm";
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
  console.debug("--------------------");
  for (const [key, value] of Object.entries(config)) {
    console.debug(`${key.toUpperCase()}:`, value.toString());
  }
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
      console.debug(JSON.stringify(req.body, null, 2));

      if (!req.auth.userId && process.env.NODE_ENV !== "development") {
        throw new GraphQLError("Unauthenticated", {
          extensions: {
            hint: "Please sign in",
          },
        });
      }

      // Just fire it off, don't await.
      const token = auth
        .getAccessToken(req.auth.userId)
        .then(r => r.json())
        .then(r => r.access_token);

      return {
        auth: req.auth,
        limits: new Limits(),
        // PostgREST runs alongside graphql, i.e. in the same ECS cluster. We
        // can hit it over localhost to avoid nginx. This also works in the
        // default developer setup since *everything* is localhost.
        pgrst: new PostgrestClient(config.pgrst_url.toString(), {
          // @ts-expect-error - idk man
          async fetch(input, init) {
            return fetch(input, {
              ...(init ?? {}),
              headers: {
                ...(init?.headers ?? {}),
                Authorization: `Bearer ${await token}`,
              },
            });
          },
        }),
        orm: makeRequestLoaders(req),
        req,
      } satisfies Context;
    },
  }),
);

await new Promise<void>(resolve => {
  httpServer.listen({ port: config.port }, resolve);
});

console.log(`Server listening on port ${config.port}`);
