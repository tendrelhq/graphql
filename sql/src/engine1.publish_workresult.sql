BEGIN;

/*
DROP FUNCTION engine1.publish_workresult(jsonb);
*/


-- Type: FUNCTION ; Name: engine1.publish_workresult(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.publish_workresult(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.workresult
    set workresultdraft = false,
        workresultmodifieddate = now(),
        workresultmodifiedby = 895
    where id in (select value from jsonb_array_elements_text(ctx))
      and workresultdraft = true
    returning *
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        '_log', 'updated: field.draft',
        'field', cte.id,
        'field.draft', cte.workresultdraft
    )
  from cte
  union all
  select
    'engine1.instantiate_workresult'::regproc,
    jsonb_agg(cte.id)
  from cte;
$function$;


REVOKE ALL ON FUNCTION engine1.publish_workresult(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.publish_workresult(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.publish_workresult(jsonb) TO graphql;

END;
