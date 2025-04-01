-- Deploy graphql:token-exchange to pg

BEGIN;

create role anonymous nologin;
create role authenticated nologin;
create role god nologin bypassrls; -- 'god mode'

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'graphql') then
    grant anonymous to graphql;
    grant authenticated to graphql;
    grant god to graphql;
  end if;
end $$;

create or replace function _api.parse_accept_language(accept_language text)
returns table(tag text, quality float)
as $$
declare
  v_parts text[];
  v_part text;
  v_language text;
  v_quality text;
  v_language_parts text[];
begin
  if nullif(accept_language, '') is null then
    tag := 'en';
    quality := 1.0;
    return next;
    return;
  end if;

  v_parts := string_to_array(accept_language, ',');

  foreach v_part in array v_parts loop
    v_part := trim(v_part);
    v_quality := 1.0;
    v_language_parts := string_to_array(v_part, ';');
    v_language := trim(v_language_parts[1]);
    if array_length(v_language_parts, 1) > 1 then
      v_quality := substring(trim(v_language_parts[2]) FROM 'q=([0-9]*\.?[0-9]+)');
      if nullif(v_quality, '') is null then
        v_quality := 1.0;
      end if;
    end if;

    tag := lower(v_language);
    quality := v_quality;
    return next;
  end loop;

  return;
end $$
language plpgsql
immutable
security definer; --> this is the new bit

create type api.grant_type as enum (
  'urn:ietf:params:oauth:grant-type:token-exchange'
);

grant usage on type api.grant_type to anonymous, authenticated, god;

create type api.token_type as enum (
  'urn:ietf:params:oauth:token-type:jwt'
);

grant usage on type api.token_type to anonymous, authenticated, god;

-- TODO: Move app.jwt_secret to a private/internal table.
-- TODO: Encode the "customer" somehow into the JWT. The assumption is the
-- client will exchange its token when "switching customers".
-- TODO: Utilize the actor_token parameters to verify the (OAuth) application.
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
    jwt.sign(
      payload := json_build_object(
          'owner', current_setting('request.jwt.claims')::jsonb ->> 'owner',
          'role', coalesce(role, 'authenticated'),
          'scope', string_agg(systagtype, ' '),
          'exp', extract(epoch from now() + '24hr'::interval),
          'iat', extract(epoch from now()),
          'iss', 'urn:tendrel:' || current_setting('app.stage'),
          'nbf', extract(epoch from now() - '30s'::interval),
          'sub', current_setting('request.jwt.claims')::jsonb ->> 'sub'
      ),
      secret := current_setting('app.jwt_secret'),
      algorithm := 'HS256'
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

  return jsonb_build_object(
      'access_token', token,
      'issued_token_type', 'urn:ietf:params:oauth:token-type:jwt',
      'token_type', 'Bearer'
  );
end $$
language plpgsql
security definer;

grant execute on function api.token to anonymous, authenticated, god;

create or replace function api.token_introspect(token text)
returns jsonb
as $$
  with cte as (
    select *
    from jwt.verify(token, current_setting('app.jwt_secret'), 'HS256')
  )
  select '{"active":false}'
  from cte
  where cte.valid = false
  union all
  select '{"active":true}' || cte.payload::jsonb
  from cte
  where cte.valid = true
$$
language sql
immutable
security definer;

grant execute on function api.token_introspect to authenticated, god;

COMMIT;
