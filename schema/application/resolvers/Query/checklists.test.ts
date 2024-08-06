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
  const out = await execute(schema, ChecklistsDocument, {
    timeZone: "America/Denver",
  });
  expect(out).toEqual({
    data: {
      checklists: [
        {
          id: "a25ceddb-b122-4825-b907-e084c295c096",
          assignees: {
            edges: [],
            pageInfo: {
              hasNextPage: false,
              hasPreviousPage: false,
            },
            totalCount: 0,
          },
          attachments: [],
          auditable: {
            enabled: false,
          },
          description: null,
          items: [],
          name: {
            value: {
              value: "Test Checklist",
            },
          },
          required: null,
          schedule: null,
          sop: null,
          status: {
            __typename: "ChecklistOpen",
            openedAt: {
              epochMilliseconds: "1722928536060",
              toZonedDateTime: {
                toString: "2024-08-06T01:15:36.06-06:00[America/Denver]",
              },
            },
          },
        },
      ],
    },
  });
});
