import { trackable as queryTrackableResolver } from "./platform/tracking";
import {
  GraphQLSchema,
  GraphQLObjectType,
  GraphQLList,
  GraphQLNonNull,
  GraphQLString,
  defaultFieldResolver,
  GraphQLInterfaceType,
  GraphQLID,
  GraphQLBoolean,
  GraphQLInt,
} from "graphql";
async function assertNonNull<T>(value: T | Promise<T>): Promise<T> {
  const awaited = await value;
  if (awaited == null)
    throw new Error("Cannot return null for semantically non-nullable field.");
  return awaited;
}
export function getSchema(): GraphQLSchema {
  const TrackingSystemType: GraphQLObjectType = new GraphQLObjectType({
    name: "TrackingSystem",
    description:
      'Identifies the current (or "active") state of a trackable Entity, as well as\nthe various legal state transitions that one can perform on said Entity.',
    fields() {
      return {
        active: {
          description:
            'The current (or "active") state of the trackable Entity.\nIt is perfectly valid for a trackable Entity to not be in *any* state, in\nwhich case it is entirely implementation defined as to the semantic meaning\nof such an "unknown" state. For example, this might indicate to an\napplication that the Entity is "idle".',
          name: "active",
          type: GraphQLString,
        },
        transitions: {
          name: "transitions",
          type: new GraphQLList(new GraphQLNonNull(GraphQLString)),
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const ComponentType: GraphQLInterfaceType = new GraphQLInterfaceType({
    description:
      "Components characterize Entities as possessing a particular trait.\nThey are just simple structs, holding all data necessary to model that trait.",
    name: "Component",
    fields() {
      return {
        id: {
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
        },
      };
    },
  });
  const TrackableType: GraphQLInterfaceType = new GraphQLInterfaceType({
    description:
      'Identifies an Entity as being "trackable".\nWhat exactly this means depends on the type underlying said entity and is\nentirely user defined.',
    name: "Trackable",
    fields() {
      return {
        id: {
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
        },
        trackable: {
          description:
            'Entrypoint into the "tracking system" for a given Entity. Note that while\nmany types admit to being trackable, this does not mean that all entities\nof those types will be trackable. For example, `Location`s admit to being\ntrackable, but are only trackable (in practice) when the user has\nexplicitly configured them to be so.',
          name: "trackable",
          type: TrackingSystemType,
        },
      };
    },
    interfaces() {
      return [ComponentType];
    },
  });
  const TrackableEdgeType: GraphQLObjectType = new GraphQLObjectType({
    name: "TrackableEdge",
    fields() {
      return {
        cursor: {
          name: "cursor",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        node: {
          name: "node",
          type: TrackableType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const PageInfoType: GraphQLObjectType = new GraphQLObjectType({
    name: "PageInfo",
    fields() {
      return {
        endCursor: {
          name: "endCursor",
          type: GraphQLString,
        },
        hasNextPage: {
          name: "hasNextPage",
          type: GraphQLBoolean,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        hasPreviousPage: {
          name: "hasPreviousPage",
          type: GraphQLBoolean,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        startCursor: {
          name: "startCursor",
          type: GraphQLString,
        },
      };
    },
  });
  const TrackableConnectionType: GraphQLObjectType = new GraphQLObjectType({
    name: "TrackableConnection",
    fields() {
      return {
        edges: {
          name: "edges",
          type: new GraphQLList(new GraphQLNonNull(TrackableEdgeType)),
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        pageInfo: {
          name: "pageInfo",
          type: PageInfoType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        totalCount: {
          name: "totalCount",
          type: GraphQLInt,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const QueryType: GraphQLObjectType = new GraphQLObjectType({
    name: "Query",
    fields() {
      return {
        trackable: {
          name: "trackable",
          type: TrackableConnectionType,
          resolve(source, _args, context) {
            return assertNonNull(queryTrackableResolver(source, context));
          },
        },
      };
    },
  });
  return new GraphQLSchema({
    query: QueryType,
    types: [
      ComponentType,
      TrackableType,
      PageInfoType,
      QueryType,
      TrackableConnectionType,
      TrackableEdgeType,
      TrackingSystemType,
    ],
  });
}
