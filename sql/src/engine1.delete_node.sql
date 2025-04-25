
-- Type: FUNCTION ; Name: engine1.delete_node(text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.delete_node(kind text, id text)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with op (kind, id) as (values (kind, id))
  select
      'engine1.delete_workresult'::regproc,
      jsonb_agg(workresult.id)
  from op, public.workresult
  where op.kind = 'workresult' and op.id = workresult.id
  union all
  select
      'engine1.delete_worktemplate'::regproc,
      jsonb_agg(worktemplate.id)
  from op, public.worktemplate
  where op.kind = 'worktemplate' and op.id = worktemplate.id
  union all
  select
      'engine1.delete_workresultinstance'::regproc,
      jsonb_agg(wri.workresultinstanceuuid)
  from op, public.workresultinstance as wri
  where op.kind = 'workresultinstance' and op.id = wri.workresultinstanceuuid
  union all
  select
      'engine1.delete_workinstance'::regproc,
      jsonb_agg(workinstance.id)
  from op, public.workinstance
  where op.kind = 'workinstance' and op.id = workinstance.id;
$function$;


REVOKE ALL ON FUNCTION engine1.delete_node(text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_node(text,text) TO tendrelservice;
GRANT EXECUTE ON FUNCTION engine1.delete_node(text,text) TO graphql;
