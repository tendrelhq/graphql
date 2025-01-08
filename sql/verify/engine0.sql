-- Verify graphql:engine0 on pg
begin
;

select pg_catalog.has_schema_privilege('engine0', 'usage')
;

select pg_catalog.has_function_privilege('engine0.execute'::regproc, 'execute')
;

rollback
;

