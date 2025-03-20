-- Deploy graphql:nodeops to pg

BEGIN;

-- No GRANTs required :)

--
-- DELETE operations
--

create or replace function engine1.delete_workinstance(ctx jsonb)
returns setof engine1.closure
as $$
  with cte as (
    update public.workinstance
    set workinstancestatusid = 711,
        workinstancetrustreasoncodeid = 765,
        workinstancemodifieddate = now(),
        workinstancemodifiedby = 895
    where workinstance.id in (select value from jsonb_array_elements_text(ctx))
        and workinstance.workinstancestatusid != 711
        and workinstance.workinstancetrustreasoncodeid != 765
    returning workinstance.id
  )
  select
      'engine1.id'::regproc as f,
      jsonb_build_object(
          'ok', true,
          'deleted', array[cte.id]
      )
  from cte;
$$
language sql;

create or replace function engine1.delete_workresult(ctx jsonb)
returns setof engine1.closure
as $$
  with cte as (
    update public.workresult
    set workresultdeleted = true,
        workresultmodifieddate = now(),
        workresultmodifiedby = 895
    where workresult.id in (select value from jsonb_array_elements_text(ctx))
        and workresultdeleted = false
    returning workresult.id
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'deleted', array[cte.id]
    )
  from cte;
$$
language sql;

create or replace function engine1.delete_workresultinstance(ctx jsonb)
returns setof engine1.closure
as $$
  select
      'engine1.id'::regproc,
      jsonb_build_object(
          'ok', true,
          'deleted', array_agg(distinct nodes.value)
      )
  from jsonb_array_elements_text(ctx) as nodes
$$
language sql
immutable;

create or replace function engine1.delete_worktemplate(ctx jsonb)
returns setof engine1.closure
as $$
  with cte as (
    update public.worktemplate
    set worktemplatedeleted = true,
        worktemplatemodifieddate = now(),
        worktemplatemodifiedby = 895
    where worktemplate.id in (select value from jsonb_array_elements_text(ctx))
        and worktemplate.worktemplatedeleted = false
    returning worktemplate.id, worktemplate.worktemplateid as _id
  )
  select
      'engine1.id'::regproc,
      jsonb_build_object(
          'ok', true,
          'deleted', array[cte.id]
      )
  from cte
  union all
  select
      'engine1.delete_workinstance'::regproc,
      to_jsonb(array_agg(workinstance.id))
  from cte, public.workinstance
  where cte._id = workinstance.workinstanceworktemplateid
      and workinstance.workinstancestatusid in (
          select systagid
          from public.systag
          where systagparentid = 705 and systagtype = 'Open'
      )
  ;
$$
language sql;

-- TODO: delete this.
-- We aren't ready for it yet, and it doesn't really serve any purpose.
create or replace function engine1.delete_node(kind text, id text)
returns setof engine1.closure
as $$
  with op (kind, id) as (values (kind, id))
  select
      'engine1.delete_workresult'::regproc,
      jsonb_build_array(workresult.id)
  from op, public.workresult
  where op.kind = 'workresult' and op.id = workresult.id
  union all
  select
      'engine1.delete_worktemplate'::regproc,
      jsonb_build_array(worktemplate.id)
  from op, public.worktemplate
  where op.kind = 'worktemplate' and op.id = worktemplate.id
  union all
  select
      'engine1.delete_workresultinstance'::regproc,
      jsonb_build_array(wri.workresultinstanceuuid)
  from op, public.workresultinstance as wri
  where op.kind = 'workresultinstance' and op.id = wri.workresultinstanceuuid
  union all
  select
      'engine1.delete_workinstance'::regproc,
      jsonb_build_array(workinstance.id)
  from op, public.workinstance
  where op.kind = 'workinstance' and op.id = workinstance.id;
$$
language sql;

--
-- INSTANTIATE operations
--

-- `ctx` is an array of json objects suitable for passing to
-- engine0.instantiate.
create or replace function engine1.instantiate(ctx jsonb)
returns setof engine1.closure
as $$
  with cte as (
      select t.instance as node
      from
        jsonb_to_recordset(ctx) as x(
            template_id text,
            location_id text,
            target_state text,
            target_type text,
            chain_root_id text,
            chain_prev_id text
        ),
        engine0.instantiate(
            template_id := x.template_id,
            location_id := x.location_id,
            target_state := x.target_state,
            target_type := x.target_type,
            chain_root_id := x.chain_root_id,
            chain_prev_id := x.chain_prev_id,
            modified_by := 895
        ) as t
      group by t.instance
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'count', count(*),
        'created', jsonb_agg(jsonb_build_object('node', cte.node))
    )
  from cte
$$
language sql;

-- `ctx` is an array of workresult uuids
create or replace function engine1.instantiate_workresult(ctx jsonb)
returns setof engine1.closure
as $$
  with cte as (
    insert into public.workresultinstance (
        workresultinstancecustomerid,
        workresultinstanceworkinstanceid,
        workresultinstanceworkresultid,
        workresultinstancestartdate,
        workresultinstancecompleteddate,
        workresultinstancevalue,
        workresultinstancetimezone,
        workresultinstancemodifiedby
    )
    select
      workinstance.workinstancecustomerid,
      workinstance.workinstanceid,
      workresult.workresultid,
      workinstance.workinstancestartdate,
      workinstance.workinstancecompleteddate,
      workresult.workresultdefaultvalue,
      workinstance.workinstancetimezone,
      auth.current_identity(
          parent := workresult.workresultcustomerid,
          identity := current_setting('user.id')
      ) as modified_by
    from public.workresult
    inner join public.workinstance
        on workresultworktemplateid = workinstanceworktemplateid
    where
      workresult.id in (select value from jsonb_array_elements_text(ctx))
      and workresult.workresultdeleted = false
      and workresult.workresultdraft = false
      and (
          workresult.workresultenddate is null
          or workresult.workresultenddate > now()
      )
      and workinstance.workinstancestatusid = (
          select systagid
          from public.systag
          where systagparentid = 705 and systagtype = 'Open'
      )
    on conflict do nothing
    returning workresultinstanceuuid as id
  )

  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'count', count(*),
        'created', jsonb_agg(jsonb_build_object('node', cte.id))
    )
  from cte
$$
language sql;

-- `ctx` is an array of worktemplate uuids
create or replace function engine1.instantiate_worktemplate(ctx jsonb)
returns setof engine1.closure
as $$
  select
    'engine1.instantiate'::regproc,
    jsonb_agg(
      jsonb_build_object(
          'template_id', worktemplate.id,
          'location_id', location.locationuuid,
          'target_state', 'Open',
          'target_type', 'On Demand'
          -- 'chain_root_id', null,
          -- 'chain_prev_id', null
      )
    )
  from public.worktemplate
  inner join public.worktemplateconstraint
    on worktemplate.id = worktemplateconstrainttemplateid
    and worktemplateconstraintconstrainedtypeid = (
        select systaguuid
        from public.systag
        where systagparentid = 849 and systagtype = 'Location'
    )
  inner join public.custag on worktemplateconstraintconstraintid = custaguuid
  inner join public.location
    on worktemplatesiteid = locationsiteid
    and custagid = locationcategoryid
  where
    worktemplate.id in (select value from jsonb_array_elements_text(ctx))
    and worktemplatedeleted = false
    and worktemplatedraft = false
    and (worktemplateenddate is null or worktemplateenddate > now())
$$
language sql
stable;

--
-- DRAFT operations
--

create or replace function engine1.publish_worktemplate(ctx jsonb)
returns setof engine1.closure
as $$
  with cte as (
    update public.worktemplate
    set worktemplatedraft = false,
        worktemplatemodifieddate = now(),
        worktemplatemodifiedby = 895
    where id in (select value from jsonb_array_elements_text(ctx))
      and worktemplatedraft = true
    returning id, worktemplateid as _id
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'count', count(*),
        'updated', jsonb_agg(jsonb_build_object('node', cte.id))
    )
  from cte
  union all
  select
    'engine1.instantiate_worktemplate'::regproc,
    jsonb_agg(cte.id)
  from cte;
$$
language sql;

-- `ctx` is an array of workresult uuids
create or replace function engine1.publish_workresult(ctx jsonb)
returns setof engine1.closure
as $$
  with cte as (
    update public.workresult
    set workresultdraft = false,
        workresultmodifieddate = now(),
        workresultmodifiedby = 895
    where id in (select value from jsonb_array_elements_text(ctx))
      and workresultdraft = true
    returning id
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'count', count(*),
        'updated', jsonb_agg(jsonb_build_object('node', cte.id))
    )
  from cte
  union all
  select
    'engine1.instantiate_workresult'::regproc,
    jsonb_agg(cte.id)
  from cte;
$$
language sql;

COMMIT;
