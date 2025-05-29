BEGIN;

/*
ALTER TABLE auth._jwk ALTER _version DROP DEFAULT;
DROP FUNCTION auth.jwk_sign(auth._jwk,json);
DROP FUNCTION auth.jwk_alg_sign(auth._jwk,text);
DROP FUNCTION auth.extract_signing_key(auth._jwk);
DROP SEQUENCE IF EXISTS auth._jwk__version_seq;
DROP FUNCTION auth.set_actor(text,text,boolean);
DROP FUNCTION auth.jwt_verify(text);
DROP FUNCTION auth.jwt_sign(json);
DROP TABLE auth._jwk; --==>> !!! ATTENTION !!! <<==--
DROP FUNCTION auth.current_identity(bigint,text);

DROP SCHEMA auth;
*/

CREATE SCHEMA auth;

GRANT USAGE ON SCHEMA auth TO graphql;

-- DEPENDANTS


-- Type: FUNCTION ; Name: auth.current_identity(bigint,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION auth.current_identity(parent bigint, identity text)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$
  select workerinstanceid
  from public.workerinstance
  inner join public.worker
      on  workerinstanceworkerid = workerid
      and workeridentityid = identity
  where workerinstancecustomerid = parent
$function$;

COMMENT ON FUNCTION auth.current_identity(bigint,text) IS '

# auth.current_identity

Returns the (big)serial primary key that corresponds to the given [customer, user] pair.

## usage

```sql
update location
set locationmodifiedby = auth.current_identity(locationcustomerid, $1)
where locationid = $2
```

';

REVOKE ALL ON FUNCTION auth.current_identity(bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION auth.current_identity(bigint,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION auth.current_identity(bigint,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION auth.current_identity(bigint,text) TO graphql;

-- Type: TABLE ; Name: _jwk; Owner: tendreladmin

CREATE TABLE auth._jwk (
    kid uuid NOT NULL,
    kty text NOT NULL,
    use text,
    alg text,
    params jsonb,
    _active boolean NOT NULL,
    _description text,
    _version integer NOT NULL
);


ALTER TABLE auth._jwk ALTER kid SET DEFAULT gen_random_uuid();
ALTER TABLE auth._jwk ALTER _active SET DEFAULT true;

CREATE SEQUENCE IF NOT EXISTS auth._jwk__version_seq;
ALTER SEQUENCE auth._jwk__version_seq OWNED BY auth._jwk._version;

ALTER TABLE auth._jwk ADD CONSTRAINT _jwk__version_key UNIQUE (_version);
ALTER TABLE auth._jwk ADD CONSTRAINT _jwk_pkey PRIMARY KEY (kid);


-- Type: FUNCTION ; Name: auth.jwt_sign(json); Owner: tendreladmin

CREATE OR REPLACE FUNCTION auth.jwt_sign(payload json)
 RETURNS text
 LANGUAGE sql
 STABLE STRICT SECURITY DEFINER
AS $function$
  select auth.jwk_sign(jwk.*, payload)
  from auth._jwk as jwk
  where _active
  order by _version desc
  limit 1;
$function$;


REVOKE ALL ON FUNCTION auth.jwt_sign(json) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION auth.jwt_sign(json) TO PUBLIC;
GRANT EXECUTE ON FUNCTION auth.jwt_sign(json) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION auth.jwt_sign(json) TO graphql;

-- Type: FUNCTION ; Name: auth.jwt_verify(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION auth.jwt_verify(token text)
 RETURNS TABLE(header json, payload json, valid boolean)
 LANGUAGE sql
 STABLE STRICT SECURITY DEFINER
AS $function$
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
$function$;


REVOKE ALL ON FUNCTION auth.jwt_verify(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION auth.jwt_verify(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION auth.jwt_verify(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION auth.jwt_verify(text) TO graphql;

-- Type: FUNCTION ; Name: auth.set_actor(text,text,boolean); Owner: tendreladmin

CREATE OR REPLACE FUNCTION auth.set_actor(actor_id text, actor_locale text, is_local boolean DEFAULT true)
 RETURNS TABLE(id text, locale text)
 LANGUAGE plpgsql
AS $function$
declare
  user_id bigint;
begin
  select workerid into user_id
  from public.worker
  where workeridentityid = actor_id;
  --
  if not found then
    raise exception 'unauthenticated';
    return;
  end if;

  return query
    with
        user_locale as (
            select systagtype as locale
            from public.systag
            where systagid = (
                select workerlanguageid
                from public.worker
                where workerid = user_id
            )
        ),

        request_locale as (
            select systagtype as locale
            from public.systag
            where systagparentid = 2 and systagtype = actor_locale
        )

    select
        set_config('user.id', actor_id, is_local) as id,
        set_config('user.locale', coalesce(r.locale, u.locale), is_local) as locale
    from user_locale u, request_locale r
  ;

  if not found then
    raise exception 'invalid locale: %', actor_locale;
  end if;

  return;
end $function$;


REVOKE ALL ON FUNCTION auth.set_actor(text,text,boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION auth.set_actor(text,text,boolean) TO PUBLIC;
GRANT EXECUTE ON FUNCTION auth.set_actor(text,text,boolean) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION auth.set_actor(text,text,boolean) TO graphql;

-- Type: SEQUENCE ; Name: _jwk__version_seq; Owner: tendreladmin

CREATE SEQUENCE auth._jwk__version_seq;


ALTER SEQUENCE auth._jwk__version_seq
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647
 START WITH 1
 NO CYCLE;

-- Type: FUNCTION ; Name: auth.extract_signing_key(auth._jwk); Owner: tendreladmin

CREATE OR REPLACE FUNCTION auth.extract_signing_key(jwk auth._jwk)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
begin
  if jwk.kty = 'oct' then
    return jwk.params ->> 'k';
  end if;

  raise exception 'unknown kty % for jwk with kid: %', jwk.kty, jwk.kid;
end $function$;


REVOKE ALL ON FUNCTION auth.extract_signing_key(auth._jwk) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION auth.extract_signing_key(auth._jwk) TO PUBLIC;
GRANT EXECUTE ON FUNCTION auth.extract_signing_key(auth._jwk) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION auth.extract_signing_key(auth._jwk) TO graphql;

-- Type: FUNCTION ; Name: auth.jwk_alg_sign(auth._jwk,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION auth.jwk_alg_sign(jwk auth._jwk, signables text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
  select jwt.algorithm_sign(signables, jwk.params ->> 'k', jwk.alg);
$function$;


REVOKE ALL ON FUNCTION auth.jwk_alg_sign(auth._jwk,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION auth.jwk_alg_sign(auth._jwk,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION auth.jwk_alg_sign(auth._jwk,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION auth.jwk_alg_sign(auth._jwk,text) TO graphql;

-- Type: FUNCTION ; Name: auth.jwk_sign(auth._jwk,json); Owner: tendreladmin

CREATE OR REPLACE FUNCTION auth.jwk_sign(jwk auth._jwk, payload json)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
  with
    header as (
      select jwt.base64_encode(
        convert_to(
          json_build_object('alg', jwk.alg, 'kid', jwk.kid, 'typ', 'JWT')::text,
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
$function$;


REVOKE ALL ON FUNCTION auth.jwk_sign(auth._jwk,json) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION auth.jwk_sign(auth._jwk,json) TO PUBLIC;
GRANT EXECUTE ON FUNCTION auth.jwk_sign(auth._jwk,json) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION auth.jwk_sign(auth._jwk,json) TO graphql;
ALTER TABLE auth._jwk ALTER _version SET DEFAULT nextval('auth._jwk__version_seq'::regclass);

END;
