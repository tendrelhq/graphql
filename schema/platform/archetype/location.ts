import { sql } from "@/datasources/postgres";
import { decodeGlobalId } from "@/schema/system";
import type { Component } from "@/schema/system/component";
import { Task, type TaskConstructorArgs } from "@/schema/system/component/task";
import type { Refetchable } from "@/schema/system/node";
import type { Connection } from "@/schema/system/pagination";
import type { Context } from "@/schema/types";
import type { ID } from "grats";
import type { Trackable } from "../tracking";

/** @gqlType */
export class Location implements Component, Refetchable, Trackable {
  __typename = "Location" as const;
  _type: string;
  _id: string;

  constructor(
    public id: ID,
    private ctx: Context,
  ) {
    const { type, ...identifier } = decodeGlobalId(id);
    this._type = type;
    this._id = identifier.id;
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
        WITH location_type AS (
            SELECT
                c.custaguuid AS category,
                s.systaguuid AS parent
            FROM public.location AS l
            INNER JOIN public.custag AS c
                ON l.locationcategoryid = c.custagid
            INNER JOIN public.systag AS s
                ON c.custagsystagid = s.systagid
            WHERE
                l.locationuuid = ${this._id}
                AND s.systagtype = 'Trackable'
        )

        SELECT encode(('worktemplate:' || wt.id)::bytea, 'base64') AS id
        FROM location_type AS lt
        INNER JOIN public.worktemplateconstraint AS wtc
            ON
                lt.category = wtc.worktemplateconstraintconstraintid
                AND lt.parent = wtc.worktemplateconstraintconstrainedtypeid
        INNER JOIN public.worktemplate AS wt
            ON wtc.worktemplateconstrainttemplateid = wt.id
        WHERE wtc.worktemplateconstraintresultid IS null;
    `;

    console.debug("Location.tracking:", JSON.stringify(nodes, null, 2));

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

// CREATE TABLE IF NOT EXISTS worktemplateconstraint (
//     worktemplateconstraintid text NOT NULL,
//     worktemplateconstraintcreateddate timestamp(3) without time zone NOT NULL,
//     worktemplateconstraintmodifieddate timestamp(3) without time zone NOT NULL,
//     worktemplateconstraintmodifiedby bigint,
//     worktemplateconstraintrefid bigint,
//     worktemplateconstraintrefuuid text,
//     worktemplateconstraintconstrainedtypeid text NOT NULL,
//     worktemplateconstraintconstraintid text NOT NULL,
//     worktemplateconstrainttemplateid text NOT NULL,
//     worktemplateconstraintresultid text,
//     worktemplateconstraintcustomerid bigint NOT NULL,
//     worktemplateconstraintcustomeruuid text
// );
