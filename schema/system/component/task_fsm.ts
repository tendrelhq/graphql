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

/** @gqlField */
export async function advance(
  _: Mutation,
  ctx: Context,
  args: {
    /**
     * The unique identifier of the FSM on which you are operating. Wherever you
     * access the `fsm` field of a `Task`, that task's id should go here.
     */
    fsm: ID;
    /**
     * The unique identifier of a `Task` _within_ the aforementioned FSM. These
     * are the tasks available as the `active` and/or `transitions` fields within
     * a task's `fsm` field. Advancing a FSM by way of this argument works as
     * follows:
     * - if the given `task` is Open, move it to In Progress and make it the
     *   active task in the given `fsm`.
     * - if the given `task` is In Progress, move it to Closed and transition the
     *   overall `fsm` as determined by the rules that define it. Note that there
     *   are by default no "on close" rules, and thus the result of this operation
     *   is effectively to revert the `fsm` to the state it was in _prior to_
     *   advancing into its current state. Note that this might imply putting the
     *   `fsm` back into its initial (typically "idle") state.
     * - if the given `task` is Closed, this operation is a no-op.
     */
    task: ID;
  },
): Promise<Task> {
  const r = new Task({ id: args.fsm }, ctx);
  console.log(`Root (fsm): ${r}`);

  const f = await fsm(r, ctx);
  if (!f) {
    throw new GraphQLError(`Task ${r} has no associated FSM`, {
      extensions: {
        code: "T_INVALID_TRANSITION",
      },
    });
  }

  const t = new Task({ id: args.task }, ctx);
  // TODO: ensure f ^ t, else throw T_INVALID_TRANSITION

  // This is where we need to switch. If the given `task` *is the active task*
  // then we must take the appropriate action, e.g. 'in progress' if 'open',
  // 'close' if 'in progress'.
  if (f.active?.id === t.id) {
    // For now, we will assume that this is happening via a "stop task" flow,
    // e.g. in MFT where we are either "End xxx Downtime" or "End Production".
    // Our job here is simply to close out the given task.
    await sql`
      UPDATE public.workinstance
      SET workinstancestatusid = 710
      WHERE id = ${t._id};
    `;
    // et voilá!
    return r;
  }

  // For now, we are going to assume that `next` is always a worktemplate. This
  // means our job is to simply instantiate the `next` template 'In Progress'.
  await sql.begin(async tx =>
    // FIXME: copyFrom does not correctly handle deduplication. Sigh.
    // This really shouldn't be part of its job anyways. However, I do think
    // this might suggest that we are using too low-level of an api in this
    // spot because at this level of abstraction we DO want to engage the rules
    // engine. Regardless, we can fix this later. CopyFrom is fine for now,
    // albeit rather overpowered and lacking proper guardrails :)
    copyFromWorkTemplate(tx, t._id, {
      // FIXME: missing originator, and so every transition task will have its
      // originator set to itself. This is not right, but will not hurt anything
      // since we only look at previous (via a RECURSIVE cte) when building the
      // chain that forms the basis of the FSM.
      previous: f.active?._id,
      withStatus: "inProgress",
    }),
  );

  // Note that we *always* return the FSM that was given to us originally. This
  // facilitates a better client experience by not requiring that they refetch
  // after they mutate.
  return r;
}
