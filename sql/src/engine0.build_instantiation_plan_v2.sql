
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
