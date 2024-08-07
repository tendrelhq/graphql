import { type ASTNode, GraphQLError, GraphQLScalarType, Kind } from "graphql";

function validate(value: unknown, ast?: ASTNode) {
  if (typeof value !== "string") {
    throw new GraphQLError(
      `Value is not a string: ${value}`,
      ast ? { nodes: ast } : {},
    );
  }
  return value;
}

export const Link = new GraphQLScalarType({
  name: "Link",
  description: "Link description",
  serialize: validate,
  parseValue: validate,
  parseLiteral: ast => {
    if (ast.kind !== Kind.STRING) {
      throw new GraphQLError(
        `Can only validate strings as Links but got a: ${ast.kind}`,
        {
          nodes: ast,
        },
      );
    }
    return validate(ast.value, ast);
  },
  extensions: {
    codegenScalarType: "string",
    jsonSchema: {
      type: "string",
      format: "uri",
    },
  },
});
