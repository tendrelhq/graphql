
-- Type: FUNCTION ; Name: legacy0.create_task_t(text,text,text,text,bigint,integer); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_task_t(customer_id text, language_type text, task_name text, task_parent_id text, modified_by bigint, task_order integer DEFAULT 0)
 RETURNS TABLE(_id bigint, id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
declare
  ins_template text;
begin
  with ins_name as (
    select *
    from i18n.create_localized_content(
        owner := customer_id,
        content := task_name,
        language := language_type
    )
  )
  insert into public.worktemplate (
      worktemplatecustomerid,
      worktemplatesiteid,
      worktemplatenameid,
      worktemplateallowondemand,
      worktemplateworkfrequencyid,
      worktemplateisauditable,
      worktemplateorder,
      worktemplatemodifiedby
  )
  select
      customer.customerid,
      location.locationid,
      ins_name._id,
      true,
      1404,
      -- FIXME: implement audits
      false,
      task_order,
      modified_by
  from public.customer, public.location, ins_name
  where customer.customeruuid = customer_id and location.locationuuid = task_parent_id
  returning worktemplate.id into ins_template
  ;
  --
  if not found then
    raise exception 'failed to create template';
  end if;

  perform *
  from
      (
          values ('Location'::text, 'Entity'::text, 'Location'::text),
                 ('Worker', 'Entity', 'Worker'),
                 ('Time At Task', 'Time At Task', null)
      ) as field (f_name, f_type, f_ref_type),
      legacy0.create_field_t(
          customer_id := customer_id,
          language_type := language_type,
          template_id := ins_template,
          field_description := null,
          field_is_draft := false,
          field_is_primary := true,
          field_is_required := false,
          field_name := field.f_name,
          field_order := 0,
          field_reference_type := field.f_ref_type,
          field_type := field.f_type,
          field_value := null,
          field_widget := null,
          modified_by := modified_by
      )
  ;
  --
  if not found then
    raise exception 'failed to create primary fields [location, worker, time at task]';
  end if;

  return query
    select worktemplateid as _id, worktemplate.id
    from public.worktemplate
    where worktemplate.id = ins_template
  ;

  return;
end $function$;


REVOKE ALL ON FUNCTION legacy0.create_task_t(text,text,text,text,bigint,integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_task_t(text,text,text,text,bigint,integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_task_t(text,text,text,text,bigint,integer) TO tendreladmin WITH GRANT OPTION;
