import { randomUUID } from "node:crypto";
import type { ChecklistItem, QueryResolvers, Temporal } from "@/schema";
import { encodeGlobalId } from "@/schema/system";

const jerry = randomUUID();
const bill = randomUUID();
const jason = randomUUID();

function makeFakeChecklist(prefix: string, assignees = 1): ChecklistItem {
  const instanceId = randomUUID();
  const templateId = randomUUID();
  return {
    __typename: "Checklist",
    id: encodeGlobalId({
      type: "workinstance",
      id: instanceId,
    }),
    active: {
      id: templateId,
      active: assignees % 2 === 0,
      updatedAt: {
        __typename: "Instant",
        epochMilliseconds: "1722928536060",
      } as Temporal,
    },
    assignees: {
      edges: Array.from({ length: assignees }, (_, i) => {
        const id = randomUUID();
        return {
          node: {
            __typename: "Assignee",
            id: encodeGlobalId({
              type: "workresultinstance",
              id: id,
            }),
            assignedAt: {
              __typename: "Instant",
              epochMilliseconds: "1722928536060",
            } as Temporal,
            assignedTo: {
              __typename: "DisplayName",
              id: encodeGlobalId({
                type: "workerinstance",
                id: i === 1 ? jerry : i === 2 ? bill : jason,
              }),
              value: {
                __typename: "DynamicString",
                locale: "en",
                value:
                  i === 1
                    ? "Jerry Garcia"
                    : i === 2
                      ? "Bill Nye"
                      : "Jason Bourne",
              },
            },
          },
          cursor: encodeGlobalId({
            type: "workresultinstance",
            id: id,
          }),
        };
      }),
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: assignees,
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
      id: encodeGlobalId({
        type: "worktemplate",
        id: templateId,
      }),
      enabled: assignees % 2 === 0,
    },
    description: {
      __typename: "Description",
      id: encodeGlobalId({
        type: "workdescription",
        id: randomUUID(),
      }),
      value: {
        __typename: "DynamicString",
        locale: "en",
        value:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
      },
    },
    items: {
      edges: [],
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: 0,
    },
    name: {
      id: encodeGlobalId({
        type: "languagemaster",
        id: randomUUID(),
      }),
      value: {
        locale: "en",
        value: `${prefix} Checklist with a ${"really ".repeat(25)} long name`,
      },
    },
    required: true,
    schedule:
      assignees % 2 === 0
        ? {
            __typename: "OnceSchedule",
            once: {
              __typename: "ZonedDateTime",
              epochMilliseconds: "1722928536060",
              timeZone: "Asia/Tokyo",
            } as Temporal,
          }
        : {
            __typename: "CronSchedule",
            cron: "0 22 * * 1-5",
          },
    sop: {
      id: encodeGlobalId({
        type: "worktemplate",
        id: templateId,
      }),
      link:
        process.env.NODE_ENV === "development"
          ? "http://localhost:3001/docs/checklist"
          : "https://beta.console.tendrel.io/docs/checklist",
    },
    status: {
      __typename: "ChecklistOpen",
      id: encodeGlobalId({
        type: "systag",
        id: randomUUID(),
      }),
      openedAt: {
        __typename: "Instant",
        epochMilliseconds: "1722928536060",
      } as Temporal,
    },
  };
}

export const FAKE_CHECKLISTS = [
  makeFakeChecklist("My", 1),
  makeFakeChecklist("Another", 2),
  makeFakeChecklist("Ultimate", 3),
];

export const FAKE_RESULTS = FAKE_CHECKLISTS.flatMap(node =>
  node.assignees.edges.map(e => e.node),
);

export const checklists: NonNullable<QueryResolvers["checklists"]> = async (
  _parent,
  _arg,
  _ctx,
) => {
  return {
    edges: FAKE_CHECKLISTS.map(node => ({
      cursor: node.id,
      node,
    })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: FAKE_CHECKLISTS.length,
  };
};
