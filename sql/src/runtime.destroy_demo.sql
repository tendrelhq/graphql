
-- Type: FUNCTION ; Name: runtime.destroy_demo(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION runtime.destroy_demo(customer_id text)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
declare
  _customer_id bigint;
begin
  select customerid into _customer_id
  from public.customer
  where customeruuid = customer_id;

  -- FIXME: CASCADE deletes.
  delete from public.apikey
  where apikeycustomerid = _customer_id;

  -- FIXME: CASCADE deletes.
  delete from public.customerconfig
  where customerconfigcustomeruuid = customer_id;

  delete from public.workdescription
  where workdescriptioncustomerid = _customer_id;

  -- FIXME: CASCADE deletes.
  delete from public.worktemplateconstraint
  where worktemplateconstraintcustomerid = _customer_id;

  -- FIXME: CASCADE deletes.
  delete from public.worktemplatetype
  where worktemplatetypecustomerid = _customer_id;

  delete from public.customer
  where customeruuid = customer_id;

  return 'ok';
end $function$;


REVOKE ALL ON FUNCTION runtime.destroy_demo(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION runtime.destroy_demo(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION runtime.destroy_demo(text) TO tendreladmin WITH GRANT OPTION;
