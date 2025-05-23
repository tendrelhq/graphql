/**
 * Tendrel implements several OAuth 2.0 grant types:
 *  - client_credentials
 *  - device_code
 */

-- This is a public schema!
create schema if not exists auth;
grant usage on schema auth to public;

-- Helper function to get the JWT payload for an authenticated user.
create function auth.jwt() returns jsonb
language sql
as $$ current_setting('request.jwt.claims'); $$
security definer
stable;
revoke all on function auth.jwt from public;
grant execute on function auth.jwt to authenticated;

create type auth.grant_type as enum (
  client_credentials
  -- device_code,   --> upcoming v1 feature
  -- token_exchange --> This will need to be implemented outside of Postgres :(
);
grant usage on type auth.grant_type to public;

-- /api/v1/auth/token
create table auth.token (
  timestamp timestamp not null,
  grant_type auth.grant_type not null,
  params jsonb not null
);
revoke all on table auth.token from public;
-- POST /api/v1/auth/token
grant insert on table auth.token to public;

-- We maintain an access_log for visibility into auth related events.
create schema audit;
revoke all on schema audit from public;

-- Historical record of access-related events.
create table audit.access_log (
  timestamp timestamp not null default now(),
  client_id text,
  sub text not null,
  method text not null, -- POST /token?grant_type=...
  resource uuid references auth.token (id) on delete set null
);
revoke all on table audit.access_log from public;
grant select on table audit.access_log to authenticated;

-- TODO: RLS policy to restrict what can be seen.

create procedure audit.log_access_event(method text, resource uuid)
language sql
as $$
  insert into audit.access_log (client_id, sub, method, resource)
  values (auth.jwt() ->> 'client_id', auth.jwt() ->> 'sub', method, resource);
$
security definer;

create function auth._token_handler() returns trigger
language plpgsql
as $$
begin
  -- Note that token verification has already happened! Which reminds me...
  -- TODO: update the pre_request_hook to verify client_credentials.
  call auth.log_access_event(
    method := 'POST /token?grant_type=token-exchange',
    resource := null
  );
  select 
end
$$;
revoke all on function auth._token_handler from public;
grant execute on function auth._token_handler to public;

create trigger auth_token_trigger
before insert, delete, update on auth.token
execute auth._token_trigger_fn();

create function auth.client_credentials()
returns jsonb
as $$
$$
language sql;
