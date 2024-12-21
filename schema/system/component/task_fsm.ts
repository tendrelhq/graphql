import { sql } from "@/datasources/postgres";
import { copyFromWorkTemplate } from "@/schema/application/resolvers/Mutation/copyFrom";
import type { Mutation } from "@/schema/root";
import type { Context } from "@/schema/types";
import { GraphQLError } from "graphql";
import type { ID } from "grats";
import type { StateMachine } from "../fsm";
import { Task, type TaskInput, advance as advance_active } from "./task";

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
  // we are missing context such that we can't identify the *specific* chain in
  // whatever hierarchy we are currently navigating. In practice this means
  // knowing what Location constitutes the parent of our (workinstance) chain.
  // We don't have that information here. We "just have a worktemplate", which
  // can potentially exist (in its instance form) at several Locations :P
  // For now we make the assumption that we are always in MFT world and work
  // templates map 1:1 to locations.
  const [fsm] = await sql<[{ active: ID; transitions: ID[] }?]>`
    with recursive
        chain as (
            select *
            from public.workinstance
            where
                workinstanceworktemplateid in (
                    select wt.worktemplateid from public.worktemplate as wt where wt.id = ${t._id}
                )
                and workinstancestatusid in (
                    select s.systagid
                    from public.systag as s
                    where s.systagparentid = 705 and s.systagtype in ('Open', 'In Progress')
                )
            union all
            select wi.*
            from chain, public.workinstance as wi
            where chain.workinstanceid = wi.workinstancepreviousid
        ),

        active as (
            select
                chain.workinstanceworktemplateid as _template,
                encode(('workinstance:' || chain.id)::bytea, 'base64') as id
            from chain
            inner join public.systag on chain.workinstancestatusid = systag.systagid
            where systag.systagtype = 'In Progress'
            order by chain.workinstancepreviousid desc nulls last
            limit 1
        ),

        transition as (
            select encode(('worktemplate:' || wt.id)::bytea, 'base64') as id
            from public.worktemplatenexttemplate as nt
            inner join
                public.worktemplate as wt
                on nt.worktemplatenexttemplatenexttemplateid = wt.worktemplateid
            where
                exists (
                    select 1
                    from active
                    where active._template = nt.worktemplatenexttemplateprevioustemplateid
                )
                and nt.worktemplatenexttemplateviaworkresultid is null
        )

    select active.id as active, array_remove(array_agg(transition.id), null) as transitions
    from active
    left join transition on true
    group by active.id
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

/** @gqlInput */
export type FsmOptions = {
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
   * - if the active task === the given task, advance the task according to
   *   its own internal state machine as defined by {@link advance_active}
   * - otherwise, advance the fsm using the given task as the intended next
   *   state
   */
  task: TaskInput;
};

/** @gqlField */
export async function advance(
  _: Mutation,
  ctx: Context,
  opts: FsmOptions,
): Promise<Task> {
  const r = new Task({ id: opts.fsm }, ctx);
  console.log(`fsm: ${r}`);

  const f = await fsm(r, ctx);
  if (!f) {
    throw new GraphQLError(`Task ${r} has no associated FSM`, {
      extensions: {
        code: "T_INVALID_TRANSITION",
      },
    });
  }

  const choice = new Task(opts.task, ctx);
  // Note that this is a potential source of conflict in the face of
  // concurrency and/or stale (client) data.
  if (is_valid_advancement(f, choice) === false) {
    throw new GraphQLError(
      `Task ${choice} is not a valid choice for FSM ${r}`,
      {
        extensions: {
          code: "T_INVALID_TRANSITION",
        },
      },
    );
  }

  if (choice.id === f.active?.id) {
    // When the "choice" is the active task, we advance that task's internal
    // state machine as defined by its own `advance` implementation.
    await advance_active(choice, opts.task);
  } else {
    // Otherwise, the "choice" identifies a transition in the fsm.
    await advance_fsm(f, choice, opts, ctx);
  }

  // We always return a fresh copy of the fsm back to the client. This allows
  // for single-roundtrip state transitions which in turn enable highly
  // responsive ux.
  return r;
}

export async function advance_fsm(
  fsm: StateMachine<Task>,
  choice: Task,
  opts: Omit<FsmOptions, "fsm">,
  ctx: Context,
): Promise<StateMachine<Task>> {
  // For now, we are going to assume that it is always a worktemplate.
  if (choice._type !== "worktemplate") {
    // Note that this is not currently possible as the underlying type of a
    // `transitions` node will always be worktemplate. The one case I can
    // think of in which this would come into play is a sort of escape hatch
    // rule that would allow transitioning from a (potentially deeply) nested
    // state back to some high-level state. For example, in the MFT case it
    // might be desirable to transition back into production directly from a
    // nested downtime state, e.g. you started planned downtime but then were
    // derailed into unplanned downtime, and now you'd like jump back into
    // production without otherwise have to re-enter - only to exit - planned
    // downtime, which would be the default "backing out" behavior that exists
    // now. This would be rather simple to implement, I think. It is just a
    // matter of closing out the active task along with all intermediate
    // ancestors on the way up to the "choice". However, the question is
    // whether this is a valid plan in the generic case. We could just as
    // easily declare the fsm (really: worktemplatenexttemplate) to be acyclic
    // and thus never have this problem (excluding concurrency).
    throw "not supported - re-entrant transitions, i.e. whose underlying type is workinstance";
  }

  // console.log("advance_fsm: overrides", opts.task.overrides);

  await sql.begin(tx =>
    // FIXME: copyFrom does not correctly handle deduplication. Sigh.
    // This really shouldn't be part of its job anyways. However, I do think
    // this might suggest that we are using too low-level of an api in this
    // spot because at this level of abstraction we DO want to engage the rules
    // engine. Regardless, we can fix this later. CopyFrom is fine for now,
    // albeit rather overpowered and lacking proper guardrails :)
    copyFromWorkTemplate(
      tx,
      choice._id,
      {
        chain: "continue",
        previous: fsm.active?._id,
        // some extra options
        carryOverAssignments: true,
        fieldOverrides: opts.task.overrides,
        withStatus: "inProgress",
      },
      ctx,
    ),
  );

  // More useful would be a changeset summary.
  return fsm;
}

/**
 * Checks whether a Task is a valid advancement of an FSM.
 * A "valid advancement" means that it is _either_ the active task for the
 * given FSM _or_ it is one of the available transitions.
 */
export function is_valid_advancement(fsm: StateMachine<Task>, t: Task) {
  if (fsm.active?.id === t.id) return true;
  return fsm.transitions?.edges.some(({ node }) => node.id === t.id);
}
