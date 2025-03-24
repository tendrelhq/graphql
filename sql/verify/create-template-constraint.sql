-- Verify graphql:create-template-constraint on pg
begin;

select
    pg_catalog.has_function_privilege(
        'legacy0.create_template_constraint_on_location'::regproc, 'execute'
    )
;

rollback;
