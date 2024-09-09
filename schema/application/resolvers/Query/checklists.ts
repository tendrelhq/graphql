import type { QueryResolvers } from "@/schema";

import { CHECKLISTS } from "@/test/d3";

export const FAKE_RESULTS = CHECKLISTS.reduce((acc, node) => {
  for (const e of node.assignees.edges) {
    acc.set(e.node.id, e.node);
  }
  for (const e of node.attachments.edges) {
    acc.set(e.node.id, e.node);
  }
  for (const e of node.items.edges) {
    for (const ee of e.node.assignees.edges) {
      acc.set(ee.node.id, ee.node);
    }
    for (const ee of e.node.attachments.edges) {
      acc.set(ee.node.id, ee.node);
    }
  }
  for (const e of node.children.edges) {
    for (const ee of e.node.assignees.edges) {
      acc.set(ee.node.id, ee.node);
    }
    for (const ee of e.node.attachments.edges) {
      acc.set(ee.node.id, ee.node);
    }
  }
  return acc;
}, new Map());

export const checklists: NonNullable<QueryResolvers["checklists"]> = async (
  _parent,
  args,
  _ctx,
) => {
  const data = CHECKLISTS.filter(node => {
    if (typeof args.search?.active === "boolean") {
      return node.active.active === args.search.active;
    }
    return true;
  }).toSorted((a, b) => {
    if (args.search?.order?.completedAt) {
      if (
        a.status?.__typename === "ChecklistClosed" &&
        b.status?.__typename === "ChecklistClosed"
      ) {
        return (
          Number(a.status.closedAt.epochMilliseconds) -
          Number(b.status.closedAt.epochMilliseconds)
        );
      }
      return (
        Number(a.status?.__typename === "ChecklistClosed") -
        Number(b.status?.__typename === "ChecklistClosed")
      );
    }
    return 0;
  });
  return {
    edges: data.map(node => ({
      cursor: node.id,
      node,
    })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: CHECKLISTS.length,
  };
};
