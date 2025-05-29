BEGIN;

/*
DROP FUNCTION auth.jwk_alg_sign(auth._jwk,text);
*/


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

END;
