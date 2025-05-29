BEGIN;

/*
DROP FUNCTION engine0.instantiate(text,text,text,text,bigint,text,text);
*/


-- Type: FUNCTION ; Name: engine0.instantiate(text,text,text,text,bigint,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.instantiate(template_id text, location_id text, target_state text, target_type text, modified_by bigint, chain_root_id text DEFAULT NULL::text, chain_prev_id text DEFAULT NULL::text)
 RETURNS TABLE(instance text, field text, value text)
 LANGUAGE plpgsql
AS $function$
declare
  ins_instance text;
begin
  insert into public.workinstance (
      workinstancecustomerid,
      workinstancesiteid,
      workinstanceworktemplateid,
      workinstanceoriginatorworkinstanceid,
      workinstancepreviousid,
      workinstancestatusid,
      workinstancetypeid,
      workinstancesoplink,
      workinstancestartdate,
      workinstancetargetstartdate,
      workinstancetimezone,
      workinstancemodifiedby
  )
  select
      task_t.worktemplatecustomerid,
      task_t.worktemplatesiteid,
      task_t.worktemplateid,
      chain_root.workinstanceid,
      chain_prev.workinstanceid,
      task_state_t.systagid,
      task_type_t.systagid,
      task_t.worktemplatesoplink,
      null, -- start date
      rr.target_start_time,
      location.locationtimezone,
      modified_by
  from
      public.worktemplate as task_t,
      public.location as location,
      public.systag as task_state_t,
      public.systag as task_type_t,
      engine0.evaluate_rrules(
          task_id := task_t.id,
          task_parent_id := location.locationuuid,
          task_prev_id := chain_prev_id,
          task_root_id := chain_root_id
      ) as rr
  left join public.workinstance as chain_root on chain_root.id = chain_root_id
  left join public.workinstance as chain_prev on chain_prev.id = chain_prev_id
  where
      task_t.id = template_id
      and location.locationuuid = location_id
      and (task_state_t.systagparentid, task_state_t.systagtype) = (705, target_state)
      and (task_type_t.systagparentid, task_type_t.systagtype) = (691, target_type)
  returning id into ins_instance;
  --
  if not found then
    raise exception 'failed to create instance';
  end if;
  --
  return query select ins_instance as instance, null, null;

  -- invariant: originator must not be null :sigh:
  update public.workinstance
  set workinstanceoriginatorworkinstanceid = workinstanceid
  where id = ins_instance and workinstanceoriginatorworkinstanceid is null;

  -- default instantiate fields
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
      i.workinstancecustomerid,
      i.workinstanceid,
      f.workresultid,
      i.workinstancestartdate,
      i.workinstancecompleteddate,
      f.workresultdefaultvalue,
      i.workinstancetimezone,
      modified_by
  from public.workinstance as i
  inner join public.workresult as f
      on i.workinstanceworktemplateid = f.workresultworktemplateid
  where
      i.id = ins_instance
      and f.workresultdeleted = false
      and f.workresultdraft = false
      and (f.workresultenddate is null or f.workresultenddate > now())
  on conflict do nothing;

  -- Ensure the location primary field is set.
  with upd_value as (
      select field.workresultinstanceid as _id
      from public.workinstance as i
      inner join public.workresult as field_t
          on i.workinstanceworktemplateid = field_t.workresultworktemplateid
          and field_t.workresulttypeid = 848
          and field_t.workresultentitytypeid = 852
          and field_t.workresultisprimary = true
      inner join public.workresultinstance as field
          on  i.workinstanceid = field.workresultinstanceworkinstanceid
          and field_t.workresultid = field.workresultinstanceworkresultid
      where i.id = ins_instance
  )
  update public.workresultinstance
  set
      workresultinstancevalue = location.locationid::text,
      workresultinstancemodifiedby = modified_by,
      workresultinstancemodifieddate = now()
  from public.location, upd_value
  where
      workresultinstanceid = upd_value._id
      and location.locationuuid = location_id
  ;
  --
  if not found then
    -- Not an error? In theory primary location is not required at this level of
    -- abstraction. "Primary Location" is really an "Activity" invariant (recall
    -- that "Activity" is a Task + Location + Worker). We *should* try to
    -- generically enforce such invariants here however. One way that I can
    -- think to accomplish this is to treat primaries as "constructor" arguments
    -- and if they are `workresultisrequired` without a value, error.
    raise warning 'no primary location field for instance %', ins_instance;
  end if;

  return query
    select
        ins_instance as instance,
        field.workresultinstanceuuid as field,
        field.workresultinstancevalue as value
    from public.workresultinstance as field
    where field.workresultinstanceworkinstanceid in (
        select workinstanceid
        from public.workinstance
        where id = ins_instance
    )
  ;

  return;
end $function$;

COMMENT ON FUNCTION engine0.instantiate(text,text,text,text,bigint,text,text) IS '
# engine0.instantiate

Instantiate a worktemplate at the given location and in the specified target state.
Note that this procedure does NOT protect against duplicates, nor perform any
validation aside from input validation. This procedure is a simple, low-level
primitive that implements generic instantiation.

## usage

```sql
select *
from engine0.instantiate(
    template_id := $1,     -- worktemplate.id (uuid)
    location_id := $2,     -- location.id (uuid), i.e. primary location
    target_state := $3,    -- ''Work Status'' variant, e.g. ''Open''
    target_type := $4,     -- ''Work Type'' variant, e.g. ''On Demand''
    chain_root_id := $5,   -- workinstance.id (uuid), i.e. originator
    chain_prev_id := $6,   -- workinstance.id (uuid), i.e. previous
    modified_by := $7      -- workerinstance.id (bigint)
);
```
';

REVOKE ALL ON FUNCTION engine0.instantiate(text,text,text,text,bigint,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.instantiate(text,text,text,text,bigint,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.instantiate(text,text,text,text,bigint,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.instantiate(text,text,text,text,bigint,text,text) TO graphql;

END;
