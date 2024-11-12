import { updateName } from "@/datasources/name";
import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const updateLocation: NonNullable<
  MutationResolvers["updateLocation"]
> = async (_, { input }, ctx) => {
  const { id } = decodeGlobalId(input.id);
  const existing = await ctx.orm.location.load(id);
  await sql.begin(async sql => {
    if (input.name?.id === existing.nameId) {
      await updateName(input.name, sql);
    }

    if (existing.scanCode !== input.scanCode) {
      await sql`
          UPDATE public.location
          SET
              locationscanid = ${input.scanCode ?? null},
              locationmodifieddate = NOW()
          WHERE locationuuid = ${id};
      `;
    }
    await sql`
        UPDATE public.location
        SET
             locationradius = ${input.geofence?.radius ?? null},
              locationlatitude = ${input.geofence?.latitude ?? null},
              locationlongitude = ${input.geofence?.longitude ?? null}
        WHERE locationuuid = ${id};
    `;
  });

  return ctx.orm.location.clear(id).load(id);
};
