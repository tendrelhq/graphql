BEGIN;

/*
DROP FUNCTION engine1.upsert_field_t(text,text,bigint,text,text,text,integer,text,text,boolean,boolean,boolean,text,text,text);
*/


-- Type: FUNCTION ; Name: engine1.upsert_field_t(text,text,bigint,text,text,text,integer,text,text,boolean,boolean,boolean,text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.upsert_field_t(customer_id text, language_type text, modified_by bigint, template_id text, field_id text, field_name text, field_order integer, field_type text, field_description text DEFAULT NULL::text, field_is_draft boolean DEFAULT false, field_is_primary boolean DEFAULT false, field_is_required boolean DEFAULT false, field_reference_type text DEFAULT NULL::text, field_value text DEFAULT NULL::text, field_widget text DEFAULT NULL::text)
 RETURNS SETOF engine1.closure
 LANGUAGE plpgsql
AS $function$
declare
  delta bigint := 0;
  field text;
begin
  select id into field
  from public.workresult
  where id = field_id;

  if not found then
    select id into field
    from legacy0.create_field_t(
        customer_id := customer_id,
        language_type := language_type,
        modified_by := modified_by,
        template_id := template_id,
        field_description := field_description,
        field_is_draft := field_is_draft,
        field_is_primary := field_is_primary,
        field_is_required := field_is_required,
        field_name := field_name,
        field_order := field_order,
        field_reference_type := field_reference_type,
        field_type := field_type,
        field_value := field_value,
        field_widget := field_widget
    );

    if field is null then
      raise exception 'failed to create result';
    end if;

    return query
      select
        'engine1.id'::regproc,
        jsonb_build_object(
          '_log', 'create: field',
          'field', field
        )
      union all
      select
        'engine1.instantiate_workresult'::regproc,
        jsonb_build_array(field)
      where field_is_draft is distinct from true
    ;

    return;
  end if;

  if field is null then
    raise exception 'failed to find result';
  end if;

  return query
    select
      'engine1.publish_workresult'::regproc,
      jsonb_build_array(workresult.id)
    from public.workresult
    where workresult.id = field
      and workresultdraft is distinct from field_is_draft
  ;

  return query
    with cte as (
      update public.workresult
      set workresultorder = field_order,
          workresultmodifieddate = now(),
          workresultmodifiedby = modified_by
      where workresult.id = field
        and workresultorder is distinct from field_order
      returning *
    )
    select
      'engine1.id'::regproc,
      jsonb_build_object(
        '_log', 'update: field.order',
        'field', id,
        'field.order', cte.workresultorder
      )
    from cte
  ;

  return query
    with cte as (
      update public.workresult
      set workresultisrequired = field_is_required,
          workresultmodifieddate = now(),
          workresultmodifiedby = modified_by
      where workresult.id = field
        and workresultisrequired is distinct from field_is_required
      returning *
    )
    select
      'engine1.id'::regproc,
      jsonb_build_object(
        '_log', 'update: field.required',
        'field', id,
        'field.required', cte.workresultisrequired
      )
    from cte
  ;

  if nullif(field_description, '') is null then
    return query
      with cte as (
        update public.workdescription
        set workdescriptionenddate = now(),
            workdescriptionmodifieddate = now(),
            workdescriptionmodifiedby = modified_by
        from public.workresult
        where workresult.id = field
          and workdescriptionworkresultid = workresultid
          and (
            workdescriptionenddate is null
            or workdescriptionenddate > now()
          )
        returning
          workresult.id as field,
          workdescription.id as description
      )
      select
        'engine1.id'::regproc,
        jsonb_build_object(
          '_log', 'deleted: field.description',
          'field', cte.field,
          'field.description', cte.description

        )
      from cte
    ;

    if not found then
      raise exception 'engine1.upsert_field_t: failed to delete field.description';
    end if;
  else
    return query
      with
        cur_desc as (
          select *
          from public.workdescription
          inner join public.languagemaster
            on workdescriptionlanguagemasterid = languagemasterid
          where
            workdescriptionworkresultid = (
                select workresultid
                from public.workresult
                where id = field
            )
            and (
              workdescriptionenddate is null
              or workdescriptionenddate > now()
            )
        ),
        upd_desc as (
          select t.*
          from
            cur_desc,
            i18n.update_localized_content(
                master_id := cur_desc.languagemasteruuid,
                content := field_description,
                language := language_type
            ) as t
        ),
        ins_desc as (
          select t.*
          from i18n.create_localized_content(
              owner := customer_id,
              content := field_description,
              language := language_type
          ) as t
          where not exists (select 1 from cur_desc)
        )
      select
        'engine1.id'::regproc,
        jsonb_build_object(
          '_log', 'updated: field.description',
          'field', field,
          'field.description', upd_desc.id
        )
      from upd_desc
      union all
      select
        'engine1.id'::regproc,
        jsonb_build_object(
          '_log', 'created: field.description',
          'field', field,
          'field.description', ins_desc.id
        )
      from ins_desc
    ;
  end if;

  return query
    with cte as (
      select
        workresult.id as field,
        t.*
      from
        public.workresult,
        public.languagemaster,
        i18n.update_localized_content(
          master_id := languagemasteruuid,
          content := field_name,
          language := language_type
        ) as t
      where workresult.id = field
        and workresultlanguagemasterid = languagemasterid
    )
    select
      'engine1.id'::regproc,
      jsonb_build_object(
        '_log', 'updated: field.name',
        'field', cte.field,
        'field.name', cte.id
      )
    from cte
  ;

  -- TODO: this should probably happen via closure.
  return query
    with cte as (
      update public.workresult
      set workresultdefaultvalue = field_value,
          workresultmodifieddate = now(),
          workresultmodifiedby = modified_by
      where workresult.id = field
        and workresultdefaultvalue is distinct from field_value
      returning *
    )
    select
      'engine1.id'::regproc,
      jsonb_build_object(
        '_log', 'updated: field.value',
        'field', cte.id,
        'field.value', cte.workresultdefaultvalue
      )
    from cte
  ;

  return;
end $function$;


REVOKE ALL ON FUNCTION engine1.upsert_field_t(text,text,bigint,text,text,text,integer,text,text,boolean,boolean,boolean,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.upsert_field_t(text,text,bigint,text,text,text,integer,text,text,boolean,boolean,boolean,text,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.upsert_field_t(text,text,bigint,text,text,text,integer,text,text,boolean,boolean,boolean,text,text,text) TO graphql;

END;
