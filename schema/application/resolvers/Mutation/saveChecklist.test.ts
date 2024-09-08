import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { NOW, execute, testGlobalId } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestSaveChecklistDocument } from "./saveChecklist.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

describe.skipIf(!!process.env.CI)("saveChecklist", () => {
  test("create a new checklist", async () => {
    const result = await execute(schema, TestSaveChecklistDocument, {
      input: {
        id: testGlobalId(),
        name: "Test checklist",
        active: true,
        assignees: [
          {
            id: testGlobalId(),
            assignTo: testGlobalId(),
            assignAt: NOW.toISOString(),
          },
        ],
        auditable: true,
        description: "This is a test checklist",
        customerId: testGlobalId(),
        items: [
          {
            type: "ChecklistResult",
            repr: JSON.stringify({
              id: testGlobalId(),
              auditable: {
                enabled: true,
              },
              name: {
                value: {
                  value: "Test result item",
                },
              },
              required: true,
              status: {
                type: "ChecklistOpen",
                repr: {
                  id: "foo",
                  openedAt: {
                    epochMilliseconds: NOW.valueOf(),
                  },
                  openedBy: {
                    id: "foobar",
                  },
                },
              },
              value: {
                count: 42,
              },
            }),
          },
        ],
        schedule: {
          type: "OnceSchedule",
          repr: NOW.toISOString(),
        },
        sop: "https://tendrel.io",
        status: {
          type: "ChecklistOpen",
          repr: JSON.stringify({
            id: testGlobalId(),
            openedAt: {
              epochMilliseconds: NOW.valueOf().toString(),
            },
            openedBy: {
              id: testGlobalId(),
            },
          }),
        },
      },
    });

    expect(result).toMatchSnapshot();
  });
});
