-- Deploy graphql:udt to pg
-- requires: name
begin
;

create function
    util.create_user_type(
        customer_id text,
        language_type text,
        type_name text,
        type_hierarchy text,
        modified_by bigint
    )
returns table(_id bigint, id text)
as $$
begin
  return query
    select custagid as _id, custaguuid as id
    from public.custag
    where
        custagcustomerid = (
            select customerid
            from public.customer
            where customeruuid = customer_id
        )
        and custagsystagid = (
            select systagid
            from public.systag
            where systagtype = type_hierarchy
        )
        and custagtype = type_name
  ;

  if not found then
    return query
      with ins_name as (
          select *
          from util.create_name(
              customer_id := customer_id,
              source_language := language_type,
              source_text := type_name,
              modified_by := modified_by
          )
      )

      insert into public.custag (
          custagcustomerid,
          custagsystagid,
          custagtype,
          custagnameid,
          custagmodifiedby
      )
      select
          c.customerid,
          s.systagid,
          type_name,
          ins_name._id,
          modified_by
      from public.customer as c, public.systag as s, ins_name
      where c.customeruuid = customer_id and s.systagtype = type_hierarchy
      returning custagid as _id, custaguuid as id
    ;
  end if;

  return;
end $$
language plpgsql
strict
;

create function
    util.create_type(type_name text, type_hierarchy text, modified_by bigint)
returns table(_id bigint, id text)
as $$
begin
  if type_name is null then
    raise exception 'util.create_type: type_name must not be null';
  end if;

  return query
    with ins_name as (
        select t.*
        from
            public.customer as c,
            util.create_name(
                customer_id := c.customeruuid,
                source_language := 'en',
                source_text := type_name,
                modified_by := modified_by
            ) as t
        where c.customerid = 0
    )
    insert into public.systag (
        systagcustomerid,
        systagparentid,
        systagtype,
        systagnameid,
        systagmodifiedby
    )
    select
        0 as customer, -- 'Tendrel'
        p.systagid,
        type_name,
        ins_name._id,
        modified_by
    from ins_name
    inner join public.systag as p on p.systagtype = type_hierarchy
    returning systagid as _id, systaguuid as id
  ;
  --
  if not found then
    raise exception 'failed to create type';
  end if;

  return;
end $$
language plpgsql
strict
;

commit
;
