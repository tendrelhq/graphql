
-- Type: FUNCTION ; Name: legacy0.create_field_t(text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_field_t(customer_id text, language_type text, template_id text, field_description text, field_is_draft boolean, field_is_primary boolean, field_is_required boolean, field_name text, field_order integer, field_reference_type text, field_type text, field_value text, field_widget text, modified_by bigint)
 RETURNS TABLE(id text)
 LANGUAGE plpgsql
AS $function$
declare
  ins_field text;
begin
  with
    ins_name as (
      select *
      from i18n.create_localized_content(
          owner := customer_id,
          content := field_name,
          language := language_type
      )
    ),

    ins_type as (
      select t.systagid as _type, r.systagid as _ref_type
      from public.systag as t
      left join public.systag as r
          on r.systagparentid = 849
          and r.systagtype = field_reference_type
      where
          t.systagparentid = 699
          and t.systagtype = field_type
    ),

    ins_widget as (
      select custagid as _id
      from public.custag
      where custagcustomerid = 0
        and custagsystagid = (
            select systagid
            from public.systag
            where systagparentid = 1 and systagtype = 'Widget Type'
        )
        and custagtype = field_widget
    )

  insert into public.workresult (
      workresultcustomerid,
      workresultdefaultvalue,
      workresultdraft,
      workresultentitytypeid,
      workresultforaudit,
      workresultfortask,
      workresultisprimary,
      workresultisrequired,
      workresultlanguagemasterid,
      workresultorder,
      workresultsiteid,
      workresultsoplink,
      workresulttypeid,
      workresultwidgetid,
      workresultworktemplateid,
      workresultmodifiedby
  )
  select
      wt.worktemplatecustomerid,
      nullif(field_value, ''),
      field_is_draft,
      ins_type._ref_type,
      false,
      true,
      field_is_primary,
      field_is_required,
      ins_name._id,
      field_order,
      wt.worktemplatesiteid,
      null,
      ins_type._type,
      ins_widget._id,
      wt.worktemplateid,
      modified_by
  from
      public.worktemplate as wt,
      ins_name,
      ins_type
  left join ins_widget on true
  where wt.id = template_id
  returning workresult.id into ins_field;

  if not found then
    raise exception 'failed creating template field';
  end if;

  id := ins_field;
  return next;

  if nullif(field_description, '') is not null then
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
        content._id,
        content._type,
        modified_by
    from
        public.workresult,
        i18n.create_localized_content(
            owner := customer_id,
            content := field_description,
            language := language_type
        ) as content
    where workresult.id = ins_field;
  end if;

  return;
end $function$;


REVOKE ALL ON FUNCTION legacy0.create_field_t(text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_field_t(text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) TO tendrelservice;
GRANT EXECUTE ON FUNCTION legacy0.create_field_t(text,text,text,text,boolean,boolean,boolean,text,integer,text,text,text,text,bigint) TO graphql;
