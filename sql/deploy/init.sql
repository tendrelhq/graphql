-- Deploy graphql:init to pg
begin;

create schema ast;
create schema auth;
create schema debug;
create schema i18n;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'graphql') then
    revoke all on schema ast from graphql;
    grant usage on schema ast to graphql;
    alter default privileges in schema ast grant execute on routines to graphql;
    --
    revoke all on schema auth from graphql;
    grant usage on schema auth to graphql;
    alter default privileges in schema auth grant execute on routines to graphql;
    --
    grant usage on schema debug to graphql;
    revoke all on schema debug from graphql;
    alter default privileges in schema debug grant execute on routines to graphql;
    --
    revoke all on schema i18n from graphql;
    grant usage on schema i18n to graphql;
    alter default privileges in schema i18n grant execute on routines to graphql;
  end if;

  if exists (select 1 from pg_roles where rolname = 'tendrelservice') then
    revoke all on schema ast from tendrelservice;
    grant usage on schema ast to tendrelservice;
    alter default privileges in schema ast grant execute on routines to tendrelservice;
    --
    revoke all on schema auth from tendrelservice;
    grant usage on schema auth to tendrelservice;
    alter default privileges in schema auth grant execute on routines to tendrelservice;
    --
    grant usage on schema debug to tendrelservice;
    revoke all on schema debug from tendrelservice;
    alter default privileges in schema debug grant execute on routines to tendrelservice;
    --
    revoke all on schema i18n from tendrelservice;
    grant usage on schema i18n to tendrelservice;
    alter default privileges in schema i18n grant execute on routines to tendrelservice;
  end if;
end $$;

-- BEGIN auth utility functions

create or replace function auth.current_identity(parent bigint, identity text)
returns bigint
as $$
  select workerinstanceid
  from public.workerinstance
  inner join public.worker
      on  workerinstanceworkerid = workerid
      and workeridentityid = identity
  where workerinstancecustomerid = parent
$$
language sql
stable
strict;

comment on function auth.current_identity is $$

# auth.current_identity

Returns the (big)serial primary key that corresponds to the given [customer, user] pair.

## usage

```sql
update location
set locationmodifiedby = auth.current_identity(locationcustomerid, $1)
where locationid = $2
```

$$;

-- END auth utility functions


-- BEGIN debugging utility functions

create or replace function debug.inspect(r anyelement)
returns anyelement
as $$
begin
  raise notice 'inspect: %', r;
  return r;
end $$
language plpgsql;

comment on function debug.inspect is $$

# debug.inspect

Log $1 and then return it.

## usage

```sql
select debug.inspect(foo.id) as id from foo;

NOTICE:  inspect: 1007
NOTICE:  inspect: 1008
NOTICE:  inspect: 1009
  id
------
 1007
 1008
 1009
(3 rows)
```

$$;

create or replace function debug.inspect_t(t text, r anyelement)
returns anyelement
as $$
begin
  raise notice 'inspect: % := %', t, r;
  return r;
end $$
language plpgsql;

comment on function debug.inspect_t is $$

# debug.inspect_t

Log $1 and $2, then return $2. This is the tagged version of `debug.inspect`.

## usage

```sql
select debug.inspect_t('foo.id', foo.id) as id from foo;

NOTICE:  inspect: foo.id := 1007
NOTICE:  inspect: foo.id := 1008
NOTICE:  inspect: foo.id := 1009
  id
------
 1007
 1008
 1009
(3 rows)
```

$$;

-- END debugging utility functions

-- BEGIN localization utility functions

create or replace function
    i18n.create_localized_content(
        owner text,
        content text,
        language text
    )
returns table(id text, _id bigint, _type bigint)
as $$
  insert into public.languagemaster (
      languagemastercustomerid,
      languagemastersource,
      languagemastersourcelanguagetypeid,
      languagemastermodifiedby
  )
  select
      customer.customerid,
      content,
      systag.systagid,
      auth.current_identity(customer.customerid, current_setting('user.id'))
  from public.customer, public.systag
  where customeruuid = owner and (systagparentid, systagtype) = (2, language)
  returning
      languagemasteruuid as id,
      languagemasterid as _id,
      languagemastersourcelanguagetypeid as _type
  ;
$$
language sql;

create or replace function
    i18n.update_localized_content(
        master_id text,
        content text,
        language text
    )
returns table(id text)
as $$
declare
  language_id bigint;
begin
  select systagid into language_id
  from public.systag
  where systagparentid = 2 and systagtype = locale;

  return query
    with
      upd_master as (
          update public.languagemaster
          set languagemastersource = content,
              languagemastersourcelanguagetypeid = language_id,
              languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
              languagemastermodifieddate = now(),
              languagemastermodifiedby = auth.current_identity(
                  parent := languagemastercustomerid,
                  identity := current_setting('user.id')
              )
          where languagemasteruuid = master_id
            and (languagemastersource, languagemastersourcelanguagetypeid)
                is distinct from (content, language_id)
          returning languagemasteruuid as id
      ),
      upd_trans as (
          update public.languagetranslations
          set languagetranslationvalue = content,
              languagetranslationmodifieddate = now(),
              languagetranslationmodifiedby = auth.current_identity(
                  parent := languagetranslationcustomerid,
                  identity := current_setting('user.id')
              )
          where
            languagetranslationmasterid = (
                select languagemasterid
                from public.languagemaster
                where languagemasteruuid = master_id
            )
            and (languagetranslationvalue, languagetranslationtypeid)
                is distinct from (content, language_id)
          returning languagetranslationuuid as id
      )

    select * from upd_master
    union all
    select * from upd_trans
  ;

  return;
end $$
language plpgsql;

-- END localization utility functions


-- BEGIN type constructor utility functions

create or replace function
    ast.create_system_type(type_name text, type_hierarchy text, modified_by bigint)
returns table(_id bigint, id text)
as $$
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
end $$
language plpgsql
strict;

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
          from i18n.create_localized_content(
              owner := customer_id,
              content := type_name,
              language := language_type
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
strict;

-- END type constructor utility functions

commit;
