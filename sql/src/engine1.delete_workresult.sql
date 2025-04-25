
-- Type: FUNCTION ; Name: engine1.delete_workresult(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.delete_workresult(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.workresult
    set workresultdeleted = true,
        workresultmodifieddate = now(),
        workresultmodifiedby = 895
    where workresult.id in (select value from jsonb_array_elements_text(ctx))
        and workresultdeleted = false
    returning workresult.id
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'deleted', array[cte.id]
    )
  from cte;
$function$;


REVOKE ALL ON FUNCTION engine1.delete_workresult(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_workresult(jsonb) TO tendrelservice;
GRANT EXECUTE ON FUNCTION engine1.delete_workresult(jsonb) TO graphql;
