import type {
  Checklist,
  Context,
  EntityComponentEdge,
  EntityConnectionResolvers,
} from "@/schema";
import { FAKE_CHECKLISTS } from "@/schema/application/resolvers/Query/checklists";
import { decodeGlobalId } from "..";

export const EntityConnection: EntityConnectionResolvers = {
  async components(parent, args, ctx) {
    const { nodes, hasNext, hasPrev, totalCount } =
      await resolveEntityComponentConnections(parent.entity, args, ctx);

    return {
      edges: nodes.map(node => ({ node: node, cursor: node.id })),
      pageInfo: {
        hasNextPage: hasNext,
        hasPreviousPage: hasPrev,
      },
      totalCount: totalCount,
    };
  },
};

function unpackPaginationArgs({
  first,
  last,
  before,
  after,
}: {
  first?: number;
  last?: number;
  before?: string;
  after?: string;
}) {
  return {
    first,
    last,
    before: before ? decodeGlobalId(before) : undefined,
    after: after ? decodeGlobalId(after) : undefined,
  };
}

async function resolveEntityComponentConnections(
  entity: string,
  args: { first?: number; last?: number; before?: string; after?: string },
  ctx: Context,
): Promise<{
  nodes: Array<EntityComponentEdge["node"]>;
  hasNext: boolean;
  hasPrev: boolean;
  totalCount: number;
}> {
  const { type, id } = decodeGlobalId(entity);
  const { first, last, before, after } = unpackPaginationArgs(args);

  switch (type) {
    case "workinstance": {
      const data = FAKE_CHECKLISTS.find(e => e.id === entity);
      return {
        nodes: data ? [data] : [],
        hasNext: false,
        hasPrev: false,
        totalCount: data ? 1 : 0,
      };
    }
  }

  return {
    nodes: [],
    hasNext: false,
    hasPrev: false,
    totalCount: 0,
  };
}
