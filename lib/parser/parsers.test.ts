import { parseChecklistItemInput, parseStatusInput } from "@/test/d3";
import { testGlobalId } from "@/test/prelude";
import { describe, expect, test } from "bun:test";

const NOW = Date.now();

describe("parser", () => {
  describe("status input", () => {
    test("parses", () => {
      const input = {
        type: "ChecklistOpen",
        repr: JSON.stringify({
          id: "foo",
          openedAt: {
            epochMilliseconds: NOW,
          },
          openedBy: {
            id: "foobar",
          },
        }),
      };

      expect(parseStatusInput(input)).toMatchObject({
        __typename: "ChecklistOpen",
        id: expect.any(String),
        openedAt: {
          __typename: "Instant",
          epochMilliseconds: NOW.toString(),
        },
        openedBy: {
          __typename: "Worker",
          id: expect.any(String),
        },
      });
    });
  });

  describe("checklist item input", () => {
    test("parses", () => {
      const input = {
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
                epochMilliseconds: NOW,
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
      };

      expect(parseChecklistItemInput(input)).toMatchObject({
        __typename: "ChecklistResult",
        id: expect.any(String),
        assignees: {
          edges: [],
          pageInfo: {
            hasNextPage: false,
            hasPreviousPage: false,
          },
          totalCount: 0,
        },
        attachments: {
          edges: [],
          pageInfo: {
            hasNextPage: false,
            hasPreviousPage: false,
          },
          totalCount: 0,
        },
        auditable: {
          id: expect.any(String),
          enabled: true,
        },
        name: {
          __typename: "DisplayName",
          id: expect.any(String),
          value: {
            locale: "en",
            value: "Test result item",
          },
        },
        required: true,
        status: {
          __typename: "ChecklistOpen",
          id: expect.any(String),
          openedAt: {
            __typename: "Instant",
            epochMilliseconds: NOW.toString(),
          },
          openedBy: {
            __typename: "Worker",
            id: expect.any(String),
          },
        },
        value: {
          __typename: "Counter",
          count: 42,
        },
      });
    });
  });
});
