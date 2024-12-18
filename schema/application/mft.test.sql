--
-- NOTE: this is a work-in-progress collection of utilities for the test suite.
--
begin
;

create schema if not exists util;

drop function if exists util.create_mft_customer
;

create or replace function
    util.create_mft_customer(
        in c_name text,
        in c_language text,  -- e.g. 'en'
        in c_initial_users text[],
        in c_initial_users_role text  -- e.g. 'Admin'
    )
returns table(customer text, workers text[])
as $$
declare
  language_type_id bigint;
begin
  -- resolve input arguments
  select systagid into language_type_id
  from public.systag
  where systagparentid = 2 and systagtype = c_language;

  -- create the administrative bits
  return query
    with customer_name as (
        insert into public.languagemaster (
            languagemastercustomerid,
            languagemastersourcelanguagetypeid,
            languagemastersource
        )
        values (
            0,
            language_type_id,
            c_name
        )
        returning languagemasterid as _id
    ),

    customer as (
        insert into public.customer (
            customername,
            customerlanguagetypeid,
            customerlanguagetypeuuid,
            customernamelanguagemasterid
        )
        select
            c_name,
            systag.systagid,
            systag.systaguuid,
            customer_name._id
        from customer_name
        inner join public.systag
            on systag.systagid = language_type_id
        returning customerid as _id, customeruuid as id
    ),

    workers as (
        insert into public.workerinstance (
            workerinstancecustomerid,
            workerinstancecustomeruuid,
            workerinstanceworkerid,
            workerinstanceworkeruuid,
            workerinstancelanguageid,
            workerinstancelanguageuuid,
            workerinstanceuserroleid,
            workerinstanceuserroleuuid
        )
        select
            c._id,
            c.id,
            u.workerid,
            u.workeruuid,
            l.systagid,
            l.systaguuid,
            r.systagid,
            r.systaguuid
        from public.worker as u
        inner join customer as c on true
        inner join public.systag as l
            on u.workerlanguageid = l.systagid
        inner join public.systag as r
            on r.systagparentid = 772 and r.systagtype = c_initial_users_role
        where u.workeruuid = any(c_initial_users)
        returning workerinstanceid as _id, workerinstanceuuid as id
    )

    select
        customer.id as customer,
        array_agg(workers.id) as workers
    from customer, workers
    group by customer.id;

  if not found then
    raise exception 'create_mft_customer: failed to create a customer';
  end if;

  -- update the name to point at the right customer :sigh:
  update public.languagemaster
  set languagemastercustomerid = c.customerid
  from public.customer as c
  where languagemaster.languagemasterid = c.customernamelanguagemasterid
  and c.customeruuid = customer;

  return;
end $$
language plpgsql
;

drop function if exists util.create_mft_locations
;

create or replace function util.create_mft_demo()
returns table(location text)
as $$
begin
  raise error 'not yet implemented';
end $$
language plpgsql
;

commit
;
--
-- test
--
begin
;

select *
from
    util.create_mft_customer(
        'My New Tendy',
        'en',
        array['worker_d3ebf472-606c-4d26-9a19-d99f187e9c92'],
        'Admin'
    )
;

rollback
;

