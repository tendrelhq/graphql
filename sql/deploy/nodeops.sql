-- Deploy graphql:nodeops to pg

BEGIN;

create or replace function
    engine1.upsert_field_t(
        customer_id text,
        language_type text,
        modified_by bigint,
        template_id text,
        field_id text,
        field_name text,
        field_order integer,
        field_type text,
        field_description text = null,
        field_is_draft boolean = false,
        field_is_primary boolean = false,
        field_is_required boolean = false,
        field_reference_type text = null,
        field_value text = null,
        field_widget text = null
    )
returns setof engine1.closure
as $$
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
          'ok', true,
          'count', 1,
          'created', jsonb_build_array(jsonb_build_object('node', field))
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
      returning workresult.id
    )
    select
      'engine1.id'::regproc,
      jsonb_build_object(
        'ok', true,
        'count', 1,
        'updated', jsonb_build_array(jsonb_build_object('node', id))
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
      returning workresult.id
    )
    select
      'engine1.id'::regproc,
      jsonb_build_object(
        'ok', true,
        'count', 1,
        'updated', jsonb_build_array(jsonb_build_object('node', id))
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
        returning workdescription.id
      )
      select
        'engine1.id'::regproc,
        jsonb_build_object(
          'ok', true,
          'count', count(*),
          'updated', jsonb_agg(jsonb_build_object('node', cte.id))

        )
      from cte
      having count(*) > 0
    ;
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
          )
          where not exists (select 1 from cur_desc)
        )
      select
        'engine1.id'::regproc,
        jsonb_build_object(
          'ok', true,
          'count', count(*),
          'updated', jsonb_agg(jsonb_build_object('node', upd_desc.id))
        )
      from upd_desc
      having count(*) > 0
      union all
      select
        'engine1.id'::regproc,
        jsonb_build_object(
          'ok', true,
          'count', count(*),
          'created', jsonb_agg(jsonb_build_object('node', ins_desc.id))
        )
      from ins_desc
      having count(*) > 0
    ;
  end if;

  return query
    with cte as (
      select t.*
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
        'ok', true,
        'count', count(*),
        'updated', jsonb_agg(jsonb_build_object('node', cte.id))
      )
    from cte
    having count(*) > 0
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
      returning workresult.id
    )
    select
      'engine1.id'::regproc,
      jsonb_build_object(
        'ok', true,
        'count', 1,
        'updated', jsonb_build_array(jsonb_build_object('node', id))
      )
    from cte
  ;

  return;
end $$
language plpgsql;

COMMIT;
