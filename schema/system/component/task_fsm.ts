import { sql } from "@/datasources/postgres";
import { copyFromWorkTemplate } from "@/schema/application/resolvers/Mutation/copyFrom";
import type { Mutation } from "@/schema/root";
import type { Context } from "@/schema/types";
import { assert } from "@/util";
import { GraphQLError } from "graphql";
import type { ID } from "grats";
import { match } from "ts-pattern";
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
  // Only instances can participate in task-based state machines. We do not
  // support lazy instantiation.
  if (t._type !== "workinstance") {
    assert(
      false,
      "only instances can participate in task-based state machines",
    );
    return null;
  }

  const [fsm] = await sql<[{ active: ID; transitions: ID[] }?]>`
    with recursive
        chain as (
            select *
            from public.workinstance
            where id = ${t._id}
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
            where systag.systagtype in ('Open', 'In Progress')
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
    // assert(false, "no fsm for task instance");
    return null;
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
  console.log(`choice: ${choice}`);

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
    console.debug("advance: operating on the active task");
    // When the "choice" is the active task, we advance that task's internal
    // state machine as defined by its own `advance` implementation.
    await advance_active(choice, opts.task);
  } else {
    console.debug("advance: operating on the fsm");
    // Otherwise, the "choice" identifies a transition in the fsm.
    await advance_fsm(f, choice, opts, ctx);
  }

  console.debug("advance: success!");
  // We always return the fsm back to the client, allowing for single-roundtrip
  // state transitions and a highly responsive ux.
  return r;
}

export async function advance_fsm(
  fsm: StateMachine<Task>,
  choice: Task,
  opts: Omit<FsmOptions, "fsm">,
  ctx: Context,
): Promise<void> {
  assert(!!fsm.active, "fsm is not active");
  const parent = await fsm.active?.parent(); // n.b. db call
  assert(!!parent, "no parent for active task");
  assert(
    parent?._type === "location",
    `unexpected parent type '${parent?._type}'`,
  );

  await match(choice._type)
    .with("workinstance", () => {
      // This path is not currently possible: transitions are guaranteed to be
      // underlied by worktemplates.
      assert(false, "advance_fsm: choice underlied by workinstance");
    })
    .with("worktemplate", () =>
      sql.begin(tx =>
        copyFromWorkTemplate(
          tx,
          choice._id,
          {
            chain: "continue",
            previous: fsm.active?._id,
            // some extra options
            autoAssign: true,
            carryOverAssignments: true,
            fieldOverrides: opts.task.overrides,
            withStatus: "inProgress",
          },
          ctx,
        ),
      ),
    )
    .otherwise(() =>
      Promise.reject(`unknown underlying type '${choice._type}'`),
    );

  // // For now, we are going to assume that it is always a worktemplate.
  // if (choice._type !== "worktemplate") {
  //   // Note that this is not currently possible as the underlying type of a
  //   // `transitions` node will always be worktemplate. The one case I can
  //   // think of in which this would come into play is a sort of escape hatch
  //   // rule that would allow transitioning from a (potentially deeply) nested
  //   // state back to some high-level state. For example, in the MFT case it
  //   // might be desirable to transition back into production directly from a
  //   // nested downtime state, e.g. you started planned downtime but then were
  //   // derailed into unplanned downtime, and now you'd like jump back into
  //   // production without otherwise have to re-enter - only to exit - planned
  //   // downtime, which would be the default "backing out" behavior that exists
  //   // now. This would be rather simple to implement, I think. It is just a
  //   // matter of closing out the active task along with all intermediate
  //   // ancestors on the way up to the "choice". However, the question is
  //   // whether this is a valid plan in the generic case. We could just as
  //   // easily declare the fsm (really: worktemplatenexttemplate) to be acyclic
  //   // and thus never have this problem (excluding concurrency).
  //   throw "not supported - re-entrant transitions, i.e. whose underlying type is workinstance";
  // }
  //
  // await sql.begin(tx =>
  //   // FIXME: copyFrom does not correctly handle deduplication. Sigh.
  //   // This really shouldn't be part of its job anyways. However, I do think
  //   // this might suggest that we are using too low-level of an api in this
  //   // spot because at this level of abstraction we DO want to engage the rules
  //   // engine. Regardless, we can fix this later. CopyFrom is fine for now,
  //   // albeit rather overpowered and lacking proper guardrails :)
  //   copyFromWorkTemplate(
  //     tx,
  //     choice._id,
  //     {
  //       chain: "continue",
  //       previous: fsm.active?._id,
  //       // some extra options
  //       carryOverAssignments: true,
  //       fieldOverrides: opts.task.overrides,
  //       withStatus: "inProgress",
  //     },
  //     ctx,
  //   ),
  // );

  // More useful would be a changeset summary.
  return /* fsm */;
}

/**
 * Checks whether a Task is a valid advancement of an FSM.
 * A "valid advancement" means that it is _either_ the active task for the
 * given FSM _or_ it is one of the available transitions.
 *
 * Note that this is a potential source of conflict in the face of concurrency
 * and/or stale (client) data. We are not going to handle this right now.
 */
export function is_valid_advancement(fsm: StateMachine<Task>, t: Task) {
  if (fsm.active?.id === t.id) return true;
  return fsm.transitions?.edges.some(({ node }) => node.id === t.id) === true;
}
