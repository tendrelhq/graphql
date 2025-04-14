
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
