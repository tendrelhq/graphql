
-- Type: FUNCTION ; Name: engine0.eval_state_condition(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.eval_state_condition(ctx jsonb)
 RETURNS TABLE(ok boolean)
 LANGUAGE sql
 STABLE
AS $function$
  select true as ok
  from jsonb_to_record(ctx) as args (state text, task text)
  inner join public.workinstance as i on args.task = i.id
  inner join public.systag as s
    on i.workinstancestatusid = s.systagid
    and args.state = s.systagtype
  ;
$function$;


REVOKE ALL ON FUNCTION engine0.eval_state_condition(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_state_condition(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_state_condition(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.eval_state_condition(jsonb) TO graphql;
