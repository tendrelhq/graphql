
-- Type: FUNCTION ; Name: ast.create_system_type(text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION ast.create_system_type(type_name text, type_hierarchy text, modified_by bigint)
 RETURNS TABLE(_id bigint, id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    with ins_name as (
        select t.*
        from
            public.customer as c,
            i18n.create_localized_content(
                owner := c.customeruuid,
                content := type_name,
                language := 'en'
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
end $function$;


REVOKE ALL ON FUNCTION ast.create_system_type(text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION ast.create_system_type(text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION ast.create_system_type(text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION ast.create_system_type(text,text,bigint) TO graphql;
