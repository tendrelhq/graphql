import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import type {
  Checklist,
  InputMaybe,
  MutationResolvers,
  WidgetInput,
} from "@/schema";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import {
  assert,
  assertNonNull,
  assertUnderlyingType,
  map,
  mapOrElse,
} from "@/util";
import { GraphQLError } from "graphql";

type RawFieldCreateInput = [
  string, // name
  string, // type
  number, // order
  boolean, // auditable
  string, // description
  boolean, // draft
  boolean, // required
  string, // default value
  string, // widget type
];

type RawFieldUpdateInput = [
  string, // id
  ...RawFieldCreateInput,
];

export const saveChecklist: NonNullable<
  MutationResolvers["saveChecklist"]
> = async (_, { input }, ctx) => {
  let existing: InputMaybe<string>;
  if (input.id) {
    const { type, id } = decodeGlobalId(input.id);

    if (type !== "worktemplate") {
      throw new GraphQLError("Can only modify templates right now", {
        extensions: {
          code: "BAD_REQUEST",
        },
      });
    }

    const [row] = await sql<[{ deleted: boolean }?]>`
      select worktemplatedeleted as deleted
      from public.worktemplate
      where id = ${id}
    `;
    existing = row ? id : undefined;

    if (row?.deleted === true) {
      throw new GraphQLError(
        "The Checklist you are trying to modify has been deleted.",
        {
          extensions: {
            code: "BAD_REQUEST",
          },
        },
      );
    }
  }

  if (existing) {
    const fields: RawFieldUpdateInput[] = mapOrElse(
      input.items,
      items =>
        items
          // We don't support nested templates at the moment.
          .filter(item => !!item.result)
          .map(({ result }) => [
            // id
            map(result.id, field => {
              try {
                const { type, id } = decodeGlobalId(field);
                assertUnderlyingType("workresult", type);
                return id;
              } catch {
                return null; // implies `field` was client generated
              }
            }) as string,
            // name
            result.name.value.value, // gross
            // type
            assertNonNull(
              map(result.widget, resultTypeFromInput),
              "unsupported result type",
            ),
            // order
            result.order,
            // auditable
            (result.auditable?.enabled ?? false) as boolean,
            // desc
            (result.description?.value.value ?? null) as string,
            // draft
            (result.draft ?? false) as boolean,
            // required
            (result.required ?? false) as boolean,
            // value (default)
            (map(result.widget, defaultValueFromInput) ?? null) as string,
            // widget
            map(result.widget, widgetTypeFromInput) as string,
          ]),
      [],
    );

    const [node, delta] = await sql.begin(async sql => {
      await setCurrentIdentity(sql, ctx);

      let count = 0;

      // First, we do all updates that don't have side effects. Side effects are
      // things like "insantiate on publish", "reap on delete", etc. Updates to
      // a template's description, name and sop are side effect free. Changing
      // whether a template is auditable, deleting a template, and publishing a
      // template (or any of its results) are operations that involve side
      // effects. We'll do those last.
      const r = await sql`
        with inputs (sop) as (
          values (${input.sop?.link.toString() ?? null}::text)
        )
        update public.worktemplate
        set worktemplatesoplink = inputs.sop,
            worktemplatemodifieddate = now(),
            worktemplatemodifiedby = auth.current_identity(worktemplatecustomerid, current_setting('user.id'))
        from inputs
        where id = ${existing}
          and nullif(worktemplatesoplink, '') is distinct from inputs.sop
        returning 1
      `;
      count += r.length;

      if (input.description) {
        // Upsert description.
        const r = await sql`
          with
            input as (
              select
                  auth.current_identity(worktemplatecustomerid, current_setting('user.id')) as actor,
                  systag.systagid as locale,
                  worktemplate.worktemplatecustomerid as owner,
                  worktemplate.worktemplateid as template,
                  ${input.description.value.value}::text as value
              from public.systag, public.worktemplate
              where systag.systagparentid = 2
                and systag.systagtype = current_setting('user.locale')
                and worktemplate.id = ${existing}
            ),

            description as (
              select *
              from public.workdescription
              where id = ${input.description.id ?? null}
            ),

            ins_content as (
              insert into public.languagemaster (
                  languagemastercustomerid,
                  languagemastersource,
                  languagemastersourcelanguagetypeid,
                  languagemastermodifiedby
              )
              select
                  input.owner,
                  input.value,
                  input.locale,
                  input.actor
              from input
              where not exists (select 1 from description)
              returning
                  languagemasterid as _id,
                  languagemastersourcelanguagetypeid as _type
            ),

            ins_desc as (
              insert into public.workdescription (
                  workdescriptioncustomerid,
                  workdescriptionworktemplateid,
                  workdescriptionlanguagemasterid,
                  workdescriptionlanguagetypeid,
                  workdescriptionmodifiedby
              )
              select
                  input.owner,
                  input.template,
                  ins_content._id,
                  ins_content._type,
                  input.actor
              from input, ins_content
              returning 1
            ),

            upd_master as (
              update public.languagemaster
              set languagemastersource = input.value,
                  languagemastersourcelanguagetypeid = input.locale,
                  languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
                  languagemastermodifieddate = now(),
                  languagemastermodifiedby = input.actor
              from input, description
              where languagemasterid = description.workdescriptionlanguagemasterid
                and (languagemastersource, languagemastersourcelanguagetypeid)
                    is distinct from (input.value, input.locale)
              returning 1
            ),

            upd_trans as (
              update public.languagetranslations
              set languagetranslationvalue = input.value,
                  languagetranslationmodifieddate = now(),
                  languagetranslationmodifiedby = input.actor
              from input, description
              where languagetranslationmasterid = description.workdescriptionlanguagemasterid
                and (languagetranslationvalue, languagetranslationtypeid)
                    is distinct from (input.value, input.locale)
              returning 1
            )

          select 1 from ins_desc
          union all
          select 1 from ins_content
          union all
          select 1 from upd_master
          union all
          select 1 from upd_trans
        `;
        count += r.length;
      } else {
        // Remove description.
        const r = await sql`
          update public.workdescription
          set workdescriptionenddate = now(),
              workdescriptionmodifieddate = now(),
              workdescriptionmodifiedby = auth.current_setting(workdescriptioncustomerid, current_setting('user.id'))
          from input
          where
            workdescriptionworktemplateid = (
                select worktemplateid
                from public.worktemplate
                where id = ${existing}
            )
            and workdescriptionworkresultid is null
          returning 1
        `;
        count += r.length;
      }

      if (input.name) {
        // Update name.
        const r = await sql`
          with
            input as (
              select ${input.name.value.value}::text as name, systagid as locale
              from public.systag
              where systagparentid = 2
                and systagtype = current_setting('user.locale')
            ),

            master as (
              select languagemasterid as id
              from public.languagemaster
              where languagemasterid in (
                  select worktemplatenameid
                  from public.worktemplate
                  where id = ${existing}
              )
            ),

            upd_trans as (
              update public.languagetranslations
              set languagetranslationvalue = input.name,
                  languagetranslationmodifieddate = now()
              from input, master
              where languagetranslationmasterid = master.id
                and languagetranslationtypeid = input.locale
                and languagetranslationvalue is distinct from input.name
              returning 1
            ),

            upd_master as (
              update public.languagemaster
              set languagemastersource = input.name,
                  languagemastersourcelanguagetypeid = input.locale,
                  languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
                  languagemastermodifieddate = now()
              from input, master
              where languagemasterid = master.id
                and (languagemastersource, languagemastersourcelanguagetypeid) is distinct from (input.name, input.locale)
              returning 1
            )

          select * from upd_master
          union all
          select * from upd_trans
        `;
        count += r.length;
      }

      // Now we begin with engine1.
      // First up, the template itself. This will cascade template-level
      // operations into instantiations. Note that this is slightly suboptimal
      // since we will need a second pass through at the result-level to ensure
      // all of the fields are instantiated correctly. Also note that the
      // operations below are no-ops if the templates are already in the given
      // states.
      {
        const r = await sql`
          with
            node as (
              select *
              from public.worktemplate
              where id = ${existing}
            ),

            ops as (
              select t.*
              from node, engine1.set_worktemplateisauditable(
                jsonb_build_array(
                  jsonb_build_object(
                      'id', node.id,
                      'enabled', ${input.auditable?.enabled ?? false}
                  )
                )
              ) as t
              union all
              select t.*
              from node, engine1.set_worktemplatedraft(
                jsonb_build_array(
                  jsonb_build_object(
                      'id', node.id,
                      'draft', ${input.draft ?? false}
                  )
                )
              ) as t
            )

          select t.*
          from ops, engine1.execute(ops.*) as t;
        `;
        count += r.length;
      }

      // Lastly we do fields. These also go through engine1, and also cascade
      // into field-level instantiations.
      if (fields.length) {
        const r = await sql`
          with
            constants as (
              select
                  auth.current_identity(customerid, current_setting('user.id')) as actor,
                  systagtype as language,
                  customeruuid as owner,
                  worktemplate.id as template
              from
                  public.worktemplate,
                  public.customer,
                  public.systag
              where
                  worktemplate.id = ${existing}
                  and systag.systagparentid = 2
                    and systag.systagtype = current_setting('user.locale')
                  and worktemplatecustomerid = customerid
            ),

            fields (id, "name", "type", "order", auditable, "desc", draft, required, "value", widget) as (
              values ${sql(fields as string[][])}
            )

          select t.*
          from
            constants as c,
            fields as f,
            engine1.upsert_field_t(
                customer_id := c."owner",
                language_type := c."language",
                modified_by := c.actor,
                template_id := c.template,
                field_description := f."desc",
                field_id := f.id,
                field_is_draft := f.draft::boolean,
                field_is_primary := false,
                field_is_required := f.required::boolean,
                field_name := f."name",
                field_order := f."order"::integer,
                field_reference_type := null,
                field_type := f."type",
                field_value := f."value",
                field_widget := f.widget
            ) as ops,
            engine1.execute(ops.*) as t
          ;
        `;
        count += r.length;
        console.debug(`saveChecklist: engine1.execute.count: ${r.length}`);
        if (process.env.NODE_ENV === "development" && r.length) {
          console.debug(
            `saveChecklist: engine1.execute:\n${JSON.stringify(r, null, 2)}`,
          );
        }
      }

      return [encodeGlobalId({ type: "worktemplate", id: existing }), count];
    });

    console.debug(`Updated Checklist by way of ${delta} operations(s).`);

    return {
      cursor: node,
      node: { id: node } as Checklist,
    };
  }

  // else: create
  const fields: RawFieldCreateInput[] = mapOrElse(
    input.items,
    items =>
      items
        // We don't support nested templates at the moment.
        .filter(item => !!item.result)
        .map(({ result }) => [
          // name
          result.name.value.value,
          // type
          assertNonNull(
            map(result.widget, resultTypeFromInput),
            "unsupported result type",
          ),
          // order
          result.order,
          // auditable
          (result.auditable?.enabled ?? false) as boolean,
          // desc
          (result.description?.value.value ?? null) as string,
          // draft
          (result.draft ?? false) as boolean,
          // required
          (result.required ?? false) as boolean,
          // value (default)
          (map(result.widget, defaultValueFromInput) ?? null) as string,
          // widget
          map(result.widget, widgetTypeFromInput) as string,
        ]),
    [],
  );
  const { type: parentType, id: parentId } = decodeGlobalId(input.parent);
  if (parentType !== "location") {
    throw new GraphQLError(`Invalid parent type for Checklist: ${parentType}`, {
      extensions: {
        code: "BAD_REQUEST",
      },
    });
  }

  const [node, delta] = await sql.begin(async sql => {
    await setCurrentIdentity(sql, ctx);

    let count = 0;
    const rows = await sql`
      select
          auth.current_identity(customerid, current_setting('user.id')) as actor,
          systagtype as language,
          customeruuid as owner,
          t.id as template
      from
        public.location,
        public.customer,
        public.systag,
        legacy0.create_task_t(
            customer_id := customeruuid,
            language_type := systagtype,
            task_name := ${input.name.value.value},
            task_parent_id := location.locationuuid,
            modified_by := auth.current_identity(customerid, current_setting('user.id'))
        ) as t
      where locationuuid = ${parentId}
        and locationcustomerid = customerid
        and systagparentid = 2 and systagtype = current_setting('user.locale')
      ;
    `;
    assert(rows.length === 1);
    count += 1;

    const { actor, language, owner, template } = rows[0];

    {
      const r = await sql`
        select *
        from legacy0.create_template_type(
            template_id := ${template},
            systag_id := (
                select systaguuid
                from public.systag
                where systagparentid = 882 and systagtype = 'Checklist'
            ),
            modified_by := ${actor}
        );
      `;
      count += r.length;
    }

    {
      const r = await sql`
        select *
        from legacy0.create_instantiation_rule(
            prev_template_id := ${template},
            next_template_id := ${template},
            state_condition := 'In Progress',
            type_tag := 'On Demand',
            modified_by := ${actor}
        );
      `;
      count += r.length;
    }

    {
      const r = await sql`
        select t.*
        from legacy0.create_template_constraint_on_location(
            template_id := ${template},
            location_id := ${parentId},
            modified_by := ${actor}
        ) as t;
      `;
      count += r.length;
    }

    if (input.auditable) {
      const r = await sql`
        update public.worktemplate
        set worktemplateisauditable = ${input.auditable.enabled}
        where id = ${template}
          and worktemplateisauditable is distinct from ${input.auditable.enabled};
      `;
      count += r.count;
    }

    if (input.description) {
      const r = await sql`
        with ins_content as (
            select *
            from i18n.create_localized_content(
                owner := ${owner},
                content := ${input.description.value.value},
                language := ${input.description.value.locale ?? ctx.req.i18n.language}
            )
        )

        insert into public.workdescription (
            workdescriptioncustomerid,
            workdescriptionworktemplateid,
            workdescriptionlanguagemasterid,
            workdescriptionlanguagetypeid,
            workdescriptionmodifiedby
        )
        select
            worktemplatecustomerid,
            worktemplateid,
            ins_content._id,
            ins_content._type,
            ${actor}
        from ins_content, public.worktemplate
        where worktemplate.id = ${template}
      `;
      count += r.count;
    }

    if (input.sop) {
      const r = await sql`
        update public.worktemplate
        set worktemplatesoplink = ${input.sop.link.toString()}
        where id = ${template};
      `;
      count += r.count;
    }

    if (fields.length) {
      const r = await sql`
        with field (f_name, f_type, f_order, f_auditable, f_desc, f_draft, f_required, f_value, f_widget) as (
          values ${sql(fields as string[][])}
        )

        select t.*
        from field, legacy0.create_field_t(
            customer_id := ${owner},
            language_type := ${language},
            template_id := ${template},
            field_description := field.f_desc,
            field_is_draft := field.f_draft::boolean,
            field_is_primary := false,
            field_is_required := field.f_required::boolean,
            field_name := field.f_name,
            field_order := field.f_order::integer,
            field_reference_type := null,
            field_type := field.f_type,
            field_value := field.f_value,
            field_widget := field.f_widget,
            modified_by := ${actor}
        ) as t;
      `;
      count += r.length;
    }

    if (input.draft !== true) {
      // This may be the update responsible for "publishing" this template...
      const r = await sql`
        with ops as (
          select *
          from engine1.instantiate_worktemplate(jsonb_build_array(${template}))
        )
        select t.*
        from ops, engine1.execute(ops.*) as t
      `;
      count += r.length;
      console.debug(`saveChecklist: engine1.execute.count: ${r.length}`);
      if (process.env.NODE_ENV === "development") {
        console.debug(
          `saveChecklist: engine1.execute:\n${JSON.stringify(r, null, 2)}`,
        );
      }
    }

    return [encodeGlobalId({ type: "worktemplate", id: template }), count];
  });

  console.debug(`Created Checklist by way of ${delta} operation(s)`);

  return {
    cursor: node,
    node: { id: node } as Checklist,
  };
};

function resultTypeFromInput(input: WidgetInput) {
  switch (true) {
    case "boolean" in input:
      return "Boolean";
    case "checkbox" in input:
      return "Boolean";
    case "clicker" in input:
      return "Number";
    case "duration" in input:
      return "Duration";
    case "multiline" in input:
      return "String";
    case "number" in input:
      return "Number";
    case "reference" in input:
      // Not supported at the moment.
      return null;
    case "section" in input:
      return "String";
    case "sentiment" in input:
      return "Number";
    case "string" in input:
      return "String";
    case "temporal" in input:
      return "Date";
    default: {
      const _: never = input;
      throw "invariant violated";
    }
  }
}

function defaultValueFromInput(input: WidgetInput) {
  switch (true) {
    case "boolean" in input:
      return input.boolean?.value?.toString();
    case "checkbox" in input:
      return input.checkbox?.value?.toString();
    case "clicker" in input:
      return input.clicker?.value?.toString();
    case "duration" in input:
      return input.duration?.value?.toString();
    case "multiline" in input:
      return input.multiline?.value;
    case "number" in input:
      return input.number?.value?.toString();
    case "reference" in input:
      // Not supported at the moment.
      return null;
    case "section" in input:
      return input.section?.value;
    case "sentiment" in input:
      return input.sentiment?.value?.toString();
    case "string" in input:
      return input.string?.value;
    case "temporal" in input: {
      if (input.temporal.value?.instant) {
        return input.temporal.value.instant;
      }
      if (input.temporal.value?.zdt) {
        return input.temporal.value.zdt.epochMilliseconds;
      }
      return null;
    }
    default: {
      const _: never = input;
      return null; // theoretically impossible but no need to panic
    }
  }
}

function widgetTypeFromInput(input: WidgetInput) {
  switch (true) {
    case "boolean" in input:
      return "Boolean";
    case "checkbox" in input:
      return "Checkbox";
    case "clicker" in input:
      return "Clicker";
    case "duration" in input:
      return "Duration";
    case "multiline" in input:
      return "Text";
    case "number" in input:
      return "Number";
    case "reference" in input:
      // Not supported at the moment.
      return null;
    case "section" in input:
      return "Section";
    case "sentiment" in input:
      return "Sentiment";
    case "string" in input:
      return "String";
    case "temporal" in input:
      return "Date";
    default: {
      const _: never = input;
      throw "invariant violated";
    }
  }
}

async function engine1() {
  //
}
