import { sql } from "@/datasources/postgres";
import type { Mutation } from "@/schema/root";
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
  // I wonder if we can get by, for now, with only allowing FSMs in the context
  // of an underlying worktemplate. What is the implication of a workinstance
  // underlying an fsm-capable Task? Not a whole lot. Especially considering
  // worktemplatenexttemplate is concerned with, well, worktemplates! I think we
  // can just bail out here. It does seem to suggest that we have potentially
  // misplaced our types a bit.
  if (t._type !== "worktemplate") {
    return null;
  }

  // `t` identifies as the "root" of the trackable chain. In practice, the
  // underlying type of a "top-level" task will almost always be a worktemplate
  // e.g. in the MFT case as a Location's tracking set. The implication of a
  // worktemplate underlying `t` is that we have no direct pointer to the chain;
  // we are missing context such that we can identify the *specific* chain in
  // whatever hierarchy we are currently navigating. In practice this means
  // knowing what Location constitutes the parent of our (workinstance) chain.
  // We don't have that information here. We "just have a worktemplate", which
  // can potentially exist (in its instance form) at several Locations :P
  // For now we will cheat by using worktemplatesiteid. Note that this really
  // throws a wrench in the Refetchable concept because it implies that Task
  // cannot be refetched! Perhaps we can allow for it by way of `parent` though,
  // i.e. when a Task (worktemplate underlying) is refetched, its fsm is
  // actually a connection that represents *all active chains*, regardless of
  // location. We can add an argument to the connection that would allow us to
  // filter these chains based on their parent (e.g. Location). This is ends up
  // being rather ergonomically awkward since, in practice, you will be
  // accessing Task.fsm within some other "trackable hierarchy", e.g. Location.
  // Perhaps we can model this in ctx...?
  const [fsm] = await sql<[{ active: ID; transitions: ID[] }?]>`
    WITH RECURSIVE chain AS (
        SELECT *
        FROM public.workinstance
        WHERE
            workinstanceworktemplateid IN (
                SELECT worktemplateid
                FROM public.worktemplate
                WHERE worktemplate.id = ${t._id}
            )
            AND workinstancestatusid IN (
                SELECT systagid
                FROM public.systag
                WHERE
                    systagparentid = 705
                    AND systagtype IN ('Open', 'In Progress')
            )
      UNION ALL
        SELECT wi.*
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
            AND nt.worktemplatenexttemplateviaworkresultid IS null
    )

    SELECT
        active.id AS "active",
        array_agg(transition.id) AS "transitions"
    FROM active, transition
    GROUP BY active.id;
  `;

  if (!fsm) {
    // This is, potentially, the lazy instantiation case. We indicate this by
    // including a transition that, semantically, means "start this task".
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

  return {
    active: new Task({ id: fsm.active }, ctx),
    transitions: {
      edges: fsm.transitions.map(id => ({
        cursor: id,
        node: new Task({ id: id }, ctx),
      })),
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: fsm.transitions.length,
    },
  };
}

// As opposed to this, which I think makes more sense based on what we want to
// do with MFT...
export async function transition(
  _: Mutation,
  id: ID,
  into: ID,
  ctx: Context,
): Promise<Task> {
  // Note that we *always* return the same Task as it was given to us. This
  // facilitates a better client experience by not requiring that they refetch
  // after they mutate.
  return new Task({ id }, ctx);
}
