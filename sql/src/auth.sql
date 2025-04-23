CREATE SCHEMA auth;

grant usage on schema auth to public;
revoke all on all tables in schema auth from public;
revoke all on all routines in schema auth from public;
