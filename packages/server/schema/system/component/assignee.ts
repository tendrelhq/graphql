import { sql } from "@/datasources/postgres";
import type { Context } from "@/schema/types";
import { normalizeBase64 } from "@/util";
import type { ID } from "grats";
import { decodeGlobalId } from "..";
import type { Component } from "../component";
import type { Refetchable } from "../node";
import type { Overridable } from "../overridable";
import type { Timestamp } from "../temporal";

/**
 * Identifies an Entity as being assignable to another Entity.
 *
 * @gqlInterface
 */
export interface Assignable extends Component {
  /**
   * @gqlField
   * @killsParentOnException
   */
  readonly id: ID;
}

/**
 * Encapsulates the "who" and "when" associated with the act of "assignment".
 * For example, both Tasks and Workers implement Assignable and therefore a Task
 * can be assigned to a Worker and vice versa ("assignment" is commutative). In
 * this example, the "who" will always be the Worker and the "when" will be the
 * timestamp when these two Entities were assigned.
 *
 * @gqlType
 */
export class Assignment implements Refetchable {
  readonly __typename = "Assignment" as const;
  readonly _type: string;
  readonly _id: string;
  readonly _field?: string;
  readonly id: ID;

  constructor(
    args: { id: ID },
    private ctx: Context,
  ) {
    this.id = normalizeBase64(args.id);
    const { type, id, suffix } = decodeGlobalId(this.id);
    this._type = type;
    this._id = id;
    this._field = suffix?.at(0);
  }

  /**
   * NOT YET IMPLEMENTED - will always return null!
   *
   * @gqlField
   */
  async assignedAt(): Promise<Overridable<Timestamp> | null> {
    console.warn("Assignment.assignedAt is not yet implemented");
    return null;
  }

  /**
   * @gqlField
   */
  async assignedTo(): Promise<Assignable | null> {
    const [row] = await sql<[{ id: string }?]>`
      WITH cte AS (
          SELECT wri.workresultinstancevalue::bigint AS id
          FROM public.workresultinstance as wri
          WHERE
              wri.workresultinstanceworkinstanceid IN (
                  SELECT workinstanceid
                  FROM public.workinstance
                  WHERE id = ${this._id}
              )
              AND wri.workresultinstanceworkresultid IN (
                  SELECT workresultid
                  FROM public.workresult
                  WHERE id = ${this._field ?? null}
              )
              AND nullif(wri.workresultinstancevalue, '') IS NOT null
      )
      SELECT encode(('worker:' || w.workerinstanceuuid)::bytea, 'base64') AS id
      FROM cte, public.workerinstance AS w
      WHERE cte.id = w.workerinstanceid
    `;

    if (row) {
      // TODO: migrate to grats.
      return {
        __typename: "Worker",
        id: row.id,
      };
    }

    return null;
  }
}

/** @gqlInput */
export type AssignmentInput = {
  // assignedAt?: Overridable<TimestampInput> | null;
  assignedTo: ID;
};
