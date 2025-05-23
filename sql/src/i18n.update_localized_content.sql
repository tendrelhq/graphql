
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
