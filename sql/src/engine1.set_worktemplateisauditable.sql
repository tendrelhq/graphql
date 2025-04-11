
-- Type: FUNCTION ; Name: engine1.set_worktemplateisauditable(jsonb); Owner: bombadil

CREATE OR REPLACE FUNCTION engine1.set_worktemplateisauditable(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.worktemplate
    set worktemplateisauditable = args.enabled,
        worktemplatemodifieddate = now(),
        worktemplatemodifiedby = auth.current_identity(worktemplatecustomerid, current_setting('user.id'))
    from jsonb_to_recordset(ctx) as args (id text, enabled boolean)
    where worktemplate.id = args.id
      and worktemplateisauditable is distinct from args.enabled
    returning worktemplate.id
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'count', count(*),
        'updated', jsonb_agg(jsonb_build_object('node', cte.id))
    )
  from cte;
$function$;


REVOKE ALL ON FUNCTION engine1.set_worktemplateisauditable(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.set_worktemplateisauditable(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.set_worktemplateisauditable(jsonb) TO bombadil WITH GRANT OPTION;
