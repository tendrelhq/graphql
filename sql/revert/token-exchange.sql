-- Deploy graphql:token-exchange to pg

BEGIN;

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

COMMIT;
