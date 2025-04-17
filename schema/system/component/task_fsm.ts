import { setCurrentIdentity } from "@/auth";
import { type Sql, type TxSql, sql } from "@/datasources/postgres";
import { Location } from "@/schema/platform/archetype/location";
import { type Diagnostic, DiagnosticKind } from "@/schema/result";
import type { Mutation } from "@/schema/root";
import type { Context } from "@/schema/types";
import { assert, assertNonNull, compareBase64, map } from "@/util";
import type { ID } from "grats";
import type { Fragment } from "postgres";
import { P, match } from "ts-pattern";
import { decodeGlobalId } from "..";
import type { StateMachine } from "../fsm";
import type { Edge } from "../pagination";
import {
  type AdvanceTaskOptions,
  Task,
  type ConstructorArgs as TaskConstructorArgs,
  advanceTask,
  applyAssignments_,
  applyFieldEdits_,
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
            select
              pb.*,
              wt.worktemplateorder as _node_order,
              l.locationcornerstoneorder as _target_order
            from
                active,
                engine0.build_instantiation_plan_v2(active.id) as pb,
                engine0.evaluate_instantiation_plan(
                    target := pb.node,
                    target_type := pb.target_type,
                    conditions := pb.ops
                ) as pc
            left join lateral (select * from public.worktemplate where id = pb.node) wt on true
            left join lateral (select * from public.location where locationuuid = pb.target) l on true
            where pb.target_type = 'On Demand' and pc.result = true
        )

    select
      encode(('workinstance:' || active.id)::bytea, 'base64') as active,
      jsonb_agg(
        jsonb_build_object(
          'id', encode(('worktemplatenexttemplate:' || plan.id)::bytea, 'base64'),
          'node', encode(('worktemplate:' || plan.node)::bytea, 'base64'),
          'target', encode(('location:' || plan.target)::bytea, 'base64')
        )
        order by plan._node_order, plan._target_order
      ) filter (where plan.id is not null) as transitions
    from active
    left join plan on true
    group by active.id
  `;
}

export type FSM = {
  active: ID;
  transitions?: { id: ID; node: ID; target?: ID | null }[] | null;
};

/**
 * Tasks can have an associated StateMachine, which defines a finite set of
 * states that the given Task can be in at any given time.
 *
 * @gqlField
 */
export async function fsm(t: Task): Promise<StateMachine<Task> | null> {
  return await fsm_(sql, t);
}

export async function fsm_(
  sql: Sql | TxSql,
  t: Task,
): Promise<StateMachine<Task> | null> {
  if (t._type !== "workinstance") {
    assert(
      false,
      "only instances can participate in task-based state machines",
    );
    return null;
  }

  const [fsm] = await sql<[FSM?]>`${fsm$fragment(t)}`;
  if (!fsm) {
    // This is most notably the case on task close.
    return null;
  }

  return {
    hash: await t.hash(), // Note that this is currently unused.
    active: new Task({ id: fsm.active }),
    transitions: {
      edges:
        fsm.transitions?.map(t => ({
          id: t.id,
          cursor: t.node,
          node: new Task({ id: t.node }),
          target: map(t.target, id => new Location({ id })),
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
  const root = new Task({ id: opts.fsm.id });
  console.debug(`fsm: ${root.id}`);
  assert(root._type === "workinstance");

  return await sql.begin(async sql => {
    await setCurrentIdentity(sql, ctx);
    const [fsm] = await sql<[FSM?]>`${fsm$fragment(root)}`;
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

    const { choice, target } = await match(decodeGlobalId(opts.task.id))
      .with({ type: "worktemplatenexttemplate", id: P.select() }, async id => {
        // When the choice is a next-template rule, we must resolve the rule to
        // ascertain the next template.
        const [row] = await sql<[{ task: ID; location?: ID | null }]>`
          select
            encode(('worktemplate:' || wt.id)::bytea, 'base64') as task,
            encode(('location:' || worktemplatenexttemplatenextlocationid)::bytea, 'base64') as location
          from public.worktemplatenexttemplate
          inner join public.worktemplate as wt
            on worktemplatenexttemplatenexttemplateid = wt.worktemplateid
          where worktemplatenexttemplateuuid = ${id}
        `;
        assert(!!row, "no such choice");
        return {
          choice: new Task({ id: row.task }),
          target: row.location ? new Location({ id: row.location }) : null,
        };
      })
      .otherwise(() => ({ choice: new Task(opts.task), target: null }));
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
      const r = await advanceTask(sql, ctx, choice, opts.task);
      return {
        root,
        ...r,
      };
    }

    // Otherwise, the "choice" identifies a transition in the fsm.
    console.debug("advance: operating on the fsm");
    return await advanceFsm(
      { choice, fsm, location: target?._id, opts, root },
      ctx,
      sql,
    );
  });
}

async function advanceFsm(
  args: {
    choice: Task;
    fsm: FSM;
    location?: string | null;
    opts: Omit<AdvanceFsmOptions, "fsm">;
    root: Task;
  },
  ctx: Context,
  sql: TxSql,
): Promise<AdvanceTaskStateMachineResult> {
  assert(!!args.fsm.active, "fsm is not active");
  return await match(args.choice._type)
    .with("workinstance", () => {
      // This path is not currently possible: transitions are guaranteed to be
      // underlied by worktemplates.
      assert(false, "advance_fsm: choice underlied by workinstance");
      return {
        root: args.root,
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
            where w.id = ${decodeGlobalId(args.fsm.active).id}
        )

        select encode(('workinstance:' || t.instance)::bytea, 'base64') as instance
        from
            options,
            engine0.instantiate(
                template_id := ${args.choice._id},
                location_id := coalesce(${args.location ?? null}, options.location_id),
                target_state := 'In Progress',
                target_type := 'Task',
                modified_by := options.modified_by,
                chain_root_id := ${args.root._id},
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
        const t = new Task({ id: ins });

        // In Progress must have a start date.
        await sql`
          update public.workinstance
          set workinstancestartdate = now()
          where id = ${t._id} and workinstancestartdate is null
        `;

        // Auto-assign.
        {
          const ma = "replace";
          const result = await applyAssignments_(sql, ctx, t, ma);
          console.debug(
            `advance: applied ${result.count} assignments (mergeAction: ${ma})`,
          );
        }

        if (args.opts.task.overrides?.length) {
          const result = await applyFieldEdits_(
            sql,
            ctx,
            t,
            args.opts.task.overrides,
          );
          console.debug(`advance: applied ${result.count} field-level edits`);
        }
      }

      return {
        root: args.root,
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
    })
    .otherwise(() => {
      assert(false, `unknown underlying type ${args.choice._type}`);
      return {
        root: args.root,
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
function is_valid_advancement(fsm: FSM, t: Task) {
  if (compareBase64(fsm.active, t.id)) return true;
  return fsm.transitions?.some(id => compareBase64(id.node, t.id)) === true;
}
