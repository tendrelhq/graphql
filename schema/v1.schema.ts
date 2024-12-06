import {
  GraphQLBoolean,
  GraphQLID,
  GraphQLInputObjectType,
  GraphQLInt,
  GraphQLInterfaceType,
  GraphQLList,
  GraphQLNonNull,
  GraphQLObjectType,
  GraphQLScalarType,
  GraphQLSchema,
  GraphQLString,
  GraphQLUnionType,
  defaultFieldResolver,
} from "graphql";
import { trackables as queryTrackablesResolver } from "./platform/tracking";
import { transition as mutationTransitionResolver } from "./platform/tracking";
import { fsm as taskFsmResolver } from "./system/component/task_fsm";
import { id as displayNameIdResolver } from "./system/node";
import { id as locationIdResolver } from "./system/node";
async function assertNonNull<T>(value: T | Promise<T>): Promise<T> {
  const awaited = await value;
  if (awaited == null)
    throw new Error("Cannot return null for semantically non-nullable field.");
  return awaited;
}
export function getSchema(): GraphQLSchema {
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
        tracking: {
          description:
            'Entrypoint into the "tracking system(s)" for a given Entity. Note that while\nmany types admit to being trackable, this does not mean that all in fact are\nin practice. In order for an Entity to be trackable, it must be explicitly\nconfigured as such.',
          name: "tracking",
          type: TrackableConnectionType,
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
        trackables: {
          name: "trackables",
          type: TrackableConnectionType,
          resolve(source, _args, context) {
            return assertNonNull(queryTrackablesResolver(source, context));
          },
        },
      };
    },
  });
  const TransitionResultType: GraphQLObjectType = new GraphQLObjectType({
    name: "TransitionResult",
    fields() {
      return {
        trackable: {
          name: "trackable",
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
  const TransitionInputType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "TransitionInput",
      fields() {
        return {
          into: {
            name: "into",
            type: new GraphQLNonNull(GraphQLID),
          },
          payload: {
            name: "payload",
            type: GraphQLString,
          },
        };
      },
    });
  const MutationType: GraphQLObjectType = new GraphQLObjectType({
    name: "Mutation",
    fields() {
      return {
        transition: {
          name: "transition",
          type: TransitionResultType,
          args: {
            input: {
              name: "input",
              type: new GraphQLNonNull(TransitionInputType),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              mutationTransitionResolver(source, args.input, context),
            );
          },
        },
      };
    },
  });
  const LocaleType: GraphQLScalarType = new GraphQLScalarType({
    description:
      "A language tag in the format of a BCP 47 (RFC 5646) standard string.",
    name: "Locale",
  });
  const ClosedType: GraphQLObjectType = new GraphQLObjectType({
    name: "Closed",
    fields() {
      return {
        closedAt: {
          name: "closedAt",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        closedBecause: {
          name: "closedBecause",
          type: GraphQLString,
        },
        closedBy: {
          name: "closedBy",
          type: GraphQLString,
        },
        dueAt: {
          name: "dueAt",
          type: GraphQLString,
        },
        inProgressAt: {
          name: "inProgressAt",
          type: GraphQLString,
        },
        inProgressBy: {
          name: "inProgressBy",
          type: GraphQLString,
        },
        openedAt: {
          name: "openedAt",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        openedBy: {
          name: "openedBy",
          type: GraphQLString,
        },
      };
    },
  });
  const InProgressType: GraphQLObjectType = new GraphQLObjectType({
    name: "InProgress",
    fields() {
      return {
        dueAt: {
          name: "dueAt",
          type: GraphQLString,
        },
        inProgressAt: {
          name: "inProgressAt",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        inProgressBy: {
          name: "inProgressBy",
          type: GraphQLString,
        },
        openedAt: {
          name: "openedAt",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        openedBy: {
          name: "openedBy",
          type: GraphQLString,
        },
      };
    },
  });
  const TimestampType: GraphQLObjectType = new GraphQLObjectType({
    name: "Timestamp",
    fields() {
      return {
        value: {
          name: "value",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const TimestampOverrideType: GraphQLObjectType = new GraphQLObjectType({
    name: "TimestampOverride",
    fields() {
      return {
        overriddenAt: {
          name: "overriddenAt",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        overriddenBy: {
          name: "overriddenBy",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        previousValue: {
          name: "previousValue",
          type: TimestampType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const TimestampOverridableType: GraphQLObjectType = new GraphQLObjectType({
    name: "TimestampOverridable",
    fields() {
      return {
        override: {
          name: "override",
          type: TimestampOverrideType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        value: {
          name: "value",
          type: TimestampType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const OpenType: GraphQLObjectType = new GraphQLObjectType({
    name: "Open",
    fields() {
      return {
        dueAt: {
          name: "dueAt",
          type: GraphQLString,
        },
        openedAt: {
          name: "openedAt",
          type: TimestampOverridableType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        openedBy: {
          name: "openedBy",
          type: GraphQLString,
        },
      };
    },
  });
  const TaskStateType: GraphQLUnionType = new GraphQLUnionType({
    name: "TaskState",
    types() {
      return [ClosedType, InProgressType, OpenType];
    },
  });
  const NodeType: GraphQLInterfaceType = new GraphQLInterfaceType({
    description: 'Indicates an object that is "refetchable".',
    name: "Node",
    fields() {
      return {
        id: {
          description: "A globally unique opaque identifier for a node.",
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
        },
      };
    },
  });
  const DynamicStringInputType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "DynamicStringInput",
      fields() {
        return {
          locale: {
            name: "locale",
            type: new GraphQLNonNull(LocaleType),
          },
          value: {
            name: "value",
            type: new GraphQLNonNull(GraphQLString),
          },
        };
      },
    });
  const DynamicStringType: GraphQLObjectType = new GraphQLObjectType({
    name: "DynamicString",
    description:
      "Plain text content that has been (potentially) translated into different\nlanguages as specified by the user's configuration.",
    fields() {
      return {
        locale: {
          name: "locale",
          type: LocaleType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        value: {
          name: "value",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const DisplayNameType: GraphQLObjectType = new GraphQLObjectType({
    name: "DisplayName",
    fields() {
      return {
        id: {
          description: "A globally unique opaque identifier for a node.",
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
          resolve(source) {
            return displayNameIdResolver(source);
          },
        },
        name: {
          name: "name",
          type: DynamicStringType,
          resolve(source, _args, context) {
            return assertNonNull(source.name(context));
          },
        },
      };
    },
    interfaces() {
      return [ComponentType, NodeType];
    },
  });
  const LocationType: GraphQLObjectType = new GraphQLObjectType({
    name: "Location",
    fields() {
      return {
        id: {
          description: "A globally unique opaque identifier for a node.",
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
          resolve(source) {
            return locationIdResolver(source);
          },
        },
        tracking: {
          description:
            'Entrypoint into the "tracking system(s)" for the given Location.',
          name: "tracking",
          type: TrackableConnectionType,
        },
      };
    },
    interfaces() {
      return [ComponentType, NodeType, TrackableType];
    },
  });
  const TaskEdgeType: GraphQLObjectType = new GraphQLObjectType({
    name: "TaskEdge",
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
          type: TaskType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const TaskConnectionType: GraphQLObjectType = new GraphQLObjectType({
    name: "TaskConnection",
    fields() {
      return {
        edges: {
          name: "edges",
          type: new GraphQLList(new GraphQLNonNull(TaskEdgeType)),
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
  const TaskStateMachineType: GraphQLObjectType = new GraphQLObjectType({
    name: "TaskStateMachine",
    description:
      'Where applicable, Entities can have an associated StateMachine that defines\ntheir current ("active") state in addition to possible next states that they\ncan "transition into". Typically, an end user does not need to be aware of\nthis state machine as Tendrel\'s internal engine maintains the machine and\nassociated states for a given Entity. However, in some cases it can be useful\nto surface this information in userland such that a user can interact\ndirectly with the underlying state machine.',
    fields() {
      return {
        active: {
          name: "active",
          type: TaskType,
        },
        transitions: {
          name: "transitions",
          type: TaskConnectionType,
        },
      };
    },
  });
  const TaskType: GraphQLObjectType = new GraphQLObjectType({
    name: "Task",
    description:
      'A system-level component that identifies an Entity as being applicable to\ntendrel\'s internal "task processing pipeline". In practice, Tasks most often\nrepresent "jobs" performed by humans. However, this need not always be the\ncase.\n\nTechnically speaking, a Task represents a (1) *named asynchronous process*\nthat (2) exists in one of three states: open, in progress, or closed.',
    fields() {
      return {
        displayName: {
          name: "displayName",
          type: DisplayNameType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        fsm: {
          description:
            "Tasks can have an associated StateMachine, which defines a finite set of\nstates that the given Task can be in at any given time.",
          name: "fsm",
          type: TaskStateMachineType,
          resolve(source, _args, context) {
            return taskFsmResolver(source, context);
          },
        },
        id: {
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
        },
        state: {
          name: "state",
          type: TaskStateType,
        },
        tracking: {
          description:
            'Entrypoint into the "tracking system(s)" for the given Task.\nAt the moment, sub-task tracking is not supported and therefore `null` will\nalways be returned for this field.',
          name: "tracking",
          type: TrackableConnectionType,
        },
      };
    },
    interfaces() {
      return [ComponentType, TrackableType];
    },
  });
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
          type: TaskType,
        },
        transitions: {
          name: "transitions",
          type: new GraphQLList(new GraphQLNonNull(TaskType)),
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  return new GraphQLSchema({
    query: QueryType,
    mutation: MutationType,
    types: [
      LocaleType,
      TaskStateType,
      ComponentType,
      NodeType,
      TrackableType,
      DynamicStringInputType,
      TransitionInputType,
      ClosedType,
      DisplayNameType,
      DynamicStringType,
      InProgressType,
      LocationType,
      MutationType,
      OpenType,
      PageInfoType,
      QueryType,
      TaskType,
      TaskConnectionType,
      TaskEdgeType,
      TaskStateMachineType,
      TimestampType,
      TimestampOverridableType,
      TimestampOverrideType,
      TrackableConnectionType,
      TrackableEdgeType,
      TrackingSystemType,
      TransitionResultType,
    ],
  });
}
