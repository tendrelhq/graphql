BEGIN;

/*
DROP FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]);
DROP FUNCTION engine0.build_instantiation_plan_v2(text);
DROP FUNCTION engine0.build_instantiation_plan(text);
DROP FUNCTION engine0.invoke(engine0.closure);
DROP FUNCTION engine0.apply_field_edit(text,text,anyelement,text,engine0.on_error);
DROP TYPE engine0.diagnostic;
DROP FUNCTION engine0.task_children(text);
DROP FUNCTION engine0.task_chain(text);
DROP FUNCTION engine0.rebase(text,text);
DROP FUNCTION engine0.instantiate(text,text,text,text,bigint,text,text);
DROP FUNCTION engine0.execute(text,bigint);
DROP FUNCTION engine0.evaluate_rrules(text,text,text,text);
DROP FUNCTION engine0.eval_state_condition(jsonb);
DROP FUNCTION engine0.eval_field_condition(jsonb);
DROP FUNCTION engine0.eval_field_and_state_condition(jsonb);
DROP FUNCTION engine0.eval_condition_expression(text,text,text,text);
DROP FUNCTION engine0.compute_rrule_next_occurrence(text,numeric,timestamp with time zone);
DROP TYPE engine0.on_error;
DROP TYPE engine0.diagnostic;
DROP TYPE engine0.diagnostic_severity;
DROP TYPE engine0.diagnostic_kind;
DROP TYPE engine0.closure;

DROP SCHEMA engine0;
*/

CREATE SCHEMA engine0;

GRANT USAGE ON SCHEMA engine0 TO graphql;

-- DEPENDANTS


-- Type: TYPE ; Name: closure; Owner: tendreladmin

CREATE TYPE engine0.closure AS (
    f regproc,
    ctx jsonb
);

COMMENT ON TYPE engine0.closure IS '

# engine0.closure

A "closure" encapsulates both a procedure, via `f`, as well as the arguments
that we intend to invoke it with, via `ctx`.

';

CREATE TYPE engine0.diagnostic_kind AS ENUM (
 'field_type_mismatch',
 'no_such_field'
);


CREATE TYPE engine0.diagnostic_severity AS ENUM (
 'error',
 'warning',
 'info',
 'hint'
);



-- Type: TYPE ; Name: diagnostic; Owner: tendreladmin

CREATE TYPE engine0.diagnostic AS (
    kind engine0.diagnostic_kind,
    severity engine0.diagnostic_severity
);


CREATE TYPE engine0.on_error AS ENUM (
 'diagnostic',
 'raise'
);



-- Type: FUNCTION ; Name: engine0.compute_rrule_next_occurrence(text,numeric,timestamp with time zone); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.compute_rrule_next_occurrence(freq text, interval_v numeric, dtstart timestamp with time zone)
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
declare
  freq_type text := case when freq = 'quarter' then 'month' else freq end;
  base_freq interval := format('1 %s', freq_type)::interval;
begin
  if freq = 'quarter' then
    base_freq := '3 month'::interval;
  end if;

  return dtstart + (base_freq / interval_v);
end $function$;


REVOKE ALL ON FUNCTION engine0.compute_rrule_next_occurrence(text,numeric,timestamp with time zone) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.compute_rrule_next_occurrence(text,numeric,timestamp with time zone) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.compute_rrule_next_occurrence(text,numeric,timestamp with time zone) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.compute_rrule_next_occurrence(text,numeric,timestamp with time zone) TO graphql;

-- Type: FUNCTION ; Name: engine0.eval_condition_expression(text,text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.eval_condition_expression(lhs text, op text, rhs text, type text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select r.*
  from
    (select lhs::boolean, rhs::boolean) as e,
    lateral (
      select false where op = '<'
      union all
      select false where op = '>'
      union all
      select e.lhs is not distinct from e.rhs where op = '='
      union all
      select e.lhs is distinct from e.rhs where op = '<>'
    ) as r
  where type = 'Boolean'
  union all
  select r.*
  from
    (
      select
        to_timestamp(lhs::bigint / 1000.0) as lhs,
        to_timestamp(rhs::bigint / 1000.0) as rhs
    ) as e,
    lateral (
      select e.lhs < e.rhs where op = '<'
      union all
      select e.lhs > e.rhs where op = '>'
      union all
      select e.lhs is not distinct from e.rhs where op = '='
      union all
      select e.lhs is distinct from e.rhs where op = '<>'
    ) as r
  where type = 'Date'
  union all
  select r.*
  from
    (select lhs::numeric, rhs::numeric) as e,
    lateral (
      select e.lhs < e.rhs where op = '<'
      union all
      select e.lhs > e.rhs where op = '>'
      union all
      select e.lhs is not distinct from e.rhs where op = '='
      union all
      select e.lhs is distinct from e.rhs where op = '<>'
    ) as r
  where type = 'Number'
  union all
  select r.*
  from
    (select lhs::text, rhs::text) as e,
    lateral (
      select e.lhs < e.rhs where op = '<'
      union all
      select e.lhs > e.rhs where op = '>'
      union all
      select e.lhs is not distinct from e.rhs where op = '='
      union all
      select e.lhs is distinct from e.rhs where op = '<>'
    ) as r
  where type = 'String'
$function$;


REVOKE ALL ON FUNCTION engine0.eval_condition_expression(text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_condition_expression(text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_condition_expression(text,text,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.eval_condition_expression(text,text,text,text) TO graphql;

-- Type: FUNCTION ; Name: engine0.eval_field_and_state_condition(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.eval_field_and_state_condition(ctx jsonb)
 RETURNS TABLE(ok boolean)
 LANGUAGE sql
 STABLE
AS $function$
  select true as ok
  from
    engine0.eval_field_condition(ctx) as f,
    engine0.eval_state_condition(ctx) as s
  where f.ok and s.ok;
$function$;


REVOKE ALL ON FUNCTION engine0.eval_field_and_state_condition(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_field_and_state_condition(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_field_and_state_condition(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.eval_field_and_state_condition(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine0.eval_field_condition(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.eval_field_condition(ctx jsonb)
 RETURNS TABLE(ok boolean)
 LANGUAGE sql
 STABLE
AS $function$
  -- op_lhs is a workresult uuid
  -- op is a systag type
  -- op_rhs is the raw, expected value
  -- task is a workinstance uuid
  select
    coalesce(
      engine0.eval_condition_expression(
        lhs := workresultinstancevalue,
        op := args.op,
        rhs := args.op_rhs,
        type := systagtype
      ),
      false
    ) as ok
  from jsonb_to_record(ctx) as args (op_lhs text, op text, op_rhs text, task text)
  inner join public.workinstance on workinstance.id = args.task
  inner join public.workresult on workresult.id = args.op_lhs
  inner join public.systag on workresulttypeid = systagid
  inner join public.workresultinstance
    on workinstanceid = workresultinstanceworkinstanceid
    and workresultid = workresultinstanceworkresultid
  ;
$function$;


REVOKE ALL ON FUNCTION engine0.eval_field_condition(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_field_condition(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_field_condition(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.eval_field_condition(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine0.eval_state_condition(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.eval_state_condition(ctx jsonb)
 RETURNS TABLE(ok boolean)
 LANGUAGE sql
 STABLE
AS $function$
  select true as ok
  from jsonb_to_record(ctx) as args (state text, task text)
  inner join public.workinstance as i on args.task = i.id
  inner join public.systag as s
    on i.workinstancestatusid = s.systagid
    and args.state = s.systagtype
  ;
$function$;


REVOKE ALL ON FUNCTION engine0.eval_state_condition(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_state_condition(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_state_condition(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.eval_state_condition(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine0.evaluate_rrules(text,text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.evaluate_rrules(task_id text, task_parent_id text, task_prev_id text DEFAULT NULL::text, task_root_id text DEFAULT NULL::text)
 RETURNS TABLE(target_start_time timestamp with time zone)
 LANGUAGE plpgsql
 STABLE
AS $function$
begin
  return query
    select coalesce(
        engine0.compute_rrule_next_occurrence(
            freq := freq.systagtype,
            interval_v := rr.workfrequencyvalue,
            dtstart := prev.workinstancecompleteddate
        ),
        now()
    ) as target_start_time
    from public.worktemplate as t
    left join public.workinstance as prev on prev.id = task_prev_id
    left join public.workfrequency as rr
        on  rr.workfrequencyworktemplateid = t.worktemplateid
        and (
            rr.workfrequencyenddate is null
            or rr.workfrequencyenddate > now()
        )
    left join public.systag as freq
        on  rr.workfrequencytypeid = freq.systagid
        and freq.systagtype != 'one time'
    where t.id = task_id
  ;

  if not found then
    return query select now() as target_start_time;
  end if;

  return;
end $function$;


REVOKE ALL ON FUNCTION engine0.evaluate_rrules(text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.evaluate_rrules(text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.evaluate_rrules(text,text,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.evaluate_rrules(text,text,text,text) TO graphql;

-- Type: FUNCTION ; Name: engine0.execute(text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.execute(task_id text, modified_by bigint)
 RETURNS TABLE(instance text)
 LANGUAGE plpgsql
AS $function$
begin
  return query
    with
      plan as (
        select distinct p0.node, p0.target, p0.target_type
        from
          engine0.build_instantiation_plan_v2(task_id) as p0,
          engine0.evaluate_instantiation_plan(
            target := p0.node,
            target_type := p0.target_type,
            conditions := p0.ops
          ) as p1
        where p0.target_type != 'On Demand' and p1.result = true
      )

    select t.instance
    from
      plan p,
      engine0.instantiate(
        template_id := p.node,
        location_id := p.target,
        target_state := 'Open',
        target_type := p.target_type,
        chain_prev_id := task_id,
        chain_root_id := (
          select r.id
          from public.workinstance as prev
          inner join public.worktemplate as t
            on prev.workinstanceworktemplateid = t.worktemplateid
          inner join public.workinstance as r
            on prev.workinstanceoriginatorworkinstanceid = r.workinstanceid
          where prev.id = task_id
            and (
              -- N.B. this is the best we can do under the current model.
              -- This will soon change. The implication is that new chains are
              -- created under two conditions:
              -- (1) The task and target [templates] are different. This is the
              -- canonical on-demand in-progress "respawn" rule: a "respawned"
              -- instance is a new chain of work.
              t.id != p.node
              -- (2) The templates are the *same* but the instantiation is
              -- cross-location. I think this will be the case for Batch, i.e.
              -- we want to continue the Batch at a new location, e.g. moving
              -- the Batch from Mixing to Assembly... but perhaps not?
              or exists (
                select 1
                from legacy0.primary_location_for_instance(task_id) as prev_location
                where prev_location.id is distinct from p.target
              )
            )
        ),
        modified_by := modified_by
      ) t
    group by t.instance
  ;

  return;
end $function$;

COMMENT ON FUNCTION engine0.execute(text,bigint) IS '
# engine0.execute
';

REVOKE ALL ON FUNCTION engine0.execute(text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.execute(text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.execute(text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.execute(text,bigint) TO graphql;

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

-- Type: FUNCTION ; Name: engine0.rebase(text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.rebase(base text, node text)
 RETURNS TABLE(id text, updates bigint)
 LANGUAGE sql
AS $function$
  -- `base` is our new originator
  -- `node` is whom we will be updating (along with all of its children)
  with recursive
    base as (
      select *
      from public.workinstance
      where id = base
    ),
    node as (
      select *
      from public.workinstance
      where id = node and workinstanceid = workinstanceoriginatorworkinstanceid
      --                  ^---------------------------------------------------^
      --                               node *must* be a chain root
    ),
    to_update as (
      select child.*
      from node, public.workinstance as child
      where node.workinstanceid = child.workinstancepreviousid
        and node.workinstanceoriginatorworkinstanceid = child.workinstanceoriginatorworkinstanceid
      union
      select child.*
      from to_update, public.workinstance as child
      where to_update.workinstanceid = child.workinstancepreviousid
        and to_update.workinstanceoriginatorworkinstanceid = child.workinstanceoriginatorworkinstanceid
    ),
    updated_children as (
      update public.workinstance as t
      set workinstanceoriginatorworkinstanceid = base.workinstanceid,
          workinstancemodifiedby = auth.current_identity(t.workinstancecustomerid, current_setting('user.id')),
          workinstancemodifieddate = now()
      from base, to_update
      where t.id = to_update.id
      returning t.id
    ),
    updated_node as (
      update public.workinstance as t
      set workinstanceoriginatorworkinstanceid = base.workinstanceid,
          workinstancepreviousid = base.workinstanceid,
          workinstancemodifiedby = auth.current_identity(t.workinstancecustomerid, current_setting('user.id')),
          workinstancemodifieddate = now()
      from base, node
      where t.id = node.id
      returning t.id
    )

  select updated_node.id, count(updated_children.*) as updates
  from updated_node
  left join updated_children on true
  group by updated_node.id;
$function$;


REVOKE ALL ON FUNCTION engine0.rebase(text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.rebase(text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.rebase(text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.rebase(text,text) TO graphql;

-- Type: FUNCTION ; Name: engine0.task_chain(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.task_chain(text)
 RETURNS TABLE(id text)
 LANGUAGE sql
 STABLE
AS $function$
  with recursive cte as (
    select *
    from public.workinstance
    where workinstance.id = $1
    union all
    select child.*
    from cte, public.workinstance as child
    where cte.workinstanceoriginatorworkinstanceid = child.workinstanceoriginatorworkinstanceid
      and cte.workinstanceid = child.workinstancepreviousid
  ) cycle id set is_cycle using path
  select cte.id
  from cte
  where not is_cycle
  order by
    workinstancestartdate,
    workinstanceid
  ;
$function$;


REVOKE ALL ON FUNCTION engine0.task_chain(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.task_chain(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.task_chain(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.task_chain(text) TO graphql;

-- Type: FUNCTION ; Name: engine0.task_children(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.task_children(text)
 RETURNS TABLE(id text)
 LANGUAGE sql
 STABLE
AS $function$
  with recursive cte as (
    select *
    from public.workinstance
    where workinstance.id = $1
    union all
    select child.*
    from cte, public.workinstance as child
    where cte.workinstanceid = child.workinstancepreviousid
  ) cycle id set is_cycle using path
  select cte.id
  from cte
  where not is_cycle
  order by
    workinstancestartdate,
    workinstanceid
  ;
$function$;


REVOKE ALL ON FUNCTION engine0.task_children(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.task_children(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.task_children(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.task_children(text) TO graphql;

-- Type: TYPE ; Name: diagnostic; Owner: tendreladmin

CREATE TYPE engine0.diagnostic AS (
    kind engine0.diagnostic_kind,
    severity engine0.diagnostic_severity
);



-- Type: FUNCTION ; Name: engine0.apply_field_edit(text,text,anyelement,text,engine0.on_error); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.apply_field_edit(entity text, field text, field_v anyelement, field_vt text, on_error engine0.on_error DEFAULT 'diagnostic'::engine0.on_error)
 RETURNS SETOF engine0.diagnostic
 LANGUAGE plpgsql
AS $function$
declare
  -- @see auth.set_actor
  user_id text := current_setting('user.id');
  user_locale text := current_setting('user.locale');
  --
  field_t bigint;
  field_i bigint;
begin
  select workresultid into field_t
  from public.workresult
  inner join public.systag on workresulttypeid = systagid and systagtype = field_vt
  where id = field;
  --
  if not found then
    if on_error = 'raise' then
      raise exception 'field_type_mismatch';
    else
      return query
        select
            'field_type_mismatch'::engine0.diagnostic_kind as kind,
            'error'::engine0.diagnostic_severity as severity
      ;
    end if;
    return;
  end if;

  select workresultinstanceid into field_i
  from public.workresultinstance
  where
      workresultinstanceworkinstanceid = (
          select workinstanceid
          from public.workinstance
          where id = entity
      )
      and workresultinstanceworkresultid = field_t
  ;

  if not found then
    -- Create.
    with
        parent as (
            select
                workinstancecustomerid as _owner,
                workinstanceid as _id,
                workinstancetimezone as timezone
            from public.workinstance
            where id = entity
        ),

        static_content (static_v, dynamic_v, dynamic_vt) as (
            values (
                nullif(field_v::text, ''),
                null::bigint,
                null::bigint
            )
        ),

        dynamic_content as (
            insert into public.languagemaster (
                languagemastercustomerid,
                languagemastersourcelanguagetypeid,
                languagemastersource,
                languagemastermodifiedby
            )
            select
                parent._owner,
                locale.systagid,
                coalesce(field_v::text, ''),
                auth.current_identity(parent._owner, user_id)
            from parent, public.systag as locale
            where
                field_vt in ('String')
                and locale.systagparentid = 2
                and locale.systagtype = user_locale
            returning
                nullif(languagemastersource, '') as static_v,
                languagemasterid as dynamic_v,
                languagemastersourcelanguagetypeid as dynamic_vt
        ),

        content as (
            select * from static_content where field_vt not in ('String')
            union all
            select * from dynamic_content
        )

    insert into public.workresultinstance (
        workresultinstancecustomerid,
        workresultinstanceworkinstanceid,
        workresultinstanceworkresultid,
        workresultinstancetimezone,
        workresultinstancevalue,
        workresultinstancevaluelanguagemasterid,
        workresultinstancevaluelanguagetypeid,
        workresultinstancemodifiedby
    )
    select
        parent.workinstancecustomerid,
        parent.workinstanceid,
        field_t,
        parent.workinstancetimezone,
        content.static_v,
        content.dynamic_v,
        content.dynamic_vt,
        auth.current_identity(parent.workinstancecustomerid, user_id)
    from public.workinstance as parent, content
    where parent.id = entity;
    --
    if not found then
      raise exception 'failed to apply field edit (%, %, %, %)', entity, field, field_v, field_vt;
    end if;

    return query
      select
          null::engine0.diagnostic_kind as kind,
          null::engine0.diagnostic_severity as severity
      ;
    return;
  end if;

  -- Update.
  with
      static_content (static_v, dynamic_v, dynamic_vt) as (
          values (
              nullif(field_v::text, ''),
              null::bigint,
              null::bigint
          )
      ),

      ins_dynamic_content as (
          insert into public.languagemaster (
              languagemastercustomerid,
              languagemastersourcelanguagetypeid,
              languagemastersource,
              languagemastermodifiedby
          )
          select
              workresultinstancecustomerid,
              locale.systagid,
              coalesce(field_v::text, ''),
              auth.current_identity(workresultinstancecustomerid, user_id)
          from public.workresultinstance, public.systag as locale
          where
              field_vt in ('String')
              and workresultinstanceid = field_i
              and workresultinstancevaluelanguagemasterid is null
              and locale.systagparentid = 2
              and locale.systagtype = user_locale
          returning
              nullif(languagemastersource, '') as static_v,
              languagemasterid as dynamic_v,
              languagemastersourcelanguagetypeid as dynamic_vt
      ),

      _upd_dynamic_content_master as (
          update public.languagemaster
          set languagemastersource = coalesce(field_v::text, ''),
              languagemastersourcelanguagetypeid = (
                  select systagid
                  from public.systag
                  where systagparentid = 2 and systagtype = user_locale
              ),
              languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
              languagemastermodifieddate = now(),
              languagemastermodifiedby = auth.current_identity(languagemastercustomerid, user_id)
          from public.workresultinstance
          where
              workresultinstanceid = field_i
              and languagemasterid = workresultinstancevaluelanguagemasterid
              and languagemastersource is distinct from coalesce(field_v::text, '')
          returning
              languagemasterid as _id,
              nullif(languagemastersource, '') as static_v,
              languagemasterid as dynamic_v,
              languagemastersourcelanguagetypeid as dynamic_vt
      ),

      _upd_dynamic_content_trans as (
          update public.languagetranslations
          set languagetranslationvalue = coalesce(field_v::text, ''),
              languagetranslationmodifieddate = now(),
              languagetranslationmodifiedby = auth.current_identity(languagetranslationcustomerid, user_id)
          from _upd_dynamic_content_master as m
          where
              languagetranslationmasterid = m._id
              and languagetranslationtypeid = (
                  select systagid
                  from public.systag
                  where systagparentid = 2 and systagtype = user_locale
              )
          returning
              nullif(languagetranslationvalue, '') as static_v,
              languagetranslationmasterid as dynamic_v,
              languagetranslationtypeid as dynamic_vt
      ),

      upd_dynamic_content as (
          select static_v, dynamic_v, dynamic_vt from _upd_dynamic_content_master
          union -- NOT all!
          select * from _upd_dynamic_content_trans
      ),

      content as (
          select * from static_content where field_vt not in ('String')
          union all
          select * from ins_dynamic_content
          union all
          select * from upd_dynamic_content
      )

  update public.workresultinstance
  set workresultinstancevalue = content.static_v,
      workresultinstancevaluelanguagemasterid = content.dynamic_v,
      workresultinstancevaluelanguagetypeid = content.dynamic_vt,
      workresultinstancemodifiedby = auth.current_identity(workresultinstancecustomerid, user_id),
      workresultinstancemodifieddate = now()
  from content
  where workresultinstanceid = field_i and workresultinstancevalue is distinct from content.static_v;

  return query
    select
        null::engine0.diagnostic_kind as kind,
        null::engine0.diagnostic_severity as severity
  ;
  return;
end $function$;


REVOKE ALL ON FUNCTION engine0.apply_field_edit(text,text,anyelement,text,engine0.on_error) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.apply_field_edit(text,text,anyelement,text,engine0.on_error) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.apply_field_edit(text,text,anyelement,text,engine0.on_error) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.apply_field_edit(text,text,anyelement,text,engine0.on_error) TO graphql;

-- Type: FUNCTION ; Name: engine0.invoke(engine0.closure); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.invoke(x engine0.closure)
 RETURNS SETOF record
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query execute format('select * from %s($1)', x.f) using x.ctx;
end $function$;


REVOKE ALL ON FUNCTION engine0.invoke(engine0.closure) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.invoke(engine0.closure) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.invoke(engine0.closure) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.invoke(engine0.closure) TO graphql;

-- Type: FUNCTION ; Name: engine0.build_instantiation_plan(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.build_instantiation_plan(task_id text)
 RETURNS TABLE(count bigint, ops engine0.closure[], i_mode text, target text, target_parent text, target_type text)
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    with
        root as (
            select
                i.*,
                (
                    select locationuuid
                    from public.location
                    where locationid = parent.workresultinstancevalue::bigint
                ) as parent_id
            from public.workinstance as i
            inner join public.workresultinstance as parent
                on i.workinstanceid = parent.workresultinstanceworkinstanceid
            inner join public.workresult as parent_t
                on i.workinstanceworktemplateid = parent_t.workresultworktemplateid
                and parent.workresultinstanceworkresultid = parent_t.workresultid
                and parent_t.workresulttypeid = 848
                and parent_t.workresultentitytypeid = 852
                and parent_t.workresultisprimary = true
            where i.id = task_id
        ),

        dst as (
            -- instantiation rules; prev != next
            select
                -- 'On Demand' implies lazy instantiation, everything else is eager
                case when t.systagtype = 'On Demand' then 'lazy'
                     else 'eager'
                end as i_mode,
                nt.worktemplatenexttemplateid as _id,
                root.id as task,
                root.parent_id as task_parent,
                n.id as next_task_id,
                t.systaguuid as next_type_id,
                f.id as field,
                f_op.systagtype as field_op,
                nt.worktemplatenexttemplateviaworkresultvalue as field_op_rhs,
                s.systagtype as state
            from root
            inner join public.worktemplatenexttemplate as nt
                on  root.workinstanceworktemplateid = nt.worktemplatenexttemplateprevioustemplateid
                and root.workinstanceworktemplateid != nt.worktemplatenexttemplatenexttemplateid
                and (
                    nt.worktemplatenexttemplateenddate is null
                    or nt.worktemplatenexttemplateenddate > now()
                )
            inner join public.worktemplate as n
                on nt.worktemplatenexttemplatenexttemplateid = n.worktemplateid
            left join public.workresult as f
                on nt.worktemplatenexttemplateviaworkresultid = f.workresultid
            left join public.systag as f_op
                on nt.worktemplatenexttemplateviaworkresultcontstraintid = f_op.systagid
            left join public.systag as s
                on nt.worktemplatenexttemplateviastatuschangeid = s.systagid
            inner join public.systag as t
                on nt.worktemplatenexttemplatetypeid = t.systagid
            union all
            -- recurrence rules; prev = next
            -- FIXME: the only reason we have to differentiate here is because
            -- worktemplatenexttemplate only has the single column "typeid"
            -- which specifies the type of the *next* task. What we want in
            -- addition to this is a column that specifies the *mode*, i.e.
            -- eager or lazy.
            select
                'eager' as i_mode, -- rrules are always eager
                nt.worktemplatenexttemplateid as _id,
                root.id as task,
                root.parent_id as task_parent,
                root_t.id as next_task_id,
                t.systaguuid as next_type_id,
                null::text as field,
                null::text as field_op,
                null::text as field_op_rhs,
                s.systagtype as state
            from root
            inner join public.worktemplatenexttemplate as nt
                on  root.workinstanceworktemplateid = nt.worktemplatenexttemplateprevioustemplateid
                and root.workinstanceworktemplateid = nt.worktemplatenexttemplatenexttemplateid
                and (
                    nt.worktemplatenexttemplateenddate is null
                    or nt.worktemplatenexttemplateenddate > now()
                )
            inner join public.worktemplate as root_t
                on root.workinstanceworktemplateid = root_t.worktemplateid
            inner join public.systag as s
                on nt.worktemplatenexttemplateviastatuschangeid = s.systagid
            inner join public.systag as t
                on nt.worktemplatenexttemplatetypeid = t.systagid
        ),

        field_dst as (
            select
                dst.*,
                (
                    'engine0.eval_field_condition',
                    jsonb_build_object(
                        'op_lhs', dst.field,
                        'op', dst.field_op,
                        'op_rhs', dst.field_op_rhs,
                        'task', dst.task
                    )
                )::engine0.closure as op
            from dst
            where dst.field is not null and dst.state is null
        ),

        state_dst as (
            select
                dst.*,
                (
                    'engine0.eval_state_condition',
                    jsonb_build_object(
                        'state', dst.state,
                        'task', dst.task
                    )
                )::engine0.closure as op
            from dst
            where dst.field is null and dst.state is not null
        ),

        field_and_state_dst as (
            select
                dst.*,
                (
                    'engine0.eval_field_and_state_condition',
                    jsonb_build_object(
                        'op_lhs', dst.field,
                        'op', dst.field_op,
                        'op_rhs', dst.field_op_rhs,
                        'state', dst.state,
                        'task', dst.task
                    )
                )::engine0.closure as op
            from dst
            where dst.field is not null and dst.state is not null
        ),

        plan as (
            select * from field_dst
            union all
            select * from state_dst
            union all
            select * from field_and_state_dst
        )

    select
        count(*) as count,
        array_agg(plan.op) as ops,
        plan.i_mode as i_mode,
        plan.next_task_id as target,
        plan.task_parent as target_parent,
        plan.next_type_id as target_type
    from plan
    group by plan.next_task_id, plan.next_type_id, plan.task_parent, plan.i_mode
  ;

  return;
end $function$;

COMMENT ON FUNCTION engine0.build_instantiation_plan(text) IS '

# engine0.build_instantiation_plan

Build an instantiation plan based on the current state of the system.

';

REVOKE ALL ON FUNCTION engine0.build_instantiation_plan(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.build_instantiation_plan(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.build_instantiation_plan(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.build_instantiation_plan(text) TO graphql;

-- Type: FUNCTION ; Name: engine0.build_instantiation_plan_v2(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.build_instantiation_plan_v2(task_id text)
 RETURNS TABLE(count bigint, ops engine0.closure[], id text, node text, target text, target_type text)
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    with
      prev as (
        select
          i.id as node,
          t.id as template,
          t.worktemplateid as _template,
          l.id as target
        from public.workinstance as i
        inner join public.worktemplate as t
          on i.workinstanceworktemplateid = t.worktemplateid
        left join lateral
          (select * from legacy0.primary_location_for_instance(i.id)) as l
          on true
        where i.id = task_id
      ),

      rules as (
        select
          nt.worktemplatenexttemplateuuid as id,
          next.id as node,
          coalesce(nt.worktemplatenexttemplatenextlocationid, prev.target) as target,
          mode.systagtype as target_type,
          -- Op context:
          f.id as field,
          f_op.systagtype as field_op,
          nt.worktemplatenexttemplateviaworkresultvalue as field_op_rhs,
          s.systagtype as state
        from prev
        inner join public.worktemplatenexttemplate as nt
          on prev._template = nt.worktemplatenexttemplateprevioustemplateid
          and (
            nt.worktemplatenexttemplateenddate is null
            or nt.worktemplatenexttemplateenddate > now()
          )
        inner join public.systag as mode
          on nt.worktemplatenexttemplatetypeid = mode.systagid
        inner join public.worktemplate as next
          on nt.worktemplatenexttemplatenexttemplateid = next.worktemplateid
        left join public.workresult as f
          on nt.worktemplatenexttemplateviaworkresultid = f.workresultid
        left join public.systag as f_op
          on nt.worktemplatenexttemplateviaworkresultcontstraintid = f_op.systagid
        left join public.systag as s
          on nt.worktemplatenexttemplateviastatuschangeid = s.systagid
        where nt.worktemplatenexttemplateprevlocationid is null
          or nt.worktemplatenexttemplateprevlocationid = prev.target
      ),

      field_plan as (
        select
          r.*,
          (
            'engine0.eval_field_condition',
            jsonb_build_object(
              'op_lhs', r.field,
              'op', r.field_op,
              'op_rhs', r.field_op_rhs,
              'task', prev.node
            )
          )::engine0.closure as op
        from prev, rules as r
        where r.field is not null and r.state is null
      ),

      state_plan as (
        select
          r.*,
          (
            'engine0.eval_state_condition',
            jsonb_build_object(
              'state', r.state,
              'task', prev.node
            )
          )::engine0.closure as op
        from prev, rules as r
        where r.field is null and r.state is not null
      ),

      field_and_state_plan as (
        select
          r.*,
          (
            'engine0.eval_field_and_state_condition',
            jsonb_build_object(
              'op_lhs', r.field,
              'op', r.field_op,
              'op_rhs', r.field_op_rhs,
              'state', r.state,
              'task', prev.node
            )
          )::engine0.closure as op
        from prev, rules as r
        where r.field is not null and r.state is not null
      ),

      plan as (
        select * from field_plan
        union all
        select * from state_plan
        union all
        select * from field_and_state_plan
      )

    select
      count(*) as count,
      array_agg(plan.op) as ops,
      plan.id,
      plan.node,
      plan.target,
      plan.target_type
    from plan
    group by plan.id, plan.node, plan.target, plan.target_type
  ;

  return;
end $function$;


REVOKE ALL ON FUNCTION engine0.build_instantiation_plan_v2(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.build_instantiation_plan_v2(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.build_instantiation_plan_v2(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.build_instantiation_plan_v2(text) TO graphql;

-- Type: FUNCTION ; Name: engine0.evaluate_instantiation_plan(text,text,engine0.closure[]); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.evaluate_instantiation_plan(target text, target_type text, conditions engine0.closure[])
 RETURNS TABLE(system regproc, result boolean)
 LANGUAGE plpgsql
 STRICT
AS $function$
declare
  x engine0.closure;
begin
  foreach x in array conditions loop
    return query 
      select x.f as system, fx.ok
      from engine0.invoke(x) as fx(ok boolean)
    ;
  end loop;

  return;
end $function$;

COMMENT ON FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]) IS '

# engine0.evaluate_instantiation_plan

Evaluate an instantiation plan.

';

REVOKE ALL ON FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]) TO graphql;

END;
