
-- Type: FUNCTION ; Name: engine0.execute(text,bigint); Owner: tendreladmin

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

COMMENT ON FUNCTION engine0.execute(text,bigint) IS '

# engine0.execute

';

REVOKE ALL ON FUNCTION engine0.execute(text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.execute(text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.execute(text,bigint) TO tendreladmin WITH GRANT OPTION;
