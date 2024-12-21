-- Verify graphql:inspect on pg
begin
;

select pg_catalog.has_schema_privilege('util', 'usage')
;

select pg_catalog.has_function_privilege('util.inspect'::regproc, 'execute')
;

select pg_catalog.has_function_privilege('util.inspect_t'::regproc, 'execute')
;

rollback
;

