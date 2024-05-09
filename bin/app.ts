import http from "node:http";
import { resolvers } from "@/resolvers";
import { type Context, typeDefs } from "@/schema";
import { ApolloServer } from "@apollo/server";
import { expressMiddleware } from "@apollo/server/express4";
import { ApolloServerPluginDrainHttpServer } from "@apollo/server/plugin/drainHttpServer";
import cors from "cors";
import express from "express";
import morgan from "morgan";

const app = express();
const httpServer = http.createServer(app);

const server = new ApolloServer<Context>({
  resolvers,
  typeDefs,
  plugins: [ApolloServerPluginDrainHttpServer({ httpServer })],
});

await server.start();

app.use(morgan("tiny")); // "access" logging

app.use(
  "/",
  cors(),
  express.json(),
  expressMiddleware(server, {
    async context({ req }) {
      return {
        authScope: await Promise.resolve(req.headers.authorization),
      };
    },
  }),
);

const port = 4000;
await new Promise<void>(resolve => httpServer.listen({ port }, resolve));

console.log(`Server ready at 0.0.0.0:${port}`);
