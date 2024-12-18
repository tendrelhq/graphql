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
  tracking(): Promise<Connection<Trackable> | null>;
}

// TODO:
// - add filter arguments to narrow down the underlying type of the trackables
//   that we return, e.g. withArchetype: ["Location"]
// - add pagination arguments
// - utilize `info` for optimizations
/**
 * Query for Trackable entities in the given `parent` hierarchy.
 *
 * @gqlField
 */
export async function trackables(
  _: Query,
  ctx: Context,
  /**
   * Pagination argument. Specifies a limit when performing forward pagination.
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
   * Allows filtering the returned set of Trackables by the *implementing* type.
   *
   * Currently this is only 'Location' (the default) or 'Task'. Note that
   * specifying the latter will return a connection of trackable Tasks that
   * represent the *chain roots* (i.e. originators). This is for you, Will
   * Twait, so you can get started on the history screen.
   */
  withImplementation: string | null,
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
            inner join
                public.worktemplatetype as wtt on parent.id = wtt.worktemplatetypeworktemplateuuid
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
                and tag.systagtype in ('Trackable')
                and chain.workinstancecompleteddate is not null
            order by chain.workinstancecompleteddate desc
            limit ${first ?? null}
          `,
        )
        .otherwise(
          () => sql<Trackable[]>`
            select
                'Location' AS "__typename",
                encode(('location:' || l.locationuuid)::bytea, 'base64') as id
            from public.location as l
            inner join public.customer as parent
                on l.locationcustomerid = parent.customerid
            inner join public.custag as c
                on l.locationcategoryid = c.custagid
            inner join public.systag as s
                on c.custagsystagid = s.systagid
            where
                parent.customeruuid = ${id}
                and s.systagtype = 'Trackable'
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

/** @gqlType */
export type Aggregate = {
  /**
   * The group, or bucket, that uniquely identifies this aggregate.
   * For example, this will be one of the `groupByTag`s passed to `trackingAgg`.
   *
   * @gqlField
   */
  group: string;

  /**
   * The computed aggregate value.
   *
   * Currently, this will always be a string value representing a duration in
   * seconds, e.g. "360" -> 360 seconds. `null` will be returned when no such
   * aggregate can be computed, e.g. "time in planned downtime" when no "planned
   * downtime" events exist.
   *
   * @gqlField
   */
  value: string | null;
};

/**
 * Construct an aggregate view of a Trackable whose constituents are grouped by
 * an arbitrary collection of type tags.
 *
 * In the MFT case, an aggregate view for both a Location and a Task can be
 * constructed using the three primary `worktemplatetype`s for the relevant MFT
 * worktemplates: "Production", "Planned Downtime", and "Unplanned Downtime".
 * Note that, in this case, "Production" implies "total time" and as such
 * "uptime" can be computed by subtracting the sum of the two downtime types
 * from the production time.
 *
 * @gqlField
 */
export async function trackingAgg(
  t: Trackable,
  ctx: Context,
  groupByTag: string[],
): Promise<Aggregate[]> {
  if (!groupByTag.length) {
    throw new GraphQLError("Must specify at least one tag to group by", {
      extensions: {
        code: "BAD_REQUEST",
      },
    });
  }

  const { type, id } = decodeGlobalId(t.id);

  // TODO: implement agg for a specific worktemplate.
  // First worktemplate, since that is the need on the "in progress" screen.
  // We could also implement this for a location, but that will be less useful
  // in the mft case, at least at first. This would be a useful dashboard metric
  // though, if there were more than one "production" worktemplate at a
  // location. To implement this for a specific worktemplate, we will need to
  // consult the chain, and furthermore we will need to provide a second
  // argument which provides the location (since we cannot infer the location
  // from just the template). Sigh.
  const rows = await match(type)
    .with(
      "worktemplate",
      () => sql<Aggregate[]>`
        select
            wtts.systagtype as group,
            sum(
                extract(
                    epoch from (wi.workinstancecompleteddate - wi.workinstancestartdate)
                )
            ) as value
        from public.worktemplate as wt
        inner join public.worktemplatetype as wtt
            on wt.id = wtt.worktemplatetypeworktemplateuuid
        inner join public.systag as wtts
            on wtt.worktemplatetypesystaguuid = wtts.systaguuid
        inner join public.workinstance as wi
            on wt.worktemplateid = wi.workinstanceworktemplateid
                and wi.workinstancestartdate is not null
                and wi.workinstancecompleteddate is not null
        where wtts.systagtype in ${sql(groupByTag)}
        group by wtts.systagtype
      `,
    )
    .otherwise(() => []);

  return rows;
}
