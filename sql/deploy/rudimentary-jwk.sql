-- Deploy graphql:rudimentary-jwk to pg

BEGIN;

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

revoke all on table auth._jwk from public, anonymous, authenticated, god;

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

COMMIT;
