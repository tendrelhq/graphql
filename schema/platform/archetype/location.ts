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
          location_type as (
              select c.custaguuid as category, s.systaguuid as parent
              from public.location as l
              inner join public.custag as c on l.locationcategoryid = c.custagid
              inner join public.systag as s on c.custagsystagid = s.systagid
              where l.locationuuid = ${this._id} and s.systagtype = 'Trackable'
          )

      select encode(('worktemplate:' || wt.id)::bytea, 'base64') as id
      from location_type as lt
      inner join
          public.worktemplateconstraint as wtc
          on lt.category = wtc.worktemplateconstraintconstraintid
          and wtc.worktemplateconstraintconstrainedtypeid in (
              select systaguuid
              from public.systag
              where systagparentid = 849 and systagtype = 'Location'
          )
      inner join public.worktemplate as wt on wtc.worktemplateconstrainttemplateid = wt.id
      where wtc.worktemplateconstraintresultid is null
;
    `;

    assert(nodes.length !== 0, "no tracking set");

    // TODO: we can potentially put the aggregate on the edge, and pass in the
    // location when we construct the edge. This gives us knowledge of our
    // parent in that location (which we don't - and can't - have in the node
    // itself, at least when it is a template). In order for the aggregate to
    // participate in the usual single-roundtrip-rerender, we'd need `advance`
    // to return an edge, as opposed to just the node.
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
