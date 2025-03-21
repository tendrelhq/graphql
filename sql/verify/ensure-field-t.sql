-- Verify graphql:ensure-field-t on pg

BEGIN;

select pg_catalog.has_function_privilege('legacy0.ensure_field_t'::regproc, 'execute');

ROLLBACK;
