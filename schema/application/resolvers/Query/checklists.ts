import type {
  Assignee,
  ChecklistItem,
  QueryResolvers,
  Temporal,
} from "@/schema";

const data: ChecklistItem[] = [
  {
    __typename: "Checklist",
    id: "a25ceddb-b122-4825-b907-e084c295c096",
    assignees: {
      edges: [
        {
          node: {
            id: "02a4b82b-4605-43fc-af2d-f377c4da63cc",
            assignedAt: {
              __typename: "Instant",
              epochMilliseconds: "1722928536060",
            } as Temporal,
          } as Assignee,
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
      id: "e8241534-f392-46f0-bd20-911c34e13572",
      enabled: false,
    },
    // description:
    items: {
      edges: [],
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: 0,
    },
    name: {
      id: "9505331e-7ccd-42b0-98be-574a834c48bb",
      value: {
        locale: "en",
        value: "Test Checklist",
      },
    },
    // required:
    // schedule:
    // sop:
    status: {
      __typename: "ChecklistOpen",
      id: "c5fc93c2-5b44-40a7-bc08-60a6b2fdf0e9",
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
    edges: data.map(node => ({ node, cursor: node.id as string })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: 1,
  };
};
