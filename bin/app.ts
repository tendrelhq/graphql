import http from "node:http";
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
      console.log(JSON.stringify(req.headers, null, 2));
      const authScope = req.headers.authorization;
      const contentLanguage = req.headers["content-language"];
      // const [{ id: languageTypeId }] = await sql<[{ id: number }]>`
      //   SELECT systagid AS id
      //   FROM public.systag
      //   WHERE
      //       systagparentid = 2
      //       AND systagtype = ${req.headers["content-language"] ?? "en"};
      // `;

      const ctx = {
        authScope,
        languageTypeId: 20,
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
