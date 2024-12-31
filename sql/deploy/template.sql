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
declare
  ins_template text;
begin
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
      -- FIXME: implement scheduling
      true,
      1404,
      -- FIXME: implement audits
      false
  from public.customer, public.location, ins_name
  where customer.customeruuid = customer_id and location.locationuuid = task_parent_id
  returning worktemplate.id into ins_template
  ;
  --
  if not found then
    raise exception 'failed to create template';
  end if;
  --
  return query select worktemplateid as _id, worktemplate.id
               from public.worktemplate
               where worktemplate.id = ins_template
  ;

  return;
end $$
language plpgsql
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
    util.create_template_constraint_on_location(template_id text, location_id text)
returns table(id text)
as $$
begin
  return query insert into public.worktemplateconstraint (
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
                       inner join public.worktemplatetype as tt
                           on t.worktemplateid = tt.worktemplatetypeworktemplateid
                       inner join public.location as l
                           on t.worktemplatesiteid = l.locationsiteid
                           and l.locationuuid = location_id
                       inner join public.custag as lt
                           on l.locationcategoryid = lt.custagid
                       where t.id = template_id
                       returning worktemplateconstraintid as id
  ;

  if not found then
    raise exception 'failed to create template constraint on location';
  end if;

  return;
end $$
language plpgsql
strict
;

create function
    util.create_field_t(
        customer_id text,
        language_type text,
        template_id text,
        field_name text,
        field_type text,
        field_is_primary boolean,
        field_order integer
    )
returns table(id text)
as $$
  with
      ins_name as (
          select *
          from util.create_name(
              customer_id := customer_id,
              source_language := language_type,
              source_text := field_name
          )
      ),

      ins_type as (
          select systagid as _id, systaguuid as id
          from public.systag
          where
              systagparentid = 699
              and systagtype = field_type
      )

  insert into public.workresult (
      workresultcustomerid,
      workresultdefaultvalue,
      workresultentitytypeid,
      workresultforaudit,
      workresultfortask,
      workresultisprimary,
      workresultisrequired,
      workresultlanguagemasterid,
      workresultorder,
      workresultsiteid,
      workresultsoplink,
      workresulttypeid,
      workresultwidgetid,
      workresultworktemplateid
  )
  select
      wt.worktemplatecustomerid,
      null,
      null,
      false,
      true,
      field_is_primary,
      false,
      ins_name._id,
      field_order,
      wt.worktemplatesiteid,
      null,
      ins_type._id,
      null,
      wt.worktemplateid
  from
      public.worktemplate as wt,
      ins_name,
      ins_type
  where wt.id = template_id
  returning id;
$$
language sql
strict
;

create function
    util.create_morphism(prev_template_id text, next_template_id text, type_tag text)
returns table(prev text, next text)
as $$
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
            worktemplatenexttemplatetypeid
        )
        select
            prev.worktemplatecustomerid,
            prev.worktemplatesiteid,
            prev.worktemplateid,
            next.worktemplateid,
            true,
            s.systagid,
            tt.systagid
        from public.worktemplate as prev
        inner join public.worktemplate as next on next.id = next_template_id
        inner join public.systag as s
            on s.systagparentid = 705 and s.systagtype = 'In Progress'
        inner join public.systag as tt
            on tt.systagparentid = 691 and tt.systagtype = type_tag
        where prev.id = prev_template_id
        returning
            worktemplatenexttemplateprevioustemplateid as _prev,
            worktemplatenexttemplatenexttemplateid as _next
    )

    select prev.id as prev, next.id as next
    from cte
    inner join public.worktemplate as prev
        on cte._prev = prev.worktemplateid
    inner join public.worktemplate as next
        on cte._next = next.worktemplateid
  ;

  if not found then
    raise exception 'failed to create morphism';
  end if;

  return;
end $$
language plpgsql
strict
;

commit
;

