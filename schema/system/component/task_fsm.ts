import { sql } from "@/datasources/postgres";
import { copyFromWorkTemplate } from "@/schema/application/resolvers/Mutation/copyFrom";
import type { Mutation } from "@/schema/root";
import type { Context } from "@/schema/types";
import { GraphQLError } from "graphql";
import type { ID } from "grats";
import type { StateMachine } from "../fsm";
import { Task, advance as advance_active } from "./task";

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
  // For now we make the assumption that we are always in MFT world and work
  // templates map 1:1 to locations.
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
     * - if the active task === the given task, advance the task according to
     *   its own internal state machine as defined by {@link advance_active}
     * - otherwise, advance the fsm using the given task as the intended next
     *   state
     */
    task: ID;
  },
): Promise<Task> {
  const r = new Task({ id: args.fsm }, ctx);
  console.log(`fsm: ${r}`);

  const f = await fsm(r, ctx);
  if (!f) {
    throw new GraphQLError(`Task ${r} has no associated FSM`, {
      extensions: {
        code: "T_INVALID_TRANSITION",
      },
    });
  }

  const t = new Task({ id: args.task }, ctx);
  // Note that this is a potential source of conflict in the face of
  // concurrency and/or stale (client) data.
  if (is_valid_advancement(f, t) === false) {
    throw new GraphQLError(`Task ${t} is not a valid advancement of FSM ${r}`, {
      extensions: {
        code: "T_INVALID_TRANSITION",
      },
    });
  }

  // When the "choice" is the active task, we advance that task's internal state
  // machine as defined by its own advance implementation.
  if (f.active?.id === t.id) {
    await advance_active(t);
  } else {
    // Else the "choice" identifies a transition in the fsm.
    // For now, we are going to assume that it is always a worktemplate.
    if (t._type !== "worktemplate") {
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

    // et voilá
    await sql.begin(tx =>
      // FIXME: copyFrom does not correctly handle deduplication. Sigh.
      // This really shouldn't be part of its job anyways. However, I do think
      // this might suggest that we are using too low-level of an api in this
      // spot because at this level of abstraction we DO want to engage the rules
      // engine. Regardless, we can fix this later. CopyFrom is fine for now,
      // albeit rather overpowered and lacking proper guardrails :)
      copyFromWorkTemplate(tx, t._id, {
        chain: "continue",
        previous: f.active?._id,
        withStatus: "inProgress",
      }),
    );
  }

  // We always return a fresh copy of the fsm back to the client. This allows
  // for single-roundtrip state transitions which in turn enable highly
  // responsive ux.
  return r;
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
