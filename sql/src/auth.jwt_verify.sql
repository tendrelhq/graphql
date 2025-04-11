
-- Type: FUNCTION ; Name: auth.jwt_verify(text); Owner: bombadil

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
GRANT EXECUTE ON FUNCTION auth.jwt_verify(text) TO bombadil WITH GRANT OPTION;
