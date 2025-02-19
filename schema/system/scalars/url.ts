import { map } from "@/util";
import {
  type ASTNode,
  GraphQLError,
  type GraphQLScalarLiteralParser,
  type GraphQLScalarSerializer,
  type GraphQLScalarType,
  Kind,
} from "graphql";

/**
 * @gqlScalar URL
 * @specifiedBy https://www.ietf.org/rfc/rfc3986.txt
 */
export type GqlUrl = URL;

export function register(type: GraphQLScalarType<GqlUrl, string>) {
  type.serialize = serialize;
  type.parseValue = parseValue;
  type.parseLiteral = parseLiteral;
}

const serialize: GraphQLScalarSerializer<string> = value => {
  if (typeof value === "string") {
    return new URL(value).toString();
  }
  if (!(value instanceof URL)) {
    throw new GraphQLError(`Value is not a URL: ${value} (${typeof value})`);
  }
  return value.toString();
};

const parseValue = (value: unknown, ast?: ASTNode) => {
  if (typeof value !== "string") {
    throw new GraphQLError(
      `Value is not a string: ${value} (${typeof value})`,
      map(ast, ast => ({ nodes: ast })),
    );
  }
  return new URL(value);
};

const parseLiteral: GraphQLScalarLiteralParser<GqlUrl> = ast => {
  if (ast.kind !== Kind.STRING) {
    throw new GraphQLError(
      `Can only validate strings as URLs but got a ${ast.kind}`,
      { nodes: ast },
    );
  }
  return parseValue(ast.value);
};
