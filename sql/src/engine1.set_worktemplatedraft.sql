
-- Type: FUNCTION ; Name: engine1.set_worktemplatedraft(jsonb); Owner: bombadil

CREATE OR REPLACE FUNCTION engine1.set_worktemplatedraft(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.worktemplate
    set worktemplatedraft = args.enabled,
        worktemplatemodifieddate = now(),
        worktemplatemodifiedby = 895
    from jsonb_to_recordset(ctx) as args (id text, enabled boolean)
    where worktemplate.id = args.id
      and worktemplatedraft = true
      and worktemplatedraft is distinct from args.enabled
    returning worktemplate.id, worktemplateid as _id
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'count', count(*),
        'updated', jsonb_agg(jsonb_build_object('node', cte.id))
    )
  from cte
  union all
  select
    'engine1.instantiate_worktemplate'::regproc,
    jsonb_agg(cte.id)
  from cte;
$function$;


REVOKE ALL ON FUNCTION engine1.set_worktemplatedraft(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.set_worktemplatedraft(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.set_worktemplatedraft(jsonb) TO bombadil WITH GRANT OPTION;
