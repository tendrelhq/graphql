-- Deploy graphql:template to pg
-- requires: name
begin
;

create function
    util.create_task_t(
        customer_id text, language_type text, task_name text, task_parent_id text
    )
returns table(_id bigint, id text)
as $$
  with ins_name as (
    select *
    from util.create_name (
      customer_id := customer_id,
      source_language := language_type,
      source_text := task_name
    )
  )
  insert into public.worktemplate (
    worktemplatecustomerid,
    worktemplatesiteid,
    worktemplatenameid,
    worktemplateallowondemand,
    worktemplateworkfrequencyid,
    worktemplateisauditable
  )
  select
    customer.customerid,
    location.locationid,
    ins_name._id,
    -- FIXME: implement scheduling, auditing
    true,
    1404,
    false
  from public.customer, public.location, ins_name
  where customer.customeruuid = customer_id and location.locationuuid = task_parent_id
  returning worktemplate.worktemplateid as _id, worktemplate.id
  ;
$$
language sql
strict
;

create function util.create_template_type(template_id text, systag_id text)
returns table(id text)
as $$
  insert into public.worktemplatetype (
      worktemplatetypecustomerid,
      worktemplatetypeworktemplateuuid,
      worktemplatetypeworktemplateid,
      worktemplatetypesystaguuid,
      worktemplatetypesystagid
  )
  select
      t.worktemplatecustomerid,
      t.id,
      t.worktemplateid,
      tt.systaguuid,
      tt.systagid
  from public.worktemplate as t, public.systag as tt
  where t.id = template_id and tt.systaguuid = systag_id
  returning worktemplatetypeuuid as id
$$
language sql
strict
;

create function
    util.create_template_constraint_foreach_child_location(
        template_id text, location_parent_id text
    )
returns table(id text)
as
    $$
  insert into public.worktemplateconstraint (
      worktemplateconstraintcustomerid,
      worktemplateconstrainttemplateid,
      worktemplateconstraintconstrainedtypeid,
      worktemplateconstraintconstraintid
  )
  select
      t.worktemplatecustomerid,
      t.id,
      tt.worktemplatetypesystaguuid,
      lt.custaguuid
  from public.worktemplate as t
  inner join public.worktemplatetype as tt on t.worktemplateid = tt.worktemplatetypeworktemplateid
  inner join public.location as l
      on t.worktemplatesiteid = l.locationsiteid
      and l.locationparentid = (
          select p.locationid
          from public.location as p
          where p.locationuuid = location_parent_id
      )
  inner join public.custag as lt on l.locationcategoryid = lt.custagid
  where t.id = template_id
  returning worktemplateconstraintid as id
  ;
$$
language sql
strict
;

commit
;

