-- Verify graphql:name on pg
begin
;

select pg_catalog.has_function_privilege('util.create_name'::regproc, 'execute')
;

rollback
;
