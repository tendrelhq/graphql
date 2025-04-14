
-- Type: FUNCTION ; Name: api.token(api.grant_type,text,api.token_type,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.token(grant_type api.grant_type, subject_token text, subject_token_type api.token_type, actor_token text DEFAULT NULL::text, actor_token_type text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
        'iss', 'urn:tendrel:test',
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
end $function$;


REVOKE ALL ON FUNCTION api.token(api.grant_type,text,api.token_type,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.token(api.grant_type,text,api.token_type,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION api.token(api.grant_type,text,api.token_type,text,text) TO tendreladmin WITH GRANT OPTION;
