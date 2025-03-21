-- Revert graphql:ensure-field-t from pg

BEGIN;

drop function if exists legacy0.ensure_field_t;

COMMIT;
