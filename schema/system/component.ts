import { sql } from "@/datasources/postgres";
import { assertNonNull, buildPaginationArgs, mapOrElse } from "@/util";
import type { ID, Int } from "grats";
import type { Fragment } from "postgres";
import { decodeGlobalId } from ".";
import {
  Attachment,
  type ConstructorArgs as AttachmentConstructorArgs,
} from "../platform/attachment";
import type { Context } from "../types";
import { DisplayName } from "./component/name";
import type { Connection, Edge, PageInfo } from "./pagination";
import type { Timestamp } from "./temporal";

/**
 * Components characterize Entities as possessing a particular trait.
 * They are just simple structs, holding all data necessary to model that trait.
 *
 * @gqlInterface
 */
export interface Component {
  readonly __typename: string;

  /**
   * @gqlField
   * @killsParentOnException
   */
  readonly id: ID;
}

export const field$fragment: Fragment = sql`
select
    f._name,
    f.id,
    case
        when f.type = 'Boolean'
        then
            jsonb_build_object(
                '__typename', 'BooleanValue', 'boolean', f.value::boolean
            )
        when f.type = 'Date'
        then
            jsonb_build_object(
                '__typename', 'TimestampValue', 'timestamp', f.value::timestamptz
            )
        when f.type = 'Number'
        then
            jsonb_build_object(
                '__typename', 'NumberValue', 'number', f.value::numeric
            )
        when f.type = 'String'
        then
            jsonb_build_object(
                '__typename', 'StringValue', 'string', f.value
            )
        else '{}'::jsonb
    end as value,
    case
        when f.type = 'Boolean' then 'boolean'
        when f.type = 'Date' then 'timestamp'
        when f.type = 'Number' then 'number'
        when f.type = 'String' then 'string'
        else 'unknown'
    end as "valueType"
from field as f
`;

/** @gqlType */
export type Field = {
  _name: ID;

  /**
   * Unique identifier for this Field.
   *
   * @gqlField
   */
  id: ID;

  /**
   * The value for this Field, if any. This field will always be present (when
   * requested) for the given Field so as to convey the underlying data type of
   * the (raw data) value. The underlying (raw data) value can be `null`.
   *
   * @gqlField
   */
  value: Value;

  /**
   * The type of data underlying `value`. This is provided as a convenience when
   * interacting with field-level edits through other apis.
   *
   * @gqlField
   */
  valueType: ValueType;
};

/**
 * Field attachments.
 *
 * @gqlField
 */
export async function attachments(
  f: Field,
  ctx: Context,
  args: {
    first?: Int | null;
    last?: Int | null;
    before?: string | null;
    after?: string | null;
  },
): Promise<Connection<Attachment>> {
  const { type, id, suffix } = decodeGlobalId(f.id);
  // Only instances can have attachments.
  if (type !== "workresultinstance") {
    return {
      edges: [],
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: 0,
    };
  }

  const p = buildPaginationArgs(args, {
    defaultLimit: ctx.limits.fieldAttachmentPaginationDefaultLimit,
    maxLimit: ctx.limits.fieldAttachmentPaginationMaxLimit,
  });
  const rows = await sql<AttachmentConstructorArgs[]>`
    select
        encode(('workpictureinstance:' || a.workpictureinstanceuuid)::bytea, 'base64') as id,
        a.workpictureinstancestoragelocation as url
    from public.workresultinstance as field
    inner join public.workpictureinstance as a
        on field.workresultinstanceworkinstanceid = a.workpictureinstanceworkinstanceid
        and field.workresultinstanceid = a.workpictureinstanceworkresultinstanceid
    where
        field.workresultinstanceworkinstanceid = (
            select workinstanceid
            from public.workinstance
            where id = ${id}
        )
        and field.workresultinstanceworkresultid = (
            select workresultid
            from public.workresult
            where id = ${assertNonNull(suffix?.at(0), "invariant violated")}
        )
        ${mapOrElse(
          p.cursor,
          cursor => sql`
        and
            (a.workpictureinstancemodifieddate, a.workpictureinstanceid)
            ${p.direction === "forward" ? sql`<` : sql`>`}
            (
                select c.workpictureinstancemodifieddate, c.workpictureinstanceid
                from public.workpictureinstance as c
                where c.workpictureinstanceuuid = ${cursor.id}
            )
          `,
          sql``,
        )}
    order by a.workpictureinstancemodifieddate desc, a.workpictureinstanceid desc
    limit ${p.limit + 1};
  `;

  const n1 = rows.length > p.limit ? rows.pop() : undefined;
  const edges: Edge<Attachment>[] = rows.map(row => ({
    cursor: row.id,
    node: new Attachment(row, ctx),
  }));
  const pageInfo: PageInfo = {
    startCursor: edges.at(0)?.cursor,
    endCursor: edges.at(-1)?.cursor,
    hasNextPage: p.direction === "forward" && !!n1,
    hasPreviousPage: p.direction === "backward" && !!n1,
  };

  const [{ count }] = await sql<[{ count: bigint }]>`
    select count(*)
    from public.workresultinstance as field
    inner join public.workpictureinstance as a
        on field.workresultinstanceworkinstanceid = a.workpictureinstanceworkinstanceid
        and field.workresultinstanceid = a.workpictureinstanceworkresultinstanceid
    where
        field.workresultinstanceworkinstanceid = (
            select workinstanceid
            from public.workinstance
            where id = ${id}
        )
        and field.workresultinstanceworkresultid = (
            select workresultid
            from public.workresult
            where id = ${assertNonNull(suffix?.at(0), "invariant violated")}
        )
  `;

  return {
    edges,
    pageInfo,
    totalCount: Number(count),
  };
}

/**
 * Display name for a Field.
 *
 * @gqlField
 */
export function name(field: Field): DisplayName {
  return new DisplayName(field._name);
}

/** @gqlInput */
export type FieldInput = {
  field: ID;
  value?: ValueInput | null;
  /**
   * Must match the type of the `value`, e.g.:
   * ```typescript
   * if (field.valueType === "string") {
   *   assert("string" in field.value);
   * }
   * ```
   */
  valueType: ValueType;
};

/** @gqlEnum */
export type ValueType =
  | "boolean"
  | "entity"
  | "number"
  | "string"
  | "timestamp"
  /** For backwards compatibility. */
  | "unknown";

/** @gqlUnion */
export type Value =
  | BooleanValue
  | EntityValue
  | NumberValue
  | StringValue
  | TimestampValue;

/** @gqlType */
type BooleanValue = {
  __typename: "BooleanValue";

  /** @gqlField */
  boolean: boolean | null;
};

/** @gqlType */
type EntityValue = {
  __typename: "EntityValue";

  /** @gqlField */
  entity: Component | null;
};

/** @gqlType */
type NumberValue = {
  __typename: "NumberValue";

  /** @gqlField */
  number: Int | null;
};

/** @gqlType */
type StringValue = {
  __typename: "StringValue";

  /** @gqlField */
  string: string | null;
};

/** @gqlType */
type TimestampValue = {
  __typename: "TimestampValue";

  /** @gqlField */
  timestamp: Timestamp | null;
};

/**
 * @gqlInput
 * @oneOf
 */
export type ValueInput =
  // Boolean
  | {
      boolean: boolean;
    }
  // Entity
  | {
      id: ID;
    }
  // Number
  | {
      number: Int;
    }
  // String
  | {
      string: string;
    }
  // Temporal
  | {
      /**
       * Date in either ISO or epoch millisecond format.
       */
      timestamp: string;
    };
