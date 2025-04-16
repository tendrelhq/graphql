
-- Type: FUNCTION ; Name: engine1.delete_worktemplate(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.delete_worktemplate(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.worktemplate
    set worktemplatedeleted = true,
        worktemplatemodifieddate = now(),
        worktemplatemodifiedby = 895
    where worktemplate.id in (select value from jsonb_array_elements_text(ctx))
        and worktemplate.worktemplatedeleted = false
    returning worktemplate.id, worktemplate.worktemplateid as _id
  )
  select
      'engine1.id'::regproc,
      jsonb_build_object(
          'ok', true,
          'deleted', array[cte.id]
      )
  from cte
  union all
  select
      'engine1.delete_workinstance'::regproc,
      to_jsonb(array_agg(workinstance.id))
  from cte, public.workinstance
  where cte._id = workinstance.workinstanceworktemplateid
      and workinstance.workinstancestatusid in (
          select systagid
          from public.systag
          where systagparentid = 705 and systagtype = 'Open'
      )
  ;
$function$;


REVOKE ALL ON FUNCTION engine1.delete_worktemplate(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_worktemplate(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_worktemplate(jsonb) TO tendreladmin WITH GRANT OPTION;
