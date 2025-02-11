-- Verify graphql:002-engine on pg
begin
;

select pg_catalog.has_schema_privilege('engine0', 'usage')
;

select pg_catalog.has_function_privilege('engine0.execute'::regproc, 'execute')
;
select
    pg_catalog.has_function_privilege(
        'engine0.build_instantiation_plan'::regproc, 'execute'
    )
;
select
    pg_catalog.has_function_privilege(
        'engine0.evaluate_instantiation_plan'::regproc, 'execute'
    )
;
select pg_catalog.has_function_privilege('engine0.instantiate'::regproc, 'execute')
;

rollback
;
