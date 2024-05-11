import http from "node:http";
import { orm, sql } from "@/datasources/postgres";
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
  express.json(),
  expressMiddleware(server, {
    async context({ req }) {
      const user = await (async () => {
        console.log("Authorization:", req.headers.authorization);
        const auth = req.headers.authorization;
        if (!auth) return;
        const [user] = await sql<[{ id: string; language: number }?]>`
          SELECT
              workeruuid AS id,
              workerlanguageid AS language
          FROM public.worker
          WHERE workerexternalid = ${auth};
        `;
        return user;
      })();

      const ctx = {
        authScope: user?.id,
        languageTypeId: user?.language ?? 20,
      };

      return {
        ...ctx,
        orm: orm(ctx),
      };
    },
  }),
);

const port = 4000;
await new Promise<void>(resolve => httpServer.listen({ port }, resolve));

console.log(`Server ready at 0.0.0.0:${port}`);
