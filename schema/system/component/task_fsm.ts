import { type Sql, type TxSql, sql } from "@/datasources/postgres";
import { copyFromWorkTemplate } from "@/schema/application/resolvers/Mutation/copyFrom";
import { DiagnosticKind, type Result } from "@/schema/result";
import type { Mutation } from "@/schema/root";
import type { Context } from "@/schema/types";
import { assert, assertNonNull, compareBase64 } from "@/util";
import type { ID } from "grats";
import type { Fragment } from "postgres";
import { match } from "ts-pattern";
import { decodeGlobalId } from "..";
import type { StateMachine } from "../fsm";
import type { Edge } from "../pagination";
import { type AdvanceTaskOptions, Task, advanceTask } from "./task";

export function fsm$fragment(t: Task): Fragment {
  assert(t._type === "workinstance");
  return sql`
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
}

export type FSM = {
  active: ID;
  transitions?: ID[] | null;
};

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
  return await fsm_(sql, t, ctx);
}

export async function fsm_(
  tx: Sql | TxSql,
  t: Task,
  ctx: Context,
): Promise<StateMachine<Task> | null> {
  if (t._type !== "workinstance") {
    assert(
      false,
      "only instances can participate in task-based state machines",
    );
    return null;
  }

  const [fsm] = await tx<[FSM?]>`${fsm$fragment(t)}`;
  if (!fsm) {
    // This is most notably the case on task close.
    return null;
  }

  return {
    hash: (await t.hash()) as string, // hash is only null when `t` is a template
    active: new Task({ id: fsm.active }, ctx),
    transitions: {
      edges:
        fsm.transitions?.map(transition => ({
          cursor: transition,
          node: new Task({ id: transition }, ctx),
        })) ?? [],
      pageInfo: {
        hasNextPage: false,
        hasPreviousPage: false,
      },
      totalCount: fsm.transitions?.length ?? 0,
    },
  };
}

/** @gqlInput */
export type AdvanceFsmOptions = {
  /**
   * The unique identifier of the FSM on which you are operating. Wherever you
   * access the `fsm` field of a `Task`, that task's id should go here.
   */
  fsm: AdvanceTaskOptions;
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
  task: AdvanceTaskOptions;
};

/** @gqlType */
export type AdvanceFsmEffect = {
  __typename: "AdvanceFsmEffect";

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
  opts: AdvanceFsmOptions,
): Promise<Result<AdvanceFsmEffect>> {
  const root = new Task({ id: opts.fsm.id }, ctx);
  console.debug(`fsm: ${root.id}`);
  assert(root._type === "workinstance");

  return await sql.begin(async tx => {
    const [fsm] = await tx<[FSM?]>`${fsm$fragment(root)}`;
    if (!fsm) {
      return {
        __typename: "Diagnostic",
        code: DiagnosticKind.no_associated_fsm,
      };
    }

    assert(!!opts.fsm.hash);
    if (!opts.fsm.hash) {
      return {
        __typename: "Diagnostic",
        code: DiagnosticKind.hash_is_required,
      };
    }

    const rootHash = assertNonNull(await root.hash());
    if (rootHash !== opts.fsm.hash) {
      console.warn("WARNING: Root hash mismatch precludes advancement");
      console.debug(`| root: ${root.id}`);
      console.debug(`| ours: ${rootHash}`);
      console.debug(`| theirs: ${opts.fsm.hash}`);
      return {
        __typename: "Diagnostic",
        code: DiagnosticKind.hash_mismatch_precludes_operation,
      };
    }

    const choice = new Task(opts.task, ctx);
    console.debug(`choice: ${choice.id}`);

    if (is_valid_advancement(fsm, choice) === false) {
      console.warn("WARNING: Task is not a valid choice");
      console.debug(`| root: ${root.id}`);
      console.debug(`| choice: ${choice.id}`);
      return {
        __typename: "Diagnostic",
        code: DiagnosticKind.candidate_choice_unavailable,
      };
    }

    if (compareBase64(choice.id, fsm.active)) {
      console.debug("advance: operating on the active task");
      // When the "choice" is the active task, we advance that task's internal
      // state machine as defined by its own `advance` implementation.
      const r = await advanceTask(tx, ctx, choice, opts.task);
      if ("code" in r) {
        return r;
      }
      return {
        __typename: "AdvanceFsmEffect",
        fsm: root,
        ...r,
      };
    }

    // Otherwise, the "choice" identifies a transition in the fsm.
    console.debug("advance: operating on the fsm");
    return await advanceFsm(tx, root, fsm, choice, opts, ctx);
  });
}

// export function createFsmHash(root: ID, fsm: FSM) {
//   const h = crypto.createHash("sha256").update(root).update(fsm.active);
//   for (const t of fsm.transitions ?? []) {
//     h.update(t);
//   }
//   return h.digest("hex");
// }

export async function advanceFsm(
  sql: TxSql,
  root: Task,
  fsm: FSM,
  choice: Task,
  opts: Omit<AdvanceFsmOptions, "fsm">,
  ctx: Context,
): Promise<Result<AdvanceFsmEffect>> {
  assert(!!fsm.active, "fsm is not active");
  return await match(choice._type)
    .with("workinstance", () => {
      // This path is not currently possible: transitions are guaranteed to be
      // underlied by worktemplates.
      assert(false, "advance_fsm: choice underlied by workinstance");
      return {
        __typename: "Diagnostic" as const,
        code: DiagnosticKind.expected_template_got_instance,
      };
    })
    .with("worktemplate", async () => {
      const _ = await copyFromWorkTemplate(
        sql,
        choice._id,
        {
          chain: "continue",
          previous: decodeGlobalId(fsm.active).id,
          // some extra options
          autoAssign: true,
          carryOverAssignments: true,
          fieldOverrides: opts.task.overrides,
          withStatus: "inProgress",
        },
        ctx,
      );
      return {
        __typename: "AdvanceFsmEffect" as const,
        fsm: root,
        task: choice, // now previous
        instantiations: [],
      };
    })
    .otherwise(() => {
      assert(false, `unknown underlying type ${choice._type}`);
      return {
        __typename: "Diagnostic" as const,
        code: DiagnosticKind.invalid_type,
      };
    });
}

/**
 * Checks whether a Task is a valid advancement of an FSM.
 * A "valid advancement" means that it is _either_ the active task for the
 * given FSM _or_ it is one of the available transitions.
 *
 * Note that this is a potential source of conflict in the face of concurrency
 * and/or stale (client) data. We are not going to handle this right now.
 */
export function is_valid_advancement(fsm: FSM, t: Task) {
  if (compareBase64(fsm.active, t.id)) return true;
  return fsm.transitions?.some(id => compareBase64(id, t.id)) === true;
}
