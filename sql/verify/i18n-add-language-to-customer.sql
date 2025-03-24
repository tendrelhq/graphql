-- Verify graphql:i18n-add-language-to-customer on pg
begin;

select
    pg_catalog.has_function_privilege(
        'i18n.add_language_to_customer'::regproc, 'execute'
    )
;

rollback;
