import { resolvers, typeDefs } from "@/schema";
import { makeExecutableSchema, mergeSchemas } from "@graphql-tools/schema";
import type { GraphQLScalarType } from "graphql";
import { type GqlUrl, register } from "./system/scalars/url";
import { getSchema } from "./v1.schema";

const legacySchema = makeExecutableSchema({ typeDefs, resolvers });
const gratsSchema = getSchema();

export const schema = mergeSchemas({ schemas: [legacySchema, gratsSchema] });

// Custom scalars. See https://grats.capt.dev/docs/docblock-tags/scalars/#serialization-and-parsing-of-custom-scalars.
register(schema.getType("URL") as GraphQLScalarType<GqlUrl, string>);
