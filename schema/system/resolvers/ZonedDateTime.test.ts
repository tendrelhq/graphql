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
      query TestInstant($options: ZonedDateTimeToStringOptions) {
        test {
          __typename
          epochMilliseconds
          toString(options: $options)
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
          timeZoneName: "auto",
        },
      },
    }),
  ).toEqual({
    data: {
      test: {
        __typename: "ZonedDateTime",
        epochMilliseconds: ZDT.epochMilliseconds,
        toString: "2024-08-05T14:20:41-07:00[America/Los_Angeles]",
      },
    },
  });
});
