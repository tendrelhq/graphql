
-- Type: FUNCTION ; Name: ast.create_user_type(text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION ast.create_user_type(customer_id text, language_type text, type_name text, type_hierarchy text, modified_by bigint)
 RETURNS TABLE(_id bigint, id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
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
          from i18n.create_localized_content(
              owner := customer_id,
              content := type_name,
              language := language_type
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
end $function$;


REVOKE ALL ON FUNCTION ast.create_user_type(text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION ast.create_user_type(text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION ast.create_user_type(text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;
