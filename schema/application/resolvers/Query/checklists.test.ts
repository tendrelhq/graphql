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
              // TODO: for testing, it'd be really nice to automatically encode
              // and decode these ids. We can just override the resolver in the
              // scalars config I guess?
              id: "eyJ0eXBlIjoid29ya2luc3RhbmNlIiwiaWQiOiJhMjVjZWRkYi1iMTIyLTQ4MjUtYjkwNy1lMDg0YzI5NWMwOTYifQ==",
              assignees: {
                __typename: "AssigneeConnection",
                edges: [
                  {
                    __typename: "AssigneeEdge",
                    node: {
                      __typename: "Assignee",
                      id: "eyJ0eXBlIjoid29ya3Jlc3VsdGluc3RhbmNlIiwiaWQiOiIwMmE0YjgyYi00NjA1LTQzZmMtYWYyZC1mMzc3YzRkYTYzY2MifQ==",
                      assignedAt: {
                        __typename: "Instant",
                        epochMilliseconds: "1722928536060",
                        toString: "2024-08-06T00:15:36.06-07:00",
                        toZonedDateTime: {
                          __typename: "ZonedDateTime",
                          toString:
                            "2024-08-06T01:15:36.06-06:00[America/Denver]",
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
