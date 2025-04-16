
-- Type: FUNCTION ; Name: engine1.delete_workinstance(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.delete_workinstance(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.workinstance
    set workinstancestatusid = 711,
        workinstancetrustreasoncodeid = 765,
        workinstancemodifieddate = now(),
        workinstancemodifiedby = 895
    where workinstance.id in (select value from jsonb_array_elements_text(ctx))
        and workinstance.workinstancestatusid != 711
        and workinstance.workinstancetrustreasoncodeid != 765
    returning workinstance.id
  )
  select
      'engine1.id'::regproc as f,
      jsonb_build_object(
          'ok', true,
          'deleted', array[cte.id]
      )
  from cte;
$function$;


REVOKE ALL ON FUNCTION engine1.delete_workinstance(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_workinstance(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_workinstance(jsonb) TO tendreladmin WITH GRANT OPTION;
