
-- Type: FUNCTION ; Name: enable_runtime(text,text,text,bigint,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.enable_runtime(customer_id text, site_uuid text, language_type text, modified_by bigint, timezone text)
 RETURNS TABLE(op text, id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
declare
  ins_locations text[];
  --
  ins_template text;
  --
  loop0_x text;
  --
  runtime_config_template_uuid text;
  --
  runtime_config_uuid text;
begin
/*
  perform set_config('user.id', workeridentityid, true)
  from public.workerinstance
  inner join public.worker on workerinstanceworkerid = workerid
  where workerinstanceid = modified_by;

  with
        inputs(location_name, location_typename) as (
            values
                ('My First Location'::text, 'Runtime Location'::text)
        )
    select array_agg(t.id) into ins_locations
    from
        inputs,
        public.create_location(
            customer_id := customer_id,
            language_type := language_type,
            timezone := timezone,
            location_name := inputs.location_name,
            location_parent_id := site_uuid,
            location_typename := inputs.location_typename,
            modified_by := modified_by
        ) as t
    ;
  --

  select t.id into ins_template
  from legacy0.create_task_t(
      customer_id := customer_id,
      language_type := language_type,
      task_name := 'Run',
      task_parent_id := site_uuid,
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

  -- The canonical on-demand in-progress "respawn" rule. This rule causes a new,
  -- Open task instance to be created when a task transitions to InProgress.
  return query
    select '  +irule', t.next
    from legacy0.create_instantiation_rule(
        prev_template_id := ins_template,
        next_template_id := ins_template,
        state_condition := 'In Progress',
        type_tag := 'On Demand',
        modified_by := modified_by
    ) as t;
  --
  if not found then
    raise exception 'failed to create canonical on-demand in-progress irule';
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
                   target_type := 'On Demand',
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

  -- Create the Idle Time template, which is a transition from public.
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
                task_parent_id := site_uuid,
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

  -- Create the Downtime template, which is a transition from public.
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
                task_parent_id := site_uuid,
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

  select uuid
  into runtime_config_template_uuid
  from public.crud_customer_config_templates_list(20)
  where category = 'Applications'
  and type = 'Runtime';

  -- get uuids
  call public.crud_customer_config_create(
      customer_uuid := customer_id,
      site_uuid := site_uuid,
      config_template_uuid := runtime_config_template_uuid,
      config_value := 'true'::text,
      modified_by := null,
      config_id := runtime_config_uuid
      );
*/
  return;
end
$function$;


REVOKE ALL ON FUNCTION enable_runtime(text,text,text,bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION enable_runtime(text,text,text,bigint,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION enable_runtime(text,text,text,bigint,text) TO tendreladmin WITH GRANT OPTION;
