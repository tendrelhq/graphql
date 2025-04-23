-- Deploy graphql:batch-support to pg

BEGIN;

-- This is necessary to support cross-location instantiation.

alter table public.worktemplatenexttemplate
  add column worktemplatenexttemplateuuid text
      not null unique default gen_random_uuid(),
  add column worktemplatenexttemplateprevlocationid text
      references public.location (locationuuid),
  add column worktemplatenexttemplatenextlocationid text
      references public.location (locationuuid)
;

-- Type: FUNCTION ; Name: engine1.instantiate_workresult(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.instantiate_workresult(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
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
        'ok', count(*) > 0,
        'count', count(*),
        'created', coalesce(
          jsonb_agg(jsonb_build_object('node', cte.id)),
          '[]'::jsonb
        )
    )
  from cte
$function$;


REVOKE ALL ON FUNCTION engine1.instantiate_workresult(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate_workresult(jsonb) TO graphql;

-- Type: FUNCTION ; Name: legacy0.create_instantiation_rule_v2(text,text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_instantiation_rule_v2(
  prev_template_id text,
  next_template_id text,
  state_condition text,
  type_tag text,
  prev_location_id text,
  next_location_id text,
  modified_by bigint
)
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

revoke all on function legacy0.create_instantiation_rule_v2 from public;
grant execute on function legacy0.create_instantiation_rule_v2 to graphql;

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

      choices as (
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
        where mode.systagtype = 'On Demand'
          and (
            nt.worktemplatenexttemplateprevlocationid is null
            or nt.worktemplatenexttemplateprevlocationid = prev.target
          )
      ),

      instantiations as (
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
        where mode.systagtype != 'On Demand'
          and (
            nt.worktemplatenexttemplateprevlocationid is null
            or nt.worktemplatenexttemplateprevlocationid = prev.target
          )
      ),

      all_rules as (
        select * from choices
        union all
        select * from instantiations
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
        from prev, all_rules as r
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
        from prev, all_rules as r
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
        from prev, all_rules as r
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

revoke all on function engine0.build_instantiation_plan_v2 from public;
grant execute on function engine0.build_instantiation_plan_v2 to graphql;

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
GRANT EXECUTE ON FUNCTION engine0.instantiate(text,text,text,text,bigint,text,text) TO graphql;

-- Type: FUNCTION ; Name: engine0.execute(text,bigint); Owner: tendreladmin

-- Note that currently cross-location instantiation is (kinda) broken. It is
-- because of the block of code below that grabs the "chain_root_id". This will
-- be soon fixed for the forthcoming release of Batch.

CREATE OR REPLACE FUNCTION engine0.execute(task_id text, modified_by bigint)
 RETURNS TABLE(instance text)
 LANGUAGE plpgsql
 STRICT
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
          where prev.id = task_id and t.id != p.node
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
GRANT EXECUTE ON FUNCTION engine0.execute(text,bigint) TO graphql;

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

  -- The canonical on-demand in-progress "respawn" rule. This rule causes a new,
  -- Open task instance to be created when a task transitions to InProgress.
  return query
    select '  +irule', t.next
    from legacy0.create_instantiation_rule(
        prev_template_id := ins_template,
        next_template_id := ins_template,
        state_condition := 'In Progress',
        type_tag := 'Task',
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


REVOKE ALL ON FUNCTION runtime.add_demo_to_customer(text,text,bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION runtime.add_demo_to_customer(text,text,bigint,text) TO graphql;

COMMIT;
