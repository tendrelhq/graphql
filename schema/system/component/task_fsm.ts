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
  return await sql.begin(async sql => {
    await setCurrentIdentity(sql, ctx);

    const t = new Task(opts.task);
    // The first thing we must do is validate the root hash. We MUST do this
    // before we lazily instantiate else we will get hash mismatches.
    assert(!!opts.fsm.hash);
    if (!opts.fsm.hash) {
      return {
        root: t,
        diagnostics: [
          {
            __typename: "Diagnostic",
            code: DiagnosticKind.hash_is_required,
          },
        ],
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
    }

    const rootHash = await t.hash();
    if (rootHash !== opts.fsm.hash) {
      console.warn("WARNING: Root hash mismatch precludes advancement");
      console.debug(`| root: ${t.id}`);
      console.debug(`| ours: ${rootHash}`);
      console.debug(`| theirs: ${opts.fsm.hash}`);
      return {
        root: t,
        diagnostics: [
          {
            __typename: "Diagnostic",
            code: DiagnosticKind.hash_mismatch_precludes_operation,
          },
        ],
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
    }

    const task = await match(t._type)
      .with("workinstance", () => t)
      .with("worktemplate", async () => {
        // If `task` is underlied by a worktemplate (as is the case under lazy
        // instantiation) then `args.parent` is required. We cannot possible
        // derive the correct parent (location) in this case, since there
        // cannot yet be a chain.
        return assertNonNull(
          await t.instantiate(
            {
              fields: opts.fsm.overrides,
              name: opts.fsm.name,
              parent: assertNonNull(
                opts.fsm.parent,
                "opts.fsm.parent is required when advancement necessitates instantiation",
              ),
            },
            ctx,
            sql,
          ),
        );
      })
      .exhaustive();

    console.debug(`fsm: ${task.id}`);
    // Of course now this must be the case:
    assert(task._type === "workinstance");

    // FIXME: broken under lazy instantiation unless we immediately instantiate
    // (which we do) above, although we'll still break in a different way below.
    // Note that this may not be the full fsm if `task` is not the root of the
    // chain, e.g. as is the case under Batch.
    const taskFsm = await fsm_(sql, task);
    if (!taskFsm) {
      return {
        root: task,
        diagnostics: [
          {
            __typename: "Diagnostic",
            code: DiagnosticKind.no_associated_fsm,
          },
        ],
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
    }

    // We need to resolve the choice. The choice is either a transition (i.e.
    // worktemplatenexttemplate) or a Task (i.e. worktemplate). The former is
    // the newer model which allows for cross-location instantiation.
    const { choice, target } = await match(decodeGlobalId(opts.task.id))
      .with({ type: "worktemplatenexttemplate", id: P.select() }, async id => {
        // When the choice is a next-template rule, we must resolve the rule to
        // ascertain the next template, and parent (location). If the rule does
        // not specify a location (which coloquially means "continue at the same
        // location") then we allow for the user to specify the next location
        // via `opts.task.parent`. Of course if neither the rule nor the user
        // provide a next parent (location) then the engine will fallback to the
        // previous's parent (location).
        const [row] = await sql<[{ id: ID; parent?: ID | null }]>`
          select
            encode(('worktemplate:' || wt.id)::bytea, 'base64') as id,
            encode(('location:' || coalesce(worktemplatenexttemplatenextlocationid, locationuuid))::bytea, 'base64') as parent
          from public.worktemplatenexttemplate
          inner join public.worktemplate as wt on worktemplatenexttemplatenexttemplateid = wt.worktemplateid
          left join public.location on locationuuid = ${opts.task.parent ?? null}
          where worktemplatenexttemplateuuid = ${id}
        `;
        assert(!!row, "no such choice");
        return {
          choice: new Task({ id: row.id }),
          target: row.parent ? new Location({ id: row.parent }) : null,
        };
      })
      .otherwise(() => ({ choice: new Task(opts.task), target: null }));
    console.debug(`choice: ${choice.id}`);

    if (isValidAdvancement(task, taskFsm, choice) === false) {
      console.warn("WARNING: Task is not a valid choice");
      console.debug(`| root: ${task.id}`);
      console.debug(`| choice: ${choice.id}`);
      return {
        root: task,
        diagnostics: [
          {
            __typename: "Diagnostic",
            code: DiagnosticKind.candidate_choice_unavailable,
          },
        ],
        instantiations: [],
      } satisfies AdvanceTaskStateMachineResult;
    }

    if (compareBase64(task.id, choice.id)) {
      console.debug("advance: operating on the root");
      const r = await advanceTask({ task: choice, opts: opts.task }, sql, ctx);
      return {
        root: task,
        ...r,
      };
    }

    if (taskFsm.active && compareBase64(choice.id, taskFsm.active.id)) {
      console.debug("advance: operating on the active task");
      // When the "choice" is the active task, we advance that task's internal
      // state machine as defined by its own `advance` implementation.
      const r = await advanceTask({ task: choice, opts: opts.task }, sql, ctx);
      return {
        root: task,
        ...r,
      };
    }

    // Otherwise, the "choice" identifies a transition in the fsm.
    console.debug("advance: operating on the fsm");
    return await advanceFsm(
      {
        choice,
        fsm: taskFsm,
        opts: {
          ...opts.task,
          parent: target?.id,
        },
        root: task,
      },
      ctx,
      sql,
    );
  });
}

async function advanceFsm(
  args: {
    choice: Task;
    fsm: StateMachine<Task>;
    opts: AdvanceTaskOptions;
    root: Task;
  },
  ctx: Context,
  sql: TxSql,
): Promise<AdvanceTaskStateMachineResult> {
  // The hypothesis is that we will never be in this state here. In practice the
  // only time the fsm is null is when the *root* is lazily instantiated and, in
  // such cases, we would have taken the `advanceTask` branch above wherein we
  // "operate on the root". Thus, the following assertion is safe:
  const active = assertNonNull(args.fsm.active, "fsm is not active");
  // This one is a bit redundant considering the active Task can only be an
  // instance (in the Open or InProgress states).
  assert(active._type === "workinstance");

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
      // Note that `args.root` is a misnomer in that it is not necessarily a
      // *chain* root, but rather the root of the fsm on which we are currently
      // operating. In order for instantiation to correctly "continue" the
      // chain, we must resolve the actual root and pass that along.
      const chainRoot = await args.root.root();
      const choice = await args.choice.instantiate(
        {
          chainPrev: args.root.id,
          chainRoot: assertNonNull(
            chainRoot?.id,
            "Failed to resolve chain root",
          ),
          parent: assertNonNull(
            args.opts.parent ??
              // FIXME: kinda hacky lmao
              (await active.parent().then(p => (p as Location)?.id)),
            "Failed to resolve parent",
          ),
          fields: args.opts.overrides,
          name: args.opts.name,
          state: {
            inProgress: {
              inProgressAt: new Date().toISOString(), // FIXME: let client decide
            },
          },
        },
        ctx,
        sql,
      );

      if (!choice) {
        console.error("advance: tried and failed to instantiate the choice");
        throw new Error("advance failed to instantiate");
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
 * given FSM _or_ it is one of the available transitions _or_ it is the FSM
 * itself.
 */
function isValidAdvancement(root: Task, fsm: StateMachine<Task>, t: Task) {
  if (compareBase64(root.id, t.id)) return true;
  if (fsm.active && compareBase64(fsm.active.id, t.id)) return true;
  return (
    fsm.transitions?.edges.some(edge => compareBase64(edge.node.id, t.id)) ===
    true
  );
}
