-- Deploy graphql:permissions to pg

BEGIN;

revoke usage on schema _api from public;
revoke usage on schema api from public;
revoke all on all tables in schema api from public;
revoke all on all tables in schema api from anonymous;
revoke all on all routines in schema api from public;
revoke all on all routines in schema api from anonymous;

grant usage on schema _api to anonymous, authenticated, god;
grant usage on schema api to anonymous, authenticated, god;
grant execute on function _api.pre_request_hook to anonymous, authenticated, god;
grant execute on function api.token to anonymous, authenticated, god;
grant execute on function api.token_introspect to authenticated, god;
grant all on table api.entity_instance to authenticated, god;
grant all on table api.entity_instance_field to authenticated, god;
grant all on table api.entity_template to authenticated, god;
grant all on table api.entity_field to authenticated, god;
grant execute on function api.delete_entity_instance to authenticated, god;
grant execute on function api.delete_entity_instance_field to authenticated, god;
grant execute on function api.delete_entity_template to authenticated, god;
grant execute on function api.delete_entity_field to authenticated, god;

COMMIT;
