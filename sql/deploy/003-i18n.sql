-- Deploy graphql:003-i18n to pg
begin
;

create schema i18n;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'graphql') then
    revoke all on schema i18n from graphql;
    grant usage on schema i18n to graphql;
    alter default privileges in schema i18n grant execute on routines to graphql;
  end if;
end $$;

create or replace function
    i18n.add_language_to_customer(
        customer_id text, language_code text, modified_by bigint
    )
returns table(id text)
as $$
  with ins as (
    insert into public.customerrequestedlanguage (
        customerrequestedlanguagecustomerid,
        customerrequestedlanguagelanguageid,
        customerrequestedlanguagemodifiedby
    )
    select
        c.customerid,
        s.systagid,
        modified_by
    from public.customer as c
    inner join public.systag as s
        on s.systagparentid = 2 and s.systagtype = language_code
    where c.customeruuid = customer_id
    on conflict do nothing
    returning customerrequestedlanguageuuid as id
  )

  select * from ins
  union all
  select customerrequestedlanguageuuid as id
  from public.customerrequestedlanguage as crl
  where
      crl.customerrequestedlanguagecustomerid = (
          select customerid
          from public.customer
          where customeruuid = customer_id
      )
      and crl.customerrequestedlanguagelanguageid = (
          select systagid
          from public.systag
          where systagparentid = 2 and systagtype = language_code
      )
  limit 1
  ;
$$
language sql
strict
;

commit
;
