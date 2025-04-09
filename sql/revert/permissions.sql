-- Revert graphql:permissions from pg

BEGIN;

revoke usage on schema _api from anonymous, authenticated, god;
revoke usage on schema api from anonymous, authenticated, god;
revoke execute on function _api.pre_request_hook from anonymous, authenticated, god;
revoke execute on function api.token from anonymous, authenticated, god;
revoke execute on function api.token_introspect from authenticated, god;
revoke all on table api.entity_instance from authenticated, god;
revoke all on table api.entity_instance_field from authenticated, god;
revoke all on table api.entity_template from authenticated, god;
revoke all on table api.entity_field from authenticated, god;

COMMIT;
