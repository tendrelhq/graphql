import { sql } from "@/datasources/postgres";
import type { Location, QueryResolvers } from "@/schema";

export const locations: NonNullable<QueryResolvers['locations']> = async (
  _,
  { customerId, options },
  __,
) => {
  return await sql<Location[]>`
    SELECT
        l.locationuuid AS id,
        (l.locationenddate IS NULL OR l.locationenddate > now()) AS active,
        l.locationstartdate::text AS activated_at,
        l.locationenddate::text AS deactivated_at,
        n.languagemasteruuid AS name_id,
        p.locationuuid AS parent_id,
        l.locationscanid AS scan_code,
        s.locationuuid AS site_id
    FROM public.location AS l
    INNER JOIN public.languagemaster AS n
        ON l.locationnameid = n.languagemasterid
    INNER JOIN public.location AS s
        ON l.locationsiteid = s.locationid
    LEFT JOIN public.location AS p
        ON l.locationparentid = p.locationid
    WHERE
        l.locationcustomerid = (
            SELECT customerid
            FROM public.customer
            WHERE customeruuid = ${customerId}
        )
        ${
          options?.cornerstone
            ? sql`AND l.locationiscornerstone = ${true}`
            : sql``
        }
        ${options?.site ? sql`AND l.locationistop = ${true}` : sql``}
  `;
};
