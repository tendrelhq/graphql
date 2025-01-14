import { sql } from "@/datasources/postgres";
import { decodeGlobalId } from "@/schema/system";
import type { Component } from "@/schema/system/component";
import {
  Task,
  type ConstructorArgs as TaskConstructorArgs,
} from "@/schema/system/component/task";
import type { Refetchable } from "@/schema/system/node";
import type { Connection } from "@/schema/system/pagination";
import type { Context } from "@/schema/types";
import { assert } from "@/util";
import type { ID } from "grats";
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

  constructor(
    args: ConstructorArgs,
    private ctx: Context,
  ) {
    // Note that Postgres will sometimes add newlines when we `encode(...)`.
    this.id = args.id.replace(/\n/g, "");

    const { type, ...identifier } = decodeGlobalId(this.id);
    this._type = type;
    this._id = identifier.id;
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
  async tracking(): Promise<Connection<Trackable> | null> {
    // Location's have a "category" [^1], which is really just a user-defined
    // type. We require that every user-defined type exist in a type hierarchy
    // whose root is a system-defined type (custagsystagid -> systag).
    //
    // In the "trackable" or "tracking system" world, there is a system-defined
    // type that identifies as the "root" of the "trackable type hierarchy". All
    // entities whose type exists in this hierarchy are "opted into" tracking.
    //
    // The question is: what are we tracking? For that, we must consult
    // worktemplatetype; we are looking for worktemplates whose type is the same
    // system-defined "root"[^2] of the "trackable type hierarchy" type as that
    // of our location category's parent (custagsystagid). Finally,
    // worktemplateconstraint allows us to join everything together:
    //
    //   location ^ worktemplateconstraint ^ worktemplatetype ^ worktemplate
    //
    // The glue in all of this is the "trackable type hierarchy". Membership in
    // this hierarchy has dual meaning, colloquially:
    //
    // - for locations: "track all relevant tasks at this location"
    // - for worktemplates: "i am a relevant task"
    //
    // [^1]: we really need to break this 1:1 relationship!
    // [^2]: in the future we can match on system-defined children as well
    const nodes = await sql<TaskConstructorArgs[]>`
      with
          -- check that the current location is indeed trackable
          is_trackable as (
              select l.locationid as _id, c.custaguuid as type_id
              from public.location as l
              inner join public.custag as c on l.locationcategoryid = c.custagid
              where
                  l.locationuuid = ${this._id}
                  and exists (
                      select 1
                      from public.systag as s
                      where c.custagsystagid = s.systagid and s.systagtype = 'Trackable'
                  )
          ),

          -- find all trackable tasks for this location
          trackable_task_t as (
              select is_trackable._id as _location_id, wt.worktemplateid as _id
              from is_trackable
              inner join public.worktemplateconstraint as wtc
                  on is_trackable.type_id = wtc.worktemplateconstraintconstraintid
                  and wtc.worktemplateconstraintresultid is null
              inner join public.worktemplate as wt
                  on wtc.worktemplateconstrainttemplateid = wt.id
              inner join public.worktemplatetype as wtt
                  on wt.id = wtt.worktemplatetypeworktemplateuuid
                  and wtt.worktemplatetypesystaguuid in (
                      select systaguuid
                      from public.systag
                      where systagparentid = 1 and systagtype = 'Trackable'
                  )
              where
                  wt.worktemplateenddate is null
                  or wt.worktemplateenddate > now()
          ),

          -- find all active (i.e. open or in progress) chains
          active_chain as (
              select distinct task.workinstanceoriginatorworkinstanceid as _id
              from trackable_task_t as ttt
              inner join public.workresult as field_t
                  on ttt._id = field_t.workresultworktemplateid
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
                  on field_t.workresultid = field.workresultinstanceworkresultid
                  and field.workresultinstancevalue = ttt._location_id::text
              inner join public.workinstance as task
                  on field.workresultinstanceworkinstanceid = task.workinstanceid
              inner join public.systag as task_state
                  on task.workinstancestatusid = task_state.systagid
                  and task_state.systagtype in ('Open', 'In Progress')
          )

      select encode(('workinstance:' || og.id)::bytea, 'base64') as id
      from active_chain as c
      inner join public.workinstance as og
          on c._id = og.workinstanceid
      ;
    `;

    assert(nodes.length !== 0, "no tracking set");

    return {
      edges: nodes.map(node => ({
        cursor: node.id,
        node: new Task(node, this.ctx),
      })),
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: nodes.length,
    };
  }
}
