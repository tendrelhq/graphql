
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

  raise exception 'unknown kty "%" for jwk with kid: %', jwk.kty, jwk.kid;
end $function$;


REVOKE ALL ON FUNCTION auth.extract_signing_key(auth._jwk) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION auth.extract_signing_key(auth._jwk) TO PUBLIC;
GRANT EXECUTE ON FUNCTION auth.extract_signing_key(auth._jwk) TO tendreladmin WITH GRANT OPTION;
