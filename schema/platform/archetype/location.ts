import { type TxSql, sql } from "@/datasources/postgres";
import { decodeGlobalId } from "@/schema/system";
import type {
  Component,
  FieldDefinitionInput,
} from "@/schema/system/component";
import {
  Task,
  type ConstructorArgs as TaskConstructorArgs,
  type TaskStateName,
} from "@/schema/system/component/task";
import type { Refetchable } from "@/schema/system/node";
import type { Connection } from "@/schema/system/pagination";
import type { Context } from "@/schema/types";
import { assert, assertUnderlyingType, normalizeBase64 } from "@/util";
import type { ID, Int } from "grats";
import { match } from "ts-pattern";
import type { Trackable } from "../tracking";

export type ConstructorArgs = {
  id: ID;
};

/** @gqlType */
export class Location implements Component, Refetchable, Trackable {
  readonly __typename = "Location" as const;
  readonly _type: string;
  readonly _id: string;
  readonly id: ID;

  constructor(args: ConstructorArgs) {
    this.id = normalizeBase64(args.id);
    const { type, id } = decodeGlobalId(this.id);
    this._type = assertUnderlyingType("location", type);
    this._id = id;
  }

  /**
   * IANA time zone identifier for this Location.
   *
   * @gqlField
   */
  async timeZone(): Promise<string> {
    const [row] = await sql`
      SELECT locationtimezone FROM public.location WHERE locationuuid = ${this._id}
    `;
    return row.locationtimezone;
  }

  /**
   * Entrypoint into the "tracking system(s)" for the given Location.
   *
   * @gqlField
   */
  async tracking(
    first?: Int | null,
    after?: ID | null,
    withStatus?: TaskStateName[] | null,
  ): Promise<Connection<Trackable>> {
    const statuses = withStatus?.map(s =>
      match(s)
        .with("Open", () => "Open")
        .with("InProgress", () => "In Progress")
        .with("Closed", () => "Complete")
        .exhaustive(),
    ) ?? ["Open", "In Progress"];
    assert(statuses.length > 0, "must provided at least one status");

    // At a given location, the "tracking systems" correspond to worktemplates
    // with a worktemplatetype tag of `Trackable`. This tag is a system-defined
    // type tag used specifically for identifying templates that are "opted
    // into" tracking (e.g. as in Runtime). Furthermore, we must inspect
    // worktemplateconstraint to identify which among these templates are
    // instantiable at the given location. Note that *any* location where a
    // "trackable" template can be instantiated is considered itself to be
    // "trackable" (e.g. in the case of Runtime's "home screen"). We do *not*
    // support opting locations *out of* tracking while also maintaining
    // instantiability of "trackable" templates. It is therefore an all or
    // nothing approach: either a location has "trackable" templates or it does
    // not. This is something that can (and probably will) change in the entity
    // model via arbitrary many to many tagging.
    const nodes = await sql<TaskConstructorArgs[]>`
      with
          -- find all trackable tasks for this location
          trackable_task_t as (
              select l.locationid as _location_id, wt.worktemplateid as _id
              from public.location as l
              inner join public.custag as c on l.locationcategoryid = c.custagid
              inner join public.worktemplateconstraint as wtc
                  on  c.custaguuid = wtc.worktemplateconstraintconstraintid
                  and wtc.worktemplateconstraintresultid is null
              inner join public.worktemplate as wt
                  on  wtc.worktemplateconstrainttemplateid = wt.id
                  and (
                      wt.worktemplateenddate is null
                      or wt.worktemplateenddate > now()
                  )
              inner join public.worktemplatetype as wtt
                  on  wt.id = wtt.worktemplatetypeworktemplateuuid
                  and wtt.worktemplatetypesystaguuid in (
                      select systaguuid
                      from public.systag
                      where systagparentid = 882 and systagtype = 'Trackable'
                  )
              where l.locationuuid = ${this._id}
          ),

          -- find all active (i.e. open or in progress) chains
          active_chain as (
              select distinct task.workinstanceoriginatorworkinstanceid as _id
              from trackable_task_t as ttt
              inner join public.workresult as field_t
                  on  ttt._id = field_t.workresultworktemplateid
                  and field_t.workresulttypeid = (
                      select systagid
                      from public.systag
                      where systagparentid = 699 and systagtype = 'Entity'
                  )
                  and field_t.workresultentitytypeid = (
                      select systagid
                      from public.systag
                      where systagparentid = 849 and systagtype = 'Location'
                  )
                  and field_t.workresultisprimary = true
              inner join public.workresultinstance as field
                  on  field_t.workresultid = field.workresultinstanceworkresultid
                  and field.workresultinstancevalue = ttt._location_id::text
              inner join public.workinstance as task
                  on  ttt._id = task.workinstanceworktemplateid
                  and field.workresultinstanceworkinstanceid = task.workinstanceid
              inner join public.systag as task_state
                  on task.workinstancestatusid = task_state.systagid
                  and task_state.systagtype in ${sql(statuses)}
          )

      select encode(('workinstance:' || og.id)::bytea, 'base64') as id
      from active_chain as c
      inner join public.workinstance as og on c._id = og.workinstanceid
    `;

    return {
      edges: nodes.map(node => ({
        cursor: node.id,
        node: new Task(node),
      })),
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: nodes.length,
    };
  }

  async createTemplate(
    args: {
      name: string;
      order?: number | null;
      fields: FieldDefinitionInput[];
      types: string[];
    },
    ctx: Context,
    sql: TxSql,
  ): Promise<Task> {
    const [row] = await sql<[{ customer_id: ID; id: ID; me: bigint }]>`
      with cte as (
        select
          customeruuid as customer_id,
          locationuuid as task_parent_id,
          auth.current_identity(customerid, ${ctx.auth.userId}) as me
        from public.location
        inner join public.customer on locationcustomerid = customerid
        where locationuuid = ${this._id}
      )
      select
        cte.customer_id,
        cte.me,
        encode(('worktemplate:' || t.id)::bytea, 'base64') as id
      from cte, legacy0.create_task_t(
        customer_id := cte.customer_id,
        language_type := ${ctx.req.i18n.language},
        task_name := ${args.name},
        task_parent_id := cte.task_parent_id,
        task_order := ${args.order ?? 0},
        modified_by := cte.me
      ) as t;
    `;

    const t = new Task(row);
    {
      const r = await sql`
        select 1
        from
          public.systag as s,
          legacy0.create_template_type(
            template_id := ${t._id},
            systag_id := s.systaguuid,
            modified_by := ${row.me}
          )
        where s.systagparentid = 882 and s.systagtype in ${sql(args.types)}
      `;
      assert(r.count === args.types.length);
    }

    for (const field of args.fields) {
      const fieldType = match(field.type)
        .with("boolean", () => "Boolean")
        .with("entity", () => "Entity")
        .with("number", () => "Number")
        .with("string", () => "String")
        .with("timestamp", () => "Date")
        .otherwise(s => {
          // N.B. so the compiler will warn us if we add anything.
          const _: "unknown" = s;
          return null;
        });
      const r = await sql`
        select 1
        from legacy0.create_field_t(
          customer_id := ${row.customer_id},
          language_type := ${ctx.req.i18n.language},
          template_id := ${t._id},
          field_description := ${field.description ?? null},
          field_is_draft := ${field.isDraft ?? false},
          field_is_primary := ${field.isPrimary ?? false},
          field_is_required := false,
          field_name := ${field.name},
          field_order := ${field.order ?? 0},
          field_reference_type := null,
          field_type := ${fieldType},
          field_value := null,
          field_widget := ${field.widget ?? null},
          modified_by := ${row.me}
        );
      `;
      assert(r.count === 1);
    }

    return t;
  }

  async insertChild(
    args: {
      name: string;
      /**
       * Default display order.
       */
      order?: number;
      type: string;
      timezone?: string;
    },
    ctx: Context,
    sql: TxSql,
  ): Promise<Location> {
    const [row] = await sql<[ConstructorArgs]>`
      with cte as (
        select
          customeruuid as customer_id,
          locationuuid as id,
          locationtimezone as timezone,
          auth.current_identity(customerid, ${ctx.auth.userId}) as modified_by
        from public.location
        inner join public.customer on locationcustomerid = customerid
        where locationuuid = ${this._id}
      )
      select encode(('location:' || t.id)::bytea, 'base64') as id
      from cte, legacy0.create_location(
          customer_id := cte.customer_id,
          language_type := ${ctx.req.i18n.language},
          location_name := ${args.name},
          location_parent_id := cte.id,
          location_timezone := coalesce(${args.timezone ?? null}, cte.timezone),
          location_typename := ${args.type},
          modified_by := cte.modified_by
      ) as t;
    `;

    const l = new Location(row);
    if (args.order) {
      // HACK: use Keller's new API.
      await sql`
        update public.location
        set locationcornerstoneorder = ${args.order}
        where locationuuid = ${l._id}
      `;
    }

    return l;
  }
}
