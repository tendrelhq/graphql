-- Verify graphql:create-location on pg
begin
;

select pg_catalog.has_function_privilege('legacy0.create_location'::regproc, 'execute')
;

rollback
;
