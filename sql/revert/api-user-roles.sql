-- Revert graphql:api-user-roles from pg

BEGIN;

revoke all on schema _api from public;

revoke all on schema  api from god;
revoke all on schema _api from god;
revoke all on schema entity from god;
revoke all on all routines in schema _api from god;
revoke all on all routines in schema  api from god;
revoke all on all tables in schema api from god;
revoke all on type api.grant_type from god;
revoke all on type api.token_type from god;
drop role god;

revoke all on schema  api from authenticated;
revoke all on schema _api from authenticated;
revoke all on schema entity from authenticated;
revoke all on all routines in schema _api from authenticated;
revoke all on all routines in schema  api from authenticated;
revoke all on all tables in schema api from authenticated;
revoke all on type api.grant_type from authenticated;
revoke all on type api.token_type from authenticated;
revoke all on schema entity from authenticated;
revoke all on all tables in schema entity from authenticated;
revoke all on all tables in schema public from authenticated;
drop role authenticated;

revoke all on schema _api from anonymous;
revoke all on schema  api from anonymous;
revoke all on all routines in schema _api from anonymous;
revoke all on all routines in schema  api from anonymous;
revoke all on type api.grant_type from anonymous;
revoke all on type api.token_type from anonymous;
drop role anonymous;

COMMIT;
