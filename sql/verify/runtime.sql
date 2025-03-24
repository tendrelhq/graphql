-- Verify graphql:runtime on pg
begin
;

select pg_catalog.has_schema_privilege('runtime', 'usage')
;

select pg_catalog.has_function_privilege('runtime.create_customer'::regproc, 'execute')
;
select pg_catalog.has_function_privilege('runtime.create_location'::regproc, 'execute')
;
select pg_catalog.has_function_privilege('runtime.create_demo'::regproc, 'execute')
;
select
    pg_catalog.has_function_privilege(
        'runtime.add_demo_to_customer'::regproc, 'execute'
    )
;
select pg_catalog.has_function_privilege('runtime.destroy_demo'::regproc, 'execute')
;

rollback
;
