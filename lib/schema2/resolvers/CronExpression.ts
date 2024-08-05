import { type ASTNode, GraphQLError, GraphQLScalarType, Kind } from "graphql";

// TODO: this is based on crontab.guru. We might not want to support all of this.
const PATTERN =
  /(@(annually|yearly|monthly|weekly|daily|hourly|reboot))|(@every (\d+(ns|us|µs|ms|s|m|h))+)|((((\d+,)+\d+|(\d+(\/|-)\d+)|\d+|\*) ?){5,7})/;

function validate(value: unknown, ast?: ASTNode) {
  if (typeof value !== "string") {
    throw new GraphQLError(
      `Value is not a string: ${value}`,
      ast ? { nodes: ast } : {},
    );
  }

  if (!PATTERN.test(value)) {
    throw new GraphQLError(
      `Value is not a valid CronExpression: ${value}`,
      ast ? { nodes: ast } : {},
    );
  }

  return value;
}

export const CronExpression = new GraphQLScalarType({
  name: "CronExpression",
  description: "CronExpression description",
  serialize: validate,
  parseValue: validate,
  parseLiteral: ast => {
    if (ast.kind !== Kind.STRING) {
      throw new GraphQLError(
        `Can only validate strings as CronExpressions but got a: ${ast.kind}`,
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
      title: "CronExpression",
      type: "string",
      pattern: PATTERN.source,
    },
  },
});
