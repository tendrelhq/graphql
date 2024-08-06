import "dotenv/config";

import http from "node:http";
import { resolvers, typeDefs } from "@/schema2";
import { ApolloServer } from "@apollo/server";
import { expressMiddleware } from "@apollo/server/express4";
import { ApolloServerPluginDrainHttpServer } from "@apollo/server/plugin/drainHttpServer";
import cors from "cors";
import express from "express";
import morgan from "morgan";

console.log(`NODE_ENV: ${process.env.NODE_ENV}`);

const app = express();
const httpServer = http.createServer(app);

// biome-ignore lint/complexity/noBannedTypes:
const server = new ApolloServer<{}>({
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
);

app.use((req, _, next) => {
  if (process.env.DEBUG_HEADERS) {
    console.log(JSON.stringify(req.headers, null, 2));
  }

  next();
});

app.use(
  "/",
  cors({
    // for w3c trace context propagation
    allowedHeaders: "*",
  }),
  express.json(),
  expressMiddleware(server, {
    async context({ req }) {
      if (process.env.NODE_ENV === "development") {
        console.log(req.body);
      }
      return {};
    },
  }),
);

const port = Number(process.env.PORT ?? 4000);
await new Promise<void>(resolve => httpServer.listen({ port }, resolve));

console.log(`Server ready at 0.0.0.0:${port}`);
