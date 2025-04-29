import {
  GraphQLBoolean,
  GraphQLEnumType,
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
import { createLocation as mutationCreateLocationResolver } from "./platform/archetype/location/create";
import { updateLocation as mutationUpdateLocationResolver } from "./platform/archetype/location/update";
import {
  attachedBy as attachmentAttachedByResolver,
  attach as mutationAttachResolver,
} from "./platform/attachment";
import { trackables as queryTrackablesResolver } from "./platform/tracking";
import {
  attachments as fieldAttachmentsResolver,
  completions as fieldCompletionsResolver,
  description as fieldDescriptionResolver,
  isRequired as fieldIsRequiredResolver,
  name as fieldNameResolver,
  parent as fieldParentResolver,
} from "./system/component";
import {
  applyFieldEdits as mutationApplyFieldEditsResolver,
  rebase as mutationRebaseResolver,
  assignees as taskAssigneesResolver,
  attachments as taskAttachmentsResolver,
  chainAgg as taskChainAggResolver,
  chain as taskChainResolver,
  fields as taskFieldsResolver,
} from "./system/component/task";
import {
  advance as mutationAdvanceResolver,
  fsm as taskFsmResolver,
} from "./system/component/task_fsm";
import { createTemplateConstraint as mutationCreateTemplateConstraintResolver } from "./system/engine0/createTemplateConstraint";
import {
  castEntityInstanceToTask as entityInstanceAsTaskResolver,
  asFieldTemplateValueType as entityInstanceEdgeAsFieldTemplateValueTypeResolver,
  entityInstanceName as entityInstanceNameResolver,
  castEntityTemplateToTask as entityTemplateAsTaskResolver,
  createCustagAsFieldTemplateValueTypeConstraint as mutationCreateCustagAsFieldTemplateValueTypeConstraintResolver,
  createInstance as mutationCreateInstanceResolver,
  instances as queryInstancesResolver,
  templates as queryTemplatesResolver,
} from "./system/entity";
import {
  id as assignmentIdResolver,
  id as attachmentIdResolver,
  id as descriptionIdResolver,
  id as displayNameIdResolver,
  id as locationIdResolver,
  deleteNode as mutationDeleteNodeResolver,
  node as queryNodeResolver,
  id as taskIdResolver,
} from "./system/node";
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
  const IdentityType: GraphQLInterfaceType = new GraphQLInterfaceType({
    name: "Identity",
    fields() {
      return {
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
  const URLType: GraphQLScalarType = new GraphQLScalarType({
    name: "URL",
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
  const AttachmentType: GraphQLObjectType = new GraphQLObjectType({
    name: "Attachment",
    fields() {
      return {
        attachedBy: {
          name: "attachedBy",
          type: IdentityType,
          resolve(source, _args, context) {
            return attachmentAttachedByResolver(source, context);
          },
        },
        attachment: {
          description:
            "If you are using [Relay](https://relay.dev), make sure you annotate this\nfield with `@catch(to: RESULT)` to avoid intermittent S3 errors from\ncrashing the entire fragment.",
          name: "attachment",
          type: URLType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        id: {
          description: "A globally unique opaque identifier for a node.",
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
          resolve(source) {
            return attachmentIdResolver(source);
          },
        },
      };
    },
    interfaces() {
      return [ComponentType, NodeType];
    },
  });
  const AttachmentEdgeType: GraphQLObjectType = new GraphQLObjectType({
    name: "AttachmentEdge",
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
          type: AttachmentType,
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
  const AttachmentConnectionType: GraphQLObjectType = new GraphQLObjectType({
    name: "AttachmentConnection",
    fields() {
      return {
        edges: {
          name: "edges",
          type: new GraphQLList(new GraphQLNonNull(AttachmentEdgeType)),
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
  const BooleanValueType: GraphQLObjectType = new GraphQLObjectType({
    name: "BooleanValue",
    fields() {
      return {
        boolean: {
          name: "boolean",
          type: GraphQLBoolean,
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
        },
      };
    },
  });
  const NumberValueType: GraphQLObjectType = new GraphQLObjectType({
    name: "NumberValue",
    fields() {
      return {
        number: {
          name: "number",
          type: GraphQLInt,
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
        },
      };
    },
  });
  const TimestampType: GraphQLScalarType = new GraphQLScalarType({
    description: "A date-time string in ISO 8601 format.",
    name: "Timestamp",
  });
  const TimestampValueType: GraphQLObjectType = new GraphQLObjectType({
    name: "TimestampValue",
    fields() {
      return {
        timestamp: {
          name: "timestamp",
          type: TimestampType,
        },
      };
    },
  });
  const ValueType: GraphQLUnionType = new GraphQLUnionType({
    name: "Value",
    types() {
      return [
        BooleanValueType,
        EntityValueType,
        NumberValueType,
        StringValueType,
        TimestampValueType,
      ];
    },
  });
  const ValueCompletionType: GraphQLObjectType = new GraphQLObjectType({
    name: "ValueCompletion",
    fields() {
      return {
        value: {
          name: "value",
          type: ValueType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const ValueCompletionEdgeType: GraphQLObjectType = new GraphQLObjectType({
    name: "ValueCompletionEdge",
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
          type: ValueCompletionType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const ValueCompletionConnectionType: GraphQLObjectType =
    new GraphQLObjectType({
      name: "ValueCompletionConnection",
      fields() {
        return {
          edges: {
            name: "edges",
            type: new GraphQLList(new GraphQLNonNull(ValueCompletionEdgeType)),
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
  const DescriptionType: GraphQLObjectType = new GraphQLObjectType({
    name: "Description",
    fields() {
      return {
        description: {
          deprecationReason: "Use Description.locale and/or Description.value.",
          name: "description",
          type: DynamicStringType,
          resolve(source, _args, context) {
            return assertNonNull(source.description(context));
          },
        },
        id: {
          description: "A globally unique opaque identifier for a node.",
          name: "id",
          type: new GraphQLNonNull(GraphQLID),
          resolve(source) {
            return descriptionIdResolver(source);
          },
        },
        locale: {
          name: "locale",
          type: GraphQLString,
          resolve(source, _args, context) {
            return assertNonNull(source.locale(context));
          },
        },
        value: {
          name: "value",
          type: GraphQLString,
          resolve(source, _args, context) {
            return assertNonNull(source.value(context));
          },
        },
      };
    },
    interfaces() {
      return [ComponentType, NodeType];
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
        locale: {
          name: "locale",
          type: GraphQLString,
          resolve(source, _args, context) {
            return assertNonNull(source.locale(context));
          },
        },
        name: {
          deprecationReason:
            "Use the DisplayName.value and/or DisplayName.locale instead.",
          name: "name",
          type: DynamicStringType,
          resolve(source, _args, context) {
            return assertNonNull(source.name(context));
          },
        },
        value: {
          name: "value",
          type: GraphQLString,
          resolve(source, _args, context) {
            return assertNonNull(source.value(context));
          },
        },
      };
    },
    interfaces() {
      return [ComponentType, NodeType];
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
  const AggregateType: GraphQLObjectType = new GraphQLObjectType({
    name: "Aggregate",
    fields() {
      return {
        group: {
          description:
            "The group, or bucket, that uniquely identifies this aggregate.\nFor example, this will be one of the `overType`s passed to `chainAgg`.",
          name: "group",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        value: {
          description:
            'The computed aggregate value.\n\nCurrently, this will always be a string value representing a duration in\nseconds, e.g. "360" -> 360 seconds. `null` will be returned when no such\naggregate can be computed, e.g. "time in planned downtime" when no "planned\ndowntime" events exist. Note also that `null` will be returned if a\nduration cannot be computed, e.g. because there is no end date.',
          name: "value",
          type: GraphQLString,
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
          args: {
            after: {
              name: "after",
              type: GraphQLID,
            },
            first: {
              name: "first",
              type: GraphQLInt,
            },
          },
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
  const TaskStateNameType: GraphQLEnumType = new GraphQLEnumType({
    name: "TaskStateName",
    values: {
      Closed: {
        value: "Closed",
      },
      InProgress: {
        value: "InProgress",
      },
      Open: {
        value: "Open",
      },
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
        timeZone: {
          description: "IANA time zone identifier for this Location.",
          name: "timeZone",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        tracking: {
          description:
            'Entrypoint into the "tracking system(s)" for the given Location.',
          name: "tracking",
          type: TrackableConnectionType,
          args: {
            after: {
              name: "after",
              type: GraphQLID,
            },
            first: {
              name: "first",
              type: GraphQLInt,
            },
            withStatus: {
              name: "withStatus",
              type: new GraphQLList(new GraphQLNonNull(TaskStateNameType)),
            },
          },
          resolve(source, args) {
            return assertNonNull(
              source.tracking(args.first, args.after, args.withStatus),
            );
          },
        },
      };
    },
    interfaces() {
      return [ComponentType, NodeType, TrackableType];
    },
  });
  const TaskTransitionType: GraphQLObjectType = new GraphQLObjectType({
    name: "TaskTransition",
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
        id: {
          name: "id",
          type: GraphQLID,
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
        target: {
          name: "target",
          type: LocationType,
        },
      };
    },
  });
  const TaskTransitionsType: GraphQLObjectType = new GraphQLObjectType({
    name: "TaskTransitions",
    fields() {
      return {
        edges: {
          name: "edges",
          type: new GraphQLList(new GraphQLNonNull(TaskTransitionType)),
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
        hash: {
          name: "hash",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        transitions: {
          name: "transitions",
          type: TaskTransitionsType,
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
          type: AssignableType,
        },
        inProgressAt: {
          name: "inProgressAt",
          type: TimestampOverridableType,
        },
        inProgressBy: {
          name: "inProgressBy",
          type: AssignableType,
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
          type: AssignableType,
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
          type: AssignableType,
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
          type: AssignableType,
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
      'A system-level component that identifies an Entity as being applicable to\nTendrel\'s internal "task processing pipeline". In practice, Tasks most often\nrepresent "jobs" performed by humans. However, this need not always be the\ncase.\n\nTechnically speaking, a Task represents a (1) *named asynchronous process*\nthat (2) exists in one of three states: open, in progress, or closed.',
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
        attachments: {
          description:
            "Attachments associated with the Task as a whole.\nNote that you can also have field-level attachments.",
          name: "attachments",
          type: AttachmentConnectionType,
          args: {
            after: {
              name: "after",
              type: GraphQLString,
            },
            before: {
              name: "before",
              type: GraphQLString,
            },
            first: {
              name: "first",
              type: GraphQLInt,
            },
            last: {
              name: "last",
              type: GraphQLInt,
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              taskAttachmentsResolver(source, context, args),
            );
          },
        },
        chain: {
          description:
            'Inspect the chain (if any) in which the given Task exists.\nAs it stands, this can only be used to perform a downwards search of the\nchain, i.e. the given Task is used as the "root" of the search tree.',
          name: "chain",
          type: TaskConnectionType,
          args: {
            first: {
              description:
                'For use in pagination. Specifies the limit for "forward pagination".',
              name: "first",
              type: GraphQLInt,
            },
          },
          resolve(source, args) {
            return assertNonNull(taskChainResolver(source, args.first));
          },
        },
        chainAgg: {
          description:
            'Given a Task identifying as a node in a chain, create an aggregate view of\nsaid chain over the type tags given in `overType`. The result is a set of\naggregates representing the *sum total duration* of nodes tagged with any of\nthe given `overType` tags, *including* the given Task (if it is so tagged).\n\nColloquially: `chainAgg(overType: ["Foo", "Bar"])` will compute the total\ntime spent in all "Foo" or "Bar" tasks in the given chain;\n\n```json\n[\n  {\n    "group": "Foo",\n    "value": "26.47", // 26.47 seconds spent doing "Foo" tasks\n  },\n  {\n    "group": "Bar",\n    "value": "5.82", // 5.82 seconds spent doing "Bar" tasks\n  },\n]\n```\n\nNote that this aggregation uses the given Task as the *root* of the chain.\nChains are tree-like structures, which means you can chainAgg over a subtree\nby choosing a different root node. Note also that this means you may need to\ndo some math depending on the structure of your chain, e.g. in the above\nexample it may be that "Foo" remains "InProgress" while "Bar" happens, and\ntherefore the aggregate for "Foo" *includes* time spent in "Bar".',
          name: "chainAgg",
          type: new GraphQLList(new GraphQLNonNull(AggregateType)),
          args: {
            overType: {
              description:
                "Which subtype-hierarchies you are interested in aggregating over.",
              name: "overType",
              type: new GraphQLNonNull(
                new GraphQLList(new GraphQLNonNull(GraphQLString)),
              ),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              taskChainAggResolver(source, context, args.overType),
            );
          },
        },
        description: {
          name: "description",
          type: DescriptionType,
          resolve(source, _args, context) {
            return source.description(context);
          },
        },
        displayName: {
          deprecationReason: "Use Task.name instead.",
          name: "displayName",
          type: DisplayNameType,
          resolve(source, _args, context) {
            return assertNonNull(source.displayName(context));
          },
        },
        field: {
          name: "field",
          type: FieldType,
          args: {
            byName: {
              name: "byName",
              type: GraphQLString,
            },
          },
        },
        fields: {
          description: "The set of Fields for the given Task.",
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
          resolve(source) {
            return taskFsmResolver(source);
          },
        },
        hash: {
          description:
            "The hash signature of the given Task. This is only useful when interacting\nwith APIs that require a hash as a concurrency control mechanism.",
          name: "hash",
          type: GraphQLString,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
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
        name: {
          name: "name",
          type: DisplayNameType,
          resolve(source, _args, context) {
            return assertNonNull(source.name(context));
          },
        },
        parent: {
          description:
            "Identifies the parent of the current Task.\n\nThis is different from previous. Previous models causality, parent models\nownership. In practice, the parent of a Task will always be a Location.\nNote that currently this only supports workinstances. Tasks whose underlying\ntype is a worktemplate will **always have a null parent**.",
          name: "parent",
          type: NodeType,
        },
        previous: {
          description:
            "Get the previous Task, which may represent an altogether different chain\nthan the current Task.",
          name: "previous",
          type: TaskType,
        },
        root: {
          name: "root",
          type: TaskType,
        },
        state: {
          name: "state",
          type: TaskStateType,
          resolve(source, _args, context) {
            return source.state(context);
          },
        },
        tracking: {
          description:
            'Entrypoint into the "tracking system(s)" for the given Task.\nAt the moment, sub-task tracking is not supported and therefore `null` will\nalways be returned for this field.',
          name: "tracking",
          type: TrackableConnectionType,
          args: {
            after: {
              name: "after",
              type: GraphQLID,
            },
            first: {
              name: "first",
              type: GraphQLInt,
            },
          },
          resolve(source, args) {
            return source.tracking(args.first, args.after);
          },
        },
      };
    },
    interfaces() {
      return [AssignableType, ComponentType, NodeType, TrackableType];
    },
  });
  const ValueTypeType: GraphQLEnumType = new GraphQLEnumType({
    name: "ValueType",
    values: {
      boolean: {
        value: "boolean",
      },
      entity: {
        value: "entity",
      },
      number: {
        value: "number",
      },
      string: {
        value: "string",
      },
      timestamp: {
        value: "timestamp",
      },
      unknown: {
        value: "unknown",
      },
    },
  });
  const FieldType: GraphQLObjectType = new GraphQLObjectType({
    name: "Field",
    fields() {
      return {
        attachments: {
          description: "Field attachments.",
          name: "attachments",
          type: AttachmentConnectionType,
          args: {
            after: {
              name: "after",
              type: GraphQLString,
            },
            before: {
              name: "before",
              type: GraphQLString,
            },
            first: {
              name: "first",
              type: GraphQLInt,
            },
            last: {
              name: "last",
              type: GraphQLInt,
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              fieldAttachmentsResolver(source, context, args),
            );
          },
        },
        completions: {
          description:
            'Intended to provide "auto-completion" in a frontend setting, this API returns\n*distinct known values* for a given Field. For Fields without constraints\n(which is most of them), this will return a "frecency" list of previously\nused values for the given Field. When constraints are involved, the\ncompletion list represents the *allowed* set of values for the given Field.\n\nNote that "frecency" is not currently implemented. For such Fields (i.e. those\nwithout constraints) you will simply get back an empty completion list.\n\nNote also that currently there is no enforcement of the latter, constraint-based\nsemantic in the backend! The client *must* validate user input using the\ncompletion list *before* issuing, for example, an `applyFieldEdits` mutation.\nOtherwise the backend will gladly accept arbitrary values (assuming they are,\nof course, of the correct type).\n\nNote also that pagination is not currently implemented.',
          name: "completions",
          type: ValueCompletionConnectionType,
          resolve(source) {
            return assertNonNull(fieldCompletionsResolver(source));
          },
        },
        description: {
          description: "Description of a Field.",
          name: "description",
          type: DescriptionType,
          resolve(source, _args, context) {
            return fieldDescriptionResolver(source, context);
          },
        },
        id: {
          description: "Unique identifier for this Field.",
          name: "id",
          type: GraphQLID,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        isRequired: {
          name: "isRequired",
          type: GraphQLBoolean,
          resolve(source, _args, context) {
            return assertNonNull(fieldIsRequiredResolver(source, context));
          },
        },
        name: {
          description: "Display name for a Field.",
          name: "name",
          type: DisplayNameType,
          resolve(source, _args, context) {
            return assertNonNull(fieldNameResolver(source, context));
          },
        },
        parent: {
          name: "parent",
          type: TaskType,
          resolve(source) {
            return assertNonNull(fieldParentResolver(source));
          },
        },
        value: {
          description:
            "The value for this Field, if any. This field will always be present (when\nrequested) for the given Field so as to convey the underlying data type of\nthe (raw data) value. The underlying (raw data) value can be `null`.",
          name: "value",
          type: ValueType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        valueType: {
          description:
            "The type of data underlying `value`. This is provided as a convenience when\ninteracting with field-level edits through other apis.",
          name: "valueType",
          type: ValueTypeType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
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
  const EntityInstanceType: GraphQLObjectType = new GraphQLObjectType({
    name: "EntityInstance",
    description:
      'Entities represent distinct objects in the system. They can be physical\nobjects, like Locations, Resources and Workers, or logical ones, like\n"Scan Codes".',
    fields() {
      return {
        asTask: {
          name: "asTask",
          type: TaskType,
          resolve(source) {
            return assertNonNull(entityInstanceAsTaskResolver(source));
          },
        },
        id: {
          name: "id",
          type: GraphQLID,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        name: {
          name: "name",
          type: DisplayNameType,
          resolve(source, _args, context) {
            return assertNonNull(entityInstanceNameResolver(source, context));
          },
        },
      };
    },
  });
  const EntityInstanceEdgeType: GraphQLObjectType = new GraphQLObjectType({
    name: "EntityInstanceEdge",
    fields() {
      return {
        asFieldTemplateValueType: {
          description:
            "Lift an EntityInstance to a set of Fields where the given EntityInstance\nidentifies as the Field's ValueType.",
          name: "asFieldTemplateValueType",
          type: FieldConnectionType,
          resolve(source) {
            return assertNonNull(
              entityInstanceEdgeAsFieldTemplateValueTypeResolver(source),
            );
          },
        },
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
          type: EntityInstanceType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const EntityInstanceConnectionType: GraphQLObjectType = new GraphQLObjectType(
    {
      name: "EntityInstanceConnection",
      fields() {
        return {
          edges: {
            name: "edges",
            type: new GraphQLList(new GraphQLNonNull(EntityInstanceEdgeType)),
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
    },
  );
  const EntityTemplateType: GraphQLObjectType = new GraphQLObjectType({
    name: "EntityTemplate",
    fields() {
      return {
        asTask: {
          name: "asTask",
          type: TaskType,
          resolve(source) {
            return assertNonNull(entityTemplateAsTaskResolver(source));
          },
        },
        id: {
          name: "id",
          type: GraphQLID,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const EntityTemplateEdgeType: GraphQLObjectType = new GraphQLObjectType({
    name: "EntityTemplateEdge",
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
          type: EntityTemplateType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const EntityTemplateConnectionType: GraphQLObjectType = new GraphQLObjectType(
    {
      name: "EntityTemplateConnection",
      fields() {
        return {
          edges: {
            name: "edges",
            type: new GraphQLList(new GraphQLNonNull(EntityTemplateEdgeType)),
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
    },
  );
  const QueryType: GraphQLObjectType = new GraphQLObjectType({
    name: "Query",
    fields() {
      return {
        instances: {
          name: "instances",
          type: EntityInstanceConnectionType,
          args: {
            after: {
              name: "after",
              type: GraphQLString,
            },
            first: {
              name: "first",
              type: GraphQLInt,
            },
            owner: {
              description:
                "TEMPORARY: this should be the customer/organization uuid.",
              name: "owner",
              type: new GraphQLNonNull(GraphQLID),
            },
            parent: {
              description: "Instances with the given parent (instance).",
              name: "parent",
              type: new GraphQLList(new GraphQLNonNull(GraphQLID)),
            },
          },
          resolve(_source, args, context) {
            return assertNonNull(queryInstancesResolver(context, args));
          },
        },
        node: {
          name: "node",
          type: new GraphQLNonNull(NodeType),
          args: {
            id: {
              name: "id",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(_source, args, context) {
            return queryNodeResolver(args, context);
          },
        },
        templates: {
          name: "templates",
          type: EntityTemplateConnectionType,
          args: {
            owner: {
              description:
                "TEMPORARY: this should be the customer/organization uuid.",
              name: "owner",
              type: new GraphQLNonNull(GraphQLID),
            },
            type: {
              description:
                "Templates of the given type. This maps (currently) to worktemplatetype.\nFor example, in Runtime the following template types exist:\n- Run\n- Downtime\n- Idle Time\nAny of these are suitable for this API.\n\nAlso see `Task.chainAgg`, as that API takes a similar parameter `overType`.",
              name: "type",
              type: new GraphQLList(new GraphQLNonNull(GraphQLString)),
            },
          },
          resolve(_source, args, context) {
            return assertNonNull(queryTemplatesResolver(args, context));
          },
        },
        trackables: {
          description:
            "Query for Trackable entities in the given `parent` hierarchy.\n\nNote that this api does not yet support pagination! The `first` argument is\nused purely for testing at the moment.",
          name: "trackables",
          type: TrackableConnectionType,
          args: {
            first: {
              description:
                "Forward pagination limit. Should only be used in conjunction with `after`.",
              name: "first",
              type: GraphQLInt,
            },
            includeInactive: {
              description:
                "By default, this api will only return Trackables that are active. This can\nbe overridden using the `includeInactive` flag.",
              name: "includeInactive",
              type: GraphQLBoolean,
            },
            parent: {
              description:
                "Identifies the root of the hierarchy in which to search for Trackable\nentities.\n\nValid parent types are currently:\n- Customer\n\nAll other parent types will be gracefully ignored.",
              name: "parent",
              type: new GraphQLNonNull(GraphQLID),
            },
            withImplementation: {
              description:
                "Allows filtering the returned set of Trackables by the *implementing* type.\n\nCurrently this is only 'Location' (the default) or 'Task'. Note that\nspecifying the latter will return a connection of trackable Tasks that\nrepresent the *chain roots* (i.e. originators). This is for you, Will\nTwait, so you can get started on the history screen. Note also that it will\nonly give you *closed* chains, i.e. `workinstancecompleteddate is not null`.",
              name: "withImplementation",
              type: GraphQLString,
            },
          },
          resolve(_source, args, context) {
            return assertNonNull(queryTrackablesResolver(args, context));
          },
        },
      };
    },
  });
  const DiagnosticKindType: GraphQLEnumType = new GraphQLEnumType({
    name: "DiagnosticKind",
    values: {
      candidate_change_discarded: {
        value: "candidate_change_discarded",
      },
      candidate_choice_unavailable: {
        value: "candidate_choice_unavailable",
      },
      expected_instance_got_template: {
        description:
          "Indicates that an operation expected an instance type to be provided but\nreceived a template type.",
        value: "expected_instance_got_template",
      },
      expected_template_got_instance: {
        description:
          "Indicates that an operation expected a template type to be provided but\nreceived an instance type.",
        value: "expected_template_got_instance",
      },
      feature_not_available: {
        value: "feature_not_available",
      },
      hash_is_required: {
        description:
          "Some operations accept an optional hash. This is misleading. You should\n_always_ pass a hash for operations that accept them.",
        value: "hash_is_required",
      },
      hash_mismatch_precludes_operation: {
        description:
          "Diagnostics of this kind indicates that the requested operation is no longer\na valid operation due to a state change that has not yet been observed by\nthe client. Typically this is due to data staleness but may also occur for\nthe _loser_ of a race under concurrency.\n\nHashes are opaque. Clients should not attempt to derive any meaning from them.",
        value: "hash_mismatch_precludes_operation",
      },
      invalid_type: {
        description:
          "Indicates that an operation received a type that it is not allowed to\noperate on.",
        value: "invalid_type",
      },
      no_associated_fsm: {
        description:
          "When you operate on a StateMachine<T>, there must obviously be a state\nmachine to operate *on*. This diagnostic is returned when no such state\nmachine exists.",
        value: "no_associated_fsm",
      },
    },
  });
  const DiagnosticType: GraphQLObjectType = new GraphQLObjectType({
    name: "Diagnostic",
    fields() {
      return {
        code: {
          name: "code",
          type: DiagnosticKindType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
        message: {
          name: "message",
          type: GraphQLString,
        },
      };
    },
  });
  const AdvanceTaskStateMachineResultType: GraphQLObjectType =
    new GraphQLObjectType({
      name: "AdvanceTaskStateMachineResult",
      fields() {
        return {
          diagnostics: {
            name: "diagnostics",
            type: new GraphQLList(new GraphQLNonNull(DiagnosticType)),
          },
          instantiations: {
            name: "instantiations",
            type: new GraphQLList(new GraphQLNonNull(TaskEdgeType)),
            resolve(source, args, context, info) {
              return assertNonNull(
                defaultFieldResolver(source, args, context, info),
              );
            },
          },
          root: {
            name: "root",
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
  const ValueInputType: GraphQLInputObjectType = new GraphQLInputObjectType({
    name: "ValueInput",
    fields() {
      return {
        boolean: {
          name: "boolean",
          type: GraphQLBoolean,
        },
        id: {
          name: "id",
          type: GraphQLID,
        },
        number: {
          name: "number",
          type: GraphQLInt,
        },
        string: {
          name: "string",
          type: GraphQLString,
        },
        timestamp: {
          description: "ISO 8601 format.",
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
        valueType: {
          description:
            'Must match the type of the `value`, e.g.\n```typescript\nif (field.valueType === "string") {\n  assert(field.value === null || "string" in field.value);\n}\n```',
          name: "valueType",
          type: new GraphQLNonNull(ValueTypeType),
        },
      };
    },
  });
  const AdvanceTaskOptionsType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "AdvanceTaskOptions",
      fields() {
        return {
          hash: {
            description:
              "This should be the Task's current hash (as far as you know) as it was\nreturned to you when first querying for the Task in question.",
            name: "hash",
            type: new GraphQLNonNull(GraphQLString),
          },
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
  const AdvanceFsmOptionsType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "AdvanceFsmOptions",
      fields() {
        return {
          fsm: {
            name: "fsm",
            type: new GraphQLNonNull(AdvanceTaskOptionsType),
          },
          task: {
            name: "task",
            type: new GraphQLNonNull(AdvanceTaskOptionsType),
          },
        };
      },
    });
  const CreateInstancePayloadType: GraphQLObjectType = new GraphQLObjectType({
    name: "CreateInstancePayload",
    fields() {
      return {
        edge: {
          name: "edge",
          type: EntityInstanceEdgeType,
          resolve(source, args, context, info) {
            return assertNonNull(
              defaultFieldResolver(source, args, context, info),
            );
          },
        },
      };
    },
  });
  const CreateLocationInputType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "CreateLocationInput",
      fields() {
        return {
          category: {
            name: "category",
            type: new GraphQLNonNull(GraphQLString),
          },
          name: {
            name: "name",
            type: new GraphQLNonNull(GraphQLString),
          },
          parent: {
            name: "parent",
            type: new GraphQLNonNull(GraphQLID),
          },
          scanCode: {
            name: "scanCode",
            type: GraphQLString,
          },
          timeZone: {
            description:
              "If not specified, the time zone will be derived from the parent (when the\nparent is a Location). This is most notably *not* the case when the parent is\na Customer.",
            name: "timeZone",
            type: GraphQLString,
          },
        };
      },
    });
  const TemplateConstraintType: GraphQLObjectType = new GraphQLObjectType({
    name: "TemplateConstraint",
    description:
      'Template constraints allow you to constrain the *type* of thing that can go\ninto a field. Currently, this is only supported for Locations (and by that I\nmean "primary locations") as a means of "enabling" a template for the given\nlocation.',
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
      };
    },
  });
  const CreateTemplateConstraintResultType: GraphQLObjectType =
    new GraphQLObjectType({
      name: "CreateTemplateConstraintResult",
      fields() {
        return {
          constraint: {
            name: "constraint",
            type: TemplateConstraintType,
          },
          diagnostics: {
            name: "diagnostics",
            type: new GraphQLList(new GraphQLNonNull(DiagnosticType)),
            resolve(source, args, context, info) {
              return assertNonNull(
                defaultFieldResolver(source, args, context, info),
              );
            },
          },
          instantiations: {
            name: "instantiations",
            type: new GraphQLList(new GraphQLNonNull(TaskEdgeType)),
            resolve(source, args, context, info) {
              return assertNonNull(
                defaultFieldResolver(source, args, context, info),
              );
            },
          },
        };
      },
    });
  const InstantiateOptionsType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "InstantiateOptions",
      fields() {
        return {
          fields: {
            name: "fields",
            type: new GraphQLList(new GraphQLNonNull(FieldInputType)),
          },
        };
      },
    });
  const TemplateConstraintOptionsType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "TemplateConstraintOptions",
      fields() {
        return {
          instantiate: {
            description: "Request eager instantiation of the given template.",
            name: "instantiate",
            type: InstantiateOptionsType,
          },
        };
      },
    });
  const GeofenceInputType: GraphQLInputObjectType = new GraphQLInputObjectType({
    name: "GeofenceInput",
    fields() {
      return {
        latitude: {
          name: "latitude",
          type: GraphQLString,
        },
        longitude: {
          name: "longitude",
          type: GraphQLString,
        },
        radius: {
          name: "radius",
          type: GraphQLFloat,
        },
      };
    },
  });
  const UpdateNameInputType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "UpdateNameInput",
      fields() {
        return {
          activatedAt: {
            name: "activatedAt",
            type: GraphQLString,
          },
          deactivatedAt: {
            name: "deactivatedAt",
            type: GraphQLString,
          },
          id: {
            name: "id",
            type: new GraphQLNonNull(GraphQLID),
          },
          languageId: {
            name: "languageId",
            type: new GraphQLNonNull(GraphQLID),
          },
          value: {
            name: "value",
            type: new GraphQLNonNull(GraphQLString),
          },
        };
      },
    });
  const UpdateLocationInputType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "UpdateLocationInput",
      fields() {
        return {
          activatedAt: {
            name: "activatedAt",
            type: GraphQLString,
          },
          deactivatedAt: {
            name: "deactivatedAt",
            type: GraphQLString,
          },
          geofence: {
            name: "geofence",
            type: GeofenceInputType,
          },
          id: {
            name: "id",
            type: new GraphQLNonNull(GraphQLID),
          },
          name: {
            name: "name",
            type: UpdateNameInputType,
          },
          scanCode: {
            name: "scanCode",
            type: GraphQLID,
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
          type: AdvanceTaskStateMachineResultType,
          args: {
            opts: {
              name: "opts",
              type: new GraphQLNonNull(AdvanceFsmOptionsType),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              mutationAdvanceResolver(source, context, args.opts),
            );
          },
        },
        applyFieldEdits: {
          name: "applyFieldEdits",
          type: TaskType,
          args: {
            edits: {
              name: "edits",
              type: new GraphQLNonNull(
                new GraphQLList(new GraphQLNonNull(FieldInputType)),
              ),
            },
            entity: {
              name: "entity",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              mutationApplyFieldEditsResolver(
                source,
                context,
                args.entity,
                args.edits,
              ),
            );
          },
        },
        attach: {
          name: "attach",
          type: new GraphQLList(new GraphQLNonNull(AttachmentEdgeType)),
          args: {
            attachments: {
              name: "attachments",
              type: new GraphQLNonNull(
                new GraphQLList(new GraphQLNonNull(URLType)),
              ),
            },
            entity: {
              name: "entity",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              mutationAttachResolver(
                source,
                args.entity,
                args.attachments,
                context,
              ),
            );
          },
        },
        createCustagAsFieldTemplateValueTypeConstraint: {
          name: "createCustagAsFieldTemplateValueTypeConstraint",
          type: EntityInstanceEdgeType,
          args: {
            field: {
              name: "field",
              type: new GraphQLNonNull(GraphQLID),
            },
            name: {
              name: "name",
              type: new GraphQLNonNull(GraphQLString),
            },
            order: {
              name: "order",
              type: GraphQLInt,
            },
            parent: {
              name: "parent",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(_source, args, context) {
            return assertNonNull(
              mutationCreateCustagAsFieldTemplateValueTypeConstraintResolver(
                context,
                args.field,
                args.name,
                args.parent,
                args.order,
              ),
            );
          },
        },
        createInstance: {
          name: "createInstance",
          type: CreateInstancePayloadType,
          args: {
            fields: {
              name: "fields",
              type: new GraphQLList(new GraphQLNonNull(FieldInputType)),
            },
            location: {
              name: "location",
              type: new GraphQLNonNull(GraphQLID),
            },
            name: {
              name: "name",
              type: GraphQLString,
            },
            template: {
              name: "template",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(_source, args, context) {
            return assertNonNull(mutationCreateInstanceResolver(args, context));
          },
        },
        createLocation: {
          name: "createLocation",
          type: LocationType,
          args: {
            input: {
              name: "input",
              type: new GraphQLNonNull(CreateLocationInputType),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              mutationCreateLocationResolver(source, context, args.input),
            );
          },
        },
        createTemplateConstraint: {
          description:
            "Template constraints allow you to limit the set of values that are valid for\na given template and, optionally, field. Practically, this allows you to\ndefine *enumerations*, e.g. a \"string enum\" with members 'foo', 'bar' and 'baz'.\n\nNote that currently constraints are *not* validated in the backend.\nValidation *should* happen on the client, prior to invoking the API.\nOtherwise, the backend willl gladly accept any arbitrary value (assuming, of\ncourse, that it is of the correct type).",
          deprecationReason: "No longer supported",
          name: "createTemplateConstraint",
          type: CreateTemplateConstraintResultType,
          args: {
            entity: {
              name: "entity",
              type: new GraphQLNonNull(GraphQLID),
            },
            options: {
              name: "options",
              type: TemplateConstraintOptionsType,
            },
            template: {
              name: "template",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              mutationCreateTemplateConstraintResolver(
                source,
                context,
                args.template,
                args.entity,
                args.options,
              ),
            );
          },
        },
        deleteNode: {
          description:
            "Delete a Node.\nThis operation is a no-op if the node has already been deleted.",
          name: "deleteNode",
          type: new GraphQLList(new GraphQLNonNull(GraphQLID)),
          args: {
            node: {
              name: "node",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(_source, args, context) {
            return assertNonNull(
              mutationDeleteNodeResolver(args.node, context),
            );
          },
        },
        rebase: {
          description:
            "Rebase a Task onto another (Task) chain.\nThe net effect of this mutation is that the Task identified by `node` will\nhave its root (`Task.root`) set to the Task identified by `base`.",
          name: "rebase",
          type: TaskType,
          args: {
            base: {
              name: "base",
              type: new GraphQLNonNull(GraphQLID),
            },
            node: {
              name: "node",
              type: new GraphQLNonNull(GraphQLID),
            },
          },
          resolve(_source, args, context) {
            return assertNonNull(mutationRebaseResolver(args, context));
          },
        },
        updateLocation: {
          name: "updateLocation",
          type: LocationType,
          args: {
            input: {
              name: "input",
              type: new GraphQLNonNull(UpdateLocationInputType),
            },
          },
          resolve(source, args, context) {
            return assertNonNull(
              mutationUpdateLocationResolver(source, args.input, context),
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
  const ClosedInputType: GraphQLInputObjectType = new GraphQLInputObjectType({
    name: "ClosedInput",
    fields() {
      return {
        closedAt: {
          name: "closedAt",
          type: TimestampType,
        },
        closedBecause: {
          name: "closedBecause",
          type: GraphQLString,
        },
        closedBy: {
          name: "closedBy",
          type: GraphQLID,
        },
        inProgressAt: {
          name: "inProgressAt",
          type: TimestampType,
        },
        inProgressBy: {
          name: "inProgressBy",
          type: GraphQLID,
        },
        openedAt: {
          name: "openedAt",
          type: TimestampType,
        },
        openedBy: {
          name: "openedBy",
          type: GraphQLID,
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
  const DescriptionInputType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "DescriptionInput",
      fields() {
        return {
          id: {
            name: "id",
            type: GraphQLID,
          },
          value: {
            name: "value",
            type: new GraphQLNonNull(DynamicStringInputType),
          },
        };
      },
    });
  const FieldDefinitionInputType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "FieldDefinitionInput",
      fields() {
        return {
          description: {
            name: "description",
            type: GraphQLString,
          },
          isDraft: {
            name: "isDraft",
            type: GraphQLBoolean,
          },
          isPrimary: {
            name: "isPrimary",
            type: GraphQLBoolean,
          },
          name: {
            name: "name",
            type: new GraphQLNonNull(GraphQLString),
          },
          order: {
            name: "order",
            type: GraphQLInt,
          },
          referenceType: {
            name: "referenceType",
            type: GraphQLString,
          },
          type: {
            name: "type",
            type: new GraphQLNonNull(ValueTypeType),
          },
          value: {
            name: "value",
            type: ValueInputType,
          },
          widget: {
            name: "widget",
            type: GraphQLString,
          },
        };
      },
    });
  const InProgressInputType: GraphQLInputObjectType =
    new GraphQLInputObjectType({
      name: "InProgressInput",
      fields() {
        return {
          inProgressAt: {
            name: "inProgressAt",
            type: TimestampType,
          },
          inProgressBy: {
            name: "inProgressBy",
            type: GraphQLID,
          },
          openedAt: {
            name: "openedAt",
            type: TimestampType,
          },
          openedBy: {
            name: "openedBy",
            type: GraphQLID,
          },
        };
      },
    });
  const OpenInputType: GraphQLInputObjectType = new GraphQLInputObjectType({
    name: "OpenInput",
    fields() {
      return {
        openedAt: {
          name: "openedAt",
          type: TimestampType,
        },
        openedBy: {
          name: "openedBy",
          type: GraphQLID,
        },
      };
    },
  });
  const TaskStateInputType: GraphQLInputObjectType = new GraphQLInputObjectType(
    {
      name: "TaskStateInput",
      fields() {
        return {
          closed: {
            name: "closed",
            type: ClosedInputType,
          },
          inProgress: {
            name: "inProgress",
            type: InProgressInputType,
          },
          open: {
            name: "open",
            type: OpenInputType,
          },
        };
      },
      isOneOf: true,
    },
  );
  return new GraphQLSchema({
    query: QueryType,
    mutation: MutationType,
    types: [
      LocaleType,
      TimestampType,
      URLType,
      DiagnosticKindType,
      TaskStateNameType,
      ValueTypeType,
      TaskStateType,
      ValueType,
      AssignableType,
      ComponentType,
      IdentityType,
      NodeType,
      TrackableType,
      AdvanceFsmOptionsType,
      AdvanceTaskOptionsType,
      AssignmentInputType,
      ClosedInputType,
      CreateLocationInputType,
      DescriptionInputType,
      DynamicStringInputType,
      FieldDefinitionInputType,
      FieldInputType,
      GeofenceInputType,
      InProgressInputType,
      InstantiateOptionsType,
      OpenInputType,
      TaskStateInputType,
      TemplateConstraintOptionsType,
      UpdateLocationInputType,
      UpdateNameInputType,
      ValueInputType,
      AdvanceTaskStateMachineResultType,
      AggregateType,
      AssignmentType,
      AssignmentConnectionType,
      AssignmentEdgeType,
      AttachmentType,
      AttachmentConnectionType,
      AttachmentEdgeType,
      BooleanValueType,
      ClosedType,
      CreateInstancePayloadType,
      CreateTemplateConstraintResultType,
      DescriptionType,
      DiagnosticType,
      DisplayNameType,
      DynamicStringType,
      EntityInstanceType,
      EntityInstanceConnectionType,
      EntityInstanceEdgeType,
      EntityTemplateType,
      EntityTemplateConnectionType,
      EntityTemplateEdgeType,
      EntityValueType,
      FieldType,
      FieldConnectionType,
      FieldEdgeType,
      InProgressType,
      LocationType,
      MutationType,
      NumberValueType,
      OpenType,
      PageInfoType,
      QueryType,
      StringValueType,
      TaskType,
      TaskConnectionType,
      TaskEdgeType,
      TaskStateMachineType,
      TaskTransitionType,
      TaskTransitionsType,
      TemplateConstraintType,
      TimestampOverridableType,
      TimestampOverrideType,
      TimestampValueType,
      TrackableConnectionType,
      TrackableEdgeType,
      ValueCompletionType,
      ValueCompletionConnectionType,
      ValueCompletionEdgeType,
    ],
  });
}
