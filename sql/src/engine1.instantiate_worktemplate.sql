
-- Type: FUNCTION ; Name: engine1.instantiate_worktemplate(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.instantiate_worktemplate(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
 STABLE
AS $function$
  select
    'engine1.instantiate'::regproc,
    jsonb_agg(
      jsonb_build_object(
          'template_id', worktemplate.id,
          'location_id', location.locationuuid,
          'target_state', 'Open',
          'target_type', 'On Demand'
          -- 'chain_root_id', null,
          -- 'chain_prev_id', null
      )
    )
  from public.worktemplate
  inner join public.worktemplateconstraint
    on worktemplate.id = worktemplateconstrainttemplateid
    and worktemplateconstraintconstrainedtypeid = (
        select systaguuid
        from public.systag
        where systagparentid = 849 and systagtype = 'Location'
    )
  inner join public.custag on worktemplateconstraintconstraintid = custaguuid
  inner join public.location
    on worktemplatesiteid = locationsiteid
    and custagid = locationcategoryid
  where
    worktemplate.id in (select value from jsonb_array_elements_text(ctx))
    and worktemplatedeleted = false
    and worktemplatedraft = false
    and (worktemplateenddate is null or worktemplateenddate > now())
$function$;


REVOKE ALL ON FUNCTION engine1.instantiate_worktemplate(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate_worktemplate(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate_worktemplate(jsonb) TO tendreladmin WITH GRANT OPTION;
