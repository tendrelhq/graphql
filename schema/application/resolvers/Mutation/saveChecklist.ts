import { sql } from "@/datasources/postgres";
import type {
  Checklist,
  ChecklistInput,
  ChecklistItemInput,
  ID,
  MutationResolvers,
} from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { P, match } from "ts-pattern";
import { copyFromWorkTemplate } from "./copyFrom";

export const saveChecklist: NonNullable<
  MutationResolvers["saveChecklist"]
> = async (_, { input }, ctx) => {
  const { type, id } = decodeGlobalId(input.id);

  // TODO: (we'll want these eventually)
  // Assignees (workinstance)
  // Items (workinstance)
  // Required (none - for now)
  // Schedule (worktemplate)
  // Status (workinstance)

  if (type !== "worktemplate") {
    throw new Error("Can only modify templates right now");
  }

  const { count: exists } =
    await sql`SELECT 1 FROM public.worktemplate WHERE id = ${id}`;

  if (exists) {
    // update.
    const result = await sql.begin(tx => [
      tx`
        UPDATE public.worktemplate
        SET
            worktemplateenddate = ${input.active?.active ? null : sql`now()`},
            worktemplatemodifieddate = now()
        WHERE
            id = ${id}
            AND ${
              input.active?.active
                ? sql`(
                    worktemplateenddate IS NOT null
                    AND worktemplateenddate < now()
                )`
                : sql`(
                    worktemplateenddate IS null
                    OR worktemplateenddate > now()
                )`
            }
      `,
      input.auditable
        ? tx`
            WITH inputs (auditable) AS (
                VALUES (
                    ${input.auditable.enabled}::boolean
                )
            )

            UPDATE public.worktemplate
            SET
                worktemplateisauditable = inputs.auditable,
                worktemplatemodifieddate = now()
            FROM inputs
            WHERE
                id = ${id}
                AND
                worktemplateisauditable != inputs.auditable
        `
        : tx`
            UPDATE public.worktemplate
            SET
                worktemplateisauditable = false,
                worktemplatemodifieddate = now()
            WHERE
                id = ${id}
                AND
                worktemplateisauditable = true
        `,
      input.description
        ? tx`
            WITH inputs (source, locale) AS (
                VALUES (
                    ${input.description.value.value}::text,
                    (
                        SELECT systagid
                        FROM public.systag
                        WHERE
                            systagparentid = 2
                            AND
                            systagtype = ${input.description.value.locale}
                    )
                )
            ),

            i AS (
                INSERT INTO public.languagemaster AS lm (
                    languagemastercustomerid,
                    languagemastersource,
                    languagemastersourcelanguagetypeid
                )
                SELECT
                    wt.worktemplatecustomerid,
                    inputs.source,
                    inputs.locale
                FROM public.worktemplate AS wt, inputs
                WHERE
                    wt.id = ${id}
                    AND wt.worktemplatedescriptionid IS null
                RETURNING lm.languagemasterid AS id
            ),

            u AS (
                UPDATE public.languagemaster AS lm
                SET
                    languagemastersource = inputs.source,
                    languagemastersourcelanguagetypeid = inputs.locale,
                    languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
                    languagemastermodifieddate = now()
                FROM public.worktemplate AS wt, inputs
                WHERE
                    wt.id = ${id}
                    AND
                    wt.worktemplatedescriptionid IS NOT null
                    AND
                    lm.languagemasterid = wt.worktemplatedescriptionid
                    AND (
                        languagemastersource != inputs.source
                        OR
                        languagemastersourcelanguagetypeid != inputs.locale
                    )
            )

            UPDATE public.worktemplate AS wt
            SET
                worktemplatedescriptionid = i.id,
                worktemplatemodifieddate = now()
            FROM i
            WHERE
                wt.id = ${id}
                AND (
                    wt.worktemplatedescriptionid IS null
                    OR
                    wt.worktemplatedescriptionid != i.id
                )
        `
        : tx`
            UPDATE public.worktemplate
            SET
                worktemplatedescriptionid = null,
                worktemplatemodifieddate = now()
            WHERE
                id = ${id}
                AND
                worktemplatedescriptionid IS NOT null
        `,
      tx`
        WITH
            inputs AS (
                SELECT
                    ${input.name.value.value}::text AS name,
                    systagid AS locale
                FROM public.systag
                WHERE
                    systagparentid = 2
                    AND systagtype = ${input.name.value.locale}
            ),

            master AS (
                SELECT languagemasterid AS id
                FROM public.languagemaster
                WHERE languagemasterid IN (
                    SELECT worktemplatenameid
                    FROM public.worktemplate
                    WHERE id = ${id}
                )
            ),

            trans AS (
                UPDATE public.languagetranslations
                SET
                    languagetranslationvalue = inputs.name,
                    languagetranslationmodifieddate = now()
                FROM inputs, master
                WHERE
                    languagetranslationmasterid = master.id
                    AND languagetranslationtypeid = inputs.locale
                    AND languagetranslationvalue IS DISTINCT FROM inputs.name
            )

        UPDATE public.languagemaster
        SET
            languagemastersource = inputs.name,
            languagemastersourcelanguagetypeid = inputs.locale,
            languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
            languagemastermodifieddate = now()
        FROM inputs, master
        WHERE
            languagemasterid = master.id
            AND (languagemastersource, languagemastersourcelanguagetypeid) IS DISTINCT FROM (inputs.name, inputs.locale)
      `,
      input.sop
        ? tx`
            WITH inputs (sop) AS (
                VALUES (
                    ${input.sop.link.toString()}::text
                )
            )

            UPDATE public.worktemplate
            SET
                worktemplatesoplink = inputs.sop,
                worktemplatemodifieddate = now()
            FROM inputs
            WHERE
                id = ${id}
                AND (
                    worktemplatesoplink IS null
                    OR
                    worktemplatesoplink != inputs.sop
                )
        `
        : tx`
            UPDATE public.worktemplate
            SET
                worktemplatesoplink = null,
                worktemplatemodifieddate = now()
            WHERE
                id = ${id}
                AND worktemplatesoplink IS NOT null
        `,
    ]);

    const delta = result.reduce((acc, res) => acc + res.count, 0);
    console.log(
      `Applied ${delta} update(s) to Entity ${input.id} (${type}:${id})`,
    );

    if (input.items?.length) {
      await saveChecklistResults(id, input.items);
    }
  } else {
    // else: create
    const result = await sql.begin(async tx => {
      const r0 = await tx`
        WITH inputs (customer, source, locale, auditable, sop, description) AS (
            VALUES (
                (
                    SELECT customerid
                    FROM public.customer
                    WHERE customeruuid = ${decodeGlobalId(input.customerId).id}
                ),
                ${input.name.value.value}::text,
                (
                    SELECT systagid
                    FROM public.systag
                    WHERE
                        systagparentid = 2
                        AND
                        systagtype = ${input.name.value.locale}
                ),
                ${input.auditable?.enabled ?? false}::boolean,
                nullif(${input.sop?.link.toString() ?? null}, '')::text,
                nullif(${input.description?.value?.value ?? null}, '')::text
            )
        ),

        description AS (
            INSERT INTO public.languagemaster (
                languagemastercustomerid,
                languagemastersource,
                languagemastersourcelanguagetypeid
            )
            SELECT
                inputs.customer,
                inputs.description,
                inputs.locale
            FROM inputs
            WHERE inputs.description IS NOT null
            RETURNING languagemasterid AS id
        ),

        name AS (
            INSERT INTO public.languagemaster (
                languagemastercustomerid,
                languagemastersource,
                languagemastersourcelanguagetypeid
            )
            SELECT
                customer,
                source,
                locale
            FROM inputs
            RETURNING languagemasterid AS id
        ),

        site AS (
            SELECT locationid AS id
            FROM public.location
            INNER JOIN inputs
                ON locationcustomerid = inputs.customer
            WHERE locationistop = true
            LIMIT 1
        )

        INSERT INTO public.worktemplate (
            id,
            worktemplateallowondemand,
            worktemplatecustomerid,
            worktemplatedescriptionid,
            worktemplateisauditable,
            worktemplatenameid,
            worktemplatesiteid,
            worktemplatesoplink,
            worktemplateworkfrequencyid
        )
        SELECT
            ${id},
            true,
            inputs.customer,
            description.id,
            inputs.auditable,
            name.id,
            site.id,
            inputs.sop,
            1404
        FROM inputs, name, site
        LEFT JOIN description ON true
      `;

      // Fix the hardcoded worktemplateworkfrequencyid we set in the last
      // INSERT. Note that this is necessary because there is a circular
      // dependency between worktemplate and workfrequency.
      const r2 = await tx`
        WITH frequency AS (
            INSERT INTO public.workfrequency (
                workfrequencycustomerid,
                workfrequencytypeid,
                workfrequencyvalue,
                workfrequencyworktemplateid
            )
            SELECT
                wt.worktemplatecustomerid,
                740,
                1,
                wt.worktemplateid
            FROM public.worktemplate AS wt
            WHERE wt.id = ${id}
            RETURNING workfrequencyid AS id
        )

        UPDATE public.worktemplate AS wt
        SET
            worktemplateworkfrequencyid = frequency.id,
            worktemplatemodifieddate = now()
        FROM frequency
        WHERE wt.id = ${id}
      `;

      // Create the necessary next template rule for the On Demand frequency
      // type.
      const r3 = await tx`
        INSERT INTO public.worktemplatenexttemplate (
            worktemplatenexttemplateprevioustemplateid,
            worktemplatenexttemplatenexttemplateid,
            worktemplatenexttemplatecustomerid,
            worktemplatenexttemplateviastatuschange,
            worktemplatenexttemplateviastatuschangeid,
            worktemplatenexttemplatesiteid,
            worktemplatenexttemplatetypeid
        )

        SELECT
            worktemplateid,
            worktemplateid,
            worktemplatecustomerid,
            true,
            707,
            worktemplatesiteid,
            811
        FROM public.worktemplate
        WHERE id = ${id}
      `;

      // Assign the correct template type: Checklist.
      // These things are kinda like "marker components". They don't really mean
      // a whole lot to the rest of the system, but are crucial on the frontend
      // and in the datawarehouse at the moment.
      const r4 = await tx`
          INSERT INTO public.worktemplatetype (
              worktemplatetypecustomerid,
              worktemplatetypecustomeruuid,
              worktemplatetypeworktemplateuuid,
              worktemplatetypeworktemplateid,
              worktemplatetypesystaguuid,
              worktemplatetypesystagid
          )
          SELECT
              c.customerid,
              c.customeruuid,
              wt.id,
              wt.worktemplateid,
              t.systaguuid,
              t.systagid
          FROM public.worktemplate AS wt
          INNER JOIN public.customer AS c
              ON wt.worktemplatecustomerid = c.customerid
          INNER JOIN public.systag AS t
              ON
                  t.systagparentid = 882
                  AND
                  t.systagtype = 'Checklist'
          WHERE wt.id = ${id}
      `;

      // Create the primary location result. This essentially maps to an
      // Assignee component.
      const r5 = await tx`
        WITH inputs AS (
            SELECT
                worktemplateid,
                worktemplatecustomerid,
                worktemplatesiteid
            FROM public.worktemplate
            WHERE id = ${id}
        ),

        name AS (
            INSERT INTO public.languagemaster (
                languagemastercustomerid,
                languagemastersource,
                languagemastersourcelanguagetypeid
            )
            SELECT
                inputs.worktemplatecustomerid,
                'Location',
                20
            FROM inputs
            RETURNING languagemasterid
        ),

        type AS (
            SELECT
                t.systagid AS type,
                e.systagid AS reftype
            FROM public.systag AS t, public.systag AS e
            WHERE
                (t.systagparentid, t.systagtype) = (699, 'Entity')
                AND
                (e.systagparentid, e.systagtype) = (849, 'Location')
        ),

        widget AS (
            SELECT custagid AS type
            FROM public.custag, inputs
            WHERE
                custagcustomerid = inputs.worktemplatecustomerid
                AND custagsystagid = (
                    SELECT systagid
                    FROM public.systag
                    WHERE
                        systagparentid = 1
                        AND systagtype = 'Widget Type'
                )
                AND custagtype = 'Location'
            UNION
            SELECT custagid AS type
            FROM public.custag
            WHERE
                custagcustomerid = 0
                AND custagsystagid = (
                    SELECT systagid
                    FROM public.systag
                    WHERE
                        systagparentid = 1
                        AND systagtype = 'Widget Type'
                )
                AND custagtype = 'Location'
            LIMIT 1
        )

        INSERT INTO public.workresult (
            workresultcustomerid,
            workresultdefaultvalue,
            workresultentitytypeid,
            workresultforaudit,
            workresultfortask,
            workresultisprimary,
            workresultisrequired,
            workresultlanguagemasterid,
            workresultorder,
            workresultsiteid,
            workresultsoplink,
            workresulttypeid,
            workresultwidgetid,
            workresultworktemplateid
        )
        SELECT
            inputs.worktemplatecustomerid,
            inputs.worktemplatesiteid::text,
            type.reftype,
            true,
            true,
            true,
            false,
            name.languagemasterid,
            0,
            inputs.worktemplatesiteid,
            null,
            type.type,
            widget.type,
            inputs.worktemplateid
        FROM inputs, name, type, widget
      `;

      // Create the primary worker result. This essentially maps to an
      // Assignee component.
      const r6 = await tx`
        WITH inputs AS (
            SELECT
                worktemplateid,
                worktemplatecustomerid,
                worktemplatesiteid
            FROM public.worktemplate
            WHERE id = ${id}
        ),

        name AS (
            INSERT INTO public.languagemaster (
                languagemastercustomerid,
                languagemastersource,
                languagemastersourcelanguagetypeid
            )
            SELECT
                inputs.worktemplatecustomerid,
                'Worker',
                20
            FROM inputs
            RETURNING languagemasterid
        ),

        type AS (
            SELECT
                t.systagid AS type,
                e.systagid AS reftype
            FROM public.systag AS t, public.systag AS e
            WHERE
                (t.systagparentid, t.systagtype) = (699, 'Entity')
                AND
                (e.systagparentid, e.systagtype) = (849, 'Worker')
        ),

        widget AS (
            SELECT custagid AS type
            FROM public.custag, inputs
            WHERE
                custagcustomerid = inputs.worktemplatecustomerid
                AND custagsystagid = (
                    SELECT systagid
                    FROM public.systag
                    WHERE
                        systagparentid = 1
                        AND systagtype = 'Widget Type'
                )
                AND custagtype = 'Location'
            UNION
            SELECT custagid AS type
            FROM public.custag
            WHERE
                custagcustomerid = 0
                AND custagsystagid = (
                    SELECT systagid
                    FROM public.systag
                    WHERE
                        systagparentid = 1
                        AND systagtype = 'Widget Type'
                )
                AND custagtype = 'Location'
            LIMIT 1
        )

        INSERT INTO public.workresult (
            workresultcustomerid,
            workresultdefaultvalue,
            workresultentitytypeid,
            workresultforaudit,
            workresultfortask,
            workresultisprimary,
            workresultisrequired,
            workresultlanguagemasterid,
            workresultorder,
            workresultsiteid,
            workresultsoplink,
            workresulttypeid,
            workresultwidgetid,
            workresultworktemplateid
        )
        SELECT
            inputs.worktemplatecustomerid,
            null,
            type.reftype,
            true,
            true,
            true,
            false,
            name.languagemasterid,
            0,
            inputs.worktemplatesiteid,
            null,
            type.type,
            widget.type,
            inputs.worktemplateid
        FROM inputs, name, type, widget
      `;

      // Create a template constraint for (primary) location.
      // This is necessary for the rules engine to correctly (re)spawn instances.
      const r7 = await tx`
        INSERT INTO public.worktemplateconstraint (
            worktemplateconstraintcustomerid,
            worktemplateconstraintcustomeruuid,
            worktemplateconstrainttemplateid,
            worktemplateconstraintconstraintid,
            worktemplateconstraintconstrainedtypeid
        )

        SELECT
            wt.worktemplatecustomerid,
            c.customeruuid,
            wt.id,
            ct.custaguuid,
            cd.systaguuid
        FROM
            public.worktemplate AS wt,
            public.customer AS c,
            public.location AS l,
            public.custag AS ct,
            public.systag AS cd
        WHERE
            wt.id = ${id}
            AND
            wt.worktemplatecustomerid = c.customerid
            AND
            wt.worktemplatesiteid = l.locationid
            AND
            l.locationcategoryid = ct.custagid
            AND (
                cd.systagparentid = 849
                AND
                cd.systagtype = 'Location'
            )
      `;

      // Create a Time At Task result.
      const r8 = await tx`
        WITH inputs AS (
            SELECT
                worktemplateid,
                worktemplatecustomerid,
                worktemplatesiteid
            FROM public.worktemplate
            WHERE id = ${id}
        ),

        name (languagemasterid) AS (
            VALUES (4367::bigint)
        ),

        -- TODO: Eventually switch this to 'Duration'?
        type AS (
            SELECT t.systagid AS type
            FROM public.systag AS t
            WHERE
                (t.systagparentid, t.systagtype) = (699, 'Time At Task')
        ),

        widget AS (
            SELECT custagid AS type
            FROM public.custag, inputs
            WHERE
                custagcustomerid = inputs.worktemplatecustomerid
                AND custagsystagid = (
                    SELECT systagid
                    FROM public.systag
                    WHERE
                        systagparentid = 1
                        AND systagtype = 'Widget Type'
                )
                AND custagtype = 'Time At Task'
            UNION
            SELECT custagid AS type
            FROM public.custag
            WHERE
                custagcustomerid = 0
                AND custagsystagid = (
                    SELECT systagid
                    FROM public.systag
                    WHERE
                        systagparentid = 1
                        AND systagtype = 'Widget Type'
                )
                AND custagtype = 'Time At Task'
            LIMIT 1
        )

        INSERT INTO public.workresult (
            workresultcustomerid,
            workresultforaudit,
            workresultfortask,
            workresultisprimary,
            workresultisvisible,
            workresultlanguagemasterid,
            workresultorder,
            workresultsiteid,
            workresulttypeid,
            workresultwidgetid,
            workresultworktemplateid
        )
        SELECT
            inputs.worktemplatecustomerid,
            false,
            true,
            true,
            false,
            name.languagemasterid,
            999,
            inputs.worktemplatesiteid,
            type.type,
            widget.type,
            inputs.worktemplateid
        FROM inputs, name, type, widget
      `;

      return [r0, r2, r3, r4, r5, r6, r7, r8];
    });

    const delta = result.reduce((acc, res) => acc + res.count, 0);
    console.log(`Created Entity ${input.id} by way of ${delta} operation(s)`);

    if (input.items?.length) {
      await saveChecklistResults(id, input.items);
    }

    // Create an Open instance of the newly created Checklist template.
    await sql.begin(sql => copyFromWorkTemplate(sql, id, {}, ctx));
  }

  return {
    cursor: input.id.toString(),
    node: { id: input.id } as Checklist,
  };
};

async function saveChecklistResults(
  parent: string,
  input: NonNullable<ChecklistInput["items"]>,
) {
  const current = await sql<{ id: ID }[]>`
    SELECT encode(('workresult:' || id)::bytea, 'base64') AS id
    FROM public.workresult
    WHERE
        workresultworktemplateid = (
            SELECT worktemplateid
            FROM public.worktemplate
            WHERE id = ${parent}
        )
  `.then(rows => new Set(rows.map(r => r.id)));

  const actions = input.reduce((acc, inp) => {
    if ("checklist" in inp) return acc; // not yet supported
    const exists = current.has(inp.result.id);
    if (!acc.has(exists)) {
      acc.set(exists, []);
    }
    acc.get(exists)?.push(inp);
    return acc;
  }, new Map<boolean, ChecklistItemInput[]>());

  const result = await sql.begin(tx =>
    [...actions.entries()].flatMap(([exists, items]) =>
      exists
        ? items.flatMap(i =>
            i.result
              ? [
                  // update
                  // TODO: i.result.assignees
                  i.result.auditable
                    ? tx`
                        WITH inputs (auditable) AS (
                            VALUES (
                                ${i.result.auditable.enabled}::boolean
                            )
                        )

                        UPDATE public.workresult
                        SET
                            workresultforaudit = inputs.auditable,
                            workresultmodifieddate = now()
                        WHERE
                            id = ${decodeGlobalId(i.result.id).id}
                            AND workresultforaudit IS DISTINCT FROM inputs.auditable
                    `
                    : tx`
                        UPDATE public.workresult
                        SET
                            workresultforaudit = false,
                            workresultmodifieddate = now()
                        WHERE
                            id = ${decodeGlobalId(i.result.id).id}
                            AND workresultforaudit = true
                    `,
                  tx`
                    WITH
                        inputs AS (
                            SELECT
                                ${i.result.name.value.value}::text AS name,
                                systagid AS locale
                            FROM public.systag
                            WHERE
                                systagparentid = 2
                                AND systagtype = ${i.result.name.value.locale}
                        ),

                        master AS (
                            SELECT languagemasterid AS id
                            FROM public.languagemaster
                            WHERE languagemasteruuid = ${decodeGlobalId(i.result.name.id).id}
                        ),

                        trans AS (
                            UPDATE public.languagetranslations
                            SET
                                languagetranslationvalue = inputs.name,
                                languagetranslationmodifieddate = now()
                            FROM inputs, master
                            WHERE
                                languagetranslationmasterid = master.id
                                AND languagetranslationtypeid = inputs.locale
                                AND languagetranslationvalue IS DISTINCT FROM inputs.name
                        )

                    UPDATE public.languagemaster
                    SET
                        languagemastersource = inputs.name,
                        languagemastersourcelanguagetypeid = inputs.locale,
                        languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
                        languagemastermodifieddate = now()
                    FROM inputs, master
                    WHERE
                        languagemasterid = master.id
                        AND (languagemastersource, languagemastersourcelanguagetypeid) IS DISTINCT FROM (inputs.name, inputs.locale)
                  `,
                  tx`
                      WITH inputs (required) AS (
                          VALUES (
                              ${i.result.required ?? false}::boolean
                          )
                      )

                      UPDATE public.workresult
                      SET
                          workresultisrequired = inputs.required,
                          workresultmodifieddate = now()
                      FROM inputs
                      WHERE
                          id = ${decodeGlobalId(i.result.id).id}
                          AND workresultisrequired IS DISTINCT FROM inputs.required
                  `,
                  tx`
                      WITH inputs (ordinality) AS (
                          VALUES (
                              ${i.result.order}::integer
                          )
                      )

                      UPDATE public.workresult
                      SET 
                          workresultorder = inputs.ordinality,
                          workresultmodifieddate = now()
                      FROM inputs
                      WHERE
                          id = ${decodeGlobalId(i.result.id).id}
                          AND workresultorder IS DISTINCT FROM inputs.ordinality
                    `,
                  tx`
                        WITH inputs (type, widget, reftype, value) AS (
                            VALUES (
                              ${(() => {
                                switch (true) {
                                  case "boolean" in i.result.widget:
                                    return "Boolean";
                                  case "checkbox" in i.result.widget:
                                    return "Boolean";
                                  case "clicker" in i.result.widget:
                                    return "Number";
                                  case "duration" in i.result.widget:
                                    return "Duration";
                                  case "multiline" in i.result.widget:
                                    return "String";
                                  case "number" in i.result.widget:
                                    return "Number";
                                  case "reference" in i.result.widget:
                                    return "Entity";
                                  case "section" in i.result.widget:
                                    return "String";
                                  case "sentiment" in i.result.widget:
                                    return "Number";
                                  case "string" in i.result.widget:
                                    return "String";
                                  case "temporal" in i.result.widget:
                                    return "Date";
                                  default: {
                                    const _: never = i.result.widget;
                                    throw "invariant violated";
                                  }
                                }
                              })()}::text,
                              ${(() => {
                                switch (true) {
                                  case "boolean" in i.result.widget:
                                    return "Boolean";
                                  case "checkbox" in i.result.widget:
                                    return "Checkbox";
                                  case "clicker" in i.result.widget:
                                    return "Clicker";
                                  case "duration" in i.result.widget:
                                    return "Duration";
                                  case "multiline" in i.result.widget:
                                    return "Text";
                                  case "number" in i.result.widget:
                                    return "Number";
                                  case "reference" in i.result.widget:
                                    // biome-ignore lint/style/noNonNullAssertion:
                                    return i.result.widget.reference!
                                      .possibleTypes[0];
                                  case "section" in i.result.widget:
                                    return "Section";
                                  case "sentiment" in i.result.widget:
                                    return "Number";
                                  case "string" in i.result.widget:
                                    return "String";
                                  case "temporal" in i.result.widget:
                                    return "Date";
                                  default: {
                                    const _: never = i.result.widget;
                                    throw "invariant violated";
                                  }
                                }
                              })()}::text,
                              ${
                                i.result.widget.reference?.value
                                  ? match(
                                      decodeGlobalId(
                                        i.result.widget.reference.value,
                                      ).type,
                                    )
                                      .with("location", () => "Location")
                                      .with("worker", () => "Worker")
                                      .otherwise(() => null)
                                  : null
                              }::text,
                              ${(() => {
                                switch (true) {
                                  case "boolean" in i.result.widget:
                                    return (
                                      i.result.widget.boolean?.value ?? null
                                    );
                                  case "checkbox" in i.result.widget:
                                    return (
                                      i.result.widget.checkbox?.value ?? null
                                    );
                                  case "clicker" in i.result.widget:
                                    return (
                                      i.result.widget.clicker?.value ?? null
                                    );
                                  case "duration" in i.result.widget:
                                    return (
                                      i.result.widget.duration?.value ?? null
                                    );
                                  case "multiline" in i.result.widget:
                                    return (
                                      i.result.widget.multiline?.value ?? null
                                    );
                                  case "number" in i.result.widget:
                                    return (
                                      i.result.widget.number?.value ?? null
                                    );
                                  case "reference" in i.result.widget: {
                                    return i.result.widget.reference?.value
                                      ? match(
                                          decodeGlobalId(
                                            i.result.widget.reference.value,
                                          ),
                                        )
                                          .with(
                                            {
                                              type: "location",
                                              id: P.string,
                                            },
                                            ({ id }) => sql`(
                                                SELECT locationid
                                                FROM public.location
                                                WHERE locationuuid = ${id}
                                            )`,
                                          )
                                          .with(
                                            { type: "worker", id: P.string },
                                            ({ id }) => sql`(
                                                SELECT workerinstanceid
                                                FROM public.workerinstance
                                                WHERE workerinstanceuuid = ${id}
                                            )`,
                                          )
                                          .otherwise(() => null)
                                      : null;
                                  }
                                  case "section" in i.result.widget:
                                    return (
                                      i.result.widget.section?.value ?? null
                                    );
                                  case "sentiment" in i.result.widget:
                                    return (
                                      i.result.widget.sentiment?.value ?? null
                                    );
                                  case "string" in i.result.widget:
                                    return (
                                      i.result.widget.string?.value ?? null
                                    );
                                  case "temporal" in i.result.widget:
                                    return null;
                                  default: {
                                    const _: never = i.result.widget;
                                    throw "invariant violated";
                                  }
                                }
                              })()}::text
                            )
                        ),

                        type AS (
                            SELECT
                                t.systagid AS type,
                                r.systagid AS reftype
                            FROM inputs
                            INNER JOIN public.systag AS t
                                ON
                                    t.systagparentid = 699
                                    AND t.systagtype = inputs.type
                            LEFT JOIN public.systag AS r
                                ON
                                    r.systagparentid = 849
                                    AND r.systagtype = inputs.reftype
                        )

                        UPDATE public.workresult AS wr
                        SET
                            workresultdefaultvalue = inputs.value,
                            workresultmodifieddate = now()
                        FROM inputs, type
                        WHERE
                            wr.id = ${decodeGlobalId(i.result.id).id}
                            AND wr.workresultdefaultvalue IS DISTINCT FROM inputs.value
                    `,
                ]
              : [],
          )
        : items.flatMap(i =>
            i.result
              ? [
                  // create
                  tx`
                    WITH p AS (
                        SELECT
                            worktemplateid AS id,
                            worktemplatecustomerid AS customer,
                            worktemplatesiteid AS location
                        FROM public.worktemplate
                        WHERE id = ${parent}
                    ),

                    t AS (
                        SELECT
                            t.systagid AS type,
                            r.systagid AS entity
                        FROM public.systag AS t
                        LEFT JOIN public.systag AS r
                            ON
                                r.systagparentid = 849
                                AND r.systagtype = ${match(
                                  i.result.widget.reference?.possibleTypes.at(
                                    0,
                                  ),
                                )
                                  .with("Location", () => "Location")
                                  .with("Worker", () => "Worker")
                                  .otherwise(() => null)}::text
                        WHERE
                            t.systagparentid = 699
                            AND t.systagtype = ${(() => {
                              switch (true) {
                                case "boolean" in i.result.widget:
                                  return "Boolean";
                                case "checkbox" in i.result.widget:
                                  return "Boolean";
                                case "clicker" in i.result.widget:
                                  return "Number";
                                case "duration" in i.result.widget:
                                  return "Duration";
                                case "multiline" in i.result.widget:
                                  return "String";
                                case "number" in i.result.widget:
                                  return "Number";
                                case "reference" in i.result.widget:
                                  return "Entity";
                                case "section" in i.result.widget:
                                  return "String";
                                case "sentiment" in i.result.widget:
                                  return "Number";
                                case "string" in i.result.widget:
                                  return "String";
                                case "temporal" in i.result.widget:
                                  return "Date";
                                default: {
                                  const _: never = i.result.widget;
                                  throw "invariant violated";
                                }
                              }
                            })()}
                    ),

                    w AS (
                        SELECT custagid AS type
                        FROM public.custag, p
                        WHERE
                            custagcustomerid = p.customer
                            AND custagsystagid = (
                                SELECT systagid
                                FROM public.systag
                                WHERE
                                    systagparentid = 1
                                    AND systagtype = 'Widget Type'
                            )
                            AND custagtype = ${(() => {
                              switch (true) {
                                case "boolean" in i.result.widget:
                                  return "Boolean";
                                case "checkbox" in i.result.widget:
                                  return "Checkbox";
                                case "section" in i.result.widget:
                                  return "Section";
                                case "clicker" in i.result.widget:
                                  return "Clicker";
                                case "duration" in i.result.widget:
                                  return "Duration";
                                case "multiline" in i.result.widget:
                                  return "Text";
                                case "number" in i.result.widget:
                                  return "Number";
                                case "reference" in i.result.widget:
                                  // biome-ignore lint/style/noNonNullAssertion:
                                  return i.result.widget.reference!
                                    .possibleTypes[0];
                                case "sentiment" in i.result.widget:
                                  return "Sentiment";
                                case "string" in i.result.widget:
                                  return "String";
                                case "temporal" in i.result.widget:
                                  return "Date";
                                default: {
                                  const _: never = i.result.widget;
                                  throw "invariant violated";
                                }
                              }
                            })()}
                        UNION
                        SELECT custagid AS type
                        FROM public.custag
                        WHERE
                            custagcustomerid = 0
                            AND custagsystagid = (
                                SELECT systagid
                                FROM public.systag
                                WHERE
                                    systagparentid = 1
                                    AND systagtype = 'Widget Type'
                            )
                            AND custagtype = ${(() => {
                              switch (true) {
                                case "boolean" in i.result.widget:
                                  return "Boolean";
                                case "checkbox" in i.result.widget:
                                  return "Checkbox";
                                case "section" in i.result.widget:
                                  return "Section";
                                case "clicker" in i.result.widget:
                                  return "Clicker";
                                case "duration" in i.result.widget:
                                  return "Duration";
                                case "multiline" in i.result.widget:
                                  return "Text";
                                case "number" in i.result.widget:
                                  return "Number";
                                case "reference" in i.result.widget:
                                  // biome-ignore lint/style/noNonNullAssertion:
                                  return i.result.widget.reference!
                                    .possibleTypes[0];
                                case "sentiment" in i.result.widget:
                                  return "Sentiment";
                                case "string" in i.result.widget:
                                  return "String";
                                case "temporal" in i.result.widget:
                                  return "Date";
                                default: {
                                  const _: never = i.result.widget;
                                  throw "invariant violated";
                                }
                              }
                            })()}
                        LIMIT 1
                    ),

                    v (value) AS (
                        VALUES (
                            ${(() => {
                              switch (true) {
                                case "boolean" in i.result.widget:
                                  return i.result.widget.boolean?.value ?? null;
                                case "checkbox" in i.result.widget:
                                  return (
                                    i.result.widget.checkbox?.value ?? null
                                  );
                                case "section" in i.result.widget:
                                  return i.result.widget.section?.value ?? null;
                                case "clicker" in i.result.widget:
                                  return i.result.widget.clicker?.value ?? null;
                                case "duration" in i.result.widget:
                                  return (
                                    i.result.widget.duration?.value ?? null
                                  );
                                case "multiline" in i.result.widget:
                                  return (
                                    i.result.widget.multiline?.value ?? null
                                  );
                                case "number" in i.result.widget:
                                  return i.result.widget.number?.value ?? null;
                                case "reference" in i.result.widget: {
                                  return i.result.widget.reference?.value
                                    ? match(
                                        decodeGlobalId(
                                          i.result.widget.reference.value,
                                        ),
                                      )
                                        .with(
                                          {
                                            type: "location",
                                            id: P.string,
                                          },
                                          ({ id }) => sql`(
                                              SELECT locationid::text
                                              FROM public.location
                                              WHERE locationuuid = ${id}
                                          )`,
                                        )
                                        .with(
                                          { type: "worker", id: P.string },
                                          ({ id }) => sql`(
                                              SELECT workerinstanceid::text
                                              FROM public.workerinstance
                                              WHERE workerinstanceuuid = ${id}
                                          )`,
                                        )
                                        .otherwise(() => null)
                                    : null;
                                }
                                case "sentiment" in i.result.widget:
                                  return (
                                    i.result.widget.sentiment?.value ?? null
                                  );
                                case "string" in i.result.widget:
                                  return i.result.widget.string?.value ?? null;
                                case "temporal" in i.result.widget:
                                  return null;
                                default: {
                                  const _: never = i.result.widget;
                                  throw "invariant violated";
                                }
                              }
                            })()}::text
                        )
                    ),

                    n AS (
                        INSERT INTO public.languagemaster (
                            languagemastercustomerid,
                            languagemastersource,
                            languagemastersourcelanguagetypeid
                        )
                        SELECT
                            p.customer,
                            ${i.result.name.value.value}::text,
                            locale.systagid
                        FROM p, public.systag AS locale
                        WHERE
                            locale.systagparentid = 2
                            AND locale.systagtype = ${i.result.name.value.locale}
                        RETURNING languagemasterid AS id
                    ),

                    a (sop) AS (
                        VALUES (
                          null::text
                        )
                    ),

                    c (auditable, required) AS (
                        VALUES (
                            ${i.result.auditable?.enabled ?? false}::boolean,
                            ${i.result.required ?? false}::boolean
                        )
                    )

                    INSERT INTO public.workresult (
                        workresultcustomerid,
                        workresultdefaultvalue,
                        workresultentitytypeid,
                        workresultforaudit,
                        workresultfortask,
                        workresultisrequired,
                        workresultlanguagemasterid,
                        workresultorder,
                        workresultsiteid,
                        workresultsoplink,
                        workresulttypeid,
                        workresultwidgetid,
                        workresultworktemplateid
                    )
                    SELECT
                        p.customer,
                        v.value,
                        t.entity,
                        c.auditable,
                        true,
                        c.required,
                        n.id,
                        ${i.result.order},
                        p.location,
                        a.sop,
                        t.type,
                        w.type,
                        p.id
                    FROM p, a, c, n, t, v, w
                  `,
                ]
              : [],
          ),
    ),
  );

  const delta = result?.reduce((acc, res) => acc + res.count, 0);
  console.log(`Applied ${delta} update(s) to nested Entities`);
}
