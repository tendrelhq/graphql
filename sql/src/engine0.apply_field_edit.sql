
-- Type: FUNCTION ; Name: engine0.apply_field_edit(text,text,anyelement,text,engine0.on_error); Owner: bombadil

CREATE OR REPLACE FUNCTION engine0.apply_field_edit(entity text, field text, field_v anyelement, field_vt text, on_error engine0.on_error DEFAULT 'diagnostic'::engine0.on_error)
 RETURNS SETOF engine0.diagnostic
 LANGUAGE plpgsql
AS $function$
declare
  -- @see auth.set_actor
  user_id text := current_setting('user.id');
  user_locale text := current_setting('user.locale');
  --
  field_t bigint;
  field_i bigint;
begin
  select workresultid into field_t
  from public.workresult
  inner join public.systag on workresulttypeid = systagid and systagtype = field_vt
  where id = field;
  --
  if not found then
    if on_error = 'raise' then
      raise exception 'field_type_mismatch';
    else
      return query
        select
            'field_type_mismatch'::engine0.diagnostic_kind as kind,
            'error'::engine0.diagnostic_severity as severity
      ;
    end if;
    return;
  end if;

  select workresultinstanceid into field_i
  from public.workresultinstance
  where
      workresultinstanceworkinstanceid = (
          select workinstanceid
          from public.workinstance
          where id = entity
      )
      and workresultinstanceworkresultid = field_t
  ;

  if not found then
    -- Create.
    with
        parent as (
            select
                workinstancecustomerid as _owner,
                workinstanceid as _id,
                workinstancetimezone as timezone
            from public.workinstance
            where id = entity
        ),

        static_content (static_v, dynamic_v, dynamic_vt) as (
            values (
                nullif(field_v::text, ''),
                null::bigint,
                null::bigint
            )
        ),

        dynamic_content as (
            insert into public.languagemaster (
                languagemastercustomerid,
                languagemastersourcelanguagetypeid,
                languagemastersource,
                languagemastermodifiedby
            )
            select
                parent._owner,
                locale.systagid,
                coalesce(field_v::text, ''),
                auth.current_identity(parent._owner, user_id)
            from parent, public.systag as locale
            where
                field_vt in ('String')
                and locale.systagparentid = 2
                and locale.systagtype = user_locale
            returning
                nullif(languagemastersource, '') as static_v,
                languagemasterid as dynamic_v,
                languagemastersourcelanguagetypeid as dynamic_vt
        ),

        content as (
            select * from static_content where field_vt not in ('String')
            union all
            select * from dynamic_content
        )

    insert into public.workresultinstance (
        workresultinstancecustomerid,
        workresultinstanceworkinstanceid,
        workresultinstanceworkresultid,
        workresultinstancetimezone,
        workresultinstancevalue,
        workresultinstancevaluelanguagemasterid,
        workresultinstancevaluelanguagetypeid,
        workresultinstancemodifiedby
    )
    select
        parent.workinstancecustomerid,
        parent.workinstanceid,
        field_t,
        parent.workinstancetimezone,
        content.static_v,
        content.dynamic_v,
        content.dynamic_vt,
        auth.current_identity(parent.workinstancecustomerid, user_id)
    from public.workinstance as parent, content
    where parent.id = entity;
    --
    if not found then
      raise exception 'failed to apply field edit (%, %, %, %)', entity, field, field_v, field_vt;
    end if;

    return query
      select
          null::engine0.diagnostic_kind as kind,
          null::engine0.diagnostic_severity as severity
      ;
    return;
  end if;

  -- Update.
  with
      static_content (static_v, dynamic_v, dynamic_vt) as (
          values (
              nullif(field_v::text, ''),
              null::bigint,
              null::bigint
          )
      ),

      ins_dynamic_content as (
          insert into public.languagemaster (
              languagemastercustomerid,
              languagemastersourcelanguagetypeid,
              languagemastersource,
              languagemastermodifiedby
          )
          select
              workresultinstancecustomerid,
              locale.systagid,
              coalesce(field_v::text, ''),
              auth.current_identity(workresultinstancecustomerid, user_id)
          from public.workresultinstance, public.systag as locale
          where
              field_vt in ('String')
              and workresultinstanceid = field_i
              and workresultinstancevaluelanguagemasterid is null
              and locale.systagparentid = 2
              and locale.systagtype = user_locale
          returning
              nullif(languagemastersource, '') as static_v,
              languagemasterid as dynamic_v,
              languagemastersourcelanguagetypeid as dynamic_vt
      ),

      _upd_dynamic_content_master as (
          update public.languagemaster
          set languagemastersource = coalesce(field_v::text, ''),
              languagemastersourcelanguagetypeid = (
                  select systagid
                  from public.systag
                  where systagparentid = 2 and systagtype = user_locale
              ),
              languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
              languagemastermodifieddate = now(),
              languagemastermodifiedby = auth.current_identity(languagemastercustomerid, user_id)
          from public.workresultinstance
          where
              workresultinstanceid = field_i
              and languagemasterid = workresultinstancevaluelanguagemasterid
              and languagemastersource is distinct from coalesce(field_v::text, '')
          returning
              languagemasterid as _id,
              nullif(languagemastersource, '') as static_v,
              languagemasterid as dynamic_v,
              languagemastersourcelanguagetypeid as dynamic_vt
      ),

      _upd_dynamic_content_trans as (
          update public.languagetranslations
          set languagetranslationvalue = coalesce(field_v::text, ''),
              languagetranslationmodifieddate = now(),
              languagetranslationmodifiedby = auth.current_identity(languagetranslationcustomerid, user_id)
          from _upd_dynamic_content_master as m
          where
              languagetranslationmasterid = m._id
              and languagetranslationtypeid = (
                  select systagid
                  from public.systag
                  where systagparentid = 2 and systagtype = user_locale
              )
          returning
              nullif(languagetranslationvalue, '') as static_v,
              languagetranslationmasterid as dynamic_v,
              languagetranslationtypeid as dynamic_vt
      ),

      upd_dynamic_content as (
          select static_v, dynamic_v, dynamic_vt from _upd_dynamic_content_master
          union -- NOT all!
          select * from _upd_dynamic_content_trans
      ),

      content as (
          select * from static_content where field_vt not in ('String')
          union all
          select * from ins_dynamic_content
          union all
          select * from upd_dynamic_content
      )

  update public.workresultinstance
  set workresultinstancevalue = content.static_v,
      workresultinstancevaluelanguagemasterid = content.dynamic_v,
      workresultinstancevaluelanguagetypeid = content.dynamic_vt,
      workresultinstancemodifiedby = auth.current_identity(workresultinstancecustomerid, user_id),
      workresultinstancemodifieddate = now()
  from content
  where workresultinstanceid = field_i and workresultinstancevalue is distinct from content.static_v;

  return query
    select
        null::engine0.diagnostic_kind as kind,
        null::engine0.diagnostic_severity as severity
  ;
  return;
end $function$;


REVOKE ALL ON FUNCTION engine0.apply_field_edit(text,text,anyelement,text,engine0.on_error) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.apply_field_edit(text,text,anyelement,text,engine0.on_error) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.apply_field_edit(text,text,anyelement,text,engine0.on_error) TO bombadil WITH GRANT OPTION;
