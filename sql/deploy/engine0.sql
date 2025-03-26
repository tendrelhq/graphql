-- Deploy graphql:engine0 to pg
begin;

create or replace function engine0.build_instantiation_plan(task_id text)
returns
    table(
        count bigint,
        ops engine0.closure[],
        i_mode text,
        target text,
        target_parent text,
        target_type text
    )
as $$
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
end $$
language plpgsql
strict;

create or replace function
  engine0.eval_condition_expression(lhs text, op text, rhs text, type text)
returns boolean
as $$
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
$$
language sql
immutable;

create or replace function engine0.eval_field_condition(ctx jsonb)
returns table(ok boolean)
as $$
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
$$
language sql
stable;

create or replace function engine0.eval_state_condition(ctx jsonb)
returns table(ok boolean)
as $$
  select true as ok
  from jsonb_to_record(ctx) as args (state text, task text)
  inner join public.workinstance as i on args.task = i.id
  inner join public.systag as s
    on i.workinstancestatusid = s.systagid
    and args.state = s.systagtype
  ;
$$
language sql
stable;

create or replace function engine0.eval_field_and_state_condition(ctx jsonb)
returns table(ok boolean)
as $$
  select true as ok
  from
    engine0.eval_field_condition(ctx) as f,
    engine0.eval_state_condition(ctx) as s
  where f.ok and s.ok;
$$
language sql
stable;

commit;
