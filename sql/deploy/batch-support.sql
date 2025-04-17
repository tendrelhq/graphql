-- Deploy graphql:cross-location-instantiation to pg

BEGIN;

alter table public.worktemplatenexttemplate
  add column worktemplatenexttemplateuuid text
      not null unique default gen_random_uuid(),
  add column worktemplatenexttemplateprevlocationid text
      references public.location (locationuuid),
  add column worktemplatenexttemplatenextlocationid text
      references public.location (locationuuid)
;

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
          nt.worktemplatenexttemplatenextlocationid as target,
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
          nt.worktemplatenexttemplatenextlocationid as target,
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
      ),

      result as (
        select t.*
        from
          plan as p,
          engine0.instantiate(
            template_id := p.node,
            location_id := p.target,
            target_state := 'Open',
            target_type := p.target_type,
            chain_prev_id := task_id,
            chain_root_id := (
              select r.id
              from public.workinstance as p
              inner join public.workinstance as r
                on p.workinstanceoriginatorworkinstanceid = r.workinstanceid
              where p.id = task_id
            ),
            modified_by := modified_by
          ) as t
      )

    select r.instance
    from result r
    group by r.instance
  ;

  return;
end $function$;

COMMIT;
