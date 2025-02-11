-- Verify graphql:001-init on pg
begin
;

select pg_catalog.has_schema_privilege('auth', 'usage')
;
select pg_catalog.has_schema_privilege('debug', 'usage')
;
select pg_catalog.has_schema_privilege('ast', 'usage')
;

select pg_catalog.has_function_privilege('debug.inspect'::regproc, 'execute')
;
select pg_catalog.has_function_privilege('debug.inspect_t'::regproc, 'execute')
;
select pg_catalog.has_function_privilege('auth.current_identity'::regproc, 'execute')
;
select pg_catalog.has_function_privilege('public.create_name'::regproc, 'execute')
;
select pg_catalog.has_function_privilege('ast.create_system_type'::regproc, 'execute')
;
select pg_catalog.has_function_privilege('ast.create_user_type'::regproc, 'execute')
;

rollback
;
