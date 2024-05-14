import { assertAuthenticated } from "@/auth";
import { sql } from "@/datasources/postgres";
import type { Location, QueryResolvers } from "@/schema";

export const locations: NonNullable<QueryResolvers["locations"]> = async (
  _,
  { customerId },
  ctx,
) => {
  assertAuthenticated(ctx);

  return await sql<Location[]>`
    SELECT
        l.locationuuid AS id,
        l.locationnameid AS name_id,
        l.locationparentid AS parent_id
    FROM public.location AS l
    INNER JOIN public.customer AS c
        ON l.locationcustomerid = c.customerid
    WHERE
        c.customeruuid = ${customerId};
  `;
};
