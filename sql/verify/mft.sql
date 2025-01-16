-- Verify graphql:mft on pg
begin
;

select pg_catalog.has_schema_privilege('mft', 'usage')
;

select pg_catalog.has_function_privilege('mft.create_customer'::regproc, 'execute')
;

select pg_catalog.has_function_privilege('mft.create_location'::regproc, 'execute')
;

select pg_catalog.has_function_privilege('mft.create_demo'::regproc, 'execute')
;

select pg_catalog.has_function_privilege('mft.destroy_demo'::regproc, 'execute')
;

rollback
;
