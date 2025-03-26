-- Deploy graphql:public-rest-api to pg
begin;

revoke usage on schema _api from anonymous, authenticated, god;
revoke usage on schema api from anonymous, authenticated, god;

revoke execute on function _api.parse_accept_language from anonymous, authenticated, god;
revoke execute on function _api.pre_request_hook from anonymous, authenticated, god;

revoke all on table api.template from authenticated, god;
revoke all on table api.template_field from authenticated, god;
revoke all on table api.instance from authenticated, god;
revoke all on table api.instance_field from authenticated, god;

create role anon noinherit nologin;
grant usage on schema _api to anon;
grant usage on schema api to anon;
grant all on all tables in schema api to anon;
alter default privileges in schema api grant all on tables to anon;

commit;
