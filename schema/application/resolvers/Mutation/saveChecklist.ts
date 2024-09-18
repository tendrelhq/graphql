import { sql } from "@/datasources/postgres";
import type { Checklist, ChecklistInput, MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";

export const saveChecklist: NonNullable<
  MutationResolvers["saveChecklist"]
> = async (_, { input }) => {
  const { id: customerId } = decodeGlobalId(input.customerId);

  await sql.begin(async tx => {
    const { type, id } = decodeGlobalId(input.id);

    if (type !== "worktemplate") {
      throw new Error("Can only modify templates right now");
    }

    const log = [];

    // Falsey -> inactive
    const active = await tx`
        UPDATE public.worktemplate
        SET
            worktemplateenddate = ${input.active?.active ? null : sql`now()`},
            worktemplatemodifieddate = now()
        WHERE
            id = ${id}
            AND ${
              input.active?.active
                ? sql`(
                    worktemplateenddate IS NOT NULL
                    AND worktemplateenddate < now()
                )`
                : sql`(
                    worktemplateenddate IS null
                    OR worktemplateenddate > now()
                )`
            }
    `;
    if (active.count) log.push("updated worktemplateenddate");

    // Falsey -> not auditable
    const auditable = await tx`
        UPDATE public.worktemplate
        SET
            worktemplateisauditable = ${input.auditable?.enabled ?? false},
            worktemplatemodifieddate = now()
        WHERE
            id = ${id}
            AND ${
              input.auditable?.enabled
                ? sql`(
                    worktemplateisauditable = false
                )`
                : sql`(
                    worktemplateisauditable = true
                )`
            }
    `;
    if (auditable.count) log.push("updated worktemplateisauditable");

    // TODO: Does not account for a wholesale swap of the languagemaster. But
    // perhaps we can say that is not allowed yet.

    // Falsey -> remove description
    if (input.description) {
      const description = await tx`
          WITH cte AS (
              INSERT INTO public.languagemaster (
                  languagemasteruuid,
                  languagemastercustomerid,
                  languagemastersource,
                  languagemastersourcelanguagetypeid
              )
              VALUES (
                  ${decodeGlobalId(input.description.id).id},
                  (
                      SELECT customerid
                      FROM public.customer
                      WHERE customeruuid = ${customerId}
                  ),
                  ${input.description.value.value},
                  (
                      SELECT systagid
                      FROM public.systag
                      WHERE
                          systagparentid = 2
                          AND systagtype = ${input.description.value.locale}
                  )
              )
              ON CONFLICT (languagemasteruuid) DO UPDATE
                  SET
                      languagemastersource = ${input.description.value.value},
                      languagemastersourcelanguagetypeid = (
                          SELECT systagid
                          FROM public.systag
                          WHERE
                              systagparentid = 2
                              AND systagtype = ${input.description.value.locale}
                      ),
                      languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
                      languagemastermodifieddate = now()
                  WHERE
                      languagemaster.languagemastersource != ${input.description.value.value}
                      OR
                      languagemaster.languagemastersourcelanguagetypeid != excluded.languagemastersourcelanguagetypeid
              RETURNING languagemasterid
          )

          UPDATE public.worktemplate AS wt
          SET
              worktemplatedescriptionid = cte.languagemasterid,
              worktemplatemodifieddate = now()
          FROM cte
          WHERE
              id = ${id}
              AND (
                  wt.worktemplatedescriptionid IS null
                  OR
                  wt.worktemplatedescriptionid != cte.languagemasterid
              )
      `;
      if (description.count) log.push("updated worktemplatedescriptionid");
    } else {
      const description = await tx`
          UPDATE public.worktemplate AS wt
          SET
              worktemplatedescriptionid = null,
              worktemplatemodifieddate = now()
          WHERE
              wt.id = ${id}
              AND wt.worktemplatedescriptionid IS NOT null;
      `;
      if (description.count) log.push("removed worktemplatedescriptionid");
    }

    await new Promise(resolve => setTimeout(resolve, 2000));

    // FIXME: Also doesn't account for a wholesale swap.
    const name = await tx`
        UPDATE public.languagemaster AS t
        SET
            languagemastersource = ${input.name.value.value},
            languagemastersourcelanguagetypeid = (
                SELECT systagid
                FROM public.systag
                WHERE
                    systagparentid = 2
                    AND systagtype = ${input.name.value.locale}
            ),
            languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
            languagemastermodifieddate = now()
        FROM public.worktemplate AS wt
        WHERE
            wt.id = ${id}
            AND wt.worktemplatenameid = t.languagemasterid
            AND (
                t.languagemastersource != ${input.name.value.value}
                OR
                t.languagemastersourcelanguagetypeid NOT IN (
                    SELECT systagid
                    FROM public.systag
                    WHERE
                        systagparentid = 2
                        AND systagtype = ${input.name.value.locale}
                )
            )
    `;
    if (name.count) log.push(`updated worktemplatenameid (${name.count})`);

    // Assignees (workinstance)
    // Items (both)
    // Required (none - for now)
    // Schedule (worktemplate)
    // Status (workinstance)

    if (input.sop) {
      const sop = await tx`
          UPDATE public.worktemplate
          SET
              worktemplatesoplink = ${input.sop.link.toString()},
              worktemplatemodifieddate = now()
          WHERE
              id = ${id}
              AND worktemplatesoplink <> ${input.sop.link.toString()}
      `;
      if (sop.count) log.push("updated sop");
    } else {
      const sop = await tx`
            UPDATE public.worktemplate
            SET
                worktemplatesoplink = null,
                worktemplatemodifieddate = now()
            WHERE
                id = ${id}
                AND worktemplatesoplink IS NOT null;
        `;
      if (sop.count) log.push("removed sop");
    }

    console.debug(
      "Performed the following actions while saving Checklist:\n",
      JSON.stringify(log, null, 2),
    );
    //   const [row] = await tx<[{ id: string }]>`
    //       WITH n AS (
    //           INSERT INTO public.languagemaster (
    //               languagemasteruuid,
    //               languagemastercustomerid,
    //               languagemastersource,
    //               languagemastersourcelanguagetypeid
    //           ) VALUES (
    //               ${decodeGlobalId(input.name.id).id},
    //               (
    //                   SELECT customerid
    //                   FROM public.customer
    //                   WHERE customeruuid = ${customerId}
    //               ),
    //               ${input.name.value.value},
    //               (
    //                   SELECT systagid
    //                   FROM public.systag
    //                   WHERE
    //                       systagparentid = 2
    //                       AND systagtype = ${input.name.value.locale}
    //               )
    //           )
    //           ON CONFLICT (languagemasteruuid) DO UPDATE
    //               SET
    //                   languagemastersource = ${input.name.value.value},
    //                   languagemastersourcelanguagetypeid = (
    //                       SELECT systagid
    //                       FROM public.systag
    //                       WHERE
    //                           systagparentid = 2
    //                           AND systagtype = ${input.name.value.locale}
    //                   ),
    //                   languagemastermodifieddate = now()
    //           RETURNING languagemasterid
    //       )
    //
    //       INSERT INTO public.worktemplate (
    //           id,
    //           worktemplateallowondemand,
    //           worktemplatestartdate,
    //           worktemplateenddate,
    //           worktemplateisauditable,
    //           worktemplatecustomerid,
    //           worktemplatedescriptionid,
    //           worktemplatenameid,
    //           worktemplatesiteid,
    //           worktemplatesoplink,
    //           worktemplateworkfrequencyid
    //       ) VALUES (
    //           ${id},
    //           true, -- allow on demand
    //           ${new Date()}, -- start date
    //           ${input.active?.active === false ? new Date() : null}, -- end date
    //           ${input.auditable?.enabled ?? false},
    //           (
    //               SELECT customerid
    //               FROM public.customer
    //               WHERE customeruuid = ${customerId}
    //           ),
    //           null, -- description
    //           (
    //               SELECT languagemasterid
    //               FROM n
    //           ),
    //           (
    //               SELECT locationid
    //               FROM public.location
    //               WHERE
    //                   locationistop = true
    //                   AND locationcustomerid = (
    //                       SELECT customerid
    //                       FROM public.customer
    //                       WHERE customeruuid = ${customerId}
    //                   )
    //           ),
    //           ${input.sop?.link.toString() ?? null},
    //           1629 -- FIXME: circular reference; worktemplate <-> workfrequency :(
    //       )
    //       ON CONFLICT (id) DO UPDATE
    //           SET
    //               worktemplateenddate = ${input.active?.active === false ? new Date() : null},
    //               worktemplateisauditable = ${input.auditable?.enabled ?? false},
    //               worktemplatemodifieddate = now()
    //       RETURNING encode(('worktemplate:' || id)::bytea, 'base64') AS id;
    //   `;
    //
    //   return row.id;
  });

  return {
    node: { id: input.id } as Checklist,
    cursor: input.id,
  };
};

async function execute(input: ChecklistInput) {
  const { type, id } = decodeGlobalId(input.id);
  switch (type) {
    case "worktemplate":
      throw "not implemented";
    case "workinstance":
      throw "not implemented";
    default:
      throw new Error(`Unknown type ${type} for id ${id}`);
  }
}

// async function createChecklistTemplate(
//   id: string,
//   input: ChecklistInput,
// ) {
//   const { id: customerId } = decodeGlobalId(input.customerId);
//
//   return row.id;
// }
