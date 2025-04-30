import { GraphQLError, GraphQLScalarType, Kind } from "graphql";
import z from "myzod";

const parser = z.number({ coerce: true });

export const Duration = new GraphQLScalarType<number, number>({
  name: "Duration",
  description: "Duration represented in seconds",
  serialize: value => parser.parse(value),
  parseValue: value => parser.parse(value),
  parseLiteral: ast => {
    if (ast.kind !== Kind.FLOAT && ast.kind !== Kind.INT) {
      throw new GraphQLError(
        `Can only validate numerics as Duration but got a: ${ast.kind}`,
        {
          nodes: ast,
        },
      );
    }
    return parser.parse(ast.value);
  },
  extensions: {
    codegenScalarType: "number",
  },
});
