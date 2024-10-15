import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { GraphQLError } from "graphql";
import { copyFromWorkTemplate } from "./copyFrom";

export const discardChecklist: NonNullable<
  MutationResolvers["discardChecklist"]
> = async (_, { entity }) => {
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
                AND
                systagtype = 'Cancelled'
        ),
        updated_instance AS (
            UPDATE public.workinstance
            SET
                workinstancestatusid = inputs.status,
                workinstancemodifieddate = now()
            FROM inputs
            WHERE
                id = ${id}
                AND
                workinstancestatusid != inputs.status
            RETURNING workinstanceworktemplateid AS templateId
        )
        SELECT 
            wt.id
        FROM updated_instance wi
        JOIN public.worktemplate wt ON wt.worktemplateid = wi.templateId
    `;

    const newInstance = await copyFromWorkTemplate(data[0].id, {});

    return newInstance;
  });

  return { edge: result.edge, discardedChecklistIds: [entity] };
};
