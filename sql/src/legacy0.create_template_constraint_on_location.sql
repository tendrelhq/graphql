
-- Type: FUNCTION ; Name: legacy0.create_template_constraint_on_location(text,text,bigint); Owner: bombadil

CREATE OR REPLACE FUNCTION legacy0.create_template_constraint_on_location(template_id text, location_id text, modified_by bigint)
 RETURNS TABLE(id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    with ins as (
        insert into public.worktemplateconstraint (
            worktemplateconstraintcustomerid,
            worktemplateconstraintcustomeruuid,
            worktemplateconstrainttemplateid,
            worktemplateconstraintconstrainedtypeid,
            worktemplateconstraintconstraintid,
            worktemplateconstraintmodifiedby
        )
        select
            c.customerid,
            c.customeruuid,
            t.id,
            s.systaguuid,
            lt.custaguuid,
            modified_by
        from public.worktemplate as t
        inner join public.customer as c
            on t.worktemplatecustomerid = c.customerid
        inner join public.systag as s
            on s.systagparentid = 849 and s.systagtype = 'Location'
        inner join public.location as l
            on t.worktemplatesiteid = l.locationsiteid
            and l.locationuuid = location_id
        inner join public.custag as lt
            on l.locationcategoryid = lt.custagid
        where t.id = template_id
        on conflict do nothing
        returning worktemplateconstraintid as id
    )

    select * from ins
    union all
    select wtc.worktemplateconstraintid as id
    from public.worktemplateconstraint as wtc
    inner join public.worktemplate as t
        on t.id = template_id
        and wtc.worktemplateconstrainttemplateid = t.id
    inner join public.location as l
        on t.worktemplatesiteid = l.locationsiteid
        and l.locationuuid = location_id
    where
        wtc.worktemplateconstraintconstrainedtypeid = (
            select systaguuid
            from public.systag
            where systagparentid = 849 and systagtype = 'Location'
        )
        and wtc.worktemplateconstraintconstraintid = (
            select custaguuid
            from public.custag
            where custagid = l.locationcategoryid
        )
    limit 1
  ;

  if not found then
    raise exception 'failed to create template constraint on location';
  end if;

  return;
end $function$;

COMMENT ON FUNCTION legacy0.create_template_constraint_on_location(text,text,bigint) IS '

# legacy0.create_template_constraint_on_location

Create a template constraint that indicates that the given template can be
instantiated at the given location.

';

REVOKE ALL ON FUNCTION legacy0.create_template_constraint_on_location(text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_template_constraint_on_location(text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_template_constraint_on_location(text,text,bigint) TO bombadil WITH GRANT OPTION;
