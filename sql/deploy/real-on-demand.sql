-- Deploy graphql:real-on-demand to pg

BEGIN;

set local client_min_messages to 'warning';

DROP FUNCTION IF EXISTS legacy0.create_task_t(text,text,text,text,bigint,integer);

-- Type: FUNCTION ; Name: legacy0.create_task_t(text,text,text,text,bigint,integer,boolean); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_task_t(customer_id text, language_type text, task_name text, task_parent_id text, modified_by bigint, task_order integer DEFAULT 0, task_supports_lazy_instantiation boolean DEFAULT true)
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
      task_supports_lazy_instantiation,
      1404,
      true,
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

-- Type: FUNCTION ; Name: runtime.add_demo_to_customer(text,text,bigint,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION runtime.add_demo_to_customer(customer_id text, language_type text, modified_by bigint, timezone text)
 RETURNS TABLE(op text, id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
declare
  ins_site text;
  ins_locations text[];
  --
  ins_template text;
  --
  loop0_x text;
begin
  select t.id into ins_site
  from
      -- NOTE: we use the internal function here since the runtime version does
      -- not all creating top-level locations (i.e. no parent).
      legacy0.create_location(
          customer_id := customer_id,
          language_type := language_type,
          location_name := 'Frozen Tendy Factory',
          location_parent_id := null,
          location_timezone := timezone,
          location_typename := 'Frozen Tendy Factory',
          modified_by := modified_by
      ) as t
  ;
  --
  if not found then
    raise exception 'failed to create site';
  end if;
  --
  return query select '+site', ins_site;

  with
      inputs(location_name, location_typename) as (
          values
              ('Mixing Line'::text, 'Runtime Location'::text),
              ('Fill Line', 'Runtime Location'),
              ('Assembly Line', 'Runtime Location'),
              ('Cartoning Line', 'Runtime Location'),
              ('Packaging Line', 'Runtime Location')
      )
  select array_agg(t.id) into ins_locations
  from
      inputs,
      runtime.create_location(
          customer_id := customer_id,
          language_type := language_type,
          timezone := timezone,
          location_name := inputs.location_name,
          location_parent_id := ins_site,
          location_typename := inputs.location_typename,
          modified_by := modified_by
      ) as t
  ;
  --
  if not found then
    raise exception 'failed to create locations';
  end if;
  --
  return query select ' +location', t.id from unnest(ins_locations) as t (id);

  select t.id into ins_template
  from legacy0.create_task_t(
      customer_id := customer_id,
      language_type := language_type,
      task_name := 'Run',
      task_parent_id := ins_site,
      modified_by := modified_by
  ) as t;
  --
  if not found then
    raise exception 'failed to create template';
  end if;
  --
  return query select ' +task', ins_template;

  return query
    select '  +type', t.id
    from
        public.systag as s,
        legacy0.create_template_type(
            template_id := ins_template,
            systag_id := s.systaguuid,
            modified_by := modified_by
        ) as t
    where s.systagparentid = 882 and s.systagtype in ('Trackable', 'Runtime')
  ;
  --
  if not found then
    raise exception 'failed to create template type';
  end if;

  return query
    with field (f_name, f_type, f_is_primary, f_order) as (
        values
            ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
            ('Override End Time', 'Date', true, 1),
            ('Run Output', 'Number', false, 2),
            ('Reject Count', 'Number', false, 3),
            ('Comments', 'String', false, 99)
    )
    select '  +field', t.id
    from
        field,
        legacy0.create_field_t(
            customer_id := customer_id,
            language_type := language_type,
            template_id := ins_template,
            field_description := null,
            field_is_draft := false,
            field_is_primary := field.f_is_primary,
            field_is_required := false,
            field_name := field.f_name,
            field_order := field.f_order,
            field_reference_type := null,
            field_type := field.f_type,
            field_value := null,
            field_widget := null,
            modified_by := modified_by
        ) as t
  ;
  --
  if not found then
    raise exception 'failed to create template fields';
  end if;

  -- Create the constraint for the root template at each child location.
  <<loop0>>
  foreach loop0_x in array ins_locations loop
    return query
      with
          ins_constraint as (
              select *
              from legacy0.create_template_constraint_on_location(
                  template_id := ins_template,
                  location_id := loop0_x,
                  modified_by := modified_by
              ) as t
          ),

          ins_instance as (
              select *
              from engine0.instantiate(
                  template_id := ins_template,
                  location_id := loop0_x,
                  target_state := 'Open',
                  target_type := 'Task',
                  modified_by := modified_by
              )
          )

      select '  +constraint', t.id
      from ins_constraint as t
      union all
      (
        select '   +instance', t.instance
        from ins_instance as t
        group by t.instance
      )
    ;
  end loop loop0;
  --
  if not found then
    raise exception 'failed to create location constraint/initial instance';
  end if;

  -- Create the Idle Time template, which is a transition from Runtime.
  return query
    with
        field (f_name, f_type, f_is_primary, f_order) as (
            values
                ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
                ('Override End Time', 'Date', true, 1),
                ('Description', 'String', false, 2)
        ),

        ins_next as (
            select t.*
            from legacy0.create_task_t(
                customer_id := customer_id,
                language_type := language_type,
                task_name := 'Idle Time',
                task_parent_id := ins_site,
                task_order := 1,
                modified_by := modified_by
            ) as t
        ),

        ins_type as (
            select t.*
            from ins_next, public.systag as s
            cross join lateral legacy0.create_template_type(
                template_id := ins_next.id,
                systag_id := s.systaguuid,
                modified_by := modified_by
            ) as t
            where s.systagtype = 'Idle Time'
        ),

        ins_field as (
            select t.*
            from field, ins_next
            cross join
                lateral legacy0.create_field_t(
                    customer_id := customer_id,
                    language_type := language_type,
                    template_id := ins_next.id,
                    field_description := null,
                    field_is_draft := false,
                    field_is_primary := field.f_is_primary,
                    field_is_required := false,
                    field_name := field.f_name,
                    field_order := field.f_order,
                    field_reference_type := null,
                    field_type := field.f_type,
                    field_value := null,
                    field_widget := null,
                    modified_by := modified_by
                ) as t
        ),

        ins_nt_rule as (
            select t.*
            from ins_next
            cross join
                lateral legacy0.create_instantiation_rule(
                    prev_template_id := ins_template,
                    next_template_id := ins_next.id,
                    state_condition := 'In Progress',
                    type_tag := 'On Demand',
                    modified_by := modified_by
                ) as t
        ),

        ins_constraint as (
            select t.*
            from
                unnest(ins_locations) as ins_location(id),
                ins_next,
                legacy0.create_template_constraint_on_location(
                    template_id := ins_next.id,
                    location_id := ins_location.id,
                    modified_by := modified_by
                ) as t
        )

        select '  +next', ins_nt_rule.next
        from ins_nt_rule
        union all
        select '   +type', ins_type.id
        from ins_type
        union all
        select '   +field', ins_field.id
        from ins_field
        union all
        select '   +constraint', ins_constraint.id
        from ins_constraint
  ;
  --
  if not found then
    raise exception 'failed to create next template (Idle Time)';
  end if;

  -- Create the Downtime template, which is a transition from Runtime.
  return query
    with
        field (f_name, f_type, f_is_primary, f_order) as (
            values
                ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
                ('Override End Time', 'Date', true, 1),
                ('Description', 'String', false, 2)
        ),

        ins_next as (
            select t.*
            from legacy0.create_task_t(
                customer_id := customer_id,
                language_type := language_type,
                task_name := 'Downtime',
                task_parent_id := ins_site,
                task_order := 0,
                modified_by := modified_by
            ) as t
        ),

        ins_type as (
            select t.*
            from ins_next, public.systag as s
            cross join lateral legacy0.create_template_type(
                template_id := ins_next.id,
                systag_id := s.systaguuid,
                modified_by := modified_by
            ) as t
            where s.systagtype = 'Downtime'
        ),

        ins_field as (
            select t.*
            from field, ins_next
            cross join
                lateral legacy0.create_field_t(
                    customer_id := customer_id,
                    language_type := language_type,
                    template_id := ins_next.id,
                    field_description := null,
                    field_is_draft := false,
                    field_is_primary := field.f_is_primary,
                    field_is_required := false,
                    field_name := field.f_name,
                    field_order := field.f_order,
                    field_reference_type := null,
                    field_type := field.f_type,
                    field_value := null,
                    field_widget := null,
                    modified_by := modified_by
                ) as t
        ),

        ins_nt_rule as (
            select t.*
            from ins_next
            cross join
                lateral legacy0.create_instantiation_rule(
                    prev_template_id := ins_template,
                    next_template_id := ins_next.id,
                    state_condition := 'In Progress',
                    type_tag := 'On Demand',
                    modified_by := modified_by
                ) as t
        ),

        ins_constraint as (
            select t.*
            from
                unnest(ins_locations) as ins_location(id),
                ins_next,
                legacy0.create_template_constraint_on_location(
                    template_id := ins_next.id,
                    location_id := ins_location.id,
                    modified_by := modified_by
                ) as t
        )

        select '  +next', ins_nt_rule.next
        from ins_nt_rule
        union all
        select '   +type', ins_type.id
        from ins_type
        union all
        select '   +field', ins_field.id
        from ins_field
        union all
        select '   +constraint', ins_constraint.id
        from ins_constraint
  ;
  --
  if not found then
    raise exception 'failed to create next template (Downtime)';
  end if;

  return;
end $function$;

COMMIT;
