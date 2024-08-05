import { expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema2";
import { mergeResolvers, mergeTypeDefs } from "@graphql-tools/merge";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { graphqlSync } from "graphql";

const I = {
  epochMilliseconds: "1722892841208",
};

const testQuery = `#graphql
  type Query {
    test: Instant!
  }
`;
const testResolver = {
  Query: {
    test: () => I,
  },
};
const schema = makeExecutableSchema({
  resolvers: mergeResolvers([testResolver, resolvers]),
  typeDefs: mergeTypeDefs([testQuery, typeDefs]),
});

test("Instant", () => {
  const source = `#graphql
      query TestInstant($options: InstantToStringOptions) {
        test {
          __typename
          epochMilliseconds
          toString(options: $options)
          toZonedDateTime(timeZone: "America/Los_Angeles") {
            epochMilliseconds
            timeZone
          }
        }
      }
    `;

  expect(
    graphqlSync({
      schema,
      source,
      variableValues: {
        options: {
          smallestUnit: "second",
          timeZone: "America/New_York",
        },
      },
    }),
  ).toEqual({
    data: {
      test: {
        __typename: "Instant",
        epochMilliseconds: I.epochMilliseconds,
        toString: "2024-08-05T17:20:41-04:00",
        toZonedDateTime: {
          epochMilliseconds: "1722892841208",
          timeZone: "America/Los_Angeles",
        },
      },
    },
  });
});
