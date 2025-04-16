import { sql } from "@/datasources/postgres";
import { assert, assertNonNull, buildPaginationArgs, mapOrElse } from "@/util";
import { GraphQLError } from "graphql";
import type { ID, Int } from "grats";
import type { Fragment } from "postgres";
import { match } from "ts-pattern";
import { decodeGlobalId } from ".";
import {
  Attachment,
  type ConstructorArgs as AttachmentConstructorArgs,
} from "../platform/attachment";
import type { Context } from "../types";
import type { Description } from "./component/description";
import type { DisplayName } from "./component/name";
import { type ConstructorArgs, Task } from "./component/task";
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
                '__typename', 'TimestampValue', 'timestamp', to_timestamp(f.value::bigint / 1000.0)
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

/** @gqlType */
export type ValueCompletion = {
  /** @gqlField */
  value: Value;
};

/**
 * Intended to provide "auto-completion" in a frontend setting, this API returns
 * *distinct known values* for a given Field. For Fields without constraints
 * (which is most of them), this will return a "frecency" list of previously
 * used values for the given Field. When constraints are involved, the
 * completion list represents the *allowed* set of values for the given Field.
 *
 * Note that "frecency" is not currently implemented. For such Fields (i.e. those
 * without constraints) you will simply get back an empty completion list.
 *
 * Note also that currently there is no enforcement of the latter, constraint-based
 * semantic in the backend! The client *must* validate user input using the
 * completion list *before* issuing, for example, an `applyFieldEdits` mutation.
 * Otherwise the backend will gladly accept arbitrary values (assuming they are,
 * of course, of the correct type).
 *
 * Note also that pagination is not currently implemented.
 *
 * @gqlField
 */
export async function completions(
  f: Field,
  ctx: Context,
): Promise<Connection<ValueCompletion>> {
  const { type, id, suffix } = decodeGlobalId(f.id);
  // FIXME: we aren't using worktemplateconstraintconstrainedtypeid here.
  // This feels like a gap. Although in the ideal model result type would inform
  // our choice of algorithm: frecency vs constraint.
  // TODO: localization.
  const cte = match(type)
    .with(
      "workresult",
      () => sql`
        select
          ''::text as id, -- unused, purely for fragment reuse
          s.systagtype as "type",
          c.custagtype as "value"
        from public.workresult as wr
        inner join public.worktemplate as wt
          on wr.workresultworktemplateid = wt.worktemplateid
        inner join public.systag as s
          on wr.workresulttypeid = s.systagid
        inner join public.worktemplateconstraint as wtc
          on wt.id = wtc.worktemplateconstrainttemplateid
          and wr.id = wtc.worktemplateconstraintresultid
        inner join public.custag as c
          on wtc.worktemplateconstraintconstraintid = c.custaguuid
          and (c.custagenddate is null or c.custagenddate > now())
        where wr.id = ${id}
        order by c.custagorder asc
      `,
    )
    .with("workresultinstance", () => {
      const instance = id; // workinstanceuuid
      const field = assertNonNull(suffix?.at(0), "invalid global identifier"); // workresultuuid
      return sql`
        select
          ''::text as id, -- unused, purely for fragment reuse
          s.systagtype as "type",
          c.custagtype as "value"
        from public.workinstance as wi
        inner join public.worktemplate as wt
          on wi.workinstanceworktemplateid = wt.worktemplateid
        inner join public.workresult as wr
          on wt.worktemplateid = wr.workresultworktemplateid
          and wr.id = ${field}
        inner join public.systag as s
          on wr.workresulttypeid = s.systagid
        inner join public.worktemplateconstraint as wtc
          on wt.id = wtc.worktemplateconstrainttemplateid
          and wr.id = wtc.worktemplateconstraintresultid
        inner join public.custag as c
          on wtc.worktemplateconstraintconstraintid = c.custaguuid
          and (c.custagenddate is null or c.custagenddate > now())
        where wi.id = ${instance}
        order by c.custagorder asc
      `;
    })
    .otherwise(() => {
      throw "";
    });

  const rows = await sql<ValueCompletion[]>`
    with field as (${cte})
    ${field$fragment}
  `;

  return {
    edges: rows.map(row => ({ node: row, cursor: "" })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: rows.length,
  };
}

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
 * Description of a Field.
 *
 * @gqlField
 */
export async function description(
  field: Field,
  ctx: Context,
): Promise<Description | null> {
  return await ctx.orm.description.load(field.id);
}

/**
 * Display name for a Field.
 *
 * @gqlField
 */
export async function name(field: Field, ctx: Context): Promise<DisplayName> {
  return await ctx.orm.displayName.load(field.id);
}

/** @gqlField */
export async function parent(field: Field): Promise<Task> {
  const { type, id } = decodeGlobalId(field.id);
  const [row] = await match(type)
    .with(
      "workresult",
      () => sql<[ConstructorArgs]>`
        select engine1.base64_encode(convert_to('worktemplate:' || id, 'utf8')) as id
        from public.worktemplate
        where worktemplateid in (
          select workresultworktemplateid
          from public.workresult
          where id = ${id}
        )
      `,
    )
    .with(
      "workresultinstance",
      () => sql<[ConstructorArgs]>`
        select engine1.base64_encode(convert_to('workinstance:' || id, 'utf8')) as id
        from public.workinstance
        where id = ${id}
      `,
    )
    .otherwise(() => {
      throw "invariant violated";
    });

  return new Task(row);
}

export type FieldDefinitionInput = {
  name: string;
  type: string;
  description?: string | null;
  isDraft?: boolean | null;
  isPrimary?: boolean | null;
  order?: number | null;
  referenceType?: string | null;
  value?: ValueInput | null;
  widget?: string | null;
};

/** @gqlInput */
export type FieldInput = {
  field: ID;
  value?: ValueInput | null;
  /**
   * Must match the type of the `value`, e.g.
   * ```typescript
   * if (field.valueType === "string") {
   *   assert(field.value === null || "string" in field.value);
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
  // Timestamp
  | {
      /**
       * ISO 8601 format.
       */
      timestamp: string;
    };
