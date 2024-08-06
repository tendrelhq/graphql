import type { QueryResolvers, ResolversTypes } from "@/schema";

const data: ResolversTypes["Checklist"][] = [
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
      id: "e8241534-f392-46f0-bd20-911c34e13572",
      enabled: false,
    },
    // description:
    items: [],
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
      } as ResolversTypes["Temporal"],
    },
  },
];

export const checklists: NonNullable<QueryResolvers["checklists"]> = async (
  _parent,
  _arg,
  _ctx,
) => {
  return data;
};