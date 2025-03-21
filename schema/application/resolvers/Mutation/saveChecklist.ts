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

export const saveChecklist: NonNullable<
  MutationResolvers["saveChecklist"]
> = async (_, { input }, ctx) => {
  const customerId = decodeGlobalId(input.customerId).id;

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
    const fields: [string, string, string, number, string, string][] =
      //           id    , name  , type  , order , desc  , widget
      mapOrElse(
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
              // desc
              (result.description?.value ?? null) as unknown as string,
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
      // effects.
      const r = await sql`
        with input (auditable, sop) as (
          values (
              ${input.auditable?.enabled ?? false}::boolean,
              ${input.sop?.link.toString() ?? null}::text
          )
        )

        update public.worktemplate
        set worktemplateisauditable = input.auditable,
            worktemplatesoplink = input.sop,
            worktemplatemodifieddate = now(),
            worktemplatemodifiedby = auth.current_identity(worktemplatecustomerid, current_setting('user.id'))
        from input
        where id = ${existing}
          and (worktemplateisauditable, worktemplatesoplink)
              is distinct from (input.auditable, input.sop)
        returning 1
      `;
      count += r.length;

      // Next we do relational updates.
      if (input.description) {
        // Upsert description.
        const r = await sql`
          with
            input as (
              select
                  auth.current_identity(worktemplatecustomerid, ${ctx.auth.userId}) as actor,
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
          with input as (
              select
                  auth.current_identity(worktemplatecustomerid, ${ctx.auth.userId}) as actor,
                  worktemplate.worktemplateid as template
              from public.worktemplate
              where worktemplate.id = ${existing}
          )

          update public.workdescription
          set workdescriptionenddate = now(),
              workdescriptionmodifieddate = now(),
              workdescriptionmodifiedby = input.actor
          from input
          where workdescriptionworktemplateid = input.template
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

      // Finally, fields.
      if (fields.length) {
        const r = await sql`
          with
            input as (
              select
                  auth.current_identity(customerid, current_setting('user.id')) as actor,
                  systagtype as language,
                  customeruuid as owner,
                  worktemplate.id as template
              from
                  public.customer,
                  public.systag,
                  public.worktemplate
              where
                  customer.customeruuid = ${customerId}
                  and systag.systagparentid = 2
                    and systag.systagtype = current_setting('user.locale')
                  and worktemplate.id = ${existing}
            ),

            field (id, f_name, f_type, f_order, f_desc, f_widget) as (
              values ${sql(fields)}
            )

          select 1
          from
            input,
            field,
            legacy0.ensure_field_t(
                customer_id := input.owner,
                language_type := input.language,
                template_id := input.template,
                field_description := field.f_desc,
                field_id := field.id,
                field_is_draft := false,
                field_is_primary := false,
                field_is_required := false,
                field_name := field.f_name,
                field_order := field.f_order::integer,
                field_reference_type := null,
                field_type := field.f_type,
                field_value := null,
                field_widget := field.f_widget,
                modified_by := input.actor
            ) as t
          ;
        `;
        count += r.length;
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
  const fields: [string, string, number, string, string][] = mapOrElse(
    //           name  , type  , order , desc  , widget
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
          // desc
          (result.description?.value ?? null) as unknown as string,
          // widget
          map(result.widget, widgetTypeFromInput) as string,
        ]),
    [],
  );
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
        public.customer,
        public.systag,
        legacy0.create_task_t(
            customer_id := customeruuid,
            language_type := systagtype,
            task_name := ${input.name.value.value},
            task_parent_id := (
                select locationuuid
                from public.location
                where locationcustomerid = customerid
                  and locationistop = true
                limit 1
            ),
            modified_by := auth.current_identity(customerid, current_setting('user.id'))
        ) as t
      where customeruuid = ${customerId}
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
            from public.create_name(
                customer_id := ${owner},
                modified_by := ${actor},
                source_language := ${input.description.value.locale ?? ctx.req.i18n.language},
                source_text := ${input.description.value.value}
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
        with field (f_name, f_type, f_order, f_desc, f_widget) as (
            values ${sql(fields)}
        )

        select t.*
        from field, legacy0.create_field_t(
            customer_id := ${owner},
            language_type := ${language},
            template_id := ${template},
            field_description := field.f_desc,
            field_is_draft := false,
            field_is_primary := false,
            field_is_required := false,
            field_name := field.f_name,
            field_order := field.f_order::integer,
            field_reference_type := null,
            field_type := field.f_type,
            field_value := null,
            field_widget := field.f_widget,
            modified_by := ${actor}
        ) as t;
      `;
      count += r.length;
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
