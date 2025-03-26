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
        field_is_draft := true, -- always start in draft
        field_is_primary := field_is_primary,
        field_is_required := field_is_required,
        field_name := field_name,
        field_order := field_order,
        field_reference_type := field_reference_type,
        field_type := field_type,
        field_value := field_value,
        field_widget := field_widget
    );

    return query
      select
          'engine1.id'::regproc,
          jsonb_build_object(
              'ok', true,
              'count', 1,
              'created', jsonb_build_array(jsonb_build_object('node', field))
          )
    ;
  end if;

  if field is null then
    raise exception 'failed to find or create result';
  end if;

  return query
    select
        'engine1.publish_workresult'::regproc,
        jsonb_build_array(id)
    from public.workresult
    where id = field and workresultdraft is distinct from field_is_draft
  ;

  return;
end $$
language plpgsql;

COMMIT;
