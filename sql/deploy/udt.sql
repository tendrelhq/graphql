-- Deploy graphql:udt to pg
begin
;

create function
    util.create_user_type(
        customer_id text, language_type text, type_name text, type_hierarchy text
    )
returns table(_id bigint, id text)
as $$
  with ins_type as (
      insert into public.custag (
        custagcustomerid,
        custagsystagid,
        custagtype
      )
      select
        c.customerid,
        s.systagid,
        type_name
      from public.customer as c, public.systag as s
      where c.customeruuid = customer_id and s.systagtype = type_hierarchy
      on conflict do nothing
      returning custagid as _id, custaguuid as id
  )

  select *
  from ins_type
  union all
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
$$
language sql
strict
;

create function util.create_type(type_name text)
returns table(_id bigint, id text)
as $$
begin
  if type_name is null then
    raise exception 'util.create_type: type_name must not be null';
  end if;

  return query
    with ins_name as (
        select t.*
        from public.customer as c
        cross join
            lateral util.create_name(
                customer_id := c.customeruuid,
                source_language := 'en',
                source_text := type_name
            ) as t
        where c.customerid = 0
    )
    insert into public.systag (
        systagcustomerid,
        systagparentid,
        systagtype,
        systagnameid
    )
    select
        0,
        1,
        type_name,
        ins_name._id
    from ins_name
    returning systagid as _id, systaguuid as id
  ;
  --
  if not found then
    raise exception 'failed to create type';
  end if;

  return;
end $$
language plpgsql
;

commit
;

