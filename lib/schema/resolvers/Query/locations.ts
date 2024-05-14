import { sql } from "@/datasources/postgres";
import type { Location } from "@/schema";
import type { QueryResolver } from "@/schema/resolvers";
import { GraphQLError } from "graphql";

export const locations: QueryResolver<"locations"> = async (
  _,
  { customerId },
  { authScope },
) => {
  if (!authScope) {
    throw new GraphQLError("Unauthenticated", {
      extensions: {
        code: 401,
      },
    });
  }

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
