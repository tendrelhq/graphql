import { decodeGlobalId } from "@/schema/system";
import { type ASTNode, GraphQLError, GraphQLScalarType, Kind } from "graphql";

function validate(value: unknown, ast?: ASTNode) {
  if (typeof value !== "string") {
    throw new GraphQLError(
      `Value is not a string: ${value}`,
      ast ? { nodes: ast } : {},
    );
  }

  try {
    decodeGlobalId(value);
  } catch (e) {
    console.log("Value:", value);
    throw new GraphQLError("Value is not a valid Entity", { nodes: ast });
  }

  return value;
}

export const Entity = new GraphQLScalarType<string, string>({
  name: "Entity",
  description:
    "An entity represents a general-purpose object. The scalar representation is just an opaque string, similar to ID.",
  serialize: validate,
  parseValue: validate,
  parseLiteral: ast => {
    if (ast.kind !== Kind.STRING) {
      throw new GraphQLError(
        `Can only validate strings as Entities but got a: ${ast.kind}`,
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
    },
  },
});
