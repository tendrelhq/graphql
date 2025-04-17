-- Revert graphql:cross-location-instantiation from pg

BEGIN;

CREATE OR REPLACE FUNCTION engine0.execute(task_id text, modified_by bigint)
 RETURNS TABLE(instance text)
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    with
        stage1 as (
            select p0.*
            from
                engine0.build_instantiation_plan(task_id) as p0,
                engine0.evaluate_instantiation_plan(
                    target := p0.target,
                    target_type := p0.target_type,
                    conditions := p0.ops
                ) as p1
            where p1.result = true
        ),

        -- FIXME: we shouldn't need to do this per se. Really we need to replace
        -- engine0.instantiate with a better procedure, one that takes uuids
        -- instead of typenames.
        stage2 as (
            select distinct
                s1.target,
                s1.target_parent,
                ts.systagtype as target_state,
                tt.systagtype as target_type
            from stage1 s1
            inner join public.systag as ts
                -- FIXME: this should be configurable. For now our goal is 1:1
                -- parity with the existing rules engine; this is the implicit
                -- configuration for that system at the moment.
                on ts.systagparentid = 705 and ts.systagtype = 'Open'
            inner join public.systag as tt
                on s1.target_type = tt.systaguuid
            where s1.i_mode = 'eager'
        ),

        stage3 as (
            select i.*
            from stage2 s2, engine0.instantiate(
                template_id := s2.target,
                location_id := s2.target_parent,
                target_state := s2.target_state,
                target_type := s2.target_type,
                chain_prev_id := task_id,
                modified_by := modified_by
            ) i
        )

    select s3.instance
    from stage3 s3
    group by s3.instance
  ;

  return;
end $function$;

revoke all on function legacy0.create_instantiation_rule_v2 from graphql;
revoke all on function engine0.build_instantiation_plan_v2 from graphql;

drop function if exists legacy0.create_instantiation_rule_v2;
drop function if exists engine0.build_instantiation_plan_v2;

alter table public.worktemplatenexttemplate
  drop column if exists worktemplatenexttemplateprevlocationid,
  drop column if exists worktemplatenexttemplatenextlocationid,
  drop column if exists worktemplatenexttemplateuuid
;

COMMIT;
