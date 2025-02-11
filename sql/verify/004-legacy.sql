-- Verify graphql:004-legacy on pg
begin
;

select pg_catalog.has_schema_privilege('legacy0', 'usage')
;

select pg_catalog.has_function_privilege('legacy0.create_location'::regproc, 'execute')
;
select pg_catalog.has_function_privilege('legacy0.create_worker'::regproc, 'execute')
;
select pg_catalog.has_function_privilege('legacy0.create_task_t'::regproc, 'execute')
;
select
    pg_catalog.has_function_privilege(
        'legacy0.create_template_type'::regproc, 'execute'
    )
;
select
    pg_catalog.has_function_privilege(
        'legacy0.create_template_constraint_on_location'::regproc, 'execute'
    )
;
select pg_catalog.has_function_privilege('legacy0.create_field_t'::regproc, 'execute')
;
select
    pg_catalog.has_function_privilege(
        'legacy0.create_instantiation_rule'::regproc, 'execute'
    )
;
select pg_catalog.has_function_privilege('legacy0.create_rrule'::regproc, 'execute')
;

rollback
;
