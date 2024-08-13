import type {
  Context,
  EntityComponentEdge,
  EntityConnectionResolvers,
} from "@/schema";
import { FAKE_RESULTS } from "@/schema/application/resolvers/Query/checklists";
import { CHECKLISTS } from "@/test/d3";
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
  console.log(`Resolving ECC for Entity of type ${type}`);
  const { first, last, before, after } = unpackPaginationArgs(args);

  // FIXME: this is specific to checklists right now but will be easily
  // genericized to support arbitrary applications. How? custags. Or, err...
  // customer configs, or worktemplate types, et al. The basic idea is this:
  // in graphql land we deal with entities and components. These constructs
  // exist above and distinct from their associated database representations. In
  // particular, a given graphql type, e.g. Checklist, might be handled
  // differently internally depending on whether the underlying database object
  // is a worktemplate or workinstance; to the end user there is no distinction.
  // All of this is to say that in the code that follows we are skipping this
  // resolution step under the assumption that there is only one "application
  // schema" right now, which is the "checklist schema". This is, obviously,
  // only temporary during development and testing.
  switch (type) {
    case "workinstance": {
      const data = CHECKLISTS.flatMap(e => [
        e,
        ...e.children.edges.map(e => e.node),
      ]).find(e => e.id === entity);
      return {
        nodes: data ? [data] : [],
        hasNext: false,
        hasPrev: false,
        totalCount: data ? 1 : 0,
      };
    }
    // The above being said, here is a case where we want to go one level
    // deeper. A "workresultinstance" can take many forms in the context of the
    // "checklist schema": Assignees, Attachments and ChecklistItems. Each of
    // these higher order types is a workresultinstance in the database. From an
    // implementation perspective, this means we should return *different* data
    // depending on what the underlying type is. Practically speaking this means
    // issuing different SQL queries... but we're still using fake data for now.
    case "workresultinstance": {
      const data = FAKE_RESULTS.get(entity);
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
