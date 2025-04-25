
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
GRANT EXECUTE ON FUNCTION engine0.execute(text,bigint) TO tendrelservice;
GRANT EXECUTE ON FUNCTION engine0.execute(text,bigint) TO graphql;
