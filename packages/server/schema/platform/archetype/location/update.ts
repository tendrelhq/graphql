import { updateName } from "@/datasources/name";
import { sql } from "@/datasources/postgres";
import type { Mutation } from "@/schema/root";
import { decodeGlobalId } from "@/schema/system";
import type { UpdateNameInput } from "@/schema/system/component/name";
import type { Context } from "@/schema/types";
import { assertUnderlyingType } from "@/util";
import type { Float, ID } from "grats";
import { Location } from "../location";

/** @gqlInput */
export type GeofenceInput = {
  latitude?: string | null;
  longitude?: string | null;
  radius?: Float | null;
};

/** @gqlInput */
export type UpdateLocationInput = {
  id: ID;
  activatedAt?: string | null;
  deactivatedAt?: string | null;
  name?: UpdateNameInput | null;
  scanCode?: ID | null;
  geofence?: GeofenceInput | null;
};

/** @gqlField */
export async function updateLocation(
  _: Mutation,
  input: UpdateLocationInput,
  ctx: Context,
): Promise<Location> {
  const { type, id } = decodeGlobalId(input.id);
  assertUnderlyingType("location", type);

  const existing = await ctx.orm.location.load(id);
  await sql.begin(async sql => {
    if (input.name?.id === existing.nameId) {
      await updateName(input.name, sql);
    }

    if (existing.scanCode !== input.scanCode) {
      await sql`
          update public.location
          set locationscanid = nullif(${input.scanCode ?? null}, ''),
              locationmodifiedby = auth.current_identity(locationcustomerid, ${ctx.auth.userId}),
              locationmodifieddate = now()
          where locationuuid = ${id};
      `;
    }

    // FIXME: conditional update!
    await sql`
      update public.location
      set locationradius = nullif(${input.geofence?.radius ?? null}, '')::numeric,
          locationlatitude = nullif(${input.geofence?.latitude ?? null}, ''),
          locationlongitude = nullif(${input.geofence?.longitude ?? null}, ''),
          locationmodifiedby = auth.current_identity(locationcustomerid, ${ctx.auth.userId}),
          locationmodifieddate = now()
      where locationuuid = ${id};
    `;
  });

  // Clear the dataloader to pick up new changes.
  ctx.orm.location.clear(id);

  return new Location(input);
}
