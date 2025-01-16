-- Verify graphql:location on pg
begin
;

select pg_catalog.has_function_privilege('util.create_location'::regproc, 'execute')
;

rollback
;
