import {
  GraphQLBoolean,
  GraphQLFloat,
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
import { fields as displayNameFieldsResolver } from "./system/component";
import { fields as taskFieldsResolver } from "./system/component";
import { fields as locationFieldsResolver } from "./system/component";
import { assignees as taskAssigneesResolver } from "./system/component/task";
import { fsm as taskFsmResolver } from "./system/component/task_fsm";
import { advance as mutationAdvanceResolver } from "./system/component/task_fsm";
import { node as queryNodeResolver } from "./system/node";
import { id as assignmentIdResolver } from "./system/node";
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
  const BooleanValueType: GraphQLObjectType = new GraphQLObjectType({
    name: "BooleanValue",
    fields() {
      return {
        boolean: {
          name: "boolean",
          type: GraphQLBoolean,
          resolve(source) {
            return assertNonNull(source.value);
          },
        },
      };
    },
  });
  const DecimalValueType: GraphQLObjectType = new GraphQLObjectType({
    name: "DecimalValue",
    fields() {
      return {
        decimal: {
          name: "decimal",
          type: GraphQLFloat,
          resolve(source) {
            return assertNonNull(source.value);
          },
        },
      };
    },
  });
  const DurationValueType: GraphQLObjectType = new GraphQLObjectType({
    name: "DurationValue",
    fields() {
      return {
        duration: {
          name: "duration",
          type: GraphQLString,
          resolve(source) {
            return assertNonNull(source.value);
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
        fields: {
          description: "TODO: description.",
          name: "fields",
          type: FieldConnectionType,
        },
        id: {
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
        },
      };
    },
  });
  const EntityValueType: GraphQLObjectType = new GraphQLObjectType({
    name: "EntityValue",
    fields() {
      return {
        entity: {
          name: "entity",
          type: ComponentType,
          resolve(source) {
            return assertNonNull(source.value);
          },
        },
      };
    },
  });
  const IntegerValueType: GraphQLObjectType = new GraphQLObjectType({
    name: "IntegerValue",
    fields() {
      return {
        integer: {
          name: "integer",
          type: GraphQLInt,
          resolve(source) {
            return assertNonNull(source.value);
          },
        },
      };
    },
  });
  const StringValueType: GraphQLObjectType = new GraphQLObjectType({
    name: "StringValue",
    fields() {
      return {
        string: {
          name: "string",
          type: GraphQLString,
          resolve(source) {
            return assertNonNull(source.value);
          },
        },
      };
    },
  });
  const TimestampType: GraphQLObjectType = new GraphQLObjectType({
    name: "Timestamp",
    fields() {
      return {
        epochMilliseconds: {
          name: "epochMilliseconds",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        timeZone: {
          name: "timeZone",
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
  const TimestampValueType: GraphQLObjectType = new GraphQLObjectType({
    name: "TimestampValue",
    fields() {
      return {
        timestamp: {
          name: "timestamp",
          type: TimestampType,
          resolve(source) {
            return assertNonNull(source.value);
          },
        },
      };
    },
  });
  const ValueType: GraphQLUnionType = new GraphQLUnionType({
    name: "Value",
    types() {
      return [
        BooleanValueType,
        DecimalValueType,
        DurationValueType,
        EntityValueType,
        IntegerValueType,
        StringValueType,
        TimestampValueType,
      ];
    },
  });
  const FieldType: GraphQLObjectType = new GraphQLObjectType({
    name: "Field",
    fields() {
      return {
        id: {
          name: "id",
          type: GraphQLID,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        value: {
          name: "value",
          type: ValueType,
        },
      };
    },
  });
  const FieldEdgeType: GraphQLObjectType = new GraphQLObjectType({
    name: "FieldEdge",
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
          type: FieldType,
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
  const FieldConnectionType: GraphQLObjectType = new GraphQLObjectType({
    name: "FieldConnection",
    fields() {
      return {
        edges: {
          name: "edges",
          type: new GraphQLList(new GraphQLNonNull(FieldEdgeType)),
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
  const TrackableType: GraphQLInterfaceType = new GraphQLInterfaceType({
    description:
      'Identifies an Entity as being "trackable".\nWhat exactly this means depends on the type underlying said entity and is\nentirely user defined.',
    name: "Trackable",
    fields() {
      return {
        fields: {
          description: "TODO: description.",
          name: "fields",
          type: FieldConnectionType,
        },
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
  const TimestampOverrideType: GraphQLObjectType = new GraphQLObjectType({
    name: "TimestampOverride",
    fields() {
      return {
        overriddenAt: {
          name: "overriddenAt",
          type: GraphQLString,
        },
        overriddenBy: {
          name: "overriddenBy",
          type: GraphQLString,
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
  const AssignableType: GraphQLInterfaceType = new GraphQLInterfaceType({
    description: "Identifies an Entity as being assignable to another Entity.",
    name: "Assignable",
    fields() {
      return {
        fields: {
          description: "TODO: description.",
          name: "fields",
          type: FieldConnectionType,
        },
        id: {
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
        },
      };
    },
    interfaces() {
      return [ComponentType];
    },
  });
  const AssignmentType: GraphQLObjectType = new GraphQLObjectType({
    name: "Assignment",
    description:
      'Encapsulates the "who" and "when" associated with the act of "assignment".\nFor example, both Tasks and Workers implement Assignable and therefore a Task\ncan be assigned to a Worker and vice versa ("assignment" is commutative). In\nthis example, the "who" will always be the Worker and the "when" will be the\ntimestamp when these two Entities were assigned.',
    fields() {
      return {
        assignedAt: {
          description: "NOT YET IMPLEMENTED - will always return null!",
          name: "assignedAt",
          type: TimestampOverridableType,
        },
        assignedTo: {
          name: "assignedTo",
          type: AssignableType,
        },
        id: {
          description: "A globally unique opaque identifier for a node.",
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
          resolve(source) {
            return assignmentIdResolver(source);
          },
        },
      };
    },
    interfaces() {
      return [NodeType];
    },
  });
  const AssignmentEdgeType: GraphQLObjectType = new GraphQLObjectType({
    name: "AssignmentEdge",
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
          type: AssignmentType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const AssignmentConnectionType: GraphQLObjectType = new GraphQLObjectType({
    name: "AssignmentConnection",
    fields() {
      return {
        edges: {
          name: "edges",
          type: new GraphQLList(new GraphQLNonNull(AssignmentEdgeType)),
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
        fields: {
          description: "TODO: description.",
          name: "fields",
          type: FieldConnectionType,
          resolve(source, _args, context) {
            return assertNonNull(displayNameFieldsResolver(source, context));
          },
        },
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
          type: TimestampOverridableType,
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
        inProgressAt: {
          name: "inProgressAt",
          type: TimestampOverridableType,
        },
        inProgressBy: {
          name: "inProgressBy",
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
  const InProgressType: GraphQLObjectType = new GraphQLObjectType({
    name: "InProgress",
    fields() {
      return {
        inProgressAt: {
          name: "inProgressAt",
          type: TimestampOverridableType,
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
  const OpenType: GraphQLObjectType = new GraphQLObjectType({
    name: "Open",
    fields() {
      return {
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
        assignees: {
          description: "[object Object],[object Object],[object Object]",
          name: "assignees",
          type: AssignmentConnectionType,
          resolve(source, _args, context) {
            return taskAssigneesResolver(source, context);
          },
        },
        displayName: {
          name: "displayName",
          type: DisplayNameType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        fields: {
          description: "TODO: description.",
          name: "fields",
          type: FieldConnectionType,
          resolve(source, _args, context) {
            return assertNonNull(taskFieldsResolver(source, context));
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
      return [AssignableType, ComponentType, NodeType, TrackableType];
    },
  });
  const ValueInputType: GraphQLInputObjectType = new GraphQLInputObjectType({
    name: "ValueInput",
    fields() {
      return {
        boolean: {
          name: "boolean",
          type: GraphQLBoolean,
        },
        decimal: {
          name: "decimal",
          type: GraphQLFloat,
        },
        duration: {
          description: "Duration in either ISO or millisecond format.",
          name: "duration",
          type: GraphQLString,
        },
        id: {
          name: "id",
          type: GraphQLID,
        },
        integer: {
          name: "integer",
          type: GraphQLInt,
        },
        string: {
          name: "string",
          type: GraphQLString,
        },
        timestamp: {
          description: "Timestamp in either ISO or epoch millisecond format.",
          name: "timestamp",
          type: GraphQLString,
        },
      };
    },
    isOneOf: true,
  });
  const FieldInputType: GraphQLInputObjectType = new GraphQLInputObjectType({
    name: "FieldInput",
    fields() {
      return {
        field: {
          name: "field",
          type: new GraphQLNonNull(GraphQLID),
        },
        value: {
          name: "value",
          type: ValueInputType,
        },
      };
    },
  });
  const TaskInputType: GraphQLInputObjectType = new GraphQLInputObjectType({
    name: "TaskInput",
    fields() {
      return {
        id: {
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
        },
        overrides: {
          name: "overrides",
          type: new GraphQLList(new GraphQLNonNull(FieldInputType)),
        },
      };
    },
  });
  const FsmOptionsType: GraphQLInputObjectType = new GraphQLInputObjectType({
    name: "FsmOptions",
    fields() {
      return {
        fsm: {
          description:
            "The unique identifier of the FSM on which you are operating. Wherever you\naccess the `fsm` field of a `Task`, that task's id should go here.",
          name: "fsm",
          type: new GraphQLNonNull(GraphQLID),
        },
        task: {
          description: "[object Object],[object Object],[object Object]",
          name: "task",
          type: new GraphQLNonNull(TaskInputType),
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
            opts: {
              name: "opts",
              type: new GraphQLNonNull(FsmOptionsType),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              mutationAdvanceResolver(source, context, args.opts),
            );
          },
        },
      };
    },
  });
  const AssignmentInputType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "AssignmentInput",
      fields() {
        return {
          assignedTo: {
            name: "assignedTo",
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
  const TimestampInputType: GraphQLInputObjectType = new GraphQLInputObjectType(
    {
      name: "TimestampInput",
      fields() {
        return {
          epochMilliseconds: {
            name: "epochMilliseconds",
            type: new GraphQLNonNull(GraphQLString),
          },
          timeZone: {
            name: "timeZone",
            type: GraphQLString,
          },
        };
      },
    },
  );
  const LocationType: GraphQLObjectType = new GraphQLObjectType({
    name: "Location",
    fields() {
      return {
        fields: {
          description: "TODO: description.",
          name: "fields",
          type: FieldConnectionType,
          resolve(source, _args, context) {
            return assertNonNull(locationFieldsResolver(source, context));
          },
        },
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
      ValueType,
      AssignableType,
      ComponentType,
      NodeType,
      TrackableType,
      AssignmentInputType,
      DynamicStringInputType,
      FieldInputType,
      FsmOptionsType,
      TaskInputType,
      TimestampInputType,
      ValueInputType,
      AssignmentType,
      AssignmentConnectionType,
      AssignmentEdgeType,
      BooleanValueType,
      ClosedType,
      DecimalValueType,
      DisplayNameType,
      DurationValueType,
      DynamicStringType,
      EntityValueType,
      FieldType,
      FieldConnectionType,
      FieldEdgeType,
      InProgressType,
      IntegerValueType,
      LocationType,
      MutationType,
      OpenType,
      PageInfoType,
      QueryType,
      StringValueType,
      TaskType,
      TaskConnectionType,
      TaskEdgeType,
      TaskStateMachineType,
      TimestampType,
      TimestampOverridableType,
      TimestampOverrideType,
      TimestampValueType,
      TrackableConnectionType,
      TrackableEdgeType,
    ],
  });
}
