BEGIN;

/*
DROP FUNCTION legacy0.primary_location_for_instance(text);
DROP FUNCTION legacy0.ensure_field_t(text,text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint);
DROP FUNCTION legacy0.create_worker(text,text,text,bigint);
DROP FUNCTION legacy0.create_template_type(text,text,bigint);
DROP FUNCTION legacy0.create_template_constraint_on_location(text,text,bigint);
DROP FUNCTION legacy0.create_task_t(text,text,text,text,bigint,integer,boolean);
DROP FUNCTION legacy0.create_rrule(text,text,numeric,bigint);
DROP FUNCTION legacy0.create_location(text,text,text,text,text,text,bigint);
DROP FUNCTION legacy0.create_instantiation_rule_v2(text,text,text,text,text,text,bigint);
DROP FUNCTION legacy0.create_instantiation_rule(text,text,text,text,bigint);
DROP FUNCTION legacy0.create_field_t(text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint);
DROP FUNCTION legacy0.compute_time_at_task(bigint);

DROP SCHEMA legacy0;
*/

CREATE SCHEMA legacy0;

GRANT USAGE ON SCHEMA legacy0 TO graphql;

-- DEPENDANTS


-- Type: FUNCTION ; Name: legacy0.compute_time_at_task(bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.compute_time_at_task(workinstanceid bigint)
 RETURNS interval
 LANGUAGE sql
 STABLE
AS $function$
  with
      ov_start as (
          select nullif(workresultinstancevalue, '') as value
          from public.workresultinstance
          inner join public.workresult
              on workresultinstanceworkresultid = workresultid
              and workresulttypeid = 868
              and workresultorder = 0
              and workresultisprimary = true
          where workresultinstanceworkinstanceid = $1
          limit 1
      ),

      ov_end as (
          select nullif(workresultinstancevalue, '') as value
          from public.workresultinstance
          inner join public.workresult
              on workresultinstanceworkresultid = workresultid
              and workresulttypeid = 868
              and workresultorder = 1
              and workresultisprimary = true
          where workresultinstanceworkinstanceid = $1
          limit 1
      )

  select
      coalesce(to_timestamp(ov_end.value::bigint / 1000.0), workinstance.workinstancecompleteddate)
      - coalesce(to_timestamp(ov_start.value::bigint / 1000.0), workinstance.workinstancestartdate)
  from public.workinstance
  left join ov_start on true
  left join ov_end on true
  where workinstance.workinstanceid = $1;
$function$;


REVOKE ALL ON FUNCTION legacy0.compute_time_at_task(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.compute_time_at_task(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.compute_time_at_task(bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.compute_time_at_task(bigint) TO graphql;

-- Type: FUNCTION ; Name: legacy0.create_field_t(text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_field_t(customer_id text, language_type text, template_id text, field_description text, field_is_draft boolean, field_is_primary boolean, field_is_required boolean, field_name text, field_order integer, field_reference_type text, field_type text, field_value text, field_widget text, modified_by bigint)
 RETURNS TABLE(id text)
 LANGUAGE plpgsql
AS $function$
declare
  ins_field text;
begin
  with
    ins_name as (
      select *
      from i18n.create_localized_content(
          owner := customer_id,
          content := field_name,
          language := language_type
      )
    ),

    ins_type as (
      select t.systagid as _type, r.systagid as _ref_type
      from public.systag as t
      left join public.systag as r
          on r.systagparentid = 849
          and r.systagtype = field_reference_type
      where
          t.systagparentid = 699
          and t.systagtype = field_type
    ),

    ins_widget as (
      select custagid as _id
      from public.custag
      where custagcustomerid = 0
        and custagsystagid = (
            select systagid
            from public.systag
            where systagparentid = 1 and systagtype = 'Widget Type'
        )
        and custagtype = field_widget
    )

  insert into public.workresult (
      workresultcustomerid,
      workresultdefaultvalue,
      workresultdraft,
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
      workresultworktemplateid,
      workresultmodifiedby
  )
  select
      wt.worktemplatecustomerid,
      nullif(field_value, ''),
      field_is_draft,
      ins_type._ref_type,
      false,
      true,
      field_is_primary,
      field_is_required,
      ins_name._id,
      field_order,
      wt.worktemplatesiteid,
      null,
      ins_type._type,
      ins_widget._id,
      wt.worktemplateid,
      modified_by
  from
      public.worktemplate as wt,
      ins_name,
      ins_type
  left join ins_widget on true
  where wt.id = template_id
  returning workresult.id into ins_field;

  if not found then
    raise exception 'failed creating template field';
  end if;

  id := ins_field;
  return next;

  if nullif(field_description, '') is not null then
    insert into public.workdescription (
        workdescriptioncustomerid,
        workdescriptionworktemplateid,
        workdescriptionworkresultid,
        workdescriptionlanguagemasterid,
        workdescriptionlanguagetypeid,
        workdescriptionmodifiedby
    )
    select
        workresultcustomerid,
        workresultworktemplateid,
        workresultid,
        content._id,
        content._type,
        modified_by
    from
        public.workresult,
        i18n.create_localized_content(
            owner := customer_id,
            content := field_description,
            language := language_type
        ) as content
    where workresult.id = ins_field;
  end if;

  return;
end $function$;


REVOKE ALL ON FUNCTION legacy0.create_field_t(text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_field_t(text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_field_t(text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.create_field_t(text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) TO graphql;

-- Type: FUNCTION ; Name: legacy0.create_instantiation_rule(text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_instantiation_rule(prev_template_id text, next_template_id text, state_condition text, type_tag text, modified_by bigint)
 RETURNS TABLE(prev text, next text)
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    with cte as (
        insert into public.worktemplatenexttemplate(
            worktemplatenexttemplatecustomerid,
            worktemplatenexttemplatesiteid,
            worktemplatenexttemplateprevioustemplateid,
            worktemplatenexttemplatenexttemplateid,
            worktemplatenexttemplateviastatuschange,
            worktemplatenexttemplateviastatuschangeid,
            worktemplatenexttemplatetypeid,
            worktemplatenexttemplatemodifiedby
        )
        select
            prev.worktemplatecustomerid,
            prev.worktemplatesiteid,
            prev.worktemplateid,
            next.worktemplateid,
            true,
            s.systagid,
            tt.systagid,
            modified_by
        from public.worktemplate as prev
        inner join public.worktemplate as next on next.id = next_template_id
        inner join public.systag as s
            on s.systagparentid = 705 and s.systagtype = state_condition
        inner join public.systag as tt
            on tt.systagparentid = 691 and tt.systagtype = type_tag
        where prev.id = prev_template_id
        returning
            worktemplatenexttemplateprevioustemplateid as _prev,
            worktemplatenexttemplatenexttemplateid as _next
    )

    select prev.id as prev, next.id as next
    from cte
    inner join public.worktemplate as prev on cte._prev = prev.worktemplateid
    inner join public.worktemplate as next on cte._next = next.worktemplateid
  ;

  if not found then
    raise exception 'failed to create instantiation rule';
  end if;

  return;
end $function$;


REVOKE ALL ON FUNCTION legacy0.create_instantiation_rule(text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_instantiation_rule(text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_instantiation_rule(text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.create_instantiation_rule(text,text,text,text,bigint) TO graphql;

-- Type: FUNCTION ; Name: legacy0.create_instantiation_rule_v2(text,text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_instantiation_rule_v2(prev_template_id text, next_template_id text, state_condition text, type_tag text, prev_location_id text, next_location_id text, modified_by bigint)
 RETURNS TABLE(prev text, next text)
 LANGUAGE plpgsql
AS $function$
begin
  return query
    with cte as (
        insert into public.worktemplatenexttemplate(
            worktemplatenexttemplatecustomerid,
            worktemplatenexttemplatesiteid,
            worktemplatenexttemplateprevioustemplateid,
            worktemplatenexttemplatenexttemplateid,
            worktemplatenexttemplateviastatuschange,
            worktemplatenexttemplateviastatuschangeid,
            worktemplatenexttemplatetypeid,
            worktemplatenexttemplatemodifiedby,
            worktemplatenexttemplateprevlocationid,
            worktemplatenexttemplatenextlocationid
        )
        select
            prev.worktemplatecustomerid,
            prev.worktemplatesiteid,
            prev.worktemplateid,
            next.worktemplateid,
            true,
            s.systagid,
            tt.systagid,
            modified_by,
            pl.locationuuid,
            nl.locationuuid
        from public.worktemplate as prev
        inner join public.worktemplate as next on next.id = next_template_id
        inner join public.systag as s
            on s.systagparentid = 705 and s.systagtype = state_condition
        inner join public.systag as tt
            on tt.systagparentid = 691 and tt.systagtype = type_tag
        left join public.location as pl on pl.locationuuid = prev_location_id
        left join public.location as nl on nl.locationuuid = next_location_id
        where prev.id = prev_template_id
        returning
            worktemplatenexttemplateprevioustemplateid as _prev,
            worktemplatenexttemplatenexttemplateid as _next
    )

    select prev.id as prev, next.id as next
    from cte
    inner join public.worktemplate as prev on cte._prev = prev.worktemplateid
    inner join public.worktemplate as next on cte._next = next.worktemplateid
  ;

  if not found then
    raise exception 'failed to create instantiation rule';
  end if;

  return;
end $function$;


REVOKE ALL ON FUNCTION legacy0.create_instantiation_rule_v2(text,text,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_instantiation_rule_v2(text,text,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_instantiation_rule_v2(text,text,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.create_instantiation_rule_v2(text,text,text,text,text,text,bigint) TO graphql;

-- Type: FUNCTION ; Name: legacy0.create_location(text,text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_location(customer_id text, language_type text, location_name text, location_parent_id text, location_timezone text, location_typename text, modified_by bigint)
 RETURNS TABLE(_id bigint, id text)
 LANGUAGE plpgsql
AS $function$
declare
  ins_location text;
begin
  perform 1
  from public.location
  where locationuuid = location_parent_id;
  --
  if location_parent_id is not null and not found then
    raise exception 'given parent % does not exist', location_parent_id;
  end if;

  with ins_name as (
    select *
    from i18n.create_localized_content(
        owner := customer_id,
        content := location_name,
        language := language_type
    )
  ),

  location_type as (
    select *
    from ast.create_user_type(
        customer_id := customer_id,
        language_type := language_type,
        type_name := location_typename,
        type_hierarchy := 'Location Category',
        modified_by := modified_by
    )
  )

  insert into public.location (
      locationcategoryid,
      locationcornerstoneorder,
      locationcustomerid,
      locationistop,
      locationiscornerstone,
      locationlookupname,
      locationmodifiedby,
      locationnameid,
      locationparentid,
      locationsiteid,
      locationtimezone
  )
  select
      location_type._id,
      0, -- cornerstone order
      c.customerid,
      location_parent_id is null,
      false,
      location_name, -- lookup name
      modified_by,
      ins_name._id,
      p.locationid,
      p.locationsiteid,
      location_timezone
  from
      public.customer as c,
      ins_name,
      location_type
  left join public.location as p
      on p.locationuuid = location_parent_id
  where c.customeruuid = customer_id
  returning locationuuid into ins_location
  ;
  --
  if not found then
    raise exception 'failed to create location';
  end if;

  return query select locationid as _id, locationuuid as id
               from public.location
               where locationuuid = ins_location
  ;

  -- invariant: locationsiteid must not be null
  update public.location
  set locationsiteid = locationid
  where locationuuid = ins_location and locationsiteid is null
  ;

  -- invariant: locationparentid must not be null
  update public.location
  set locationparentid = locationid
  where locationuuid = ins_location and locationparentid is null
  ;

  -- invariant: locationcornerstoneid must not be null
  update public.location
  set locationcornerstoneid = locationid
  where locationuuid = ins_location and locationcornerstoneid is null
  ;

  return;
end $function$;


REVOKE ALL ON FUNCTION legacy0.create_location(text,text,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_location(text,text,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_location(text,text,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.create_location(text,text,text,text,text,text,bigint) TO graphql;

-- Type: FUNCTION ; Name: legacy0.create_rrule(text,text,numeric,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_rrule(task_id text, frequency_type text, frequency_interval numeric, modified_by bigint)
 RETURNS TABLE(_id bigint)
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    with
        task as (
            select *
            from public.worktemplate
            where id = task_id
        ),

        type as (
            select *
            from public.systag
            where systagparentid = 738 and systagtype = frequency_type
        ),

        ins_freq as (
            insert into public.workfrequency (
                workfrequencycustomerid,
                workfrequencyworktemplateid,
                workfrequencytypeid,
                workfrequencyvalue,
                workfrequencymodifiedby
            )
            select
                task.worktemplatecustomerid,
                task.worktemplateid,
                type.systagid,
                frequency_interval,
                modified_by
            from task, type
            where not exists (
                select 1
                from public.workfrequency as wf
                inner join task on wf.workfrequencyworktemplateid = task.worktemplateid
                inner join type on wf.workfrequencytypeid = type.systagid
                where wf.workfrequencyvalue = frequency_interval
            )
            returning workfrequencyid
        )

    select workfrequencyid as _id
    from ins_freq
    union all
    select wf.workfrequencyid as _id
    from task, type, public.workfrequency as wf
    where
        wf.workfrequencyworktemplateid = task.worktemplateid
        and wf.workfrequencytypeid = type.systagid
        and wf.workfrequencyvalue = frequency_interval
  ;
  --
  if not found then
    raise exception 'failed to create recurrence rule';
  end if;

  return;
end $function$;


REVOKE ALL ON FUNCTION legacy0.create_rrule(text,text,numeric,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_rrule(text,text,numeric,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_rrule(text,text,numeric,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.create_rrule(text,text,numeric,bigint) TO graphql;

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
      false, -- The engine supports this but it is useless without frontend support, so disabling for now -rugg
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
end 
$function$;


REVOKE ALL ON FUNCTION legacy0.create_task_t(text,text,text,text,bigint,integer,boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_task_t(text,text,text,text,bigint,integer,boolean) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_task_t(text,text,text,text,bigint,integer,boolean) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.create_task_t(text,text,text,text,bigint,integer,boolean) TO graphql;

-- Type: FUNCTION ; Name: legacy0.create_template_constraint_on_location(text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_template_constraint_on_location(template_id text, location_id text, modified_by bigint)
 RETURNS TABLE(id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    with ins as (
        insert into public.worktemplateconstraint (
            worktemplateconstraintcustomerid,
            worktemplateconstraintcustomeruuid,
            worktemplateconstrainttemplateid,
            worktemplateconstraintconstrainedtypeid,
            worktemplateconstraintconstraintid,
            worktemplateconstraintmodifiedby
        )
        select
            c.customerid,
            c.customeruuid,
            t.id,
            s.systaguuid,
            lt.custaguuid,
            modified_by
        from public.worktemplate as t
        inner join public.customer as c
            on t.worktemplatecustomerid = c.customerid
        inner join public.systag as s
            on s.systagparentid = 849 and s.systagtype = 'Location'
        inner join public.location as l
            on t.worktemplatesiteid = l.locationsiteid
            and l.locationuuid = location_id
        inner join public.custag as lt
            on l.locationcategoryid = lt.custagid
        where t.id = template_id
        on conflict do nothing
        returning worktemplateconstraintid as id
    )

    select * from ins
    union all
    select wtc.worktemplateconstraintid as id
    from public.worktemplateconstraint as wtc
    inner join public.worktemplate as t
        on t.id = template_id
        and wtc.worktemplateconstrainttemplateid = t.id
    inner join public.location as l
        on t.worktemplatesiteid = l.locationsiteid
        and l.locationuuid = location_id
    where
        wtc.worktemplateconstraintconstrainedtypeid = (
            select systaguuid
            from public.systag
            where systagparentid = 849 and systagtype = 'Location'
        )
        and wtc.worktemplateconstraintconstraintid = (
            select custaguuid
            from public.custag
            where custagid = l.locationcategoryid
        )
    limit 1
  ;

  if not found then
    raise exception 'failed to create template constraint on location';
  end if;

  return;
end $function$;

COMMENT ON FUNCTION legacy0.create_template_constraint_on_location(text,text,bigint) IS '

# legacy0.create_template_constraint_on_location

Create a template constraint that indicates that the given template can be
instantiated at the given location.

';

REVOKE ALL ON FUNCTION legacy0.create_template_constraint_on_location(text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_template_constraint_on_location(text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_template_constraint_on_location(text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.create_template_constraint_on_location(text,text,bigint) TO graphql;

-- Type: FUNCTION ; Name: legacy0.create_template_type(text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_template_type(template_id text, systag_id text, modified_by bigint)
 RETURNS TABLE(id text)
 LANGUAGE sql
 STRICT
AS $function$
  insert into public.worktemplatetype (
      worktemplatetypecustomerid,
      worktemplatetypeworktemplateuuid,
      worktemplatetypeworktemplateid,
      worktemplatetypesystaguuid,
      worktemplatetypesystagid,
      worktemplatetypemodifiedby
  )
  select
      t.worktemplatecustomerid,
      t.id,
      t.worktemplateid,
      tt.systaguuid,
      tt.systagid,
      modified_by
  from public.worktemplate as t, public.systag as tt
  where t.id = template_id and tt.systaguuid = systag_id
  returning worktemplatetypeuuid as id
$function$;


REVOKE ALL ON FUNCTION legacy0.create_template_type(text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_template_type(text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_template_type(text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.create_template_type(text,text,bigint) TO graphql;

-- Type: FUNCTION ; Name: legacy0.create_worker(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_worker(customer_id text, user_id text, user_role text, modified_by bigint)
 RETURNS TABLE(_id bigint, id text)
 LANGUAGE sql
 STRICT
AS $function$
  insert into public.workerinstance (
      workerinstancecustomerid,
      workerinstancecustomeruuid,
      workerinstanceworkerid,
      workerinstanceworkeruuid,
      workerinstancelanguageid,
      workerinstancelanguageuuid,
      workerinstanceuserroleid,
      workerinstanceuserroleuuid,
      workerinstancemodifiedby
  )
  select
      c.customerid,
      c.customeruuid,
      u.workerid,
      u.workeruuid,
      l.systagid,
      l.systaguuid,
      r.systagid,
      r.systaguuid,
      modified_by
  from public.customer as c
  inner join public.worker as u
      on u.workeruuid = user_id
  inner join public.systag as l
      on u.workerlanguageid = l.systagid
  inner join public.systag as r
      on r.systagparentid = 772 and r.systagtype = user_role
  where c.customeruuid = customer_id
  returning workerinstanceid as _id, workerinstanceuuid as id;
$function$;


REVOKE ALL ON FUNCTION legacy0.create_worker(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_worker(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_worker(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.create_worker(text,text,text,bigint) TO graphql;

-- Type: FUNCTION ; Name: legacy0.ensure_field_t(text,text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.ensure_field_t(customer_id text, language_type text, template_id text, field_description text, field_id text, field_is_draft boolean, field_is_primary boolean, field_is_required boolean, field_name text, field_order integer, field_reference_type text, field_type text, field_value text, field_widget text, modified_by bigint)
 RETURNS TABLE(id text)
 LANGUAGE plpgsql
AS $function$
begin
  if not exists (select 1 from public.workresult where workresult.id = field_id) then
    -- Create.
    return query
      select *
      from legacy0.create_field_t(
          customer_id := customer_id,
          language_type := language_type,
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
          field_widget := field_widget,
          modified_by := modified_by
      )
    ;

    return;
  end if;

  -- Update.
  -- First we do the simple bits.
  update public.workresult
  set workresultdefaultvalue = nullif(field_value, ''),
      workresultisrequired = field_is_required,
      workresultorder = field_order,
      workresultmodifieddate = now(),
      workresultmodifiedby = modified_by
  where workresult.id = field_id;

  -- Second we do relational updates, e.g. description.
  if nullif(field_description, '') is not null then
    with
      existing_desc as (
          select d.*
          from public.workdescription as d
          inner join public.workresult
              on d.workdescriptionworkresultid = workresultid
          where
              workresult.id = field_id
              and (
                  d.workdescriptionenddate is null
                  or d.workdescriptionenddate > now()
              )
          order by d.workdescriptionid desc
          limit 1
      ),

      ins_content as (
          select *
          from i18n.create_localized_content(
              owner := customer_id,
              content := field_description,
              language := language_type
          )
          where not exists (select 1 from existing_desc)
      ),

      ins_desc as (
          insert into public.workdescription (
              workdescriptioncustomerid,
              workdescriptionworktemplateid,
              workdescriptionworkresultid,
              workdescriptionlanguagemasterid,
              workdescriptionlanguagetypeid,
              workdescriptionmodifiedby
          )
          select
              workresultcustomerid,
              workresultworktemplateid,
              workresultid,
              ins_content._id,
              ins_content._type,
              modified_by
          from public.workresult
          where workresult.id = field_id
      ),

      upd_master as (
          update public.languagemaster
          set languagemastersource = field_description,
              languagemastersourcelanguagetypeid = systagid,
              languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
              languagemastermodifieddate = now(),
              languagemastermodifiedby = modified_by
          from existing_desc, public.systag
          where languagemasterid = workdescriptionlanguagemasterid
            and systagparentid = 2
              and systagtype = language_type
            and (languagemastersource, languagemastersourcelanguagetypeid)
                is distinct from (field_description, systagid)
      )

    update public.languagetranslations
    set languagetranslationvalue = field_description,
        languagetranslationmodifieddate = now(),
        languagetranslationmodifiedby = modified_by
    from existing_desc
    where languagetranslationmasterid = workdescriptionlanguagemasterid
      and languagetranslationtypeid = (
          select systagid
          from public.systag
          where systagparentid = 2 and systagtype = language_type
      )
      and languagetranslationvalue is distinct from field_description
    ;

  else
    update public.workdescription
    set workdescriptionenddate = now(),
        workdescriptionmodifieddate = now(),
        workdescriptionmodifiedby = modified_by
    from public.workresult
    where workresult.id = field_id
      and workdescriptionworktemplateid = workresultworktemplateid
      and workdescriptionworkresultid = workresultid
    ;
  end if;

  -- Update the name's master, if applicable.
  update public.languagemaster
  set languagemastersource = field_name,
      languagemastersourcelanguagetypeid = (
          select systagid
          from public.systag
          where systagparentid = 2 and systagtype = language_type
      ),
      languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
      languagemastermodifieddate = now(),
      languagemastermodifiedby = modified_by
  from public.workresult, public.systag
  where workresult.id = field_id
    and (languagemasterid, languagemastersourcelanguagetypeid)
        = (workresultlanguagemasterid, systagid)
    and (languagemastersource, systagtype)
        is distinct from (field_name, language_type)
  ;

  -- Update the name's transations, if applicable.
  update public.languagetranslations
  set languagetranslationvalue = field_name,
      languagetranslationmodifieddate = now(),
      languagetranslationmodifiedby = modified_by
  from public.workresult, public.systag 
  where workresult.id = field_id
    and workresultlanguagemasterid = languagetranslationmasterid
    and (languagetranslationtypeid, language_type) = (systagid, systagtype)
    and (languagetranslationvalue, systagtype)
        is distinct from (field_name, language_type)
  ;

  id := field_id;
  return next;

  return;
end $function$;


REVOKE ALL ON FUNCTION legacy0.ensure_field_t(text,text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.ensure_field_t(text,text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.ensure_field_t(text,text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.ensure_field_t(text,text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) TO graphql;

-- Type: FUNCTION ; Name: legacy0.primary_location_for_instance(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.primary_location_for_instance(instance_id text)
 RETURNS TABLE(id text, _id bigint)
 LANGUAGE sql
 STABLE STRICT
AS $function$
  with cte as materialized (
      select workresultinstancevalue::bigint as value
      from public.workinstance
      inner join public.workresult
          on  workinstanceworktemplateid = workresultworktemplateid
          and workresulttypeid = (
              select systagid
              from public.systag
              where systagparentid = 699 and systagtype = 'Entity'
          )
          and workresultentitytypeid = (
              select systagid
              from public.systag
              where systagparentid = 849 and systagtype = 'Location'
          )
          and workresultisprimary = true
      inner join public.workresultinstance
          on  workinstanceid = workresultinstanceworkinstanceid
          and workresultid = workresultinstanceworkresultid
      where workinstance.id = instance_id
  )

  select locationuuid as id, locationid as _id
  from cte, public.location
  where cte.value = locationid
$function$;


REVOKE ALL ON FUNCTION legacy0.primary_location_for_instance(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.primary_location_for_instance(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.primary_location_for_instance(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.primary_location_for_instance(text) TO graphql;

END;
