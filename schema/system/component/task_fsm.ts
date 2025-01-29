import { sql } from "@/datasources/postgres";
import { copyFromWorkTemplate } from "@/schema/application/resolvers/Mutation/copyFrom";
import type { Mutation } from "@/schema/root";
import type { Context } from "@/schema/types";
import { assert } from "@/util";
import { GraphQLError } from "graphql";
import type { ID } from "grats";
import { match } from "ts-pattern";
import type { StateMachine } from "../fsm";
import type { Edge } from "../pagination";
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

  type Plan = {
    active: ID;
    transitions: ID[];
  };

  const [plan] = await sql<[Plan?]>`
    with recursive
        chain as (
            select *
            from public.workinstance
            where id = ${t._id}
            union all
            select wi.*
            from chain, public.workinstance as wi
            where
                chain.workinstanceoriginatorworkinstanceid = wi.workinstanceoriginatorworkinstanceid
                and chain.workinstanceid = wi.workinstancepreviousid
        ),

        active as (
            select chain.id
            from chain
            inner join public.systag on chain.workinstancestatusid = systag.systagid
            where systag.systagtype in ('Open', 'In Progress')
            order by chain.workinstancepreviousid desc nulls last
            limit 1
        ),

        plan as (
            select pb.*
            from
                active,
                engine0.build_instantiation_plan(active.id) as pb,
                engine0.evaluate_instantiation_plan(
                    target := pb.target,
                    target_type := pb.target_type,
                    conditions := pb.ops
                ) as pc
            where pb.i_mode = 'lazy' and pc.result = true
        )

    select
        encode(('workinstance:' || active.id)::bytea, 'base64') as active,
        array_remove(
          array_agg(encode(('worktemplate:' || wt.id)::bytea, 'base64') order by wt.worktemplateorder, wt.worktemplateid),
          null
        ) as transitions
    from active
    left join plan on true
    left join public.worktemplate as wt on plan.target = wt.id
    group by active.id
  `;

  if (!plan) {
    // This is most notably the case on task close.
    // assert(false, "no fsm for task instance");
    return null;
  }

  return {
    active: new Task({ id: plan.active }, ctx),
    transitions: {
      edges: plan.transitions.map(transition => ({
        cursor: transition,
        node: new Task({ id: transition }, ctx),
      })),
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: plan.transitions.length,
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

/** @gqlType */
export type AdvanceResult = {
  /** @gqlField */
  fsm: Task;
  /** @gqlField */
  task: Task;
  /** @gqlField */
  instantiations: Edge<Task>[];
};

/** @gqlField */
export async function advance(
  _: Mutation,
  ctx: Context,
  opts: FsmOptions,
): Promise<AdvanceResult> {
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

  let instantiations: Edge<Task>[] = [];
  if (choice.id === f.active?.id) {
    console.debug("advance: operating on the active task");
    // When the "choice" is the active task, we advance that task's internal
    // state machine as defined by its own `advance` implementation.
    const r = await advance_active(ctx, choice, opts.task);
    instantiations = r.instantiations;
  } else {
    console.debug("advance: operating on the fsm");
    // Otherwise, the "choice" identifies a transition in the fsm.
    await advance_fsm(f, choice, opts, ctx);
  }

  console.debug("advance: success!");

  // Return the FSM, the (now previous) choice, as well as any new
  // instantiations resultant of this operation such that the caller can refresh
  // their local state without requiring another roundtrip.
  return {
    fsm: r,
    task: choice,
    instantiations,
  };
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
    .otherwise(() => assert(false, `unknown underlying type ${choice._type}`));

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
