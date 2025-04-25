-- Deploy graphql:graphql-service-role to pg

BEGIN;

do $$
begin
if not exists (select 1 from pg_catalog.pg_roles where rolname = 'graphql') then
  create role graphql login password 'graphql';
end if;
end $$;

grant usage on schema public to graphql;
grant all on all tables in schema public to graphql;

grant usage on schema ast to graphql;
grant execute on all routines in schema ast to graphql;

grant usage on schema auth to graphql;
grant execute on all routines in schema auth to graphql;

grant usage on schema debug to graphql;
grant execute on all routines in schema debug to graphql;

grant usage on schema engine0 to graphql;
grant execute on all routines in schema engine0 to graphql;

grant usage on schema engine1 to graphql;
grant execute on all routines in schema engine1 to graphql;

grant usage on schema entity to graphql;
grant execute on all routines in schema entity to graphql;
grant all on all tables in schema entity to graphql;

grant usage on schema i18n to graphql;
grant execute on all routines in schema i18n to graphql;

grant usage on schema legacy0 to graphql;
grant execute on all routines in schema legacy0 to graphql;

grant usage on schema runtime to graphql;
grant execute on all routines in schema runtime to graphql;

revoke all on schema _api from public;
revoke all on schema api from public;
revoke all on all routines in schema _api from public;
revoke all on all routines in schema api from public;
revoke all on all tables in schema api from public;
grant usage on schema _api to public;

do $$
begin
if not exists (select 1 from pg_catalog.pg_roles where rolname = 'anonymous') then
  create role anonymous nologin;
end if;
end $$;

grant usage on schema api to anonymous;
grant execute on function _api.pre_request_hook to anonymous;
grant execute on function api.token to anonymous;

do $$
begin
if not exists (select 1 from pg_catalog.pg_roles where rolname = 'authenticated') then
  create role authenticated nologin in role anonymous;
end if;
end $$;

grant execute on all routines in schema _api to authenticated;
grant execute on all routines in schema  api to authenticated;
-- Note that in Postgres 14 views are implicitly SECURITY DEFINER, meaning that
-- the below GRANTS have no effect on the generated api aside from making these
-- tables available through the api. That is to say: even though we explicitly
-- only grant SELECT, INSERT, and UPDATE there will still be a DELETE verb in the
-- generated api :(
-- Until we find the time to upgrade, we should probably create triggers that block
-- deletes on all of these tables to protect ourselves. Particularly because it is
-- *very* easy to TRUNCATE a table via the api lmao.
revoke all on all tables in schema api from authenticated;
grant select, insert, update on all tables in schema api to authenticated;
grant usage on schema entity to authenticated;
revoke all on all tables in schema entity from authenticated;
revoke all on all tables in schema public from authenticated;
grant select, insert, update on all tables in schema entity to authenticated;
grant select, insert, update on all tables in schema public to authenticated;

do $$
begin
if not exists (select 1 from pg_catalog.pg_roles where rolname = 'god') then
  create role god nologin bypassrls in role authenticated;
end if;
end $$;

grant anonymous to graphql;
grant authenticated to graphql;
grant god to graphql;

notify pgrst, 'reload schema';

COMMIT;
