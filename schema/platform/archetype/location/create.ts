import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import type { Mutation } from "@/schema/root";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import type { Context } from "@/schema/types";
import { GraphQLError } from "graphql";
import type { ID } from "grats";
import type { Fragment } from "postgres";
import { match } from "ts-pattern";
import { Location } from "../location";

/** @gqlInput */
export type CreateLocationInput = {
  category: string;
  name: string;
  parent: ID;
  scanCode?: string | null;
  /**
   * If not specified, the time zone will be derived from the parent (when the
   * parent is a Location). This is most notably *not* the case when the parent is
   * a Customer.
   */
  timeZone?: string | null;
};

/** @gqlField */
export async function createLocation(
  _: Mutation,
  ctx: Context,
  input: CreateLocationInput,
): Promise<Location> {
  const { type: parentType, id: parentId } = decodeGlobalId(input.parent);
  if (parentType !== "organization" && parentType !== "location") {
    throw new GraphQLError(`Invalid parent type for Location: ${parentType}`, {
      extensions: {
        code: "BAD_REQUEST",
      },
    });
  }

  const parentFragment: Fragment = match(parentType)
    .with(
      "organization",
      () => sql`
        select
            customerid as _owner,
            customeruuid as owner,
            null::text as id,
            ${input.timeZone ?? "utc"} as timezone
        from public.customer
        where customeruuid = ${parentId}
      `,
    )
    .with(
      "location",
      () => sql`
        select
            c.customerid as _owner,
            c.customeruuid as owner,
            l.locationuuid as id,
            coalesce(${input.timeZone ?? null}, l.locationtimezone) as timezone
        from public.location as l
        inner join public.customer as c on l.locationcustomerid = c.customerid
        where l.locationuuid = ${parentId}
      `,
    )
    .exhaustive();

  const result = await sql.begin(async sql => {
    await setCurrentIdentity(sql, ctx);
    const [row] = await sql<[{ id: string }]>`
      with parent as (${parentFragment})
      select t.id
      from
          parent,
          legacy0.create_location(
              customer_id := parent.owner,
              language_type := current_setting('user.locale'),
              location_name := ${input.name},
              location_parent_id := parent.id,
              location_timezone := parent.timezone,
              location_typename := ${input.category},
              modified_by := auth.current_identity(parent._owner, current_setting('user.id'))
          ) as t
      ;
    `;

    if (input.scanCode) {
      await sql`
        update public.location
        set locationscanid = ${input.scanCode}
        where locationuuid = ${row.id};
      `;
    }

    // Create open instances at the new location, based on
    // worktemplateconstraint and worktemplatenexttemplate. This is sort of a
    // hack, but in reality this should be built into the next version of the
    // rules engine. Why worktemplatenexttemplate? Just because a template *can*
    // be instantiated at a location does not necessarily mean that we should
    // instantiate it. This is where eager vs lazy instantiation comes into
    // play. The eager case tells us that we *should* instantiate, while the
    // lazy case tells us to hold off. If we do *not* listen we will end up over
    // instantiating in some cases, e.g. under Runtime we would instantiate Run,
    // Idle Time and Downtime which is obviously not desired.
    {
      const result = await sql`
        with to_instantiate as (
            select distinct
                wt.id as template_id,
                loc.locationuuid as location_id,
                tt.systagtype as target_type,
                auth.current_identity(loc.locationcustomerid, current_setting('user.id')) as modified_by
            from public.location as loc
            inner join public.worktemplate as wt
                -- Ensure that we only evaluate templates that are in scope
                on loc.locationsiteid = wt.worktemplatesiteid
            inner join public.worktemplatenexttemplate as nt
                -- Only templates that use "eager" instantiation
                on  wt.worktemplateid = nt.worktemplatenexttemplateprevioustemplateid
                and wt.worktemplateid = nt.worktemplatenexttemplatenexttemplateid
                and (
                    nt.worktemplatenexttemplateenddate is null
                    or nt.worktemplatenexttemplateenddate > now()
                )
            inner join public.systag as tt
                on nt.worktemplatenexttemplatetypeid = tt.systagid
            where
                loc.locationuuid = ${row.id}
                -- Only templates that *can* be instantiated at the given location *type*
                and exists (
                    select 1
                    from public.worktemplateconstraint as wtc
                    where
                        wtc.worktemplateconstrainttemplateid = wt.id
                        and wtc.worktemplateconstraintconstraintid = (
                            select custaguuid
                            from public.custag
                            where custagid = loc.locationcategoryid
                        )
                        and wtc.worktemplateconstraintconstrainedtypeid = (
                            select systaguuid
                            from public.systag
                            where systagparentid = 849 and systagtype = 'Location'
                        )
                    limit 1
                )
        )

        select r.instance
        from
            to_instantiate as t,
            engine0.instantiate(
                template_id := t.template_id,
                location_id := t.location_id,
                target_state := 'Open',
                target_type := t.target_type,
                modified_by := t.modified_by
            ) as r
        group by r.instance
      `;
      console.debug(
        `createLocation: engine.instantiate.count: ${result.length}`,
      );
      if (process.env.NODE_ENV === "development") {
        console.debug(
          `createLocation: engine.instantiate:\n${JSON.stringify(result, null, 2)}`,
        );
      }
    }

    return encodeGlobalId({
      type: "location",
      id: row.id,
    });
  });

  return new Location({ id: result });
}
