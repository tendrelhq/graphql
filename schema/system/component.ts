import { sql } from "@/datasources/postgres";
import { GraphQLError } from "graphql";
import type { Float, ID, Int } from "grats";
import { match } from "ts-pattern";
import { decodeGlobalId } from ".";
import type { Context } from "../types";
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
  parent: Component,
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
      () => sql`
        WITH fields AS (
            SELECT
                encode(('workresultinstance:' || wi.id || ':' || wr.id)::bytea, 'base64') AS id,
                wi.id AS _id,
                wr.id AS _field,
                wr.workresultdefaultvalue AS default_value,
                t.systagtype AS value_type
            FROM public.workinstance AS wi
            INNER JOIN public.workresult AS wr
                ON wi.workinstanceworktemplateid = wr.workresultworktemplateid
                   AND (wr.workresultenddate IS null OR wr.workresultenddate > now())
            INNER JOIN public.systag AS t
                ON wi.workresulttypeid = t.systagid
            WHERE wi.id = ${id}
        )

        SELECT
            f.id,
            coalesce(wri.workresultinstancevalue, f.default_value) AS value
        FROM fields AS f
        LEFT JOIN public.workresultinstance AS wri
            ON (f._id, f._field) = (wri.workresultinstanceworkinstanceid, wri.workresultinstanceworkresultid)
      `,
    )
    .with(
      "worktemplate",
      () => sql`
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
  /** @gqlField */
  id: ID;
  /** @gqlField */
  value?: Value | null;
};

/** @gqlInput */
export type FieldInput = {
  field: ID;
  value?: ValueInput | null;
};

/** @gqlUnion */
export type Value =
  | BooleanValue
  | EntityValue
  | IntegerValue
  | DecimalValue
  | StringValue
  | DurationValue
  | TimestampValue;

/** @gqlType */
class BooleanValue {
  __typename = "BooleanValue" as const;

  constructor(
    /** @gqlField boolean */
    public readonly value: boolean,
  ) {}
}

/** @gqlType */
class EntityValue {
  __typename = "EntityValue" as const;

  constructor(
    /** @gqlField entity */
    public readonly value: Component,
  ) {}
}

/** @gqlType */
class IntegerValue {
  __typename = "IntegerValue" as const;

  constructor(
    /** @gqlField integer */
    public readonly value: Int,
  ) {}
}

/** @gqlType */
class DecimalValue {
  __typename = "DecimalValue" as const;

  constructor(
    /** @gqlField decimal */
    public readonly value: Float,
  ) {}
}

/** @gqlType */
class StringValue {
  __typename = "StringValue" as const;

  constructor(
    /** @gqlField string */
    public readonly value: string,
  ) {}
}

/** @gqlType */
class DurationValue {
  __typename = "DurationValue" as const;

  constructor(
    /** @gqlField duration */
    public readonly value: string,
  ) {}
}

/** @gqlType */
class TimestampValue {
  __typename = "TimestampValue" as const;

  constructor(
    /** @gqlField timestamp */
    public readonly value: Timestamp,
  ) {}
}

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
      integer: Int;
    }
  | {
      decimal: Float;
    }
  // String
  | {
      string: string;
    }
  // Temporal
  | {
      /**
       * Duration in either ISO or millisecond format.
       */
      duration: string;
    }
  | {
      /**
       * Timestamp in either ISO or epoch millisecond format.
       */
      timestamp: string;
    };
