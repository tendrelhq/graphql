import { resolvers, typeDefs } from "@/schema";
import { makeExecutableSchema, mergeSchemas } from "@graphql-tools/schema";
import { getSchema } from "./v1.schema";

const legacySchema = makeExecutableSchema({ typeDefs, resolvers });
const gratsSchema = getSchema();

export const schema = mergeSchemas({ schemas: [legacySchema, gratsSchema] });
