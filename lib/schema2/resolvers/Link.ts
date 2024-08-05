import { GraphQLError, GraphQLScalarType } from "graphql";

export const Link = new GraphQLScalarType({
  name: "Link",
  description: "Link description",
  serialize: value => {
    throw new GraphQLError("Not implemented");
  },
  parseValue: value => {
    throw new GraphQLError("Not implemented");
  },
  parseLiteral: ast => {
    throw new GraphQLError("Not implemented");
  },
});
