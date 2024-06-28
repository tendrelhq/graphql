import { updateName } from "@/datasources/name";
import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const updateLocation: NonNullable<MutationResolvers["updateLocation"]> =
  async (_, { input }, ctx) => {
    const existing = await ctx.orm.location.load(input.id);

    await sql.begin(async sql => {
      if (input.name?.id === existing.name_id) {
        await updateName(input.name, sql);
      }

      if (existing.scan_code !== input.scan_code) {
        await sql`
            UPDATE public.location
            SET
                locationscanid = ${input.scan_code ?? null},
                locationmodifieddate = NOW()
            WHERE locationuuid = ${existing.id};
        `;
      }
    });

    return ctx.orm.location.clear(input.id).load(input.id);
  };
