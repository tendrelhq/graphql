import { ApolloServer } from "@apollo/server";
import { startStandaloneServer } from "@apollo/server/standalone";

import { resolvers } from "@/resolvers";
import { type Context, typeDefs } from "@/schema";

const server = new ApolloServer<Context>({ typeDefs, resolvers });

const { url } = await startStandaloneServer(server, {
  async context({ req }) {
    return {
      authScope: await Promise.resolve(req.headers.authorization),
    };
  },
  listen: {
    port: 4000,
  },
});
console.log(`Server ready at ${url}`);
