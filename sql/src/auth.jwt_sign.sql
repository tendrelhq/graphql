BEGIN;

/*
DROP FUNCTION auth.jwt_sign(json);
*/


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

END;
