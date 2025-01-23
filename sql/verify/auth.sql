-- Verify graphql:auth on pg
begin
;

select pg_catalog.has_schema_privilege('auth', 'usage')
;

select pg_catalog.has_function_privilege('auth.current_identity'::regproc, 'execute')
;

rollback
;
