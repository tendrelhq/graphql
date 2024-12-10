import { sql } from "@/datasources/postgres";
import type { Context } from "@/schema/types";
import type { ID } from "grats";
import type { StateMachine } from "../fsm";
import { Task } from "./task";

/**
 * Tasks can have an associated StateMachine, which defines a finite set of
 * states that the given Task can be in at any given time.
 *
 * @gqlField
 */
export async function fsm(
  t: Task,
  ctx: Context,
): Promise<StateMachine<Task> | null> {
  // `t` identifies as the "root" of the trackable chain. However, we must
  // account for the lazy instantiation case:
  if (t._type === "worktemplate") {
    // The implication here is that we have yet to even start the Task; we are
    // implicitly in the "Open" state. The only valid transition is thus to
    // start the Task itself. I'm not entirely sure that directly returning a
    // Task here is the right move. We might need to include some additional
    // information which highlights the nature of the transition, rather than
    // the just the Task itself. Without the additional context, we are forcing
    // the _user_ to infer the intent of the transition, e.g. does this
    // transition mean "start" or "stop"? We need to make this plainly obvious
    // to the user, which is potentially as simple as including a "action" or
    // operative in the response payload. There is, though, `Task.state`...
    return {
      active: null,
      transitions: {
        edges: [
          {
            cursor: t.id,
            node: t,
          },
        ],
        pageInfo: {
          hasNextPage: false,
          hasPreviousPage: false,
        },
        totalCount: 1,
      },
    };
  }

  if (t._type !== "workinstance") {
    console.warn(
      `Expected Task to have underlying type of: 'worktemplate' | 'workinstance', but got: '${t._type}'`,
    );
    throw "invariant violated";
  }

  const [fsm] = await sql<[{ active: ID; transitions: ID[] }]>`
    WITH RECURSIVE chain AS (
        SELECT *
        FROM public.workinstance
        WHERE id = ${t._id}
      UNION ALL
        SELECT *
        FROM chain, public.workinstance AS wi
        WHERE chain.workinstanceid = wi.workinstancepreviousid
    ),

    active AS (
        SELECT
            encode(('workinstance:' || chain.id)::bytea, 'base64') AS id,
            wt.worktemplateid AS _template
        FROM chain
        INNER JOIN public.systag
            ON chain.workinstancestatusid = systag.systagid
        INNER JOIN public.worktemplate AS wt
            ON chain.workinstanceworktemplateid = wt.worktemplateid
        WHERE systag.systagtype = 'In Progress'
        LIMIT 1
    ),

    transition AS (
        SELECT encode(('worktemplate:' || wt.id)::bytea, 'base64') AS id
        FROM public.worktemplatenexttemplate AS nt
        INNER JOIN public.worktemplate AS wt
            ON nt.worktemplatenexttemplatenexttemplateid = wt.worktemplateid
        WHERE
            nt.worktemplatenexttemplateprevioustemplateid IN (
                SELECT _template
                FROM active
            )
            AND nt.worktemplatenexttemplateviaresultid IS null
    )

    SELECT
        active.id AS "active",
        array_agg(transition.id) AS "transitions"
    FROM active, transition;
  `;

  return {
    active: new Task({ id: fsm.active }, ctx),
    transitions: {
      edges: fsm.transitions.map(t => ({
        cursor: t,
        node: new Task({ id: t }, ctx),
      })),
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: fsm.transitions.length,
    },
  };
}
