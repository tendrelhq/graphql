import { expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute } from "@/test/prelude";
import { mergeResolvers, mergeTypeDefs } from "@graphql-tools/merge";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { ChecklistsDocument } from "./checklists.test.generated";

const schema = makeExecutableSchema({
  resolvers: mergeResolvers([resolvers]),
  typeDefs: mergeTypeDefs([ChecklistsDocument, typeDefs]),
});

test("checklists", async () => {
  const result = await execute(schema, ChecklistsDocument, {
    timeZone: "America/Denver",
  });
  expect(result).toEqual({
    data: {
      __typename: "Query",
      checklists: {
        __typename: "ChecklistConnection",
        edges: [
          {
            __typename: "ChecklistEdge",
            node: {
              __typename: "Checklist",
              id: "a25ceddb-b122-4825-b907-e084c295c096",
              assignees: {
                __typename: "AssigneeConnection",
                edges: [],
                pageInfo: {
                  __typename: "PageInfo",
                  hasNextPage: false,
                  hasPreviousPage: false,
                },
                totalCount: 0,
              },
              attachments: {
                __typename: "AttachmentConnection",
                edges: [],
                pageInfo: {
                  __typename: "PageInfo",
                  hasNextPage: false,
                  hasPreviousPage: false,
                },
                totalCount: 0,
              },
              auditable: {
                __typename: "Auditable",
                enabled: false,
              },
              description: null,
              items: {
                __typename: "ChecklistConnection",
                edges: [],
                pageInfo: {
                  __typename: "PageInfo",
                  hasNextPage: false,
                  hasPreviousPage: false,
                },
                totalCount: 0,
              },
              name: {
                __typename: "DisplayName",
                value: {
                  __typename: "DynamicString",
                  value: "Test Checklist",
                },
              },
              required: null,
              schedule: null,
              sop: null,
              status: {
                __typename: "ChecklistOpen",
                openedAt: {
                  __typename: "Instant",
                  epochMilliseconds: "1722928536060",
                  toZonedDateTime: {
                    __typename: "ZonedDateTime",
                    toString: "2024-08-06T01:15:36.06-06:00[America/Denver]",
                  },
                },
              },
            },
          },
        ],
        pageInfo: {
          __typename: "PageInfo",
          hasNextPage: false,
          hasPreviousPage: false,
        },
        totalCount: 1,
      },
    },
  });
});
