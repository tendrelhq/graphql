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
import { attachedBy as attachmentAttachedByResolver } from "./platform/attachment";
import { attach as mutationAttachResolver } from "./platform/attachment";
import { trackables as queryTrackablesResolver } from "./platform/tracking";
import { attachments as fieldAttachmentsResolver } from "./system/component";
import { name as fieldNameResolver } from "./system/component";
import { assignees as taskAssigneesResolver } from "./system/component/task";
import { attachments as taskAttachmentsResolver } from "./system/component/task";
import { chain as taskChainResolver } from "./system/component/task";
import { chainAgg as taskChainAggResolver } from "./system/component/task";
import { fields as taskFieldsResolver } from "./system/component/task";
import { applyFieldEdits as mutationApplyFieldEditsResolver } from "./system/component/task";
import { fsm as taskFsmResolver } from "./system/component/task_fsm";
import { advance as mutationAdvanceResolver } from "./system/component/task_fsm";
import { node as queryNodeResolver } from "./system/node";
import { id as assignmentIdResolver } from "./system/node";
import { id as attachmentIdResolver } from "./system/node";
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
          resolve(source, args, context) {
            return assertNonNull(
              queryTrackablesResolver(
                source,
                context,
                args.first,
                args.parent,
                args.includeInactive,
                args.withImplementation,
              ),
            );
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
      };
    },
  });
  const TimestampType: GraphQLScalarType = new GraphQLScalarType({
    description: "A date-time string in ISO 8601 format.",
    name: "Timestamp",
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
            "The group, or bucket, that uniquely identifies this aggregate.\nFor example, this will be one of the `groupByTag`s passed to `trackingAgg`.",
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
            'The computed aggregate value.\n\nCurrently, this will always be a string value representing a duration in\nseconds, e.g. "360" -> 360 seconds. `null` will be returned when no such\naggregate can be computed, e.g. "time in planned downtime" when no "planned\ndowntime" events exist.',
          name: "value",
          type: GraphQLString,
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
        name: {
          description: "Display name for a Field.",
          name: "name",
          type: DisplayNameType,
          resolve(source) {
            return assertNonNull(fieldNameResolver(source));
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
          resolve(source, args, context) {
            return assertNonNull(
              taskChainResolver(source, context, args.first),
            );
          },
        },
        chainAgg: {
          description:
            'Given a Task identifying as a node in a chain, create an aggregate view of\nsaid chain over the type tags given in `overType`. The result is a set of\naggregates representing the *sum total duration* of nodes tagged with any of\nthe given `overType` tags, *including* the given Task (if it is so tagged).\n\nColloquially: `chainAgg(overType: ["Foo", "Bar"])` will compute the total\ntime spent in all "Foo" or "Bar" tasks in the given chain;\n\n```json\n[\n  {\n    "group": "Foo",\n    "value": "26.47", // 26.47 seconds spent doing "Foo" tasks\n  },\n  {\n    "group": "Bar",\n    "value": "5.82", // 5.82 seconds spent doing "Bar" tasks\n  },\n]\n```',
          name: "chainAgg",
          type: new GraphQLList(new GraphQLNonNull(AggregateType)),
          args: {
            overType: {
              description:
                "Which sub-type-hierarchies you are interested in aggregating over.",
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
        parent: {
          description:
            "Identifies the parent of the current Task.\n\nThis is different from previous. Previous models causality, parent models\nownership. In practice, the parent of a Task will always be a Location.\nNote that currently this only supports workinstances. Tasks whose underlying\ntype is a worktemplate will **always have a null parent**.",
          name: "parent",
          type: NodeType,
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
          description: "Date in either ISO or epoch millisecond format.",
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
            'Must match the type of the `value`, e.g.:\n```typescript\nif (field.valueType === "string") {\n  assert("string" in field.value);\n}\n```',
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
          },
          resolve(source, args) {
            return assertNonNull(source.tracking(args.first, args.after));
          },
        },
      };
    },
    interfaces() {
      return [ComponentType, NodeType, TrackableType];
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
            name: "timeZone",
            type: new GraphQLNonNull(GraphQLString),
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
  return new GraphQLSchema({
    query: QueryType,
    mutation: MutationType,
    types: [
      LocaleType,
      TimestampType,
      URLType,
      DiagnosticKindType,
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
      CreateLocationInputType,
      DynamicStringInputType,
      FieldInputType,
      GeofenceInputType,
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
      DiagnosticType,
      DisplayNameType,
      DynamicStringType,
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
      TimestampOverridableType,
      TimestampOverrideType,
      TimestampValueType,
      TrackableConnectionType,
      TrackableEdgeType,
    ],
  });
}
