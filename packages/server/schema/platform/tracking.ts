import { join, sql } from "@/datasources/postgres";
import { map, mapOrElse } from "@/util";
import type { ID, Int } from "grats";
import { match } from "ts-pattern";
import { decodeGlobalId } from "../system";
import type { Component } from "../system/component";
import { Task, type TaskStateName } from "../system/component/task";
import type { Connection } from "../system/pagination";
import type { Context } from "../types";
import { Location } from "./archetype/location";

/**
 * Identifies an Entity as being "trackable".
 * What exactly this means depends on the type underlying said entity and is
 * entirely user defined.
 *
 * @gqlInterface
 */
export interface Trackable extends Component {
  /**
   * @gqlField
   * @killsParentOnException
   */
  id: ID;

  /**
   * Entrypoint into the "tracking system(s)" for a given Entity. Note that while
   * many types admit to being trackable, this does not mean that all in fact are
   * in practice. In order for an Entity to be trackable, it must be explicitly
   * configured as such.
   *
   * @gqlField
   */
  tracking(args: {
    first?: Int | null;
    after?: ID | null;
  }): Promise<Connection<Trackable> | null>;
}

// TODO:
// - add filter arguments to narrow down the underlying type of the trackables
//   that we return, e.g. withArchetype: ["Location"]
// - add pagination arguments
// - utilize `info` for optimizations
/**
 * Query for Trackable entities in the given `parent` hierarchy.
 *
 * Note that this api does not yet support pagination! The `first` argument is
 * used purely for testing at the moment.
 *
 * @gqlQueryField
 */
export async function trackables(
  args: {
    /**
     * Forward pagination limit. Should only be used in conjunction with `after`.
     */
    first?: Int | null;
    /**
     * Identifies the root of the hierarchy in which to search for Trackable
     * entities.
     *
     * Valid parent types are currently:
     * - Customer
     *
     * All other parent types will be gracefully ignored.
     */
    parent: ID;
    /**
     * By default, this api will only return Trackables that are active. This can
     * be overridden using the `includeInactive` flag.
     */
    includeInactive?: boolean | null;
    /**
     * Allows filtering the returned set of Trackables by the *implementing* type.
     *
     * Currently this is only 'Location' (the default) or 'Task'. Note that
     * specifying the latter will return a connection of trackable Tasks that
     * represent the *chain roots* (i.e. originators). This is for you, Will
     * Twait, so you can get started on the history screen. Note also that it will
     * only give you *closed* chains, i.e. `workinstancecompleteddate is not null`.
     */
    withImplementation?: string | null;
    /**
     * Whether to return only chain roots, or all Tasks that satisfy the given
     * criteria.
     *
     * **Only applies when `withImplemention === "Task"`**
     */
    onlyRoots?: boolean | null;
    /**
     * Filter by state(s).
     * This maps (currently) to workinstancestatusid.
     *
     * **Only applies when `withImplemention === "Task"`**
     */
    state?: TaskStateName[] | null;
    /**
     * Filter by type(s).
     * This maps (currently) to worktemplatetype.
     *
     * For example, in Runtime the folowing types exist:
     * - Run
     * - Downtime
     * - Idle Time
     *
     * Any of these are suitable for this API.
     *
     * Also see `Task.chainAgg`, as that API takes a similar parameter `overType`.
     *
     * **Only applies when `withImplemention === "Task"`**
     */
    type?: string[] | null;
  },
  ctx: Context,
): Promise<Connection<Trackable>> {
  const { type, id } = decodeGlobalId(args.parent);
  const nodes = await match(type)
    .with("organization", () => {
      if (!args.withImplementation || args.withImplementation === "Location") {
        return sql<Trackable[]>`
          select
              'Location' AS "__typename",
              encode(('location:' || l.locationuuid)::bytea, 'base64') as id
          from public.customer as parent
          inner join public.location as l
              on parent.customerid = l.locationcustomerid
              and (
                  l.locationenddate is null
                  or l.locationenddate > now()
              )
          inner join public.custag as c on l.locationcategoryid = c.custagid
          inner join public.worktemplate as wt
              on  parent.customerid = wt.worktemplatecustomerid
              ${
                !args.includeInactive
                  ? sql`
              and (
                  wt.worktemplateenddate is null
                  or wt.worktemplateenddate > now()
              )
                  `
                  : sql``
              }
              and exists (
                  select 1
                  from public.worktemplatetype as wtt
                  where
                      wt.worktemplateid = wtt.worktemplatetypeworktemplateid
                      and wtt.worktemplatetypesystaguuid = (
                          select systaguuid
                          from public.systag
                          where systagparentid = 882 and systagtype = 'Trackable'
                      )
                      ${
                        !args.includeInactive
                          ? sql`
                      and (
                          wtt.worktemplatetypeenddate is null
                          or wtt.worktemplatetypeenddate > now()
                      )
                          `
                          : sql``
                      }
              )
              and exists (
                  select 1
                  from public.worktemplateconstraint as wtc
                  inner join public.systag as wtc_t
                      on  wtc.worktemplateconstraintconstraintid = c.custaguuid
                      and wtc.worktemplateconstraintconstrainedtypeid = (
                          select systaguuid
                          from public.systag
                          where systagparentid = 849 and systagtype = 'Location'
                      )
                  where wt.id = wtc.worktemplateconstrainttemplateid
              )
          where parent.customeruuid = ${id}
          order by l.locationid
          limit ${args.first ?? null}
        `;
      }

      if (args.withImplementation === "Task") {
        const onlyRoots = args.onlyRoots ?? true; // For backwards compatibility.
        const states = mapOrElse(
          args.state,
          states =>
            states.map(s => {
              switch (s) {
                case "Open":
                  return "Open" as const;
                case "InProgress":
                  return "In Progress" as const;
                case "Closed":
                  return "Complete" as const;
              }
            }),
          ["Complete" as const],
        );
        const types = args.type?.length ? args.type : ["Trackable"]; // For backwards compatibility.
        return sql<Trackable[]>`
          select
            'Task' as "__typename",
            encode(('workinstance:' || chain.id)::bytea, 'base64') as id
          from public.worktemplate as parent
          inner join public.worktemplatetype as wtt
            on parent.id = wtt.worktemplatetypeworktemplateuuid
            ${
              !args.includeInactive
                ? sql`
            and (
              wtt.worktemplatetypeenddate is null
              or wtt.worktemplatetypeenddate > now()
            )`
                : sql``
            }
          inner join public.systag as tag
            on wtt.worktemplatetypesystaguuid = tag.systaguuid
            and tag.systagtype in ${sql(types)}
          inner join public.workinstance as chain
            on ${join(
              [
                sql`parent.worktemplateid = chain.workinstanceworktemplateid`,
                ...(onlyRoots
                  ? [
                      sql`chain.workinstanceid = chain.workinstanceoriginatorworkinstanceid`,
                    ]
                  : []),
              ],
              sql`and`,
            )}
          inner join public.systag as state
            on chain.workinstancestatusid = state.systagid
            and state.systagtype in ${sql(states)}
          where
            parent.worktemplatecustomerid = (
              select customerid
              from public.customer
              where customeruuid = ${id}
            )
            ${
              !args.includeInactive
                ? sql`
            and (
              parent.worktemplateenddate is null
              or parent.worktemplateenddate > now()
            )`
                : sql``
            }
          order by
            chain.workinstancecompleteddate desc nulls first,
            chain.workinstancestartdate desc nulls first,
            chain.workinstanceid desc
          limit ${args.first ?? null}
        `;
      }

      // Treat it as a worktemplatetype.
      return sql<Trackable[]>`
        select
            'Task' as "__typename",
            encode(('workinstance:' || chain.id)::bytea, 'base64') as id
        from public.worktemplate as parent
        inner join public.worktemplatetype as wtt
            on parent.id = wtt.worktemplatetypeworktemplateuuid
            ${
              !args.includeInactive
                ? sql`
            and (
                wtt.worktemplatetypeenddate is null
                or wtt.worktemplatetypeenddate > now()
            )
                `
                : sql``
            }
        inner join public.systag as tag on wtt.worktemplatetypesystaguuid = tag.systaguuid
        inner join
            public.workinstance as chain
            on parent.worktemplateid = chain.workinstanceworktemplateid
            and chain.workinstanceid = chain.workinstanceoriginatorworkinstanceid
        where
            parent.worktemplatecustomerid = (
                select customerid
                from public.customer
                where customeruuid = ${id}
            )
            ${
              !args.includeInactive
                ? sql`
            and (
                parent.worktemplateenddate is null
                or parent.worktemplateenddate > now()
            )
                `
                : sql``
            }
            and tag.systagtype = ${args.withImplementation}
        order by chain.workinstanceid desc
        limit ${args.first ?? null}
      `;
    })
    .with("worktemplate", () => {
      if (args.withImplementation !== "Task") {
        throw "not yet implemented";
      }

      // FIXME: This is fucked. In reality we should do the whole sql.Fragment
      // cte thing that we've been elsewhere...
      return sql<Trackable[]>`
        select
          'Task' as "__typename",
          engine1.base64_encode(convert_to('workinstance:' || chain.id, 'utf8')) as id
        from public.worktemplate as parent
        inner join public.workinstance as chain
          on parent.worktemplateid = chain.workinstanceworktemplateid
          and chain.workinstanceid = chain.workinstanceoriginatorworkinstanceid
        where parent.id = ${id}
        order by chain.workinstanceid desc
        limit ${args.first ?? null}
      `;
    })
    .otherwise(() => {
      console.warn(`Unknown parent type '${type}'`);
      return [];
    });

  return {
    edges: nodes.map(node => ({
      cursor: node.id,
      node: match(node.__typename)
        .with("Location", () => new Location(node))
        .with("Task", () => new Task(node))
        .otherwise(() => {
          console.warn(`Unknown implementing type '${node.__typename}'`);
          throw "invariant violated";
        }),
    })),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: nodes.length,
  };
}
