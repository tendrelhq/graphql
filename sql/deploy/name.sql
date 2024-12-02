-- Deploy graphql:name to pg
begin
;

create function
    util.create_name(
        customer_id text, modified_by bigint, source_language text, source_text text
    )
returns table(_id bigint, id text)
as $$
  insert into public.languagemaster (
    languagemastercustomerid,
    languagemastersourcelanguagetypeid,
    languagemastersource,
    languagemastermodifiedby
  )
  select
    c.customerid,
    s.systagid,
    source_text,
    modified_by
  from public.customer as c, public.systag as s
  where
    c.customeruuid = customer_id
    and s.systagparentid = 2
    and s.systagtype = source_language
  returning languagemasterid as _id, languagemasteruuid as id;
$$
language sql
strict
;

commit
;
