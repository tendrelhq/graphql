import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";
import { copyFromWorkTemplate } from "./copyFrom";

export const discardChecklist: NonNullable<
  MutationResolvers["discardChecklist"]
> = async (_, { entity }, ctx) => {
  const { type, id } = decodeGlobalId(entity);

  if (type !== "workinstance") {
    throw new GraphQLError("Entity cannot be discarded.", {
      extensions: {
        code: "E_INVALID_STATE_CHANGE",
      },
    });
  }

  const result = await sql.begin(async tx => {
    const data = await tx`
        WITH inputs AS (
            SELECT systagid AS status
            FROM public.systag
            WHERE
                systagparentid = 705
                AND systagtype = 'Cancelled'
        )

        UPDATE public.workinstance AS wi
        SET
            workinstancestatusid = inputs.status,
            workinstancemodifieddate = now(),
            workinstancemodifiedby = w.workerinstanceid
        FROM
            inputs,
            public.worktemplate AS wt,
            public.workerinstance AS w
        WHERE
            wi.id = ${id}
            AND workinstanceworktemplateid = worktemplateid
            AND (
                w.workerinstancecustomerid = wi.workinstancecustomerid
                AND w.workerinstanceworkerid IN (
                    SELECT workerid
                    FROM public.worker
                    WHERE workeridentityid = ${ctx.auth.userId}
                )
            )
        RETURNING wt.id
    `;

    return copyFromWorkTemplate(tx, data[0].id, {});
  });

  return { edge: result.edge, discardedChecklistIds: [entity] };
};
