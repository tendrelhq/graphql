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
  timeZone: string;
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
        select customeruuid as authority, null::text as id
        from public.customer
        where customeruuid = ${parentId}
      `,
    )
    .with(
      "location",
      () => sql`
        select c.customeruuid as authority, l.locationuuid as id
        from public.location as l
        inner join public.customer as c on l.locationcustomerid = c.customerid
        where l.locationuuid = ${parentId}
      `,
    )
    .exhaustive();

  const result = await sql.begin(async tx => {
    // FIXME: modified by
    const [row] = await tx<[{ id: string }]>`
      with parent as (${parentFragment})
      select t.id
      from
          parent,
          util.create_location(
              customer_id := parent.authority,
              language_type := ${ctx.req.i18n.language},
              location_name := ${input.name},
              location_parent_id := parent.id,
              location_typename := ${input.category},
              location_type_hierarchy := 'Location Category',
              location_timezone := ${input.timeZone}
          ) as t
      ;
    `;

    if (input.scanCode) {
      await tx`
        update public.location
        set locationscanid = ${input.scanCode}
        where locationuuid = ${row.id};
      `;
    }

    return encodeGlobalId({
      type: "location",
      id: row.id,
    });
  });

  return new Location({ id: result }, ctx);
}
