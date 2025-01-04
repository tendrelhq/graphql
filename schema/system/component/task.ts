import { sql } from "@/datasources/postgres";
import {
  Location,
  type ConstructorArgs as LocationConstructorArgs,
} from "@/schema/platform/archetype/location";
import type { Trackable } from "@/schema/platform/tracking";
import type { Context } from "@/schema/types";
import { assert, assertNonNull, map } from "@/util";
import { GraphQLError } from "graphql/error";
import type { ID, Int } from "grats";
import type { Fragment } from "postgres";
import { match } from "ts-pattern";
import { decodeGlobalId } from "..";
import type { Aggregate } from "../aggregation";
import type { Component, FieldInput } from "../component";
import type { Refetchable } from "../node";
import type { Overridable } from "../overridable";
import type { Connection } from "../pagination";
import type { Timestamp } from "../temporal";
import { type Assignable, Assignment } from "./assignee";
import type { DisplayName, Named } from "./name";

export type ConstructorArgs = {
  id: ID;
};

/**
 * A system-level component that identifies an Entity as being applicable to
 * tendrel's internal "task processing pipeline". In practice, Tasks most often
 * represent "jobs" performed by humans. However, this need not always be the
 * case.
 *
 * Technically speaking, a Task represents a (1) *named asynchronous process*
 * that (2) exists in one of three states: open, in progress, or closed.
 *
 * @gqlType
 */
export class Task
  implements Assignable, Component, Named, Refetchable, Trackable
{
  readonly __typename = "Task" as const;
  readonly _type: string;
  readonly _id: string;
  readonly id: ID;

  constructor(
    args: ConstructorArgs,
    private ctx: Context,
  ) {
    // Note that Postgres will sometimes add newlines when we `encode(...)`.
    this.id = args.id.replace(/\n/g, "");
    // Private.
    const g = decodeGlobalId(this.id);
    this._type = g.type;
    this._id = g.id;
  }

  /** @gqlField */
  async displayName(): Promise<DisplayName> {
    return await this.ctx.orm.displayName.load(this.id);
  }

  /**
   * Identifies the parent of the current Task.
   *
   * This is different from previous. Previous models causality, parent models
   * ownership. In practice, the parent of a Task will always be a Location.
   * Note that currently this only supports workinstances. Tasks whose underlying
   * type is a worktemplate will **always have a null parent**.
   *
   * @gqlField
   */
  async parent(): Promise<Refetchable | null> {
    // We just punt on the worktemplate case for now.
    if (this._type !== "workinstance") return null;

    // We are primarily solving for the history screen at the moment anyways
    // which operates solely on workinstances. As we know, instances are really
    // just a template + a location (at least under our current world view).

    const [row] = await sql<[LocationConstructorArgs?]>`
      with parent as materialized (
          select wri.workresultinstancevalue::bigint as _id
          from public.workresultinstance as wri
          inner join public.workresult as wr
              on wri.workresultinstanceworkresultid = wr.workresultid
          where
              wri.workresultinstanceworkinstanceid in (
                  select wi.workinstanceid
                  from public.workinstance as wi
                  where wi.id = ${this._id}
              )
              and wr.workresulttypeid = (
                  select systagid
                  from public.systag
                  where systagparentid = 699 and systagtype = 'Entity'
              )
              and wr.workresultentitytypeid = (
                  select systagid
                  from public.systag
                  where systagparentid = 849 and systagtype = 'Location'
              )
              and wr.workresultisprimary = true
      )
      select encode(('location:' || l.locationuuid)::bytea, 'base64') as id
      from parent
      inner join public.location as l
          on parent._id = l.locationid
    `;

    if (!row) return null;

    return new Location(row, this.ctx);
  }

  // FIXME: We should probably implement this as a StateMachine<TaskState>?
  // This would allow the frontend to disambiguate start vs end, i.e. not have
  // to infer the valid action(s) based on the TaskState.
  /** @gqlField */
  async state(): Promise<TaskState | null> {
    // Only workinstances have statuses.
    if (this._type !== "workinstance") return null;

    // NOTE: the following sql supports start/end date overrides as per the
    // mocks. It does NOT do any bullshit name matching, but requires that you
    // set up the workresults correctly.
    // - workresulttypeid must point at 'Date'
    // - workresultisprimary must be true
    // - workresultorder should be 0 for 'start' and 1 for 'end'
    const [row] = await sql<
      [
        {
          status: string;
          create_date: string;
          start_date?: string;
          ov_start_date?: string;
          close_date?: string;
          ov_close_date?: string;
          time_zone: string;
        }?,
      ]
    >`
      SELECT
          wis.systagtype AS status,
          wi.workinstancecreateddate AS create_date,
          wi.workinstancestartdate AS start_date,
          nullif(ov_start.workresultinstancevalue, '')::timestamptz AS ov_start_date,
          wi.workinstancecompleteddate AS close_date,
          nullif(ov_close.workresultinstancevalue, '')::timestamptz AS ov_close_date,
          wi.workinstancetimezone AS time_zone
      FROM public.workinstance AS wi
      INNER JOIN public.systag AS wis
          ON wi.workinstancestatusid = wis.systagid
      LEFT JOIN public.workresult AS ov_start_f
          ON
              wi.workinstanceworktemplateid = ov_start_f.workresultworktemplateid
              AND ov_start_f.workresultisprimary = true
              AND ov_start_f.workresulttypeid IN (
                  SELECT systagid
                  FROM public.systag
                  WHERE systagtype = 'Date'
              )
              AND ov_start_f.workresultorder = 0
      LEFT JOIN public.workresultinstance AS ov_start
          ON
              wi.workinstanceid = ov_start.workresultinstanceworkinstanceid
              AND ov_start_f.workresultid = ov_start.workresultinstanceworkresultid
      LEFT JOIN public.workresult AS ov_close_f
          ON
              wi.workinstanceworktemplateid = ov_close_f.workresultworktemplateid
              AND ov_close_f.workresultisprimary = true
              AND ov_close_f.workresulttypeid IN (
                  SELECT systagid
                  FROM public.systag
                  WHERE systagtype = 'Date'
              )
              AND ov_close_f.workresultorder = 1
      LEFT JOIN public.workresultinstance AS ov_close
          ON
              wi.workinstanceid = ov_close.workresultinstanceworkinstanceid
              AND ov_close_f.workresultid = ov_close.workresultinstanceworkresultid
      WHERE wi.id = ${this._id};
    `;

    if (!row) {
      console.warn(`No TaskState for ${this}... which is odd?`);
      return null;
    }

    return match(row.status)
      .with(
        "Open",
        () =>
          ({
            __typename: "Open",
            openedAt: {
              override: null,
              value: row.create_date,
            },
          }) satisfies Open,
      )
      .with(
        "In Progress",
        () =>
          ({
            __typename: "InProgress",
            openedAt: {
              override: null,
              value: row.create_date,
            },
            inProgressAt: {
              override:
                row.start_date && row.ov_start_date
                  ? {
                      previousValue: row.start_date,
                    }
                  : null,
              value: assertNonNull(
                row.ov_start_date ?? row.start_date,
                `Task ${this}, in state 'In Progress', has no start date`,
              ),
            },
          }) satisfies InProgress,
      )
      .with(
        "Cancelled",
        () =>
          ({
            __typename: "Closed",
            openedAt: {
              override: null,
              value: row.create_date,
            },
            inProgressAt: row.start_date
              ? {
                  override: row.ov_start_date
                    ? {
                        previousValue: row.start_date,
                      }
                    : null,
                  value: row.ov_start_date ?? row.start_date,
                }
              : null,
            closedAt: {
              override:
                row.close_date && row.ov_close_date
                  ? {
                      previousValue: row.close_date,
                    }
                  : null,
              value: assertNonNull(
                row.ov_close_date ?? row.close_date,
                `Task ${this}, in state 'Cancelled', has no close date`,
              ),
            },
          }) satisfies Closed,
      )
      .with(
        "Complete",
        () =>
          ({
            __typename: "Closed",
            openedAt: {
              override: null,
              value: row.create_date,
            },
            inProgressAt: row.start_date
              ? {
                  override: row.ov_start_date
                    ? {
                        previousValue: row.start_date,
                      }
                    : null,
                  value: row.ov_start_date ?? row.start_date,
                }
              : null,
            closedAt: {
              override:
                row.close_date && row.ov_close_date
                  ? {
                      previousValue: row.close_date,
                    }
                  : null,
              value: assertNonNull(
                row.ov_close_date ?? row.close_date,
                `Task ${this}, in state 'Closed', has no close date`,
              ),
            },
          }) satisfies Closed,
      )
      .otherwise(s => {
        console.warn(`Unknown TaskState type '${s}'`);
        return null;
      });
  }

  /**
   * Entrypoint into the "tracking system(s)" for the given Task.
   * At the moment, sub-task tracking is not supported and therefore `null` will
   * always be returned for this field.
   *
   * @gqlField
   */
  async tracking(): Promise<Connection<Trackable> | null> {
    return null;
  }

  toString() {
    return `'${this.id}' (${this._type}:${this._id})`;
  }
}

/**
 * {@link Assignment} connection for the given Task.
 * *Currently, tasks can only have a single assignment.*
 *
 * @gqlField
 */
export async function assignees(
  t: Task,
  ctx: Context,
): Promise<Connection<Assignment> | null> {
  // Only workinstances can be assigned.
  if (t._type !== "workinstance") return null;

  const rows = await sql<{ id: string; entity: string }[]>`
    SELECT encode(('workresultinstance:' || wi.id || ':' || wr.id)::bytea, 'base64') AS id
    FROM public.workinstance AS wi
    INNER JOIN public.workresultinstance AS wri
        ON wi.workinstanceid = wri.workresultinstanceworkinstanceid
    INNER JOIN public.workresult AS wr
        ON
            wri.workresultinstanceworkresultid = wr.workresultid
            AND wr.workresultisprimary = true
            AND wr.workresulttypeid = 848
            AND wr.workresultentitytypeid = 850
    WHERE wi.id = ${t._id}
  `;

  return {
    edges: rows.map(row => ({
      cursor: row.id,
      // FIXME: this may not be ideal as it introduces a chance for interleaving
      // to put us an illegal state, i.e. the above query runs and it finds a
      // match then another session unassigns (the same row) _and then_ the
      // resolver in Assigment runs and finds that the row that we told it would
      // be there is no longer there!
      node: new Assignment(row, ctx),
    })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: rows.count,
  };
}

/**
 * Inspect the chain (if any) in which the given Task exists.
 * As it stands, this can only be used to perform a downwards search of the
 * chain, i.e. the given Task is used as the "root" of the search tree.
 *
 * @gqlField
 */
export async function chain(
  t: Task,
  ctx: Context,
  /**
   * For use in pagination. Specifies the limit for "forward pagination".
   */
  first?: Int | null,
): Promise<Connection<Task>> {
  // Only workinstances can participate in chains.
  if (t._type !== "workinstance") {
    console.warn(
      `Task.chain is not supported for underlying type '${t._type}'.`,
    );
    return {
      edges: [],
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: 0,
    };
  }

  const rows = await sql<{ id: ID }[]>`
    with recursive chain as (
        select *
        from public.workinstance
        where workinstance.id = ${t._id}
        union all
        select children.*
        from chain, public.workinstance as children
        where chain.workinstanceid = children.workinstancepreviousid
    )
    select encode(('workinstance:' || id)::bytea, 'base64') as id
    from chain
    order by workinstanceid asc
    limit ${first ?? null};
  `;

  return {
    edges: rows.map(row => ({
      cursor: row.id,
      node: new Task(row, ctx),
    })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: rows.length,
  };
}

/**
 * Given a Task identifying as a node in a chain, create an aggregate view of
 * said chain over the type tags given in `overType`. The result is a set of
 * aggregates representing the *sum total duration* of nodes tagged with any of
 * the given `overType` tags, *including* the given Task (if it is so tagged).
 *
 * Colloquially: `chainAgg(overType: ["Foo", "Bar"])` will compute the total
 * time spent in all "Foo" or "Bar" tasks in the given chain;
 *
 * ```json
 * [
 *   {
 *     "group": "Foo",
 *     "value": "26.47", // 26.47 seconds spent doing "Foo" tasks
 *   },
 *   {
 *     "group": "Bar",
 *     "value": "5.82", // 5.82 seconds spent doing "Bar" tasks
 *   },
 * ]
 * ```
 *
 * @gqlField
 */
export async function chainAgg(
  t: Task,
  ctx: Context,
  /**
   * Which sub-type-hierarchies you are interested in aggregating over.
   */
  overType: string[],
): Promise<Aggregate[]> {
  if (!overType.length) {
    throw new GraphQLError("Must specify at least one tag to group by", {
      extensions: {
        code: "BAD_REQUEST",
      },
    });
  }

  const rows = await match(t._type)
    .with(
      "workinstance",
      () => sql<Aggregate[]>`
        with recursive chain as (
            select *
            from public.workinstance
            where workinstance.id = ${t._id}
            union all
            select children.*
            from chain, public.workinstance as children
            where chain.workinstanceid = children.workinstancepreviousid
        )
        select
            tt.systagtype as "group",
            sum(
                extract(
                    epoch from (chain.workinstancecompleteddate - chain.workinstancestartdate)
                )
            ) as value
        from chain
        inner join public.worktemplatetype as t
            on chain.workinstanceworktemplateid = t.worktemplatetypeworktemplateid
        inner join public.systag as tt
            on t.worktemplatetypesystaguuid = tt.systaguuid
        where tt.systagtype in ${sql(overType)}
        group by tt.systagtype
      `,
    )
    .otherwise(() => []);

  return rows;
}

// FIXME: this might be a confusing name in combination with TaskStateMachine...
// Probably should just name it TaskStatus?
/** @gqlUnion */
export type TaskState = Open | InProgress | Closed;

/** @gqlType */
export type Open = {
  __typename: "Open";

  /** @gqlField */
  openedAt: Overridable<Timestamp>;
  /** @gqlField */
  openedBy?: string;
};

/** @gqlType */
export type InProgress = {
  __typename: "InProgress";

  /** @gqlField */
  openedAt: Overridable<Timestamp>;
  /** @gqlField */
  openedBy?: string | null;
  /** @gqlField */
  inProgressAt: Overridable<Timestamp>;
  /** @gqlField */
  inProgressBy?: string | null;
};

/** @gqlType */
export type Closed = {
  __typename: "Closed";

  /** @gqlField */
  openedAt: Overridable<Timestamp>;
  /** @gqlField */
  openedBy?: string | null;
  /** @gqlField */
  inProgressAt?: Overridable<Timestamp> | null;
  /** @gqlField */
  inProgressBy?: string | null;
  /** @gqlField */
  closedAt: Overridable<Timestamp>;
  /** @gqlField */
  closedBecause?: string | null;
  /** @gqlField */
  closedBy?: string;
};

/** @gqlInput */
export type TaskInput = {
  id: ID;
  overrides?: FieldInput[] | null;
  // TODO: for photos
  // attachments?: Attachment[] | null;
};

/**
 * Similar to task_fsm's advance method, this method advances a Task through its
 * internal state machine. A Task's state machine has its finite set defined by
 * the variants of the {@link TaskState} union, with a dag of the form:
 * ```
 * Open -> InProgress -> Closed
 * ```
 */
export async function advance(
  t: Task,
  opts?: Omit<TaskInput, "id"> | null,
): Promise<Task> {
  if (t._type !== "workinstance") {
    // Punt on this for now. We can come back to it.
    // This is, at least at present, used solely by the `advance` implementation
    // for StateMachine<Task>.
    throw "not yet implemented - lazy instantiation of a Task";
  }

  await sql.begin(async tx => {
    // TODO: move to a SQL procedure so we can pipeline.
    const result = await tx`
      merge into public.workinstance as t
      using (
        select *
        from public.workinstance
        where id = ${t._id}
      ) as s on t.workinstanceid = s.workinstanceid
      when matched and s.workinstancestatusid = 706 then
        update set workinstancestatusid = 707,
                   workinstancestartdate = now(),
                   workinstancemodifieddate = now()
      when matched and s.workinstancestatusid = 707 then
        update set workinstancestatusid = 710,
                   workinstancecompleteddate = now(),
                   workinstancemodifieddate = now()
      ;
    `;

    if (!result.count) {
      assert(false, "no merge action performed");
    }

    // TODO: auto-assign via SQL procedure so we can pipeline.

    if (opts?.overrides?.length) {
      // TODO: move to a SQL procedure so we can pipeline.
      const edits = applyEdits$fragment(t, opts.overrides);
      if (edits) {
        const r = await tx`${edits}`;
        console.log(`Applied ${r.count} field-level edits.`);
      }
    }
  });

  return t;
}

/**
 * The purpose of this function is to abstract the process of applying
 * field-level edits to a Task (i.e. a workinstance's workresultinstances).
 *
 * - This is an UPSERT operation; it will create workresultinstances if necessary.
 * - This operation does not affect field-level status.
 */
export function applyEdits$fragment(
  t: Task,
  edits: FieldInput[],
): Fragment | undefined {
  if (t._type !== "workinstance") {
    assert(t._type === "workinstance", `cannot apply edits to a '${t._type}'`);
    return;
  }

  if (!edits.length) return;

  const edits_ = edits.flatMap(e => {
    const { type, id, suffix } = decodeGlobalId(e.field);
    switch (type) {
      case "workresult": {
        return [
          [
            id,
            valueInputToSql(e.value) ?? null,
            valueInputTypeToSql(e.value) ?? null,
          ],
        ];
      }
      case "workresultinstance": {
        return [
          [
            assertNonNull(suffix?.at(0)),
            valueInputToSql(e.value) ?? null,
            valueInputTypeToSql(e.value) ?? null,
          ],
        ];
      }
      default: {
        console.warn(`Underlying type '${type}' not expected in this context.`);
        return [];
      }
    }
  });

  return sql`
    WITH edits (field, value, type) AS (
        VALUES ${sql(edits_ as string[][])}
    )

    INSERT INTO public.workresultinstance AS t (
        workresultinstancecustomerid,
        workresultinstanceworkinstanceid,
        workresultinstanceworkresultid,
        workresultinstancetimezone,
        workresultinstancevalue
    )
    SELECT
        wi.workinstancecustomerid,
        wi.workinstanceid,
        wr.workresultid,
        wi.workinstancetimezone,
        coalesce(nullif(edits.value, ''), wr.workresultdefaultvalue)
    FROM edits
    INNER JOIN public.workinstance AS wi
        ON wi.id = ${t._id}
    INNER JOIN public.workresult AS wr
        ON edits.field = wr.id
           AND wi.workinstanceworktemplateid = wr.workresultworktemplateid
    INNER JOIN public.systag AS wrt
        ON edits.type = wrt.systagtype
           AND wrt.systagparentid = 699
    ON CONFLICT
        (workresultinstanceworkinstanceid, workresultinstanceworkresultid)
    DO UPDATE
        SET workresultinstancevalue = EXCLUDED.workresultinstancevalue,
            workresultinstancemodifieddate = now()
        WHERE
            t.workresultinstancevalue IS DISTINCT FROM EXCLUDED.workresultinstancevalue
    RETURNING 1
  `;
}

export function valueInputToSql(value?: FieldInput["value"]) {
  if (!value) return null;
  switch (true) {
    case "boolean" in value:
      return map(value.boolean, v => (v ? "true" : "false"));
    // case "decimal" in value:
    //   return value.decimal.toString();
    // case "duration" in value:
    //   return value.duration;
    case "id" in value:
      return value.id;
    case "number" in value:
      return value.number?.toString();
    case "string" in value:
      return value.string;
    case "timestamp" in value: {
      return map(value.timestamp, t => {
        const ms = Date.parse(t);
        if (Number.isNaN(ms)) {
          console.warn(`Discarding invalid timestamp '${t}'`);
          return null;
        }
        return new Date(t).toISOString();
      });
    }
    default: {
      const _: never = value;
      console.warn(`Unhandled input variant '${JSON.stringify(value)}'`);
      return null;
    }
  }
}

export function valueInputTypeToSql(value?: FieldInput["value"]) {
  if (!value) return null;
  switch (true) {
    case "boolean" in value:
      return "Boolean";
    // case "decimal" in value:
    //   return "Number";
    // case "duration" in value:
    //   return "Duration";
    case "id" in value:
      return value.id;
    case "number" in value:
      return "Number";
    case "string" in value:
      return "String";
    case "timestamp" in value:
      return "Date";
    default: {
      const _: never = value;
      console.warn(`Unhandled input variant: ${JSON.stringify(value)}`);
      return null;
    }
  }
}
