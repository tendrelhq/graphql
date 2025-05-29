BEGIN;

/*
DROP FUNCTION i18n.update_localized_content(text,text,text);
DROP FUNCTION i18n.create_localized_content(text,text,text);
DROP FUNCTION i18n.add_language_to_customer(text,text,bigint);

DROP SCHEMA i18n;
*/

CREATE SCHEMA i18n;

GRANT USAGE ON SCHEMA i18n TO graphql;

-- DEPENDANTS


-- Type: FUNCTION ; Name: i18n.add_language_to_customer(text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION i18n.add_language_to_customer(customer_id text, language_code text, modified_by bigint)
 RETURNS TABLE(id text)
 LANGUAGE sql
 STRICT
AS $function$
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
  limit 1;
$function$;


REVOKE ALL ON FUNCTION i18n.add_language_to_customer(text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION i18n.add_language_to_customer(text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION i18n.add_language_to_customer(text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION i18n.add_language_to_customer(text,text,bigint) TO graphql;

-- Type: FUNCTION ; Name: i18n.create_localized_content(text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION i18n.create_localized_content(owner text, content text, language text)
 RETURNS TABLE(id text, _id bigint, _type bigint)
 LANGUAGE sql
AS $function$
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
$function$;


REVOKE ALL ON FUNCTION i18n.create_localized_content(text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION i18n.create_localized_content(text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION i18n.create_localized_content(text,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION i18n.create_localized_content(text,text,text) TO graphql;

-- Type: FUNCTION ; Name: i18n.update_localized_content(text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION i18n.update_localized_content(master_id text, content text, language text)
 RETURNS TABLE(id text)
 LANGUAGE plpgsql
AS $function$
declare
  language_id bigint;
begin
  select systagid into language_id
  from public.systag
  where systagparentid = 2 and systagtype = language;

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
            and languagetranslationtypeid = language_id
            and languagetranslationvalue is distinct from content
          returning languagetranslationuuid as id
      )

    select * from upd_master
    union all
    select * from upd_trans
  ;

  return;
end $function$;


REVOKE ALL ON FUNCTION i18n.update_localized_content(text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION i18n.update_localized_content(text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION i18n.update_localized_content(text,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION i18n.update_localized_content(text,text,text) TO graphql;

END;
