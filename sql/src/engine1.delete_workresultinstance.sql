
-- Type: FUNCTION ; Name: engine1.delete_workresultinstance(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.delete_workresultinstance(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select
      'engine1.id'::regproc,
      jsonb_build_object(
          'ok', true,
          'deleted', array_agg(distinct nodes.value)
      )
  from jsonb_array_elements_text(ctx) as nodes
$function$;


REVOKE ALL ON FUNCTION engine1.delete_workresultinstance(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_workresultinstance(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_workresultinstance(jsonb) TO tendreladmin WITH GRANT OPTION;
