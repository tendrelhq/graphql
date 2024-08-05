import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema2";
import { mergeResolvers, mergeTypeDefs } from "@graphql-tools/merge";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { graphqlSync } from "graphql";

const I = {
  epochMilliseconds: "1722892841208",
};
const Z = {
  epochMilliseconds: I.epochMilliseconds,
  timeZone: "America/Los_Angeles",
};

const testQuery = `#graphql
  type Query {
    testInstant: Instant!
    testZonedDateTime: ZonedDateTime!
  }
`;
const testResolver = {
  Query: {
    testInstant: () => I,
    testZonedDateTime: () => Z,
  },
};
const schema = makeExecutableSchema({
  resolvers: mergeResolvers([testResolver, resolvers]),
  typeDefs: mergeTypeDefs([testQuery, typeDefs]),
});

describe("Temporal", () => {
  test("Instant", () => {
    const source = `#graphql
      query TestInstant($options: InstantToStringOptions) {
        testInstant {
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
        testInstant: {
          __typename: "Instant",
          epochMilliseconds: I.epochMilliseconds,
          toString: "2024-08-05T17:20:41-04:00",
          toZonedDateTime: Z,
        },
      },
    });
  });

  test("ZonedDateTime", () => {
    const source = `#graphql
      query TestZonedDateTime($options: ZonedDateTimeToStringOptions) {
        testZonedDateTime {
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
          },
        },
      }),
    ).toEqual({
      data: {
        testZonedDateTime: {
          __typename: "ZonedDateTime",
          epochMilliseconds: Z.epochMilliseconds,
          toString: "2024-08-05T14:20:41-07:00[America/Los_Angeles]",
        },
      },
    });
  });
});
