-- Verify graphql:template on pg
begin
;

select
    pg_catalog.has_function_privilege('util.create_template_type'::regproc, 'execute')
;

select
    pg_catalog.has_function_privilege(
        'util.create_template_constraint_foreach_child_location'::regproc, 'execute'
    )
;

rollback
;

