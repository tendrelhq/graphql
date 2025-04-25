
-- Type: FUNCTION ; Name: legacy0.ensure_field_t(text,text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.ensure_field_t(customer_id text, language_type text, template_id text, field_description text, field_id text, field_is_draft boolean, field_is_primary boolean, field_is_required boolean, field_name text, field_order integer, field_reference_type text, field_type text, field_value text, field_widget text, modified_by bigint)
 RETURNS TABLE(id text)
 LANGUAGE plpgsql
AS $function$
begin
  if not exists (select 1 from public.workresult where workresult.id = field_id) then
    -- Create.
    return query
      select *
      from legacy0.create_field_t(
          customer_id := customer_id,
          language_type := language_type,
          template_id := template_id,
          field_description := field_description,
          field_is_draft := field_is_draft,
          field_is_primary := field_is_primary,
          field_is_required := field_is_required,
          field_name := field_name,
          field_order := field_order,
          field_reference_type := field_reference_type,
          field_type := field_type,
          field_value := field_value,
          field_widget := field_widget,
          modified_by := modified_by
      )
    ;

    return;
  end if;

  -- Update.
  -- First we do the simple bits.
  update public.workresult
  set workresultdefaultvalue = nullif(field_value, ''),
      workresultisrequired = field_is_required,
      workresultorder = field_order,
      workresultmodifieddate = now(),
      workresultmodifiedby = modified_by
  where workresult.id = field_id;

  -- Second we do relational updates, e.g. description.
  if nullif(field_description, '') is not null then
    with
      existing_desc as (
          select d.*
          from public.workdescription as d
          inner join public.workresult
              on d.workdescriptionworkresultid = workresultid
          where
              workresult.id = field_id
              and (
                  d.workdescriptionenddate is null
                  or d.workdescriptionenddate > now()
              )
          order by d.workdescriptionid desc
          limit 1
      ),

      ins_content as (
          select *
          from i18n.create_localized_content(
              owner := customer_id,
              content := field_description,
              language := language_type
          )
          where not exists (select 1 from existing_desc)
      ),

      ins_desc as (
          insert into public.workdescription (
              workdescriptioncustomerid,
              workdescriptionworktemplateid,
              workdescriptionworkresultid,
              workdescriptionlanguagemasterid,
              workdescriptionlanguagetypeid,
              workdescriptionmodifiedby
          )
          select
              workresultcustomerid,
              workresultworktemplateid,
              workresultid,
              ins_content._id,
              ins_content._type,
              modified_by
          from public.workresult
          where workresult.id = field_id
      ),

      upd_master as (
          update public.languagemaster
          set languagemastersource = field_description,
              languagemastersourcelanguagetypeid = systagid,
              languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
              languagemastermodifieddate = now(),
              languagemastermodifiedby = modified_by
          from existing_desc, public.systag
          where languagemasterid = workdescriptionlanguagemasterid
            and systagparentid = 2
              and systagtype = language_type
            and (languagemastersource, languagemastersourcelanguagetypeid)
                is distinct from (field_description, systagid)
      )

    update public.languagetranslations
    set languagetranslationvalue = field_description,
        languagetranslationmodifieddate = now(),
        languagetranslationmodifiedby = modified_by
    from existing_desc
    where languagetranslationmasterid = workdescriptionlanguagemasterid
      and languagetranslationtypeid = (
          select systagid
          from public.systag
          where systagparentid = 2 and systagtype = language_type
      )
      and languagetranslationvalue is distinct from field_description
    ;

  else
    update public.workdescription
    set workdescriptionenddate = now(),
        workdescriptionmodifieddate = now(),
        workdescriptionmodifiedby = modified_by
    from public.workresult
    where workresult.id = field_id
      and workdescriptionworktemplateid = workresultworktemplateid
      and workdescriptionworkresultid = workresultid
    ;
  end if;

  -- Update the name's master, if applicable.
  update public.languagemaster
  set languagemastersource = field_name,
      languagemastersourcelanguagetypeid = (
          select systagid
          from public.systag
          where systagparentid = 2 and systagtype = language_type
      ),
      languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
      languagemastermodifieddate = now(),
      languagemastermodifiedby = modified_by
  from public.workresult, public.systag
  where workresult.id = field_id
    and (languagemasterid, languagemastersourcelanguagetypeid)
        = (workresultlanguagemasterid, systagid)
    and (languagemastersource, systagtype)
        is distinct from (field_name, language_type)
  ;

  -- Update the name's transations, if applicable.
  update public.languagetranslations
  set languagetranslationvalue = field_name,
      languagetranslationmodifieddate = now(),
      languagetranslationmodifiedby = modified_by
  from public.workresult, public.systag 
  where workresult.id = field_id
    and workresultlanguagemasterid = languagetranslationmasterid
    and (languagetranslationtypeid, language_type) = (systagid, systagtype)
    and (languagetranslationvalue, systagtype)
        is distinct from (field_name, language_type)
  ;

  id := field_id;
  return next;

  return;
end $function$;


REVOKE ALL ON FUNCTION legacy0.ensure_field_t(text,text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.ensure_field_t(text,text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) TO tendrelservice;
GRANT EXECUTE ON FUNCTION legacy0.ensure_field_t(text,text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) TO graphql;
