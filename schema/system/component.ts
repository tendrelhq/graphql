import { sql } from "@/datasources/postgres";
import type { ID, Int } from "grats";
import type { Fragment } from "postgres";
import { DisplayName } from "./component/name";
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
