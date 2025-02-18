-- Deploy graphql:create-user-type to pg
begin
;

create or replace function
    ast.create_user_type(
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
          from public.create_name(
              customer_id := customer_id,
              source_language := language_type,
              source_text := type_name,
              modified_by := modified_by
          )
      )

      insert into public.custag (
          custagcustomerid,
          custagcustomeruuid,
          custagsystagid,
          custagsystaguuid,
          custagtype,
          custagnameid,
          custagmodifiedby
      )
      select
          c.customerid,
          c.customeruuid,
          s.systagid,
          s.systaguuid,
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

commit
;
