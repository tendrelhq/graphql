import type { ChecklistItem, QueryResolvers, Temporal } from "@/schema";
import { encodeGlobalId } from "@/schema/system";

const data: ChecklistItem[] = [
  {
    __typename: "Checklist",
    id: encodeGlobalId({
      type: "workinstance",
      id: "a25ceddb-b122-4825-b907-e084c295c096",
    }),
    assignees: {
      edges: [
        {
          node: {
            id: encodeGlobalId({
              type: "workresultinstance",
              id: "02a4b82b-4605-43fc-af2d-f377c4da63cc",
            }),
            assignedAt: {
              __typename: "Instant",
              epochMilliseconds: "1722928536060",
            } as Temporal,
            assignedTo: {
              __typename: "DisplayName",
              id: encodeGlobalId({
                type: "workerinstance",
                id: "b9facef4-b716-45fd-af3c-478194d943e2",
              }),
              value: {
                __typename: "DynamicString",
                locale: "en",
                value: "Jerry Garcia",
              },
            },
          },
          cursor: "NDIwNjk=",
        },
      ],
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: 1,
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
        id: "e8241534-f392-46f0-bd20-911c34e13572",
      }),
      enabled: false,
    },
    description: {
      __typename: "Description",
      id: encodeGlobalId({
        type: "workdescription",
        id: "8efe4ad5-766b-4c1c-b3d3-60c677bc0177",
      }),
      value: {
        __typename: "DynamicString",
        locale: "en",
        value: "It's a really cool test Checklist!",
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
        id: "9505331e-7ccd-42b0-98be-574a834c48bb",
      }),
      value: {
        locale: "en",
        value: "Test Checklist",
      },
    },
    required: true,
    schedule: {
      __typename: "CronSchedule",
      cron: "0 12 * * 3", // at noon every wednesday
    },
    sop: {
      id: encodeGlobalId({
        type: "worktemplate",
        id: "e8241534-f392-46f0-bd20-911c34e13572",
      }),
      link: "https://console.tendrel.io/docs/checklists",
    },
    status: {
      __typename: "ChecklistOpen",
      id: encodeGlobalId({
        type: "systag",
        id: "c5fc93c2-5b44-40a7-bc08-60a6b2fdf0e9",
      }),
      openedAt: {
        __typename: "Instant",
        epochMilliseconds: "1722928536060",
      } as Temporal,
    },
  },
];

export const checklists: NonNullable<QueryResolvers["checklists"]> = async (
  _parent,
  _arg,
  _ctx,
) => {
  return {
    edges: data.map(node => ({
      cursor: node.id,
      node,
    })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: 1,
  };
};
