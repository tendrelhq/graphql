import { expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { mergeResolvers, mergeTypeDefs } from "@graphql-tools/merge";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { graphqlSync } from "graphql";

const ZDT = {
  epochMilliseconds: "1722892841208",
  timeZone: "America/Los_Angeles",
};

const testQuery = `#graphql
type Query {
  test: ZonedDateTime!
}
`;
const testResolver = {
  Query: {
    test: () => ZDT,
  },
};
const schema = makeExecutableSchema({
  resolvers: mergeResolvers([testResolver, resolvers]),
  typeDefs: mergeTypeDefs([testQuery, typeDefs]),
});

test("ZonedDateTime", () => {
  const source = `#graphql
query TestInstant {
  test {
    __typename
    epochMilliseconds
  }
}
  `;

  expect(
    graphqlSync({
      schema,
      source,
    }),
  ).toEqual({
    data: {
      test: {
        __typename: "ZonedDateTime",
        epochMilliseconds: ZDT.epochMilliseconds,
      },
    },
  });
});
