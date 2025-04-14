-- Revert graphql:permissions from pg

BEGIN;

revoke all on schema _api from public;

do $$
begin
  if exists(select 1 from pg_roles where rolname = 'god') then
    drop role god;
  end if;
  if exists(select 1 from pg_roles where rolname = 'authenticated') then
    revoke all on all routines in schema api from authenticated;
    revoke all on all tables in schema api from authenticated;
    drop role authenticated;
  end if;

  if exists(select 1 from pg_roles where rolname = 'anonymous') then
    revoke all on schema api from anonymous;
    revoke all on all routines in schema _api from anonymous;
    revoke all on all routines in schema  api from anonymous;
    drop role anonymous;
  end if;

end $$;

COMMIT;
