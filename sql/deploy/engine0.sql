-- Deploy graphql:engine0 to pg
begin
;

create schema engine0;

create function engine0.execute(task_id text)
returns table(instance text)
as $$
begin
  return query
    with
        stage1 as (
            select * from engine0.plan_build(task_id)
        ),

        stage2 as (
            select distinct s1.target, s1.target_parent, s1.target_type
            from stage1 s1, engine0.plan_check(
                target := s1.target,
                target_type := s1.target_type,
                conditions := s1.ops
            ) pc
            where pc.result = true
        ),

        stage3 as (
            select i.*
            from stage2 s2, util.instantiate(
                template_id := s2.target,
                location_id := s2.target_parent,
                target_state := 'Open',    -- FIXME: s2.target_state (doesn't exist)
                target_type := 'On Demand' -- FIXME: s2.target_type (but its a uuid)
            ) i
        )

    select s3.instance from stage3 s3
    group by s3.instance
  ;

  return;
end $$
language plpgsql
strict
;

comment on function engine0.execute is $$

# engine0.execute

$$;

create type engine0.closure as (
    f regproc,
    ctx jsonb
);

comment on type engine0.closure is $$

# engine0.closure

A "closure" encapsulates both a procedure, via `f`, as well as the arguments
that we intend to invoke it with, via `ctx`.

$$;

-- fmt: off
create function engine0.plan_build(task_id text)
returns
    table(
        count bigint,
        ops engine0.closure[],
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
            select
                nt.worktemplatenexttemplateid as _id,
                root.id as task,
                root.parent_id as task_parent,
                n.id as next_task_id,
                f.id as curr_field_id,
                f_op.systaguuid as curr_field_op_id,
                s.systaguuid as curr_state_id,
                t.systaguuid as next_type_id
            from root
            inner join public.worktemplatenexttemplate as nt
                on root.workinstanceworktemplateid = nt.worktemplatenexttemplateprevioustemplateid
            inner join public.worktemplate as n
                on nt.worktemplatenexttemplatenexttemplateid = n.worktemplateid
            left join public.workresult as f
                on nt.worktemplatenexttemplateviaworkresultid = f.workresultid
            left join public.systag as f_op
                on nt.worktemplatenexttemplateviaworkresultcontstraintid = f_op.systagid
            left join public.systag as s
                on nt.worktemplatenexttemplateviastatuschangeid = s.systagid
            left join public.systag as t
                on nt.worktemplatenexttemplatetypeid = t.systagid
        ),

        field_dst as (
            select
                dst.*,
                (
                    'engine0.eval_field_condition',
                    jsonb_build_object(
                        'field',
                        dst.curr_field_id,
                        'field_operator',
                        dst.curr_field_op_id,
                        'task',
                        dst.task
                    )
                )::engine0.closure as op
            from dst
            where dst.curr_field_id is not null and dst.curr_state_id is null
        ),

        state_dst as (
            select
                dst.*,
                (
                    'engine0.eval_state_condition',
                    jsonb_build_object(
                        'state',
                        dst.curr_state_id,
                        'task',
                        dst.task
                    )
                )::engine0.closure as op
            from dst
            where dst.curr_field_id is null and dst.curr_state_id is not null
        ),

        field_and_state_dst as (
            select
                dst.*,
                (
                    'engine0.eval_field_and_state_condition',
                    jsonb_build_object(
                        'field',
                        dst.curr_field_id,
                        'field_operator',
                        dst.curr_field_op_id,
                        'state',
                        dst.curr_state_id,
                        'task',
                        dst.task
                    )
                )::engine0.closure as op
            from dst
            where dst.curr_field_id is not null and dst.curr_state_id is not null
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
        plan.next_task_id as target,
        plan.task_parent as target_parent,
        plan.next_type_id as target_type
    from plan
    group by plan.next_task_id, plan.next_type_id, plan.task_parent
  ;

  return;
end $$
language plpgsql
strict
;
-- fmt: on

comment on function engine0.plan_build is $$

# engine0.plan_build

Build an instantiation plan based on the current state of the system.

$$;

create function
    engine0.plan_check(target text, target_type text, conditions engine0.closure[])
returns table(system regproc, result boolean)
as $$
declare
  x engine0.closure;
begin
  foreach x in array conditions loop
    return query
      execute format('select $1, %s($2)', x.f)
      using x.f, x.ctx
    ;
  end loop;

  return;
end $$
language plpgsql
strict
;

comment on function engine0.plan_check is $$

# engine0.plan_check

$$;

create function engine0.eval_field_condition(ctx jsonb)
returns boolean
as $$
begin
  return false;
end $$
language plpgsql
strict
;

create function engine0.eval_state_condition(ctx jsonb)
returns boolean
as $$
begin
  perform 1
  from jsonb_to_record(ctx) as x(state text, task text)
  inner join public.workinstance as i on x.task = i.id
  inner join public.systag as s on x.state = s.systaguuid
  where i.workinstancestatusid = s.systagid
  ;

  return found;
end $$
language plpgsql
strict
;

create function engine0.eval_field_and_state_condition(ctx jsonb)
returns boolean
as $$
begin
  return engine0.eval_field_condition(ctx) and engine0.eval_state_condition(ctx);
end $$
language plpgsql
strict
;

commit
;

