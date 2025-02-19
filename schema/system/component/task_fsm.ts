import { type Sql, type TxSql, sql } from "@/datasources/postgres";
import { type Diagnostic, DiagnosticKind } from "@/schema/result";
import type { Mutation } from "@/schema/root";
import type { Context } from "@/schema/types";
import { assert, assertNonNull, compareBase64 } from "@/util";
import type { ID } from "grats";
import type { Fragment } from "postgres";
import { match } from "ts-pattern";
import { decodeGlobalId } from "..";
import type { StateMachine } from "../fsm";
import type { Edge } from "../pagination";
import {
  type AdvanceTaskOptions,
  Task,
  advanceTask,
  applyAssignments$fragment,
  applyEdits$fragment,
} from "./task";

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
  fsm: AdvanceTaskOptions;
  task: AdvanceTaskOptions;
};

/** @gqlType */
export type AdvanceTaskStateMachineResult = {
  /** @gqlField */
  root: Task;
  /** @gqlField */
  diagnostics?: Diagnostic[] | null;
  /** @gqlField */
  instantiations: Edge<Task>[];
};

/** @gqlField */
export async function advance(
  _: Mutation,
  ctx: Context,
  opts: AdvanceFsmOptions,
): Promise<AdvanceTaskStateMachineResult> {
  const root = new Task({ id: opts.fsm.id }, ctx);
  console.debug(`fsm: ${root.id}`);
  assert(root._type === "workinstance");

  return await sql.begin(async tx => {
    await tx`select * from auth.set_actor(${ctx.auth.userId}, ${ctx.req.i18n.language})`;

    const [fsm] = await tx<[FSM?]>`${fsm$fragment(root)}`;
    if (!fsm) {
      return {
        root,
        diagnostics: [
          {
            __typename: "Diagnostic",
            code: DiagnosticKind.no_associated_fsm,
          },
        ],
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
    }

    assert(!!opts.fsm.hash);
    if (!opts.fsm.hash) {
      return {
        root,
        diagnostics: [
          {
            __typename: "Diagnostic",
            code: DiagnosticKind.hash_is_required,
          },
        ],
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
    }

    const rootHash = assertNonNull(await root.hash());
    if (rootHash !== opts.fsm.hash) {
      console.warn("WARNING: Root hash mismatch precludes advancement");
      console.debug(`| root: ${root.id}`);
      console.debug(`| ours: ${rootHash}`);
      console.debug(`| theirs: ${opts.fsm.hash}`);
      return {
        root,
        diagnostics: [
          {
            __typename: "Diagnostic",
            code: DiagnosticKind.hash_mismatch_precludes_operation,
          },
        ],
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
    }

    const choice = new Task(opts.task, ctx);
    console.debug(`choice: ${choice.id}`);

    if (is_valid_advancement(fsm, choice) === false) {
      console.warn("WARNING: Task is not a valid choice");
      console.debug(`| root: ${root.id}`);
      console.debug(`| choice: ${choice.id}`);
      return {
        root,
        diagnostics: [
          {
            __typename: "Diagnostic",
            code: DiagnosticKind.candidate_choice_unavailable,
          },
        ],
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
    }

    if (compareBase64(choice.id, fsm.active)) {
      console.debug("advance: operating on the active task");
      // When the "choice" is the active task, we advance that task's internal
      // state machine as defined by its own `advance` implementation.
      const r = await advanceTask(tx, ctx, choice, opts.task);
      return {
        root,
        ...r,
      };
    }

    // Otherwise, the "choice" identifies a transition in the fsm.
    console.debug("advance: operating on the fsm");
    return await advanceFsm(tx, root, fsm, choice, opts, ctx);
  });
}

export async function advanceFsm(
  sql: TxSql,
  root: Task,
  fsm: FSM,
  choice: Task,
  opts: Omit<AdvanceFsmOptions, "fsm">,
  ctx: Context,
): Promise<AdvanceTaskStateMachineResult> {
  assert(!!fsm.active, "fsm is not active");
  return await match(choice._type)
    .with("workinstance", () => {
      // This path is not currently possible: transitions are guaranteed to be
      // underlied by worktemplates.
      assert(false, "advance_fsm: choice underlied by workinstance");
      return {
        root,
        diagnostics: [
          {
            __typename: "Diagnostic" as const,
            code: DiagnosticKind.expected_template_got_instance,
          },
        ],
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
    })
    .with("worktemplate", async () => {
      const result = await sql<[{ instance: ID }]>`
        with options as (
            select
                w.id as previous_id,
                auth.current_identity(w.workinstancecustomerid, ${ctx.auth.userId}) as modified_by,
                (select l.id from legacy0.primary_location_for_instance(w.id) as l) as location_id
            from public.workinstance as w
            where w.id = ${decodeGlobalId(fsm.active).id}
        )

        select encode(('workinstance:' || t.instance)::bytea, 'base64') as instance
        from
            options,
            engine0.instantiate(
                template_id := ${choice._id},
                location_id := options.location_id,
                target_state := 'In Progress',
                target_type := 'Task',
                modified_by := options.modified_by,
                chain_root_id := ${root._id},
                chain_prev_id := options.previous_id
            ) as t
        group by t.instance;
      `;
      console.debug(`advance: engine.instantiate.count: ${result.length}`);

      // The only instantiation should be the choice, although the engine might
      // cut us off, hence:
      assert(result.length < 2);

      const ins = result.at(0)?.instance;
      if (ins) {
        const t = new Task({ id: ins }, ctx);

        // In Progress must have a start date.
        await sql`
          update public.workinstance
          set workinstancestartdate = now()
          where id = ${t._id}
        `;

        // Auto-assign.
        {
          const ma = "replace";
          const result = await sql`${applyAssignments$fragment(ctx, t, ma)}`;
          console.debug(
            `advance: applied ${result.count} assignments (mergeAction: ${ma})`,
          );
        }

        if (opts.task.overrides) {
          const f = applyEdits$fragment(ctx, t, opts.task.overrides);
          if (f) {
            const result = await sql`${f}`;
            console.debug(`advance: applied ${result.count} field-level edits`);
          }
        }
      }

      return {
        root,
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
    })
    .otherwise(() => {
      assert(false, `unknown underlying type ${choice._type}`);
      return {
        root,
        diagnostics: [
          {
            __typename: "Diagnostic" as const,
            code: DiagnosticKind.invalid_type,
          },
        ],
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
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
