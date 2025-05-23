import { expect, test } from "bun:test";
import { schema /* as _schema */ } from "@/schema/final";
import { makeExecutableSchema, mergeSchemas } from "@graphql-tools/schema";
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

// const schema = mergeSchemas({
//   schemas: [
//     _schema,
//     makeExecutableSchema({
//       resolvers: [testResolver],
//       typeDefs: [testQuery],
//     }),
//   ],
// });

test.skip("Instant", () => {
  const source = `#graphql
    query TestInstant {
      test {
        __typename
        epochMilliseconds
        toZonedDateTime(timeZone: "America/Los_Angeles") {
          timeZone
          toString
        }
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
        __typename: "Instant",
        epochMilliseconds: I.epochMilliseconds,
        toZonedDateTime: {
          timeZone: "America/Los_Angeles",
          toString: "2024-08-05T14:20:41.208-07:00[America/Los_Angeles]",
        },
      },
    },
  });
});
