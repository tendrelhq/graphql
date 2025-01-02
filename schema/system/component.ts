import { sql } from "@/datasources/postgres";
import type { ID, Int } from "grats";
import { match } from "ts-pattern";
import { decodeGlobalId } from ".";
import type { Context } from "../types";
import { DisplayName } from "./component/name";
import type { Task } from "./component/task";
import type { Connection } from "./pagination";
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

/**
 * TODO: description.
 *
 * @gqlField
 */
export async function fields(
  parent: Task,
  ctx: Context,
): Promise<Connection<Field>> {
  const { type, id } = decodeGlobalId(parent.id);

  if (type !== "workinstance" && type !== "worktemplate") {
    console.warn(`Underlying type '${type}' does not support fields`);
    return {
      edges: [],
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: 0,
    };
  }

  const rows = await match(type)
    .with(
      "workinstance",
      () => sql<{ _name: string; id: string; value: object }[]>`
        WITH field AS (
            SELECT
                encode(('workresultinstance:' || wi.id || ':' || wr.id)::bytea, 'base64') AS id,
                encode(('name:' || n.languagemasteruuid)::bytea, 'base64') AS "_name",
                wi.workinstanceid AS _id,
                wr.workresultid AS _field,
                wr.workresultdefaultvalue AS default_value,
                t.systagtype AS type
            FROM public.workinstance AS wi
            INNER JOIN public.workresult AS wr
                ON wi.workinstanceworktemplateid = wr.workresultworktemplateid
                   and (wr.workresultenddate is null or wr.workresultenddate > now())
                   and (
                      wr.workresultisprimary = false
                      or (
                          wr.workresultisprimary = true
                          and wr.workresultentitytypeid is null
                      )
                   )
            INNER JOIN public.languagemaster AS n
                ON wr.workresultlanguagemasterid = n.languagemasterid
            INNER JOIN public.systag AS t
                ON wr.workresulttypeid = t.systagid
            WHERE wi.id = ${id}
            ORDER BY wr.workresultorder ASC
        )

        SELECT
            f._name,
            f.id,
            CASE
                WHEN f.type = 'Boolean' THEN jsonb_build_object(
                    '__typename', 'BooleanValue',
                    'boolean', coalesce(wri.workresultinstancevalue::boolean, f.default_value::boolean)
                )
                WHEN f.type = 'Date' THEN jsonb_build_object(
                    '__typename', 'TimestampValue',
                    'timestamp', coalesce(
                        wri.workresultinstancevalue::timestamptz,
                        f.default_value::timestamptz
                    )
                )
                WHEN f.type = 'Number' THEN jsonb_build_object(
                    '__typename', 'NumberValue',
                    'number', coalesce(wri.workresultinstancevalue::numeric, f.default_value::numeric)
                )
                WHEN f.type = 'String' THEN jsonb_build_object(
                    '__typename', 'StringValue',
                    'string', coalesce(wri.workresultinstancevalue, f.default_value)
                )
                ELSE '{}'::jsonb
            END AS value
        FROM field AS f
        LEFT JOIN public.workresultinstance AS wri
            ON (f._id, f._field) = (wri.workresultinstanceworkinstanceid, wri.workresultinstanceworkresultid)
      `,
    )
    .with(
      "worktemplate",
      () => sql<{ _name: string; id: string; value: object }[]>`
        WITH field AS (
            SELECT
                encode(('workresult:' || wr.id)::bytea, 'base64') AS id,
                encode(('name:' || n.languagemasteruuid)::bytea, 'base64') AS "_name",
                wr.workresultid AS _field,
                wr.workresultdefaultvalue AS default_value,
                t.systagtype AS type
            FROM public.worktemplate AS wt
            INNER JOIN public.workresult AS wr
                ON wt.worktemplateid = wr.workresultworktemplateid
                   and (wr.workresultenddate is null or wr.workresultenddate > now())
                   and (
                      wr.workresultisprimary = false
                      or (
                          wr.workresultisprimary = true
                          and wr.workresultentitytypeid is null
                      )
                   )
            INNER JOIN public.languagemaster AS n
                ON wr.workresultlanguagemasterid = n.languagemasterid
            INNER JOIN public.systag AS t
                ON wr.workresulttypeid = t.systagid
            WHERE wt.id = ${id}
            ORDER BY wr.workresultorder ASC
        )

        SELECT
            f._name,
            f.id,
            CASE
                WHEN f.type = 'Boolean' THEN jsonb_build_object(
                    '__typename', 'BooleanValue',
                    'boolean', f.default_value::boolean
                )
                WHEN f.type = 'Date' THEN jsonb_build_object(
                    '__typename', 'TimestampValue',
                    'timestamp', f.default_value::timestamptz
                )
                WHEN f.type = 'Number' THEN jsonb_build_object(
                    '__typename', 'NumberValue',
                    'number', f.default_value::numeric
                )
                WHEN f.type = 'String' THEN jsonb_build_object(
                    '__typename', 'StringValue',
                    'string', f.default_value::text
                )
                ELSE '{}'::jsonb
            END AS value
        FROM field AS f
      `,
    )
    //
    .otherwise((_: never) => []);

  return {
    edges: rows.map(row => ({ cursor: row.id, node: row as Field })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: rows.length,
  };
}

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
  value: ValueInput;
};

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
      boolean: boolean | null;
    }
  // Entity
  | {
      id: ID | null;
    }
  // Number
  | {
      number: Int | null;
    }
  // String
  | {
      string: string | null;
    }
  // Temporal
  | {
      /**
       * Date in either ISO or epoch millisecond format.
       */
      timestamp: string | null;
    };
