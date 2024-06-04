import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const createLocation: NonNullable<MutationResolvers['createLocation']> =
  async (_, { input }, ctx) => {
    const [location] = await sql<[{ id: string }?]>`
        INSERT INTO public.location (
        ) VALUES (
        )
        ON CONFLICT DO NOTHING
        RETURNING locationuuid AS id;
    `;

    // FIXME: This feels janky. I like the idea of ON CONFLICT (...) DO UPDATE
    // way more because it's
    // (a) atomic
    // (b) simple
    // (c) less code :D
    // For now we'll do it this way though...
    if (!location) {
      // This implies ON CONFLICT DO NOTHING hit.
      // i.e. the location already exists, so we just need to find it.
      const [location] = await sql<[{ id: string }?]>`
          SELECT locationuuid
          FROM public.location
          WHERE
              locationuuid = ${input.id ?? null}
              OR (
                  locationcustomerid = (
                      SELECT customerid
                      FROM public.customer
                      WHERE customeruuid = ${input.org_id}
                  )
                  AND ${input.scan_code ?? null} IS NOT NULL
                  AND locationscanid = ${input.scan_code ?? null};
              )
      `;

      if (!location) throw "must've messed up the unique constraints";
      return ctx.orm.location.load(location.id);
    }

    return ctx.orm.location.load(location.id);
  };
