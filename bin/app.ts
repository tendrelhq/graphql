import "dotenv/config";

import http from "node:http";
import auth from "@/auth";
import { orm, user } from "@/datasources/postgres";
import { type Context, resolvers, typeDefs } from "@/schema";
import { ApolloServer } from "@apollo/server";
import { expressMiddleware } from "@apollo/server/express4";
import { ApolloServerPluginDrainHttpServer } from "@apollo/server/plugin/drainHttpServer";
import cors from "cors";
import express from "express";
import morgan from "morgan";
import { match } from "ts-pattern";

const app = express();
const httpServer = http.createServer(app);

const server = new ApolloServer<Context>({
  resolvers,
  typeDefs,
  plugins: [ApolloServerPluginDrainHttpServer({ httpServer })],
});

await server.start();

app.use(
  morgan(
    ":date[iso] :method :url :status :res[content-length] - :response-time ms",
  ),
);

app.use(
  "/",
  cors(),
  auth.clerk(),
  express.json(),
  expressMiddleware(server, {
    async context({ req }) {
      try {
        const ctx = {
          auth: req.auth,
          user: await user.byIdentityId.load(req.auth.userId),
        };

        return {
          ...ctx,
          orm: orm(ctx),
        };
      } catch (e) {
        match(e)
          .with({ type: "user" }, console.debug)
          // everything else is a 500
          .otherwise(console.error);

        throw e;
      }
    },
  }),
);

const port = Number(process.env.PORT ?? 4000);
await new Promise<void>(resolve => httpServer.listen({ port }, resolve));

console.log(`Server ready at 0.0.0.0:${port}`);
