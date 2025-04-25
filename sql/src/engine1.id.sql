
-- Type: FUNCTION ; Name: engine1.id(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.id(jsonb)
 RETURNS SETOF jsonb
 LANGUAGE sql
 IMMUTABLE
AS $function$select $1$function$;


REVOKE ALL ON FUNCTION engine1.id(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.id(jsonb) TO tendrelservice;
GRANT EXECUTE ON FUNCTION engine1.id(jsonb) TO graphql;
