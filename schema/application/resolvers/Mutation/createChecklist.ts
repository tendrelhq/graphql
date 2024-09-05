import type { MutationResolvers } from "@/schema";
import { USERS, appendChecklist, makeOpen } from "@/test/d3";

export const createChecklist: NonNullable<
  MutationResolvers["createChecklist"]
> = async (_, { input }) => {
  // simulate some latency
  await new Promise(resolve => setTimeout(resolve, 2000));

  const checklist = appendChecklist({
    id: input.id,
    active: input.active,
    activeAt: new Date(),
    assignees: [],
    children: [],
    description: input.description,
    items: [],
    name: input.name,
    sop: input.sop,
    status: makeOpen({
      at: new Date(),
      by: USERS.Rugg,
    }),
  });

  return {
    node: checklist,
    cursor: checklist.id,
  };
};

/*
async function execute(input: CreateChecklistInput) {
  const { type, id } = decodeGlobalId(input.id);
  switch (type) {
    case "worktemplate":
      return createChecklistTemplate(id, input);
    case "workinstance":
      throw "not implemented";
    default:
      throw new Error(`Unknown type ${type} for id ${id}`);
  }
}

async function createChecklistTemplate(
  id: string,
  input: CreateChecklistInput,
) {
  const { id: customerId } = decodeGlobalId(input.customerId);
  const [row] = await sql<[{ id: string }]>`
    WITH n AS (
        INSERT INTO public.languagemaster (
            languagemastercustomerid,
            languagemastersource,
            languagemastersourcelanguagetypeid
        ) VALUES (
            (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${customerId}
            ),
            ${input.name},
            (
                SELECT systagid
                FROM public.systag
                WHERE
                    systagparentid = 2
                    AND systagtype = 'en'
            )
        )
        RETURNING languagemasterid
    )

    INSERT INTO public.worktemplate (
        id,
        worktemplateallowondemand,
        worktemplatestartdate,
        worktemplateenddate,
        worktemplateisauditable,
        worktemplatecustomerid,
        worktemplatedescriptionid,
        worktemplatenameid,
        worktemplatesiteid,
        worktemplatesoplink,
        worktemplateworkfrequencyid
    ) VALUES (
        ${id},
        true, -- allow on demand
        ${new Date()}, -- start date
        ${input.active === false ? new Date() : null}, -- end date
        ${input.auditable},
        (
            SELECT customerid
            FROM public.customer
            WHERE customeruuid = ${customerId}
        ),
        null, -- description
        (
            SELECT languagemasterid
            FROM n
        ),
        (
            SELECT locationid
            FROM public.location
            WHERE
                locationistop = true
                AND locationcustomerid = (
                    SELECT customerid
                    FROM public.customer
                    WHERE customeruuid = ${customerId}
                )
        ),
        ${input.sop?.toString() ?? null},
        1629 -- FIXME: circular reference; worktemplate <-> workfrequency :(
    )
    RETURNING encode(('worktemplate:' || id)::bytea, 'base64') AS id;
  `;

  return row.id;
}
*/
