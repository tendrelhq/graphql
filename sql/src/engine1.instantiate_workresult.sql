
-- Type: FUNCTION ; Name: engine1.instantiate_workresult(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.instantiate_workresult(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    insert into public.workresultinstance (
        workresultinstancecustomerid,
        workresultinstanceworkinstanceid,
        workresultinstanceworkresultid,
        workresultinstancestartdate,
        workresultinstancecompleteddate,
        workresultinstancevalue,
        workresultinstancetimezone,
        workresultinstancemodifiedby
    )
    select
      workinstance.workinstancecustomerid,
      workinstance.workinstanceid,
      workresult.workresultid,
      workinstance.workinstancestartdate,
      workinstance.workinstancecompleteddate,
      workresult.workresultdefaultvalue,
      workinstance.workinstancetimezone,
      auth.current_identity(
          parent := workresult.workresultcustomerid,
          identity := current_setting('user.id')
      ) as modified_by
    from public.workresult
    inner join public.workinstance
        on workresultworktemplateid = workinstanceworktemplateid
    where
      workresult.id in (select value from jsonb_array_elements_text(ctx))
      and workresult.workresultdeleted = false
      and workresult.workresultdraft = false
      and (
          workresult.workresultenddate is null
          or workresult.workresultenddate > now()
      )
      and workinstance.workinstancestatusid = (
          select systagid
          from public.systag
          where systagparentid = 705 and systagtype = 'Open'
      )
    on conflict do nothing
    returning workresultinstanceuuid as id
  )

  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', count(*) > 0,
        'count', count(*),
        'created', coalesce(
          jsonb_agg(jsonb_build_object('node', cte.id)),
          '[]'::jsonb
        )
    )
  from cte
$function$;


REVOKE ALL ON FUNCTION engine1.instantiate_workresult(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate_workresult(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate_workresult(jsonb) TO tendreladmin WITH GRANT OPTION;
