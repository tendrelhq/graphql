import { sql } from "@/datasources/postgres";
import { GraphQLError } from "graphql";
import type { ID, Int } from "grats";
import { match } from "ts-pattern";
import type { Query } from "../root";
import { decodeGlobalId } from "../system";
import type { Component } from "../system/component";
import { Task } from "../system/component/task";
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
  tracking(
    first?: Int | null,
    after?: ID | null,
  ): Promise<Connection<Trackable> | null>;
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
 * @gqlField
 */
export async function trackables(
  _: Query,
  ctx: Context,
  /**
   * Forward pagination limit. Should only be used in conjunction with `after`.
   */
  first: Int | null,
  /**
   * Identifies the root of the hierarchy in which to search for Trackable
   * entities.
   *
   * Valid parent types are currently:
   * - Customer
   *
   * All other parent types will be gracefully ignored.
   */
  parent: ID,
  /**
   * By default, this api will only return Trackables that are active. This can
   * be overridden using the `includeInactive` flag.
   */
  includeInactive?: boolean | null,
  /**
   * Allows filtering the returned set of Trackables by the *implementing* type.
   *
   * Currently this is only 'Location' (the default) or 'Task'. Note that
   * specifying the latter will return a connection of trackable Tasks that
   * represent the *chain roots* (i.e. originators). This is for you, Will
   * Twait, so you can get started on the history screen. Note also that it will
   * only give you *closed* chains, i.e. `workinstancecompleteddate is not null`.
   */
  withImplementation?: string | null,
): Promise<Connection<Trackable>> {
  const { type, id } = decodeGlobalId(parent);
  const nodes = await match(type)
    .with("organization", () =>
      match(withImplementation)
        .with(
          "Task",
          () => sql<Trackable[]>`
            select
                'Task' as "__typename",
                encode(('workinstance:' || chain.id)::bytea, 'base64') as id
            from public.worktemplate as parent
            inner join public.worktemplatetype as wtt
                on parent.id = wtt.worktemplatetypeworktemplateuuid
                ${
                  !includeInactive
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
                  !includeInactive
                    ? sql`
                and (
                    parent.worktemplateenddate is null
                    or parent.worktemplateenddate > now()
                )
                    `
                    : sql``
                }
                and tag.systagtype in ('Trackable')
                and chain.workinstancecompleteddate is not null
            order by chain.workinstancecompleteddate desc
            limit ${first ?? null}
          `,
        )
        .otherwise(
          // We can't use locationcategoryid because that is user defined.
          // Instead, we need to look for all templates with the Trackable type
          // that also have a constraint allowing them to be instantiated at the
          // given location. Ugh.
          () => sql<Trackable[]>`
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
                  !includeInactive
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
                            where systagtype = 'Trackable'
                        )
                        ${
                          !includeInactive
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
            limit ${first ?? null}
          `,
        ),
    )
    .otherwise(() => {
      console.warn(`Unknown parent type '${type}'`);
      return [];
    });

  return {
    edges: nodes.map(node => ({
      cursor: node.id,
      node: match(node.__typename)
        .with("Location", () => new Location(node, ctx))
        .with("Task", () => new Task(node, ctx))
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
