-- Revert graphql:api-user-roles from pg

BEGIN;

do $$
begin
if exists (select 1 from pg_catalog.pg_roles where rolname = 'graphql') then

  revoke usage on schema public from graphql;
  revoke all on all tables in schema public from graphql;

  revoke usage on schema ast from graphql;
  revoke execute on all routines in schema ast from graphql;

  revoke usage on schema auth from graphql;
  revoke execute on all routines in schema auth from graphql;

  revoke usage on schema debug from graphql;
  revoke execute on all routines in schema debug from graphql;

  revoke usage on schema engine0 from graphql;
  revoke execute on all routines in schema engine0 from graphql;

  revoke usage on schema engine1 from graphql;
  revoke execute on all routines in schema engine1 from graphql;

  revoke usage on schema entity from graphql;
  revoke execute on all routines in schema entity from graphql;
  revoke all on all tables in schema entity from graphql;

  revoke usage on schema i18n from graphql;
  revoke execute on all routines in schema i18n from graphql;

  revoke usage on schema legacy0 from graphql;
  revoke execute on all routines in schema legacy0 from graphql;

  revoke usage on schema runtime from graphql;
  revoke execute on all routines in schema runtime from graphql;

end if;
end $$;

revoke all on schema _api from public;

do $$
begin
if exists (select 1 from pg_catalog.pg_roles where rolname = 'god') then

  revoke all on schema  api from god;
  revoke all on schema _api from god;
  revoke all on schema entity from god;
  revoke all on all routines in schema _api from god;
  revoke all on all routines in schema  api from god;
  revoke all on all tables in schema api from god;
  revoke all on type api.grant_type from god;
  revoke all on type api.token_type from god;
  drop role god;

end if;
end $$;

do $$
begin
if exists (select 1 from pg_catalog.pg_roles where rolname = 'authenticated') then

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

end if;
end $$;

do $$
begin
if exists (select 1 from pg_catalog.pg_roles where rolname = 'anonymous') then

  revoke all on schema _api from anonymous;
  revoke all on schema  api from anonymous;
  revoke all on all routines in schema _api from anonymous;
  revoke all on all routines in schema  api from anonymous;
  revoke all on type api.grant_type from anonymous;
  revoke all on type api.token_type from anonymous;
  drop role anonymous;

end if;
end $$;

COMMIT;
