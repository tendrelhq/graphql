
-- Type: FUNCTION ; Name: runtime.create_customer(text,text,bigint); Owner: bombadil

CREATE OR REPLACE FUNCTION runtime.create_customer(customer_name text, language_type text, modified_by bigint)
 RETURNS TABLE(_id bigint, id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
declare
  ins_customer text;
begin
  with ins_name as (
    select t.*
    from public.customer as c
    cross join
        lateral i18n.create_localized_content(
            owner := c.customeruuid,
            content := customer_name,
            language := language_type
        ) as t
    where c.customerid = 0
  )
  insert into public.customer (
      customername,
      customerlanguagetypeid,
      customerlanguagetypeuuid,
      customernamelanguagemasterid,
      customermodifiedby
  )
  select
      customer_name,
      s.systagid,
      s.systaguuid,
      ins_name._id,
      modified_by
  from ins_name
  inner join public.systag as s on s.systagparentid = 2 and s.systagtype = language_type
  returning customeruuid into ins_customer;
  --
  if not found then
    raise exception 'failed to create customer';
  end if;

  -- update the name to point at the right customer :sigh:
  update public.languagemaster as lm
  set languagemastercustomerid = c.customerid
  from public.customer as c
  where lm.languagemasterid = c.customernamelanguagemasterid
  and c.customeruuid = ins_customer;

  -- create a customerrequestedlanguage
  perform 1
  from i18n.add_language_to_customer(
      customer_id := ins_customer,
      language_code := language_type,
      modified_by := modified_by
  );

  return query select customerid as _id, customeruuid as id
               from public.customer
               where customeruuid = ins_customer;

  return;
end $function$;


REVOKE ALL ON FUNCTION runtime.create_customer(text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION runtime.create_customer(text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION runtime.create_customer(text,text,bigint) TO bombadil WITH GRANT OPTION;
