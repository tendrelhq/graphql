
-- Type: FUNCTION ; Name: runtime.create_demo(text,text[],bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION runtime.create_demo(customer_name text, admins text[], modified_by bigint)
 RETURNS TABLE(op text, id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
declare
  default_language_type text := 'en';
  default_user_role text := 'Admin';
  default_timezone text := 'UTC';
  --
  ins_customer text;
begin
  select t.id into ins_customer
  from
      runtime.create_customer(
          customer_name := customer_name,
          language_type := default_language_type,
          modified_by := modified_by
      ) as t
  ;
  --
  return query select '+customer', ins_customer;

  return query
    select ' +worker', t.id
    from
        public.worker as w,
        legacy0.create_worker(
            customer_id := ins_customer,
            user_id := w.workeruuid,
            user_role := default_user_role,
            modified_by := modified_by
        ) as t
    where w.workeruuid = any(admins)
  ;
  --
  if not found and array_length(admins, 1) > 0 then
    raise exception 'failed to create admin workers';
  end if;

  return query
    select *
    from runtime.add_demo_to_customer(
        customer_id := ins_customer,
        language_type := default_language_type,
        modified_by := modified_by,
        timezone := default_timezone
    )
  ;
  --
  if not found then
    raise exception 'failed to add runtime to customer';
  end if;

  return;
end $function$;


REVOKE ALL ON FUNCTION runtime.create_demo(text,text[],bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION runtime.create_demo(text,text[],bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION runtime.create_demo(text,text[],bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION runtime.create_demo(text,text[],bigint) TO graphql;
