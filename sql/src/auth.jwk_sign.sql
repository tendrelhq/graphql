
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
$function$;


REVOKE ALL ON FUNCTION auth.jwk_sign(auth._jwk,json) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION auth.jwk_sign(auth._jwk,json) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION auth.jwk_sign(auth._jwk,json) TO graphql;
