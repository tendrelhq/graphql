-- Verify graphql:language on pg
begin
;

select pg_catalog.has_schema_privilege('i18n', 'usage')
;

select
    pg_catalog.has_function_privilege(
        'i18n.add_language_to_customer'::regproc, 'execute'
    )
;

rollback
;
