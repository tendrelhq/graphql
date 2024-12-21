-- Verify graphql:worker on pg
begin
;

select pg_catalog.has_function_privilege('util.create_worker'::regproc, 'execute')
;

rollback
;

