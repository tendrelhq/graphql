-- Verify graphql:create-user-type on pg
begin
;

select pg_catalog.has_function_privilege('ast.create_user_type'::regproc, 'execute')
;

rollback
;
