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
import type { ID, Int } from "grats";
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
  async tracking(
    first?: Int | null,
    after?: ID | null,
  ): Promise<Connection<Trackable>> {
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
                      where systagparentid = 1 and systagtype = 'Trackable'
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
                  and task_state.systagtype in ('Open', 'In Progress')
          )

      select encode(('workinstance:' || og.id)::bytea, 'base64') as id
      from active_chain as c
      inner join public.workinstance as og on c._id = og.workinstanceid
      ;
    `;

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
