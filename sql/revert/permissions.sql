-- Revert graphql:permissions from pg

BEGIN;

revoke all on schema _api from public;

revoke all on schema api from anonymous;
revoke all on all routines in schema _api from anonymous;
revoke all on all routines in schema  api from anonymous;

revoke all on all routines in schema api from authenticated;
revoke all on all tables in schema api from authenticated;

drop role god;
drop role authenticated;
drop role anonymous;

COMMIT;
