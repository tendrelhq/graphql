
-- Type: FUNCTION ; Name: engine1.base64_decode(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.base64_decode(data text)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$
  with
    t as (select translate(data, '-_', '+/') as trans),
    rem as (select length(t.trans) % 4 as remainder from t) -- compute padding size
  select decode(
      t.trans ||
        case when rem.remainder > 0 then repeat('=', (4 - rem.remainder)) else '' end,
      'base64'
  ) from t, rem;
$function$;


REVOKE ALL ON FUNCTION engine1.base64_decode(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.base64_decode(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.base64_decode(text) TO tendreladmin WITH GRANT OPTION;
