-- Verify graphql:init on pg
begin;

select pg_catalog.has_function_privilege('i18n.update_localized_content'::regproc, 'execute');

rollback;
