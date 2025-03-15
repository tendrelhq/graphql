-- Deploy graphql:engine0t to pg

BEGIN;

create schema engine0t;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'graphql') then
    revoke all on schema engine0t from graphql;
    grant usage on schema engine0t to graphql;
    alter default privileges in schema engine0 grant execute on routines to graphql;
  end if;
end $$;

create or replace function engine0t.execute(template_id text)
returns table(instance text)
as $$
begin
  -- Whenever you make a change to a template (which includes fields), you
  -- should execute the template engine (engine0t). The template engine will
  -- look for changes and apply various rules (similar to engine0).
  return;
end $$
language plpgsql
strict;

create or replace function engine0t.on_template_deleted(public.worktemplate)
returns setof public.workinstance
as $$
  update public.workinstance
  set workinstancestatusid = (
          select systagid
          from public.systag
          where systagparentid = 705 and systagtype = 'Cancelled'
      ),
      workinstancetrustreasoncodeid = (
          select systagid
          from public.systag
          where systagparentid = 761 and systagtype = 'Reaped'
      ),
      workinstancemodifieddate = now(),
      workinstancemodifiedby = auth.current_identity(
          parent := $1.worktemplatecustomerid,
          identity := current_setting('user.id')
      )
  where
      $1.worktemplatedeleted = true
      and workinstanceworktemplateid = $1.worktemplateid
      and workinstancestatusid = (
          select systagid
          from public.systag
          where systagparentid = 705 and systagtype = 'Open'
      )
  returning *
$$
language sql;

comment on function engine0t.on_template_deleted is $$
This system runs when a template is deleted, i.e. has its `worktemplatedeleted` property set to `true`.
When this happens, the following happens:
  1. Open `workinstances` are reaped, i.e. set to status=Canceled
$$;

create or replace function engine0t.on_template_published(public.worktemplate)
returns setof public.workinstance
as $$
begin
  raise exception 'not yet implemented';
end $$
language plpgsql;

comment on function engine0t.on_template_published is $$
This system runs when a template is published, i.e. has its `worktemplatedraft` property set to `false`.
When this happens, the following happens:
  1. In accordance with `worktemplatenexttemplate` and `worktemplateconstraint`, instantiation occurs.
$$;

create or replace function engine0t.on_field_published(public.workresult)
returns setof public.workresultinstance
as $$
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
      $1.workresultid,
      workinstance.workinstancestartdate,
      workinstance.workinstancecompleteddate,
      $1.workresultdefaultvalue,
      workinstance.workinstancetimezone,
      auth.current_identity(
          parent := $1.workresultcustomerid,
          identity := current_setting('user.id')
      )
  from public.workinstance
  where
      $1.workresultdeleted = false
      and $1.workresultdraft = false
      and (
          $1.workresultenddate is null
          or $1.workresultenddate > now()
      )
      and workinstanceworktemplateid = $1.workresultworktemplateid
      and workinstancestatusid = (
          select systagid
          from public.systag
          where systagparentid = 705 and systagtype = 'Open'
      )
  on conflict do nothing
  returning *;
$$
language sql;

comment on function engine0t.on_field_published is $$
This system runs when a field is deleted, i.e. has its `workresultdraft` property set to `false`.
When this happens, the following happens:
  1. For all Open instances of the parent template, field-level instantiation occurs.
$$;

COMMIT;
