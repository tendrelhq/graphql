import { sql } from "@/datasources/postgres";
import { decodeGlobalId } from "@/schema/system";
import type { QueryResolvers } from "./../../../__generated__/types.generated";

export const checklistCompletionsByYear: NonNullable<
  QueryResolvers["checklistCompletionsByYear"]
> = async (_, args) => {
  const parent = decodeGlobalId(args.parent);

  const results = await sql<Array<{ date: string; count: string }>>`
    WITH template_id AS (
      SELECT workinstanceworktemplateid
      FROM public.workinstance
      WHERE id = ${parent.id}
    )
    SELECT 
      TO_CHAR(wi.workinstancecompleteddate, 'YYYY-MM-DD') as date,
      COUNT(*) as count
    FROM public.workinstance AS wi
    INNER JOIN public.systag AS status 
      ON wi.workinstancestatusid = status.systagid
    INNER JOIN template_id 
      ON wi.workinstanceworktemplateid = template_id.workinstanceworktemplateid
    WHERE 
      status.systagtype = 'Complete'
      AND EXTRACT(YEAR FROM wi.workinstancecompleteddate) = ${args.year}
      AND wi.workinstancecompleteddate IS NOT NULL
    GROUP BY date
    ORDER BY date
  `;

  return results.map(({ date, count }) => ({
    date,
    count: Number(count),
  }));
};
