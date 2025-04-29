-- Deploy graphql:fix-x-location to pg

BEGIN;

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
        where mode.systagtype != 'On Demand'
          and (
            nt.worktemplatenexttemplateprevlocationid is null
            or nt.worktemplatenexttemplateprevlocationid = prev.target
          )
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

-- Type: FUNCTION ; Name: engine0.execute(text,bigint); Owner: tendreladmin

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

COMMIT;
