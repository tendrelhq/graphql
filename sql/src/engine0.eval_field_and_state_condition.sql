
-- Type: FUNCTION ; Name: engine0.eval_field_and_state_condition(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.eval_field_and_state_condition(ctx jsonb)
 RETURNS TABLE(ok boolean)
 LANGUAGE sql
 STABLE
AS $function$
  select true as ok
  from
    engine0.eval_field_condition(ctx) as f,
    engine0.eval_state_condition(ctx) as s
  where f.ok and s.ok;
$function$;


REVOKE ALL ON FUNCTION engine0.eval_field_and_state_condition(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_field_and_state_condition(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_field_and_state_condition(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.eval_field_and_state_condition(jsonb) TO graphql;
