-- Verify graphql:apply-field-edits on pg
begin
;

select pg_catalog.has_function_privilege('auth.set_actor'::regproc, 'execute')
;
select pg_catalog.has_function_privilege('engine0.apply_field_edit'::regproc, 'execute')
;

rollback
;
