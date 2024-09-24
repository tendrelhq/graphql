import { expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { mergeResolvers, mergeTypeDefs } from "@graphql-tools/merge";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { graphqlSync } from "graphql";

const ZDT = {
  epochMilliseconds: "1722892841208",
  timeZone: "America/Denver",
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
query TestInstant($toStringOptions: ZonedDateTimeToStringOptions!) {
  test {
    __typename
    year
    month
    day
    hour
    minute
    second
    millisecond
    timeZone
    toString(options: $toStringOptions)
  }
}
  `;

  expect(
    graphqlSync({
      schema,
      source,
      variableValues: {
        toStringOptions: {
          calendarName: "never",
          offset: "never",
          smallestUnit: "minute",
          timeZoneName: "never",
        },
      },
    }),
  ).toEqual({
    data: {
      test: {
        __typename: "ZonedDateTime",
        year: 2024,
        month: 8,
        day: 5,
        hour: 15,
        minute: 20,
        second: 41,
        millisecond: 208,
        timeZone: "America/Denver",
        toString: "2024-08-05T15:20",
      },
    },
  });
});
