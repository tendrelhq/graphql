import { sql } from "@/datasources/postgres";
import { copyFromWorkTemplate } from "@/schema/application/resolvers/Mutation/copyFrom";
import type { Mutation } from "@/schema/root";
import type { Context } from "@/schema/types";
import { GraphQLError } from "graphql";
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
            chain.workinstanceworktemplateid AS _template
        FROM chain
        INNER JOIN public.systag
            ON chain.workinstancestatusid = systag.systagid
        WHERE systag.systagtype = 'In Progress'
        ORDER BY workinstancepreviousid DESC NULLS LAST
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
        array_remove(array_agg(transition.id), null) AS "transitions"
    FROM active
    LEFT JOIN transition ON true
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
/** @gqlField */
export async function transition(
  _: Mutation,
  /**
   * The `id` of the root AST node. This is the node that defines the FSM for
   * the given Task chain.
   */
  id: ID,
  /**
   * The `id` of the "next Task" in the given Task chain. This must be a valid
   * transition for the given Task chain (as defined by the root's FSM).
   */
  into: ID,
  ctx: Context,
): Promise<Task> {
  const task = new Task({ id }, ctx);

  const f = await fsm(task, ctx);
  if (!f) {
    throw new GraphQLError(`Task '${task.id}' has no associated FSM`, {
      extensions: {
        code: "T_INVALID_TRANSITION",
      },
    });
  }

  // FIXME: Not quite right. Task.root will always be null with the way we've
  // (kinda confusingly) set things up right now. This is because it is always a
  // worktemplate! What we want here is to actually work off of the fsm.
  // Meaning: fsm.active. Our operation is thus something along the lines of:
  //  `f.active.into(next)`
  // If there is no active, then what? Such cases should probably be an error.
  // We can _force_ the existence of an underlying workinstance by saying that
  // if you have no fsm, your only option is to call `startTask`. This returns
  // a new Task whose underlying type is a workinstance. We might want an
  // intermediate screen on the client side, e.g. in the MFT case, to handle
  // this swapping of refs. This would be similar to what we do in the Checklist
  // app with the initial "preview" screen. I don't like this though as it
  // essentially forces the client to make TWO network calls just to get their
  // into the "In Progress" state... (1) mutation, (2) refetch... bleh.
  const root = await task.root();
  const next = new Task({ id: into }, ctx);
  // For now, we are going to assume that `next` is always a worktemplate. This
  // means our job is to simply instantiate the `next` template 'In Progress'.
  await sql.begin(async tx =>
    copyFromWorkTemplate(tx, next._id, {
      originator: root?._id,
      previous: f.active?._id,
      withStatus: "inProgress",
    }),
  );

  // Note that we *always* return the same Task as it was given to us. This
  // facilitates a better client experience by not requiring that they refetch
  // after they mutate.
  return new Task({ id }, ctx);
}
