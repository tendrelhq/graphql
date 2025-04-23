
-- Type: FUNCTION ; Name: legacy0.create_instantiation_rule_v2(text,text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_instantiation_rule_v2(
  prev_template_id text,
  next_template_id text,
  state_condition text,
  type_tag text,
  prev_location_id text,
  next_location_id text,
  modified_by bigint
)
 RETURNS TABLE(prev text, next text)
 LANGUAGE plpgsql
AS $function$
begin
  return query
    with cte as (
        insert into public.worktemplatenexttemplate(
            worktemplatenexttemplatecustomerid,
            worktemplatenexttemplatesiteid,
            worktemplatenexttemplateprevioustemplateid,
            worktemplatenexttemplatenexttemplateid,
            worktemplatenexttemplateviastatuschange,
            worktemplatenexttemplateviastatuschangeid,
            worktemplatenexttemplatetypeid,
            worktemplatenexttemplatemodifiedby,
            worktemplatenexttemplateprevlocationid,
            worktemplatenexttemplatenextlocationid
        )
        select
            prev.worktemplatecustomerid,
            prev.worktemplatesiteid,
            prev.worktemplateid,
            next.worktemplateid,
            true,
            s.systagid,
            tt.systagid,
            modified_by,
            pl.locationuuid,
            nl.locationuuid
        from public.worktemplate as prev
        inner join public.worktemplate as next on next.id = next_template_id
        inner join public.systag as s
            on s.systagparentid = 705 and s.systagtype = state_condition
        inner join public.systag as tt
            on tt.systagparentid = 691 and tt.systagtype = type_tag
        left join public.location as pl on pl.locationuuid = prev_location_id
        left join public.location as nl on nl.locationuuid = next_location_id
        where prev.id = prev_template_id
        returning
            worktemplatenexttemplateprevioustemplateid as _prev,
            worktemplatenexttemplatenexttemplateid as _next
    )

    select prev.id as prev, next.id as next
    from cte
    inner join public.worktemplate as prev on cte._prev = prev.worktemplateid
    inner join public.worktemplate as next on cte._next = next.worktemplateid
  ;

  if not found then
    raise exception 'failed to create instantiation rule';
  end if;

  return;
end $function$;

revoke all on function legacy0.create_instantiation_rule_v2 from public;
grant execute on function legacy0.create_instantiation_rule_v2 to graphql;
