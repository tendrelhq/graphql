import type { QueryResolvers } from "@/schema";
import { CHECKLISTS } from "@/test/d3";

export const checklists: NonNullable<QueryResolvers["checklists"]> = async (
  _parent,
  _args,
  _ctx,
) => {
  return {
    edges: CHECKLISTS.map(row => ({
      cursor: row.id,
      node: row,
    })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: CHECKLISTS.length,
  };
};
