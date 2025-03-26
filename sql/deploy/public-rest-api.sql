-- Deploy graphql:public-rest-api to pg
begin;

-- PATCH: remove `anon` role
revoke all on schema _api from anon;
revoke all on schema api from anon;
revoke all on all tables in schema api from anon;
alter default privileges in schema api revoke all on tables from anon;
drop role anon;

grant usage on schema _api to anonymous, authenticated, god;
grant usage on schema api to anonymous, authenticated, god;

-- PATCH: add SECURITY DEFINER
create or replace function _api.parse_accept_language(accept_language text)
returns table(tag text, quality float)
as $$
declare
  v_parts text[];
  v_part text;
  v_language text;
  v_quality text;
  v_language_parts text[];
begin
  if nullif(accept_language, '') is null then
    tag := 'en';
    quality := 1.0;
    return next;
    return;
  end if;

  v_parts := string_to_array(accept_language, ',');

  foreach v_part in array v_parts loop
    v_part := trim(v_part);
    v_quality := 1.0;
    v_language_parts := string_to_array(v_part, ';');
    v_language := trim(v_language_parts[1]);
    if array_length(v_language_parts, 1) > 1 then
      v_quality := substring(trim(v_language_parts[2]) FROM 'q=([0-9]*\.?[0-9]+)');
      if nullif(v_quality, '') is null then
        v_quality := 1.0;
      end if;
    end if;

    tag := lower(v_language);
    quality := v_quality;
    return next;
  end loop;

  return;
end $$
language plpgsql
immutable
security definer; --> this is new

grant execute on function _api.parse_accept_language to anonymous, authenticated, god;
grant execute on function _api.pre_request_hook to anonymous, authenticated, god;

-- This table is effectively readonly. It is a hack until languagemaster is
-- moved over to the entity model.
revoke all on table api.localized from anonymous;
revoke all on table api.localized from authenticated;
revoke all on table api.localized from god;

-- PATCH: add fake RLS.
create or replace view api.template as
  select
    entitytemplatedeleted as _deleted,
    entitytemplatedraft as _draft,
    entitytemplateorder as _order,
    entitytemplateisprimary as _primary,
    entitytemplatestartdate as activated_at,
    entitytemplatecreateddate as created_at,
    entitytemplateenddate as deactivated_at,
    entitytemplateexternalid as external_id,
    entitytemplateexternalsystementityuuid as external_system,
    entitytemplateuuid as id,
    entitytemplatemodifiedbyuuid as modified_by,
    entitytemplatename as name,
    entitytemplateownerentityuuid as owner,
    entitytemplateparententityuuid as parent,
    entitytemplatescanid as scan_code,
    entitytemplatetypeentityuuid as type,
    entitytemplatemodifieddate as updated_at
  from entity.entitytemplate
  where
    entitytemplateownerentityuuid = (current_setting('request.jwt.claims', true)::json ->> 'owner')::uuid
    or current_setting('request.jwt.claims', true)::json ->> 'role' = 'god'
;

create or replace view api.template_field as
  select
    entityfielduuid as id,
    entityfieldentitytemplateentityuuid as template,
    entityfieldtypeentityuuid as type_id,
    entityfieldcreateddate as created_at,
    entityfieldmodifieddate as updated_at,
    entityfieldstartdate as activated_at,
    entityfieldenddate as deactivated_at,
    entityfielddefaultvalue as default_value,
    entityfieldname as name,
    entityfieldownerentityuuid as owner,
    entityfieldparententityuuid as parent,
    entityfielddeleted as _deleted,
    entityfielddraft as _draft,
    entityfieldorder::integer as _order,
    entityfieldisprimary as _primary
  from entity.entityfield
  where
    entityfieldownerentityuuid = (current_setting('request.jwt.claims', true)::json ->> 'owner')::uuid
    or current_setting('request.jwt.claims', true)::json ->> 'role' = 'god'
;

create or replace view api.instance as
  select
    entityinstanceuuid as id,
    entityinstanceownerentityuuid as owner,
    entityinstanceentitytemplateentityuuid as template,
    entityinstancecreateddate as created_at,
    entityinstancemodifieddate as updated_at,
    entityinstancestartdate as activated_at,
    entityinstanceenddate as deactivated_at,
    entityinstanceentitytemplatename as name,
    entityinstancedeleted as _deleted,
    entityinstancedraft as _draft,
    entityinstancecornerstoneorder as _order
  from entity.entityinstance
  where
    entityinstanceownerentityuuid = (current_setting('request.jwt.claims', true)::json ->> 'owner')::uuid
    or current_setting('request.jwt.claims', true)::json ->> 'role' = 'god'
;

create or replace view api.instance_field as
  select
    entityfieldinstanceuuid as id,
    entityfieldinstanceentityinstanceentityuuid as instance,  
    entityfieldinstanceownerentityuuid as owner, 
    entityfieldinstancecreateddate as created_at,
    entityfieldinstancemodifieddate as updated_at, 
    entityfieldinstanceentityfieldentityuuid as template, 
    entityfieldinstanceentityfieldname as name,  
    entityfieldinstancedeleted as _deleted, 
    entityfieldinstancedraft as _draft
  from entity.entityfieldinstance
  where
    entityfieldinstanceownerentityuuid = (current_setting('request.jwt.claims', true)::json ->> 'owner')::uuid
    or current_setting('request.jwt.claims', true)::json ->> 'role' = 'god'
;

grant all on table api.template to authenticated, god;
grant all on table api.template_field to authenticated, god;
grant all on table api.instance to authenticated, god;
grant all on table api.instance_field to authenticated, god;

commit;
