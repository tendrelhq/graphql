import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { WORKERS } from "@/test/d3";
import { NOW, execute, testGlobalId } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestSaveChecklistDocument } from "./saveChecklist.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

describe.skipIf(!!process.env.CI)("saveChecklist", () => {
  test("create a new checklist", async () => {
    const result = await execute(schema, TestSaveChecklistDocument, {
      input: {
        id: testGlobalId(),
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "Test checklist",
          },
        },
        active: {
          id: testGlobalId(),
          active: true,
          updatedAt: {
            instant: NOW.valueOf().toString(),
          },
        },
        assignees: [
          {
            id: testGlobalId(),
            assignTo: WORKERS.Mark.id,
            assignAt: {
              instant: NOW.valueOf().toString(),
            },
          },
        ],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        description: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "This is a test checklist",
          },
        },
        customerId: testGlobalId(),
        items: [
          {
            result: {
              id: testGlobalId(),
              assignees: [],
              auditable: {
                id: testGlobalId(),
                enabled: true,
              },
              name: {
                id: testGlobalId(),
                value: {
                  locale: "en",
                  value: "Test result item",
                },
              },
              required: true,
              status: {
                open: {
                  id: testGlobalId(),
                  at: {
                    instant: NOW.valueOf().toString(),
                  },
                  by: WORKERS.Mark.id,
                },
              },
              value: {
                counter: 42,
              },
            },
          },
        ],
        schedule: {
          once: {
            instant: NOW.valueOf().toString(),
          },
        },
        sop: {
          id: testGlobalId(),
          link: "https://tendrel.io",
        },
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Mark.id,
          },
        },
      },
    });

    expect(result).toMatchSnapshot();
  });
});
