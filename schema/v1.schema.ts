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
import { startTask as mutationStartTaskResolver } from "./system/component/task";
import { stopTask as mutationStopTaskResolver } from "./system/component/task";
import { fsm as taskFsmResolver } from "./system/component/task_fsm";
import { advance as mutationAdvanceResolver } from "./system/component/task_fsm";
import { node as queryNodeResolver } from "./system/node";
import { id as displayNameIdResolver } from "./system/node";
import { id as taskIdResolver } from "./system/node";
import { id as locationIdResolver } from "./system/node";
async function assertNonNull<T>(value: T | Promise<T>): Promise<T> {
  const awaited = await value;
  if (awaited == null)
    throw new Error("Cannot return null for semantically non-nullable field.");
  return awaited;
}
export function getSchema(): GraphQLSchema {
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
        node: {
          name: "node",
          type: new GraphQLNonNull(NodeType),
          args: {
            id: {
              name: "id",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(source, args, context) {
            return queryNodeResolver(source, args, context);
          },
        },
        trackables: {
          description:
            "Query for Trackable entities in the given `parent` hierarchy.",
          name: "trackables",
          type: TrackableConnectionType,
          args: {
            parent: {
              description:
                "Identifies the root of the hierarchy in which to search for Trackable\nentities.\n\nValid parent types are currently:\n- Customer\n\nAll other parent types will be gracefully ignored.",
              name: "parent",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              queryTrackablesResolver(source, context, args.parent),
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
          description: "A globally unique opaque identifier for a node.",
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
          resolve(source) {
            return taskIdResolver(source);
          },
        },
        state: {
          name: "state",
          type: TaskStateType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
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
      return [ComponentType, NodeType, TrackableType];
    },
  });
  const TaskActionResultType: GraphQLObjectType = new GraphQLObjectType({
    name: "TaskActionResult",
    fields() {
      return {
        parent: {
          name: "parent",
          type: NodeType,
        },
        task: {
          name: "task",
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
  const MutationType: GraphQLObjectType = new GraphQLObjectType({
    name: "Mutation",
    fields() {
      return {
        advance: {
          name: "advance",
          type: TaskType,
          args: {
            fsm: {
              description:
                "The unique identifier of the FSM on which you are operating. Wherever you\naccess the `fsm` field of a `Task`, that task's id should go here.",
              name: "fsm",
              type: new GraphQLNonNull(GraphQLID),
            },
            task: {
              description:
                'The unique identifier of a `Task` _within_ the aforementioned FSM. These\nare the tasks available as the `active` and/or `transitions` fields within\na task\'s `fsm` field. Advancing a FSM by way of this argument works as\nfollows:\n- if the given `task` is Open, move it to In Progress and make it the\n  active task in the given `fsm`.\n- if the given `task` is In Progress, move it to Closed and transition the\n  overall `fsm` as determined by the rules that define it. Note that there\n  are by default no "on close" rules, and thus the result of this operation\n  is effectively to revert the `fsm` to the state it was in _prior to_\n  advancing into its current state. Note that this might imply putting the\n  `fsm` back into its initial (typically "idle") state.\n- if the given `task` is Closed, this operation is a no-op.',
              name: "task",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              mutationAdvanceResolver(source, context, args),
            );
          },
        },
        startTask: {
          description:
            "Start the given Task, identified by the `task` argument.\nOptionally, a `parent` argument may also be provided to this function. The\npurpose of this argument is to avoid necessitating *two* network calls where\nthe first is this mutation and the second would be another query to refetch\ndata only transitively related to this Task.",
          name: "startTask",
          type: TaskActionResultType,
          args: {
            parent: {
              name: "parent",
              type: GraphQLID,
            },
            task: {
              name: "task",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              mutationStartTaskResolver(
                source,
                args.task,
                args.parent,
                context,
              ),
            );
          },
        },
        stopTask: {
          name: "stopTask",
          type: TaskActionResultType,
          args: {
            parent: {
              name: "parent",
              type: GraphQLID,
            },
            task: {
              name: "task",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              mutationStopTaskResolver(source, args.task, args.parent, context),
            );
          },
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
      TaskActionResultType,
      TaskConnectionType,
      TaskEdgeType,
      TaskStateMachineType,
      TimestampType,
      TimestampOverridableType,
      TimestampOverrideType,
      TrackableConnectionType,
      TrackableEdgeType,
    ],
  });
}
