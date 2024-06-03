import "dotenv/config";

import http from "node:http";
import auth from "@/auth";
import { orm } from "@/datasources/postgres";
import { type Context, resolvers, typeDefs } from "@/schema";
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
  introspection: true,
  formatError: (formattedError, error) => {
    console.warn(error);
    return formattedError;
  },
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
      return {
        auth: req.auth,
        orm: orm(req),
      };
    },
  }),
);

const port = Number(process.env.PORT ?? 4000);
await new Promise<void>(resolve => httpServer.listen({ port }, resolve));

console.log(`Server ready at 0.0.0.0:${port}`);
