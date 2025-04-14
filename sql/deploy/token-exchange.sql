-- Deploy graphql:token-exchange to pg

BEGIN;

create schema if not exists auth;

-- Signing keys to be used by our new OAuth model.
-- For now we will only support 'oct' i.e. symmetric, keys.
-- @see https://datatracker.ietf.org/doc/html/rfc7517#section-4
create table auth._jwk (
  -- Key id; #section-4.5
  kid uuid primary key default gen_random_uuid(),
  -- Key type; see #section-4.1
  kty text not null,
  -- Public key use; see #section-4.2
  use text,
  -- Algorithm; see #section-4.4
  alg text,
  -- Kty specific; see https://datatracker.ietf.org/doc/html/rfc7518#section-6
  params jsonb,
  -- The rest are our own
  _active boolean not null default true,
  _description text,
  _version serial unique not null
);

revoke all on table auth._jwk from public;

create or replace function auth.extract_signing_key(jwk auth._jwk)
returns text
as $$
begin
  if jwk.kty = 'oct' then
    return jwk.params ->> 'k';
  end if;

  raise exception 'unknown kty "%" for jwk with kid: %', jwk.kty, jwk.kid;
end $$
language plpgsql
immutable;

create or replace function auth.jwk_alg_sign(jwk auth._jwk, signables text)
returns text
as $$
  select jwt.algorithm_sign(signables, jwk.params ->> 'k', jwk.alg);
$$
language sql
immutable
strict;

create or replace function auth.jwk_sign(jwk auth._jwk, payload json)
returns text
as $$
  with
    header as (
      select jwt.base64_encode(
        convert_to(
          '{"alg":"' || jwk.alg || '","kid":"' || jwk.kid || '","typ":"JWT"}',
          'utf8'
        )
      ) as data
    ),
    payload as (
      select jwt.base64_encode(convert_to(payload::text, 'utf8')) as data
    ),
    signables as (
      select header.data || '.' || payload.data as data from header, payload
    )
  select signables.data || '.' || auth.jwk_alg_sign(jwk, signables.data)
  from signables;
$$
language sql
immutable
strict;

create or replace function auth.jwt_sign(payload json)
returns text
as $$
  select auth.jwk_sign(jwk.*, payload)
  from auth._jwk as jwk
  where _active
  order by _version desc
  limit 1;
$$
language sql
security definer
stable
strict;

create or replace function auth.jwt_verify(token text)
returns table(header json, payload json, valid boolean)
as $$
  with
    jwt as (
      select
        convert_from(jwt.base64_decode(r[1]), 'utf8')::json as header,
        convert_from(jwt.base64_decode(r[2]), 'utf8')::json as payload,
        r[1] as h,
        r[2] as p,
        r[3] as sig
      from regexp_split_to_array(token, '\.') as r
    ),
    jwk as (
      select jwk.*
      from jwt
      inner join auth._jwk as jwk on (jwt.header ->> 'kid')::uuid = jwk.kid
      where jwk._active = true
    ),
    sig as (
      select jwt.sig = auth.jwk_alg_sign(jwk.*, jwt.h || '.' || jwt.p) as ok
      from jwt, jwk
    )
  select
    jwt.header,
    jwt.payload,
    sig.ok and tstzrange(
      to_timestamp(jwt.try_cast_double(jwt.payload ->> 'nbf')),
      to_timestamp(jwt.try_cast_double(jwt.payload ->> 'exp'))
    ) @> current_timestamp as valid
  from jwt, sig;
$$
language sql
security definer
stable
strict;

create type api.grant_type as enum (
  'urn:ietf:params:oauth:grant-type:token-exchange'
);

create type api.token_type as enum (
  'urn:ietf:params:oauth:token-type:jwt'
);

create or replace function
  api.token(
      grant_type api.grant_type,
      subject_token text,
      subject_token_type api.token_type,
      actor_token text = null,
      actor_token_type text = null
  )
returns jsonb
as $$
declare
  role text;
  token text;
begin
  if grant_type != 'urn:ietf:params:oauth:grant-type:token-exchange' then
    raise sqlstate 'PGRST' using
      message = '{"code":"unsupported_grant_type","message":"The authorization grant type is not supported by the authorization server."}',
      detail = '{"status":400,"headers":{"Cache-Control":"no-store","Pragma":"no-cache"}}'
    ;
  end if;

  if subject_token_type != 'urn:ietf:params:oauth:token-type:jwt' then
    raise sqlstate 'PGRST' using
      message = '{"code":"invalid_request","message":"The subject token type is not supported by the authorization server."}',
      detail = '{"status":400,"headers":{"Cache-Control":"no-store","Pragma":"no-cache"}}'
    ;
  end if;

  select 'god' into role
  from public.worker
  inner join public.workerinstance
    on workerid = workerinstanceworkerid
    and workerinstancecustomerid = 0
  where workeridentityid is not null
    and workeridentityid = current_setting('request.jwt.claims')::jsonb ->> 'sub'
  limit 1;

  -- TODO: This needs to consult the entity model, not the legacy model.
  select
    auth.jwt_sign(
      json_build_object(
        'owner', current_setting('request.jwt.claims')::jsonb ->> 'owner',
        'role', coalesce(role, 'authenticated'),
        'scope', string_agg(systagtype, ' '),
        'exp', extract(epoch from now() + '24hr'::interval),
        'iat', extract(epoch from now()),
        'iss', 'urn:tendrel:dev',
        'nbf', extract(epoch from now() - '30s'::interval),
        'sub', current_setting('request.jwt.claims')::jsonb ->> 'sub'
      )
    ) into token
  from public.worker
  left join public.customer
    on customeruuid = current_setting('request.jwt.claims')::jsonb ->> 'owner'
  left join public.workerinstance
    on workerid = workerinstanceworkerid
    and customerid = workerinstancecustomerid
  left join public.systag
    on workerinstanceuserroleid = systagid
  where
    workeridentityid is not null
    and workeridentityid = current_setting('request.jwt.claims')::jsonb ->> 'sub'
    and (workerenddate is null or workerenddate > now())
  ;

  if not found then
    raise exception 'token exchange failed';
  end if;

  return jsonb_build_object(
      'access_token', token,
      'issued_token_type', 'urn:ietf:params:oauth:token-type:jwt',
      'token_type', 'Bearer'
  );
end $$
language plpgsql
security definer;

create or replace function api.token_introspect(token text)
returns jsonb
as $$
  with jwt as (select * from auth.jwt_verify(token))
  select '{"active":false}'
  from jwt
  where jwt.valid = false
  union all
  select '{"active":true}' || jwt.payload::jsonb
  from jwt
  where jwt.valid = true
$$
language sql
immutable
security definer;

COMMIT;
