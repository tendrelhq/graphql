-- Deploy graphql:api-user-roles to pg

BEGIN;

revoke all on schema _api from public;
revoke all on schema api from public;
revoke all on all routines in schema _api from public;
revoke all on all routines in schema api from public;
revoke all on all tables in schema api from public;
grant usage on schema _api to public;

create role anonymous nologin;
grant usage on schema api to anonymous;
grant execute on function _api.pre_request_hook to anonymous;
grant execute on function api.token to anonymous;

create role authenticated nologin in role anonymous;
grant execute on function api.token_introspect to authenticated;
grant execute on all routines in schema _api to authenticated;
grant execute on all routines in schema  api to authenticated;
grant all on table api.entity_description to authenticated;
grant all on table api.entity_instance to authenticated;
grant all on table api.entity_instance_field to authenticated;
grant all on table api.entity_instance_file to authenticated;
grant all on table api.entity_tag to authenticated;
grant all on table api.entity_template to authenticated;
grant all on table api.entity_field to authenticated;
grant usage on schema entity to authenticated;
grant all on all tables in schema entity to authenticated;
grant all on all tables in schema public to authenticated;

create role god nologin bypassrls in role authenticated;

grant anonymous to graphql;
grant authenticated to graphql;
grant god to graphql;

COMMIT;
