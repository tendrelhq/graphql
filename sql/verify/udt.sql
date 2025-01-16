-- Verify graphql:udt on pg
begin
;

select pg_catalog.has_function_privilege('util.create_user_type'::regproc, 'execute')
;

select pg_catalog.has_function_privilege('util.create_type'::regproc, 'execute')
;

rollback
;
