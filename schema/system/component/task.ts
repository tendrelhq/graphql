import { setCurrentIdentity } from "@/auth";
import { type Sql, type TxSql, sql } from "@/datasources/postgres";
import {
  Location,
  type ConstructorArgs as LocationConstructorArgs,
} from "@/schema/platform/archetype/location";
import {
  Attachment,
  type ConstructorArgs as AttachmentConstructorArgs,
} from "@/schema/platform/attachment";
import type { Trackable } from "@/schema/platform/tracking";
import { type Diagnostic, DiagnosticKind } from "@/schema/result";
import type { Mutation } from "@/schema/root";
import type { Context } from "@/schema/types";
import {
  assert,
  assertNonNull,
  assertUnderlyingType,
  buildPaginationArgs,
  map,
  mapOrElse,
  normalizeBase64,
} from "@/util";
import { Temporal } from "@js-temporal/polyfill";
import { GraphQLError } from "graphql/error";
import type { ID, Int } from "grats";
import type { Fragment } from "postgres";
import { P, match } from "ts-pattern";
import { decodeGlobalId, encodeGlobalId } from "..";
import type { Aggregate } from "../aggregation";
import {
  type Component,
  type Field,
  type FieldDefinitionInput,
  type FieldInput,
  field$fragment,
} from "../component";
import type { Refetchable } from "../node";
import type { Overridable } from "../overridable";
import type { Connection, Edge, PageInfo } from "../pagination";
import type { Timestamp } from "../temporal";
import { type Assignable, Assignment } from "./assignee";
import type { Description } from "./description";
import type { DisplayName } from "./name";

export type ConstructorArgs = {
  id: ID;
};

/**
 * A system-level component that identifies an Entity as being applicable to
 * Tendrel's internal "task processing pipeline". In practice, Tasks most often
 * represent "jobs" performed by humans. However, this need not always be the
 * case.
 *
 * Technically speaking, a Task represents a (1) *named asynchronous process*
 * that (2) exists in one of three states: open, in progress, or closed.
 *
 * @gqlType
 */
export class Task implements Assignable, Component, Refetchable, Trackable {
  readonly __typename = "Task" as const;
  readonly _type: "workinstance" | "worktemplate";
  readonly _id: string;
  readonly id: ID;

  constructor(args: ConstructorArgs) {
    const { type, id } = decodeGlobalId(args.id);
    this._type = assertUnderlyingType(["workinstance", "worktemplate"], type);
    this._id = id;
    this.id = normalizeBase64(args.id);
  }

  static fromTypeId(type: string, id: string) {
    return new Task({ id: encodeGlobalId({ type, id }) });
  }

  /**
   * @gqlField
   */
  async description(ctx: Context): Promise<Description | null> {
    return await ctx.orm.description.load(this.id);
  }

  /**
   * @deprecated Use Task.name instead.
   * @gqlField
   */
  async displayName(ctx: Context): Promise<DisplayName> {
    return await ctx.orm.displayName.load(this.id);
  }

  /**
   * @gqlField
   */
  async field(args: { byName?: string | null }): Promise<Field | null> {
    const [row] = await match(this._type)
      .with(
        "workinstance",
        () => sql<[Field?]>`
          with field as (
              select
                  encode(
                      ('workresultinstance:' || wi.id || ':' || wr.id)::bytea, 'base64'
                  ) as id,
                  t.systagtype as type,
                  wri.workresultinstancevalue as value
              from public.workinstance as wi
              inner join public.workresultinstance as wri
                  on wi.workinstanceid = wri.workresultinstanceworkinstanceid
              inner join public.workresult as wr
                  on wri.workresultinstanceworkresultid = wr.workresultid
              inner join public.systag as t on wr.workresulttypeid = t.systagid
              ${
                args.byName
                  ? sql`
              inner join public.languagemaster as n
                  on wr.workresultlanguagemasterid = n.languagemasterid
                  and n.languagemastersource = ${args.byName}
                  `
                  : sql``
              }
              where wi.id = ${this._id}
              limit 1
          )

          ${field$fragment}
        `,
      )
      .with(
        "worktemplate",
        () => sql<[Field?]>`
          with field as (
              select
                  encode(('workresult:' || wr.id)::bytea, 'base64') as id,
                  t.systagtype as type,
                  wr.workresultdefaultvalue as value
              from public.worktemplate as wt
              inner join
                  public.workresult as wr
                  on wt.worktemplateid = wr.workresultworktemplateid
              inner join public.systag as t on wr.workresulttypeid = t.systagid
              ${
                args.byName
                  ? sql`
              inner join
                  public.languagemaster as n
                  on wr.workresultlanguagemasterid = n.languagemasterid
                  and n.languagemastersource = ${args.byName}
                  `
                  : sql``
              }
              where wt.id = ${this._id}
              limit 1
          )

          ${field$fragment}
        `,
      )
      .exhaustive();

    return row ?? null;
  }

  async addField(ctx: Context, input: FieldDefinitionInput): Promise<Field> {
    const cte = match(this._type)
      .with(
        "workinstance",
        () => sql`
          select
            customer.customeruuid as customer_id,
            'en' as language_type,
            auth.current_identity(customer.customerid, current_setting('user.id')) as modified_by,
            worktemplate.id as template_id
          from public.workinstance
          inner join public.customer on workinstancecustomerid = customerid
          inner join public.worktemplate on workinstanceworktemplateid = worktemplateid
          where id = ${this._id}
        `,
      )
      .with(
        "worktemplate",
        () => sql`
          select
            customer.customeruuid as customer_id,
            'en' as language_type,
            auth.current_identity(customer.customerid, current_setting('user.id')) as modified_by,
            worktemplate.id as template_id
          from public.worktemplate
          inner join public.customer on worktemplatecustomerid = customerid
          where id = ${this._id}
        `,
      )
      .exhaustive();

    const fieldType = match(input.type)
      .with("boolean", () => "Boolean")
      .with("entity", () => "Entity")
      .with("number", () => "Number")
      .with("string", () => "String")
      .with("timestamp", () => "Date")
      .otherwise(() => null);

    const result = await sql.begin(async sql => {
      await setCurrentIdentity(sql, ctx);
      return await sql`
        with cte as (${cte})
        select t.*
        from
          cte,
          engine1.upsert_field_t(
            customer_id := cte.customer_id,
            language_type := cte.language_type,
            modified_by := cte.modified_by,
            template_id := cte.template_id,
            field_id := null,
            field_name := ${input.name},
            field_order := ${input.order ?? 0},
            field_type := ${fieldType}
          ) as ops,
          engine1.execute(ops.*) as t
        ;
      `;
    });

    // TODO: the return value could be more helpful.
    // For now we know we the workresult will always be the first one.
    const field: string = assertNonNull(
      map(result.at(0)?.ctx.at(0)?.created.at(0)?.node, id =>
        encodeGlobalId({ type: "workresult", id }),
      ),
      "failed to add field",
    );

    // This is still ugly...
    // but honestly it's gotten way better since the Checklist days lmao.
    return match(input.type)
      .with("boolean", () => ({
        id: field,
        value: {
          __typename: "BooleanValue" as const,
          boolean: match(input.value)
            .with({ boolean: P.boolean }, v => v.boolean)
            .otherwise(() => null),
        },
        valueType: "boolean" as const,
      }))
      .with("entity", () => ({
        id: field,
        value: {
          __typename: "EntityValue" as const,
          entity: null,
        },
        valueType: "entity" as const,
      }))
      .with("number", () => ({
        id: field,
        value: {
          __typename: "NumberValue" as const,
          number: match(input.value)
            .with({ number: P.number }, v => v.number)
            .otherwise(() => null),
        },
        valueType: "number" as const,
      }))
      .with("string", () => ({
        id: field,
        value: {
          __typename: "StringValue" as const,
          string: match(input.value)
            .with({ string: P.string }, v => v.string)
            .otherwise(() => null),
        },
        valueType: "string" as const,
      }))
      .with("timestamp", () => ({
        id: field,
        value: {
          __typename: "TimestampValue" as const,
          timestamp: match(input.value)
            .with({ timestamp: P.string }, v =>
              Temporal.Instant.from(v.timestamp).epochSeconds.toString(),
            )
            .otherwise(() => null),
        },
        valueType: "timestamp" as const,
      }))
      .otherwise(() => {
        throw new GraphQLError("Unknown Field value type", {
          extensions: {
            code: "BAD_REQUEST",
            hint: "Expected one of: Boolean, Entity, Number, String, Timestamp",
          },
        });
      });
  }

  async createTransition(
    args: {
      atLocation?: ID | null;
      whenStatusChangesTo: TaskStateName;
      instantiate: {
        template: ID;
        atLocation?: ID | null;
        /** @default "Task" */
        withType?: "Task" | "Audit" | "Remediation";
      };
      /** @default "eager" */
      type?: "eager" | "lazy";
    },
    ctx: Context,
    sql: TxSql,
  ): Promise<void> {
    const { type: nextTemplateType, id: nextTemplate } = decodeGlobalId(
      args.instantiate.template,
    );
    assertUnderlyingType("worktemplate", nextTemplateType);

    const stateCondition = match(args.whenStatusChangesTo)
      .with("Open", () => "Open")
      .with("InProgress", () => "In Progress")
      .with("Closed", () => "Complete")
      .exhaustive();

    const prevLocation = map(args.atLocation, l => {
      const { type, id } = decodeGlobalId(l);
      assertUnderlyingType("location", type);
      return id;
    });
    const nextLocation = map(args.instantiate.atLocation, l => {
      const { type, id } = decodeGlobalId(l);
      assertUnderlyingType("location", type);
      return id;
    });

    const typeTag =
      args.type === "lazy"
        ? "On Demand"
        : (args.instantiate.withType ?? "Task");

    const r = await sql`
      select 1
      from legacy0.create_instantiation_rule_v2(
        prev_template_id := ${this._id},
        next_template_id := ${nextTemplate},
        state_condition := ${stateCondition},
        type_tag := ${typeTag},
        prev_location_id := ${prevLocation ?? null},
        next_location_id := ${nextLocation ?? null},
        modified_by := 895
      );
    `;
    assert(r.count === 1);
  }

  async ensureInstantiableAt(
    args: { locations: ID[] },
    ctx: Context,
    sql: TxSql,
  ): Promise<void> {
    const rows = await sql`
      select 1
      from
        public.location as l,
        legacy0.create_template_constraint_on_location(
          template_id := ${this._id},
          location_id := l.locationuuid,
          modified_by := auth.current_identity(l.locationcustomerid, ${ctx.auth.userId})
        )
      where l.locationuuid in ${sql(args.locations.map(l => decodeGlobalId(l).id))}
    `;
    assert(rows.count === args.locations.length);
  }

  /**
   * The hash signature of the given Task. This is only useful when interacting
   * with APIs that require a hash as a concurrency control mechanism.
   *
   * @gqlField
   */
  async hash(): Promise<string> {
    // We'll just punt on non-instances for now.
    if (this._type !== "workinstance") return "";
    const { hash } = await computeTaskHash(sql, this);
    return hash;
  }

  async instantiate(
    args: {
      chainPrev?: ID | null;
      chainRoot?: ID | null;
      name?: string | null;
      fields?: FieldInput[] | null;
      location: ID;
      state?: TaskStateInput | null;
    },
    ctx: Context,
    sql: TxSql,
  ): Promise<Task> {
    assertUnderlyingType("worktemplate", this._type);
    const chainPrev = map(args.chainPrev, id => new Task({ id }));
    const chainRoot = map(args.chainRoot, id => new Task({ id }));
    const location = new Location({ id: args.location });
    const targetState = match(args.state)
      .with({ open: P._ }, () => "Open")
      .with({ inProgress: P._ }, () => "In Progress")
      .with({ closed: P._ }, () => "Completed")
      .otherwise(() => "Open");
    const [row] = await sql<[ConstructorArgs]>`
      select encode(('workinstance:' || t.instance)::bytea, 'base64') as id
      from engine0.instantiate(
          template_id := ${this._id},
          location_id := ${location._id},
          target_state := ${targetState},
          target_type := 'Task',
          modified_by := 895,
          chain_root_id := ${chainRoot?._id ?? null},
          chain_prev_id := ${chainPrev?._id ?? null}
      ) as t
      group by t.instance
    `;
    const t = new Task(row);

    if (args.name?.length) {
      const r = await sql`
        update public.workinstance
        set workinstancenameid = (
          select n.id
          from
            public.customer,
            i18n.create_localized_content(
                owner := customeruuid,
                content := ${args.name},
                language := ${ctx.req.i18n.language}
            ) as n
          where customerid = workinstancecustomerid
        )
        where id = ${t._id}
      `;
      assert(r.count === 1);
    }

    if (args.fields?.length) {
      await applyFieldEdits_(sql, ctx, t, args.fields);
    }

    return t;
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
    const [row] = await match(this._type)
      .with(
        "workinstance",
        () => sql<[LocationConstructorArgs]>`
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
          select encode(('location:' || location.locationuuid)::bytea, 'base64') as id
          from parent, public.location
          where parent._id = location.locationid
        `,
      )
      .with("worktemplate", () => [null])
      .otherwise(t => {
        console.warn(`Unknown underlying type ${t} for Task`);
        return [null];
      });

    if (row) return new Location(row);

    return null;
  }

  /**
   * Get the previous Task, which may represent an altogether different chain
   * than the current Task.
   *
   * @gqlField
   */
  async previous(): Promise<Task | null> {
    if (this._type !== "workinstance") return null;

    // Note: explicitly NOT joining on originator because the previous *might*
    // be in a different chain.
    const [row] = await sql<[ConstructorArgs?]>`
      select encode(('workinstance:' || prev.id)::bytea, 'base64') as id
      from public.workinstance as t
      inner join public.workinstance as prev
          on t.workinstancepreviousid = prev.workinstanceid
      where t.id = ${this._id}
    `;

    if (!row) return null;

    return new Task(row);
  }

  /**
   * @gqlField
   */
  async root(): Promise<Task | null> {
    if (this._type !== "workinstance") return null;
    const [row] = await sql<[ConstructorArgs?]>`
      select engine1.base64_encode(convert_to('workinstance:' || root.id, 'utf8')) as id
      from public.workinstance as node
      inner join public.workinstance as root
        on node.workinstanceoriginatorworkinstanceid = root.workinstanceid
      where node.id = ${this._id}
        and node.workinstanceid is distinct from node.workinstanceoriginatorworkinstanceid
    `;
    if (!row) return null;
    return new Task(row);
  }

  /**
   * @gqlField
   */
  async name(ctx: Context): Promise<DisplayName> {
    return await ctx.orm.displayName.load(this.id);
  }

  // FIXME: We should probably implement this as a StateMachine<TaskState>?
  // This would allow the frontend to disambiguate start vs end, i.e. not have
  // to infer the valid action(s) based on the TaskState.
  /** @gqlField */
  async state(ctx: Context): Promise<TaskState | null> {
    // Only workinstances have statuses.
    if (this._type !== "workinstance") return null;

    // NOTE: the following sql supports start/end date overrides as per the
    // mocks. It does NOT do any bullshit name matching, but requires that you
    // set up the workresults correctly. We could make the order configurable.
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
          to_timestamp(nullif(ov_start.workresultinstancevalue, '')::bigint / 1000.0) AS ov_start_date,
          wi.workinstancecompleteddate AS close_date,
          to_timestamp(nullif(ov_close.workresultinstancevalue, '')::bigint / 1000.0) AS ov_close_date,
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

    // HACK: not great, but ok for now.
    const ass = await assignees(this, ctx); // n.b. db call

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
        async () =>
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
            inProgressBy: await ass?.edges.at(0)?.node.assignedTo(), // n.b. db call :/
          }) satisfies InProgress,
      )
      .with(
        "Cancelled",
        async () =>
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
            closedBy: await ass?.edges.at(0)?.node.assignedTo(), // n.b. db call :/
          }) satisfies Closed,
      )
      .with(
        "Complete",
        async () =>
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
            closedBy: await ass?.edges.at(0)?.node.assignedTo(), // n.b. db call :/
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
  async tracking(args: {
    first?: Int | null;
    after?: ID | null;
  }): Promise<Connection<Trackable> | null> {
    return null;
  }

  toString() {
    return `${this.id} (${this._type}:${this._id})`;
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
 * Attachments associated with the Task as a whole.
 * Note that you can also have field-level attachments.
 *
 * @gqlField
 */
export async function attachments(
  t: Task,
  ctx: Context,
  args: {
    first?: Int | null;
    last?: Int | null;
    before?: string | null;
    after?: string | null;
  },
): Promise<Connection<Attachment>> {
  // Only instances can have attachments.
  if (t._type !== "workinstance") {
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
    defaultLimit: ctx.limits.attachmentPaginationDefaultLimit,
    maxLimit: ctx.limits.attachmentPaginationMaxLimit,
  });
  const rows = await sql<AttachmentConstructorArgs[]>`
    select
        encode(('workpictureinstance:' || a.workpictureinstanceuuid)::bytea, 'base64') as id,
        a.workpictureinstancestoragelocation as url
    from public.workpictureinstance as a
    where
        a.workpictureinstanceworkinstanceid = (
            select workinstanceid
            from public.workinstance
            where id = ${t._id}
        )
        and a.workpictureinstanceworkresultinstanceid is null
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
    from public.workpictureinstance as a
    where
        a.workpictureinstanceworkinstanceid = (
            select workinstanceid
            from public.workinstance
            where id = ${t._id}
        )
        and a.workpictureinstanceworkresultinstanceid is null
  `;

  return {
    edges,
    pageInfo,
    totalCount: Number(count),
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
        select child.*
        from chain, public.workinstance as child
        where
            chain.workinstanceoriginatorworkinstanceid = child.workinstanceoriginatorworkinstanceid
            and chain.workinstanceid = child.workinstancepreviousid
    )
    select encode(('workinstance:' || id)::bytea, 'base64') as id
    from chain
    order by workinstanceid asc
    limit ${first ?? null};
  `;

  return {
    edges: rows.map(row => ({
      cursor: row.id,
      node: new Task(row),
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
 * Note that this aggregation uses the given Task as the *root* of the chain.
 * Chains are tree-like structures, which means you can chainAgg over a subtree
 * by choosing a different root node. Note also that this means you may need to
 * do some math depending on the structure of your chain, e.g. in the above
 * example it may be that "Foo" remains "InProgress" while "Bar" happens, and
 * therefore the aggregate for "Foo" *includes* time spent in "Bar".
 *
 * @gqlField
 */
export async function chainAgg(
  t: Task,
  _ctx: Context,
  /**
   * Which subtype-hierarchies you are interested in aggregating over.
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
            select child.*
            from chain, public.workinstance as child
            where
                chain.workinstanceoriginatorworkinstanceid = child.workinstanceoriginatorworkinstanceid
                and chain.workinstanceid = child.workinstancepreviousid
        )
        select
            tt.systagtype as "group",
            sum(extract(epoch from (legacy0.compute_time_at_task(chain.workinstanceid)))) as value
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

/**
 * @gqlInput
 * @oneOf
 */
export type TaskStateInput =
  | {
      open: OpenInput;
    }
  | {
      inProgress: InProgressInput;
    }
  | {
      closed: ClosedInput;
    };

/** @gqlEnum */
export type TaskStateName = "Open" | "InProgress" | "Closed";

/** @gqlType */
export type Open = {
  __typename: "Open";

  /** @gqlField */
  openedAt: Overridable<Timestamp>;
  /** @gqlField */
  openedBy?: Assignable | null;
};

/** @gqlInput */
export type OpenInput = {
  // TODO: probably want this to be overridable? Ugh. I hate the concept of
  // overrides.
  openedAt?: Timestamp | null;
  openedBy?: ID | null;
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
  inProgressBy?: Assignable | null;
};

/** @gqlInput */
export type InProgressInput = {
  openedAt?: Timestamp | null;
  openedBy?: ID | null;
  inProgressAt?: Timestamp | null;
  inProgressBy?: ID | null;
};

/** @gqlType */
export type Closed = {
  __typename: "Closed";

  /** @gqlField */
  openedAt: Overridable<Timestamp>;
  /** @gqlField */
  openedBy?: Assignable | null;
  /** @gqlField */
  inProgressAt?: Overridable<Timestamp> | null;
  /** @gqlField */
  inProgressBy?: Assignable | null;
  /** @gqlField */
  closedAt: Overridable<Timestamp>;
  /** @gqlField */
  closedBecause?: string | null;
  /** @gqlField */
  closedBy?: Assignable | null;
};

/** @gqlInput */
export type ClosedInput = {
  openedAt?: Timestamp | null;
  openedBy?: ID | null;
  inProgressAt?: Timestamp | null;
  inProgressBy?: ID | null;
  closedAt?: Timestamp | null;
  closedBecause?: string | null;
  closedBy?: ID | null;
};

/** @gqlInput */
export type AdvanceTaskOptions = {
  id: ID;
  /**
   * This should be the Task's current hash (as far as you know) as it was
   * returned to you when first querying for the Task in question.
   */
  hash: string;
  overrides?: FieldInput[] | null;
  /**
   * When advancing a Task necessitates instantiation, you may use the `parent`
   * argument to indicate _where_ to place the new instance. In some cases this
   * argument is required, e.g. when no suitable parent can be derived (for
   * example when the new instance represents a new chain).
   */
  parent?: ID | null;
};

export type AdvanceTaskResult = {
  task: Task;
  diagnostics?: Diagnostic[] | null;
  instantiations: Edge<Task>[];
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
  ctx: Context,
  task: Task,
  opts: Omit<AdvanceTaskOptions, "id">,
): Promise<AdvanceTaskResult> {
  return await sql.begin(async sql => {
    await setCurrentIdentity(sql, ctx);
    return await advanceTask({ task, opts }, sql, ctx);
  });
}

export async function advanceTask(
  args: {
    task: Task;
    opts: Omit<AdvanceTaskOptions, "id">;
  },
  sql: TxSql,
  ctx: Context,
): Promise<AdvanceTaskResult> {
  const { task, opts } = args;
  if (task._type !== "workinstance") {
    // Punt on this for now. We can come back to it.
    // This is, at least at present, used solely by the `advance` implementation
    // for StateMachine<Task>.
    console.warn(`Task ${task} is not an instance`);
    return {
      task: task,
      diagnostics: [
        {
          __typename: "Diagnostic",
          code: DiagnosticKind.feature_not_available,
        },
      ],
      instantiations: [],
    };
  }

  assert(!!opts.hash, "hash is required");
  if (!opts.hash) {
    return {
      task: task,
      diagnostics: [
        {
          __typename: "Diagnostic",
          code: DiagnosticKind.hash_is_required,
        },
      ],
      instantiations: [],
    };
  }

  const { hash, version } = await computeTaskHash(sql, task);
  if (hash !== opts.hash) {
    console.warn("WARNING: Hash mismatch precludes advancement");
    console.debug(`| task: ${task.id}`);
    console.debug(`| ours: ${hash}`);
    console.debug(`| theirs: ${opts.hash}`);
    return {
      task: task,
      diagnostics: [
        {
          __typename: "Diagnostic",
          code: DiagnosticKind.hash_mismatch_precludes_operation,
        },
      ],
      instantiations: [],
    };
  }

  // FIXME: use MERGE once we've upgraded to postgres >=15
  const [result] = await sql<
    [
      (ConstructorArgs & {
        hash: string;
        _hack_needs_tat: boolean;
        _version: bigint;
      })?,
    ]
  >`
    with
        when_open as (
            update public.workinstance as wi
            set version = wi.version + 1,
                workinstancestatusid = 707,
                workinstancestartdate = now(),
                workinstancemodifieddate = now(),
                workinstancemodifiedby = auth.current_identity(workinstancecustomerid, ${ctx.auth.userId})
            where wi.id = ${task._id}
              and wi.workinstancestatusid = 706
              and wi.version = ${version}
            returning
                wi.id, 
                ${hash$fragment("wi")} as hash,
                false as _hack_needs_tat,
                wi.version as _version
        ),

        when_in_progress as (
            update public.workinstance as wi
            set version = wi.version + 1,
                workinstancestatusid = 710,
                workinstancecompleteddate = now(),
                workinstancemodifieddate = now(),
                workinstancemodifiedby = auth.current_identity(workinstancecustomerid, ${ctx.auth.userId})
            where wi.id = ${task._id}
              and wi.workinstancestatusid = 707
              and wi.version = ${version}
            returning
                wi.id, 
                ${hash$fragment("wi")} as hash,
                true as _hack_needs_tat,
                wi.version as _version
        )

    select * from when_open
    union all
    select * from when_in_progress
    limit 1
  `;

  if (!result) {
    // FIXME: this is possible under concurrency. We are doing OCC here after
    // all! What we need to do better here is differentiate between an illegal
    // action (e.g. advancing a closed task) and losing the race. If the action
    // is legal then the only alternative is that we lost the race, and thus we
    // can return a proper diagnostic indicative of this outcome.
    //
    // TODO: think about how we can remove the assumption inherent in our logic
    // here. This would mean allowing for arbitrary task states via something
    // like wtnt rather than assuming the canonical open -> in-prog -> closed.
    console.error(
      `Discarding candidate change, presumably because the Task (${task}) is not in a state suitable to advancement.`,
    );
    return {
      task: task,
      diagnostics: [
        {
          __typename: "Diagnostic",
          code: DiagnosticKind.candidate_change_discarded,
        },
      ],
      instantiations: [],
    };
  }

  {
    /** @see {@link applyAssignments_} */
    const ma = "replace";
    const result = await sql`${applyAssignments_(sql, ctx, task, ma)}`;
    console.debug(
      `advance: applied ${result.count} assignments (mergeAction: ${ma})`,
    );
  }

  if (opts?.overrides?.length) {
    const result = await applyFieldEdits_(sql, ctx, task, opts.overrides);
    console.debug(`advance: applied ${result.count} field-level edits`);
  }

  if (result._hack_needs_tat) {
    // Ensure "Time At Task" is set.
    const [tat] = await sql<[{ _value: string }]>`
      update public.workresultinstance
      set
          workresultinstancevalue = extract(epoch from i.workinstancecompleteddate - i.workinstancestartdate)::text,
          workresultinstancemodifieddate = now(),
          workresultinstancemodifiedby = auth.current_identity(workresultinstancecustomerid, ${ctx.auth.userId})
      from public.workinstance as i
      where
          i.id = ${task._id}
          and workresultinstanceworkinstanceid = i.workinstanceid
          and workresultinstanceworkresultid = (
              select workresultid
              from public.workresult
              where
                  workresultworktemplateid = i.workinstanceworktemplateid
                  and workresulttypeid = 737
          )
      returning workresultinstancevalue as _value
    `;
    console.debug(`advance: recorded time at task: ${tat._value}s`);
  }

  // Run the "rules engine".
  const instantiations = await sql<{ id: string }[]>`
    with t as (
        select *
        from public.workinstance
        where id = ${task._id}
    )

    select encode(('workinstance:' || i.instance)::bytea, 'base64') as id
    from t, engine0.execute(
        task_id := t.id,
        modified_by := auth.current_identity(t.workinstancecustomerid, ${ctx.auth.userId})
    ) as i
  `;
  console.debug(`advance: engine.execute.count: ${instantiations.length}`);

  return {
    task: task,
    instantiations: instantiations.map(i => ({
      cursor: i.id,
      node: new Task(i),
    })),
  };
}

/**
 * @param mergeAction `replace` overwrites, `keep` does not
 */
export function applyAssignments_(
  sql: TxSql,
  ctx: Context,
  t: Task,
  mergeAction: "keep" | "replace" = "replace",
) {
  const ma: Fragment = match(mergeAction)
    // When keeping, we only perform the update when the value is null.
    .with("keep", () => sql`t.workresultinstancevalue is null`)
    // When replacing, we only perform the update when the value is distinctly
    // different from the existing value.
    .with(
      "replace",
      () =>
        sql`t.workresultinstancevalue is distinct from auth.current_identity(cte._parent, ${ctx.auth.userId})::text`,
    )
    .exhaustive();

  return sql`
    with cte as (
        select i.workinstancecustomerid as _parent, field.workresultinstanceid as _id
        from public.workinstance as i
        inner join public.workresultinstance as field
            on i.workinstanceid = field.workresultinstanceworkinstanceid
        inner join public.workresult as field_t
            on field.workresultinstanceworkresultid = field_t.workresultid
        where
            i.id = ${t._id}
            and field_t.workresulttypeid = 848
            and field_t.workresultentitytypeid = 850
            and field_t.workresultisprimary = true
        limit 1
    )

    update public.workresultinstance as t
    set workresultinstancevalue = auth.current_identity(cte._parent, ${ctx.auth.userId})::text,
        workresultinstancemodifieddate = now(),
        workresultinstancemodifiedby = auth.current_identity(cte._parent, ${ctx.auth.userId})
    from cte
    where t.workresultinstanceid = cte._id and ${ma}
  `;
}

/**
 * The set of Fields for the given Task.
 *
 * @gqlField
 */
export async function fields(
  parent: Task,
  ctx: Context,
): Promise<Connection<Field>> {
  if (parent._type !== "workinstance" && parent._type !== "worktemplate") {
    console.warn(`Underlying type '${parent._type}' does not support fields`);
    return {
      edges: [],
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: 0,
    };
  }

  // FIXME: one last bit of jankiness down below: L1168-1173, L1215-1220.
  // This hack is solely for the janky ass start/end time override "fields".
  const rows = await match(parent._type)
    .with(
      "workinstance",
      () => sql<Field[]>`
        with
            field as (
                select
                    encode(
                        ('workresultinstance:' || wi.id || ':' || wr.id)::bytea, 'base64'
                    ) as id,
                    encode(('name:' || n.languagemasteruuid)::bytea, 'base64') as _name,
                    wi.workinstanceid as _id,
                    wr.workresultid as _field,
                    t.systagtype as type,
                    nullif(
                        coalesce(vt.languagetranslationvalue, v.languagemastersource, wri.workresultinstancevalue),
                        ''
                    ) as value
                from public.workinstance as wi
                inner join
                    public.workresultinstance as wri
                    on wi.workinstanceid = wri.workresultinstanceworkinstanceid
                inner join
                    public.workresult as wr
                    on wri.workresultinstanceworkresultid = wr.workresultid
                    and (
                        wr.workresultisprimary = false
                        or (
                            wr.workresultisprimary = true
                            and wr.workresultentitytypeid is null
                            and wr.workresulttypeid != 737
                        )
                    )
                inner join
                    public.languagemaster as n
                    on wr.workresultlanguagemasterid = n.languagemasterid
                inner join
                    public.systag as t
                    on wr.workresulttypeid = t.systagid
                left join
                    public.languagemaster as v
                    on wri.workresultinstancevaluelanguagemasterid = v.languagemasterid
                left join
                    public.languagetranslations as vt
                    on v.languagemasterid = vt.languagetranslationmasterid
                    and vt.languagetranslationtypeid = (
                        select systagid
                        from public.systag
                        where systagparentid = 2 and systagtype = ${ctx.req.i18n.language}
                    )
                where wi.id = ${parent._id}
                order by wr.workresultorder asc, wr.workresultid asc
            )
        ${field$fragment}
      `,
    )
    .with(
      "worktemplate",
      () => sql<Field[]>`
        with
            field as (
                select
                    encode(('workresult:' || wr.id)::bytea, 'base64') as id,
                    encode(('name:' || n.languagemasteruuid)::bytea, 'base64') as "_name",
                    wr.workresultid as _field,
                    t.systagtype as type,
                    wr.workresultdefaultvalue as value
                from public.worktemplate as wt
                inner join
                    public.workresult as wr
                    on wt.worktemplateid = wr.workresultworktemplateid
                    and (wr.workresultenddate is null or wr.workresultenddate > now())
                    and (
                        wr.workresultisprimary = false
                        or (
                            wr.workresultisprimary = true
                            and wr.workresultentitytypeid is null
                            and wr.workresulttypeid != 737
                        )
                    )
                inner join
                    public.languagemaster as n
                    on wr.workresultlanguagemasterid = n.languagemasterid
                inner join
                    public.systag as t
                    on wr.workresulttypeid = t.systagid
                where wt.id = ${parent._id}
                order by wr.workresultorder asc, wr.workresultid asc
            )
        ${field$fragment}
      `,
    )
    //
    .otherwise((_: never) => []);

  return {
    edges: rows.map(row => ({ cursor: row.id, node: row })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: rows.length,
  };
}

/** @gqlField */
export async function applyFieldEdits(
  _: Mutation,
  ctx: Context,
  entity: ID,
  edits: FieldInput[],
): Promise<Task> {
  const t = new Task({ id: entity });

  if (t._type === "workinstance" && edits.length > 0) {
    const result = await sql.begin(async sql => {
      await setCurrentIdentity(sql, ctx);
      return await applyFieldEdits_(sql, ctx, t, edits);
    });
    console.debug(`applyFieldEdits: count: ${result.count}`);
  }

  return t;
}

/**
 * The purpose of this function is to abstract the process of applying
 * field-level edits to a Task (i.e. a workinstance's workresultinstances).
 *
 * - This is an UPSERT operation; it will create workresultinstances if necessary.
 * - This operation does not affect field-level status.
 */
export function applyFieldEdits_(
  sql: TxSql,
  _ctx: Context,
  t: Task,
  edits: FieldInput[],
) {
  assert(t._type === "workinstance", `cannot apply edits to a '${t._type}'`);
  assert(edits.length > 0, "must supply at least one edit");

  const edits_ = edits.flatMap(e => {
    const { type, id, suffix } = decodeGlobalId(e.field);
    assertUnderlyingType(["workresult", "workresultinstance"], type);
    switch (type) {
      case "workresult": {
        return [[id, valueInputToSql(e), valueInputTypeToSql(e)]];
      }
      case "workresultinstance": {
        return [
          [
            assertNonNull(suffix?.at(0)),
            valueInputToSql(e),
            valueInputTypeToSql(e),
          ],
        ];
      }
      default: {
        console.warn(`Underlying type '${type}' not expected in this context.`);
        return [];
      }
    }
  });

  // N.B. no `await` so we can use the return value as a `sql.Fragment`.
  return sql`
    with edits (field, value, type) as (
        values ${sql(edits_ as string[][])}
    )

    select t.*
    from
        edits,
        engine0.apply_field_edit(
            entity := ${t._id},
            field := edits.field,
            field_v := edits.value,
            field_vt := edits.type
        ) as t
  `;
}

export function valueInputToSql(input: FieldInput) {
  if (!input.value) return null;
  switch (true) {
    case "boolean" in input.value: {
      assert(
        input.valueType === "boolean",
        `invalid valueType '${input.valueType}' for boolean input`,
      );
      return input.value.boolean ? "true" : "false";
    }
    // case "decimal" in value:
    //   return value.decimal.toString();
    // case "duration" in value:
    //   return value.duration;
    case "id" in input.value: {
      assert(
        input.valueType === "entity",
        `invalid valueType '${input.valueType}' for entity input`,
      );
      return input.value.id;
    }
    case "number" in input.value: {
      assert(
        input.valueType === "number",
        `invalid valueType '${input.valueType}' for number input`,
      );
      return input.value.number.toString();
    }
    case "string" in input.value: {
      assert(
        input.valueType === "string",
        `invalid valueType '${input.valueType}' for string input`,
      );
      return input.value.string;
    }
    case "timestamp" in input.value: {
      assert(
        input.valueType === "timestamp",
        `invalid valueType '${input.valueType}' for timestamp input`,
      );
      const epoch = Date.parse(input.value.timestamp);
      if (Number.isNaN(epoch)) {
        console.warn(`Discarding invalid timestamp '${input.value.timestamp}'`);
        return null;
      }
      return epoch.toString();
    }
    default: {
      const _: never = input.value;
      console.warn(`Unhandled input variant '${JSON.stringify(input.value)}'`);
      return null;
    }
  }
}

export function valueInputTypeToSql(input: FieldInput) {
  switch (input.valueType) {
    case "boolean":
      return "Boolean";
    // case "decimal" in value:
    //   return "Number";
    // case "duration" in value:
    //   return "Duration";
    case "entity":
      return "Entity";
    case "number":
      return "Number";
    case "string":
      return "String";
    case "timestamp":
      return "Date";
    default: {
      const _: "unknown" = input.valueType;
      console.warn("Unknown input variant:", JSON.stringify(input));
      return null; // will get INNER JOIN'd out
    }
  }
}

type TaskHash = {
  hash: string;
  version: bigint;
};

export function hash$fragment(table_name: string) {
  return sql`encode((${sql(table_name)}.id || ':' || ${sql(table_name)}.version::text)::bytea, 'hex')`;
}

export async function computeTaskHash(
  sql: Sql | TxSql,
  t: Task,
): Promise<TaskHash> {
  assert(t._type === "workinstance");
  const [row] = await sql<[TaskHash]>`
    select ${hash$fragment("wi")} as hash, wi.version
    from public.workinstance as wi
    where wi.id = ${t._id}
  `;
  return assertNonNull(row);
}

/**
 * Rebase a Task onto another (Task) chain.
 * The net effect of this mutation is that the Task identified by `node` will
 * have its root (`Task.root`) set to the Task identified by `base`.
 *
 * @gqlMutationField
 */
export async function rebase(
  args: { node: ID; base: ID; location?: ID | null },
  ctx: Context,
): Promise<Task> {
  const base = new Task({ id: args.base });
  assertUnderlyingType("workinstance", base._type);
  const node = new Task({ id: args.node });
  return await match(node._type)
    .with("workinstance", async () => {
      // TODO: verify hash.
      // TODO: move to SQL + recursive/full chain update
      const result = await sql`
        update public.workinstance as node
        set workinstanceoriginatorworkinstanceid = base.workinstanceid,
            workinstancepreviousid = base.workinstanceid,
            workinstancemodifieddate = now(),
            workinstancemodifiedby = auth.current_identity(node.workinstancecustomerid, ${ctx.auth.userId})
        from public.workinstance as base
        where node.id = ${node._id} and base.id = ${base._id}
      `;
      assert(result.count === 1);
      return node;
    })
    .with("worktemplate", () =>
      sql.begin(async sql => {
        console.debug("rebase: requires instantiation");
        await setCurrentIdentity(sql, ctx);
        return await node.instantiate(
          {
            location: assertNonNull(args.location),
            chainPrev: base.id,
            chainRoot: base.id,
          },
          ctx,
          sql,
        );
      }),
    )
    .exhaustive();
}
