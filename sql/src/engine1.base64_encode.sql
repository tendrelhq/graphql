
-- Type: FUNCTION ; Name: engine1.base64_encode(bytea); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.base64_encode(data bytea)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select translate(encode(data, 'base64'), E'+/e\n', '-_');
$function$;


REVOKE ALL ON FUNCTION engine1.base64_encode(bytea) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.base64_encode(bytea) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.base64_encode(bytea) TO tendreladmin WITH GRANT OPTION;
