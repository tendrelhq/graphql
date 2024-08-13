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
  _arg,
  _ctx,
) => {
  return {
    edges: CHECKLISTS.map(node => ({
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
