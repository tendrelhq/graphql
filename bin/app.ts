import "dotenv/config";

import http from "node:http";
import auth from "@/auth";
import { orm } from "@/datasources/postgres";
import i18n from "@/i18n";
import { type Context, resolvers, typeDefs } from "@/schema";
import upload from "@/upload";
import { ApolloServer } from "@apollo/server";
import { expressMiddleware } from "@apollo/server/express4";
import { ApolloServerPluginDrainHttpServer } from "@apollo/server/plugin/drainHttpServer";
import cors from "cors";
import express from "express";
import { GraphQLError } from "graphql";
import morgan from "morgan";

console.log(`NODE_ENV: ${process.env.NODE_ENV}`);

const app = express();
const httpServer = http.createServer(app);

const server = new ApolloServer<Context>({
  resolvers,
  typeDefs,
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
  morgan(
    ":date[iso] :method :url :status :res[content-length] - :response-time ms",
  ),
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

app.post("/upload", auth.clerk(), express.json(), upload.POST);

app.use(
  "/",
  auth.clerk(),
  i18n.accept(),
  express.json(),
  expressMiddleware(server, {
    async context({ req }) {
      if (process.env.NODE_ENV === "development") {
        console.log(req.body);
      }
      if (!req.auth.userId && process.env.NODE_ENV !== "development") {
        throw new GraphQLError("Unauthenticated", {
          extensions: {
            hint: "Please sign in",
          },
        });
      }
      return {
        auth: req.auth,
        orm: orm(req),
        req,
      };
    },
  }),
);

app.post("/upload", (req, res) => {
  res.send("ok");
});

const port = Number(process.env.PORT ?? 4000);
await new Promise<void>(resolve => httpServer.listen({ port }, resolve));

console.log(`Server ready at 0.0.0.0:${port}`);
