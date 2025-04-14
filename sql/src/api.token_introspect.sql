
-- Type: FUNCTION ; Name: api.token_introspect(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.token_introspect(token text)
 RETURNS jsonb
 LANGUAGE sql
 IMMUTABLE SECURITY DEFINER
AS $function$
  with jwt as (select * from auth.jwt_verify(token))
  select '{"active":false}'
  from jwt
  where jwt.valid = false
  union all
  select '{"active":true}' || jwt.payload::jsonb
  from jwt
  where jwt.valid = true
$function$;


REVOKE ALL ON FUNCTION api.token_introspect(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.token_introspect(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION api.token_introspect(text) TO tendreladmin WITH GRANT OPTION;
