-- Deploy graphql:public-rest-api to pg
begin;

-- This is our "exposed schema".
-- @see https://docs.postgrest.org/en/v12/references/api/schemas.html#schemas
create schema api;
-- This schema holds utility functions, e.g. our pre-request hook. It is not
-- exposed and therefore cannot be directly "hit" via the REST api.
create schema _api;
comment on schema api is $$
# Tendrel REST API

## Authentication and authorization

Most of the public api requires two tokens to be present in every request:

1. An application token, in JWT format via the X-Tendrel-App header.
2. An authorization token, in JWT format via the Authorization header.

The application token is essentially an OAuth 2.0 client secret, where the
"application" (e.g. a mobile app) is the OAuth 2.0 client. Application tokens
are required for all api calls.

The authorization token is a Tendrel issued JWT that uniquely identifies the
user making the request. Most api calls require a valid authorization token.
A client may exchange an IDP-issued security token for a Tendrel-issued token by
calling the /token api, which is implemented as an [OAuth 2.0 Token
Exchange](https://datatracker.ietf.org/doc/html/rfc8693).

### The "anonymous" role

The anonymous (`anon`) role can only be used to perform a select few operations
that do not require an authorization token. In particular, the `anon` role can
be used to signup for a Tendrel account as well as in various "introspection"
related operations, e.g. introspecting the OpenAPI schema. This role is the
default role for HTTP requests which do not include an authorization token.

## Localization

Tendrel is not a content management system. It does, however, provide mechanisms
that allow for content to be dynamically localized according to user preference.

Dynamic localization can be customized using various HTTP headers:

- `Accept-Language: en` specifies the locale.
- `Prefer: timezone=America/Denver` specifies the timezone.
$$;

-- 
-- Pre-request
--

-- Parse the value extracted from the Accept-Language header.
-- Note that this function does NOT validate the parsed language tags!
-- @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Language
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
immutable;

-- @see https://docs.postgrest.org/en/v12/references/transactions.html#pre-request
create or replace function _api.pre_request_hook()
returns void
as $$
declare
  accept_language text := nullif(current_setting('request.headers', true)::json ->> 'accept-language', '')::text;
  preferred_language text;
begin
  -- TODO: This just uses the Accept-Language header to determine language
  -- preference. It does not yet look at the user's configured preference, e.g.
  -- workerlanguagetypeid (or whatever it is).
  select systagtype into preferred_language
  from _api.parse_accept_language(accept_language)
  inner join public.systag on systagparentid = 2 and systagtype = tag
  order by quality desc
  limit 1;

  perform set_config('user.preferred_language', preferred_language, true);

  return;
end $$
language plpgsql
-- To avoid leaking systag, we create this function as SECURITY DEFINER.
-- In the future we work through the normal entity tables/views and remove the
-- SECURITY DEFINER attribute.
security definer; 

--
-- Authentication, authorization
--

-- The anonymous role. This is the default role used for HTTP requests which do
-- not contain an Authorization token.
create role anon noinherit nologin;
-- FIXME: the anonymous role should only be able to signup?
grant usage on schema api to anon;
alter default privileges in schema api grant all on tables to anon;
grant usage on schema _api to anon;

--
-- Localization
--

-- FIXME: This feels extremely awkward and out of place...
-- I'm not sure which I like better to be honest:
--  a. instance.display_name => string, localized
--  b. instance.display_name => uuid
--  c. instance.display_name(id,locale,value) => {...}
-- 
-- This is essentially Keller's read_min vs read_full idiom.
-- I _think_ we want (b) and (c). Such that (b) is the read_min variant (and
-- promotes caching) while (c) is the read_full variant.
create table api.localized (
    locale text not null,
    value text not null,
    created_at timestamptz not null,
    updated_at timestamptz not null
);
-- This table is not intended to be modified. It is essentially a type alias.
revoke all on table api.localized from public;
revoke all on table api.localized from anon;

--
-- Templates
--

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
;
comment on view api.template is $$
## Templates

TODO describe what templates are.
$$;

--
-- Template CRUD operations
--

--
-- CREATE
--
create or replace function api.create_template()
returns trigger
as $$
declare
  ins_entity uuid;
  ins_row api.template%rowtype;
begin
  call entity.crud_entitytemplate_create(
      create_entitytemplatecornerstoneorder := new._order,
      create_entitytemplatedeleted := new._deleted,
      create_entitytemplatedraft := new._draft,
      create_entitytemplateexternalid := new.external_id,
      create_entitytemplateexternalsystemuuid := new.external_system,
      create_entitytemplateisprimary := new._primary,
      create_entitytemplatename := new.name,
      create_entitytemplateownerentityuuid := new.owner,
      create_entitytemplateparententityuuid := new.parent,
      create_entitytemplatescanid := new.scan_code,
      create_entitytemplatetag := null::text,
      create_entitytemplatetaguuid := null::uuid,
      create_languagetypeuuid := null::uuid,
      create_modifiedbyid := 895,
      create_entitytemplateentityuuid := ins_entity
  );

  select * into ins_row
  from api.template
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end $$
language plpgsql
security definer;

create or replace trigger create_template_tg
instead of insert on api.template
for each row execute function api.create_template();

--
-- UPDATE
--
create or replace function api.update_template()
returns trigger
as $$
begin
  raise sqlstate 'PT405' using detail = 'not yet implemented';
end $$
language plpgsql
security definer;

create or replace trigger update_template_tg
instead of update on api.template
for each row execute function api.update_template();

--
-- DELETE
--
create or replace function api.delete_template()
returns trigger
as $$
declare
  del_row api.template%rowtype;
begin
  call entity.crud_entitytemplate_delete(
      create_entitytemplateownerentityuuid := old.owner,
      create_entitytemplateentityuuid := old.id,
      create_modifiedbyid := 895
  );

  select * into del_row
  from api.template
  where id = old.id;

  return del_row;
end $$
language plpgsql
security definer;

create or replace trigger delete_template_tg
instead of delete on api.template
for each row execute function api.delete_template();

create or replace function api.display_name(api.template)
returns setof api.localized
as $$
  select
      coalesce(lt_locale.systagtype, lm_locale.systagtype) as locale,
      coalesce(languagetranslationvalue, languagemastersource) as value,
      coalesce(languagetranslationcreateddate, languagemastercreateddate) as created_at,
      coalesce(languagetranslationmodifieddate, languagemastermodifieddate) as updated_at
  from entity.entitytemplate
  inner join public.languagemaster
      on entitytemplatenameuuid = languagemasteruuid
  inner join public.systag as lm_locale
      on languagemastersourcelanguagetypeid = lm_locale.systagid
  left join public.languagetranslations
      on languagemasterid = languagetranslationmasterid
      and languagetranslationtypeid = (
          select systagid
          from public.systag
          where systagparentid = 2 and systagtype = current_setting('user.preferred_language', true)
      )
  left join public.systag as lt_locale
      on languagetranslationtypeid = lt_locale.systagid
  where entitytemplateuuid = $1.id
  limit 1
$$
language sql
rows 1 -- n.b. one-to-one
security definer -- fixme: precludes inlining
stable;

--
-- Template fields
--

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
;
comment on view api.template_field is $$
### Template fields

TODO describe what template fields are.
$$;

--
-- Template field CRUD operations
--

--
-- CREATE
--
create or replace function api.create_template_field()
returns trigger
as $$
declare
  ins_entity uuid;
  ins_row api.template_field%rowtype;
begin
  call entity.crud_entityfield_create(
      create_entityfieldownerentityuuid := new.owner,
      create_entityfieldparententityuuid := new.parent,
      create_entityfieldtemplateentityuuid := new.template,
      create_entityfieldcornerstoneorder := new._order,
      create_entityfieldname := new.name,
      create_entityfieldtypeentityuuid := new.type_id,
      create_entityfieldentityparenttypeentityuuid := null::uuid,
      create_entityfieldentitytypeentityuuid := null::uuid,
      create_entityfielddefaultvalue := new.default_value,
      create_entityfieldformatentityuuid := null::uuid,
      create_entityfieldformatentityname := null::text,
      create_entityfieldwidgetentityuuid := null::uuid,
      create_entityfieldwidgetentityname := null::text,
      create_entityfieldiscalculated := null::boolean,
      create_entityfieldiseditable := null::boolean,
      create_entityfieldisvisible := null::boolean,
      create_entityfieldisrequired := null::boolean,
      create_entityfieldisprimary := new._primary,
      create_entityfieldtranslate := null::boolean,
      create_entityfieldexternalid := null::text,
      create_entityfieldexternalsystemuuid := null::uuid,
      create_languagetypeuuid := null::uuid,
      create_entityfielddeleted := new._deleted,
      create_entityfielddraft := new._draft,
      create_modifiedbyid := 895::bigint,
      create_entityfieldentityuuid := ins_entity
  );

  select * into ins_row
  from api.template_field
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end $$
language plpgsql
security definer;

create or replace trigger create_template_field_tg
instead of insert on api.template_field
for each row execute function api.create_template_field();

--
-- UPDATE
--
create or replace function api.update_template_field()
returns trigger
as $$
begin
  raise sqlstate 'PT405' using detail = 'not yet implemented';
end $$
language plpgsql
security definer;

create or replace trigger update_template_field_tg
instead of update on api.template_field
for each row execute function api.update_template_field();

--
-- DELETE
--
create or replace function api.delete_template_field()
returns trigger
as $$
declare
  del_row api.template_field%rowtype;
begin
  call entity.crud_entityfield_delete(
      create_entityfieldownerentityuuid := old.owner,
      create_entityfieldentityuuid := old.id,
      create_modifiedbyid := 895
  );

  select * into del_row
  from api.template_field
  where id = old.id;

  return del_row;
end $$
language plpgsql
security definer;

create or replace trigger delete_template_field_tg
instead of delete on api.template_field
for each row execute function api.delete_template_field();

create or replace function api.display_name(api.template_field)
returns setof api.localized
as $$
  select
      coalesce(lt_locale.systagtype, lm_locale.systagtype) as locale,
      coalesce(languagetranslationvalue, languagemastersource) as value,
      coalesce(languagetranslationcreateddate, languagemastercreateddate) as created_at,
      coalesce(languagetranslationmodifieddate, languagemastermodifieddate) as updated_at
  from entity.entityfield
  inner join public.languagemaster
      on entityfieldlanguagemasteruuid = languagemasteruuid
  inner join public.systag as lm_locale
      on languagemastersourcelanguagetypeid = lm_locale.systagid
  left join public.languagetranslations
      on languagemasterid = languagetranslationmasterid
      and languagetranslationtypeid = (
          select systagid
          from public.systag
          where systagparentid = 2 and systagtype = current_setting('user.preferred_language', true)
      )
  left join public.systag as lt_locale
      on languagetranslationtypeid = lt_locale.systagid
  where entityfielduuid = $1.id
  limit 1;
$$
language sql
rows 1 -- n.b. one-to-one
security definer -- fixme: precludes inlining
stable;

create or replace function api.fields(api.template)
returns setof api.template_field
as $$
  select *
  from api.template_field
  where template = $1.id;
$$
language sql
security definer -- fixme: precludes inlining
stable;

--
-- Instances
--

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
;
comment on view api.instance is $$
## Instances

TODO describe what instances are.
$$;

--
-- Instance CRUD operations
--

--
-- CREATE
--
create or replace function api.create_instance()
returns trigger
as $$
declare
  ins_entity uuid;
  ins_row api.instance%rowtype;
begin
  call entity.crud_entityinstance_create(
      create_entityinstanceownerentityuuid := new.owner,
      create_entityinstanceentitytemplateentityuuid := new.template,
      create_entityinstanceentitytemplateentityname := null::text,
      create_entityinstanceparententityuuid := null::uuid,
      create_entityinstanceecornerstoneentityuuid := null::uuid,
      create_entityinstancecornerstoneorder := new._order,
      create_entityinstancetaguuid := null::uuid,
      create_entityinstancetag := null::text,
      create_entityinstancename := new.name,
      create_entityinstancescanid := null::text,
      create_entityinstancetypeuuid := null::uuid,
      create_entityinstanceexternalid := null::text,
      create_entityinstanceexternalsystemuuid := null::uuid,
      create_entityinstancedeleted := new._deleted,
      create_entityinstancedraft := new._draft,
      create_languagetypeuuid := null::uuid,
      create_modifiedbyid := 895,
      create_entityinstanceentityuuid := ins_entity
  );

  select * into ins_row
  from api.instance
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end $$
language plpgsql
security definer;

create or replace trigger create_instance_tg
instead of insert on api.instance
for each row execute function api.create_instance();

--
-- UPDATE
--
create or replace function api.update_instance()
returns trigger
as $$
begin
  raise sqlstate 'PT405' using detail = 'not yet implemented';
end $$
language plpgsql
security definer;

create or replace trigger update_instance_tg
instead of update on api.instance
for each row execute function api.update_instance();

--
-- DELETE
--
create or replace function api.delete_instance()
returns trigger
as $$
declare
  del_row api.instance%rowtype;
begin
  call entity.crud_entityinstance_delete(
    create_entityinstanceownerentityuuid := old.owner,
    create_entityinstanceentityuuid := old.id,
    create_modifiedbyid := 895
  );

  select * into del_row
  from api.instance
  where id = old.id;

  return del_row;
end $$
language plpgsql
security definer;

create or replace trigger delete_instance_tg
instead of delete on api.instance
for each row execute function api.delete_instance();

create or replace function api.display_name(api.instance)
returns setof api.localized
as $$
  select n.*
  from
      api.template as t,
      api.display_name(t.*) as n
  where t.id = $1.template;
$$
language sql
rows 1 -- n.b. one-to-one
security definer -- fixme: precludes inlining
stable;

create or replace function api.template(api.instance)
returns setof api.template
as $$
  select t.*
  from entity.entityinstance as s
  inner join api.template as t on s.entityinstanceentitytemplateentityuuid = t.id
  where s.entityinstanceuuid = $1.id;
$$
language sql
rows 1 -- n.b. one-to-one
security definer -- fixme: precludes inlining
stable;

create or replace function api.type(api.template_field)
returns setof api.instance
as $$
  select *
  from api.instance
  where id = $1.type_id;
$$
language sql
rows 1 -- n.b. one-to-one
security definer -- fixme: precludes inlining
stable;

--
-- Instance fields
--

create or replace view api.instance_field as
  select
      entityfieldinstanceuuid as id,
      entityfieldinstanceentityinstanceentityuuid as instance,  
      entityfieldinstanceownerentityuuid as owner, 
      -- NOTE: the following are available via api.value(api.instance_field):
      -- entityfieldinstancevalue,  
      -- entityfieldinstancevaluelanguagemasteruuid, 
      entityfieldinstancecreateddate as created_at,
      entityfieldinstancemodifieddate as updated_at, 
      -- entityfieldinstancestartdate, 
      -- entityfieldinstancecompleteddate, 
      entityfieldinstanceentityfieldentityuuid as template, 
      -- entityfieldinstancemodifiedbyuuid, 
      -- entityfieldinstancerefid, 
      -- entityfieldinstancerefuuid, 
      entityfieldinstanceentityfieldname as name,  
      -- entityfieldinstancevaluelanguagetypeentityuuid, 
      entityfieldinstancedeleted as _deleted, 
      entityfieldinstancedraft as _draft
  from entity.entityfieldinstance
;
comment on view api.instance_field is $$
### Instance fields

TODO describe what instance fields are.
$$;

--
-- Instance field CRUD operations
--

--
-- CREATE
--
create or replace function api.create_instance_field()
returns trigger
as $$
declare
  ins_entity uuid;
  ins_row api.instance_field%rowtype;
begin
  call entity.crud_entityfieldinstance_create(
      create_entityfieldinstanceownerentityuuid := new.owner,
      create_entityfieldinstanceentityinstanceentityuuid := new.instance,
      create_entityfieldinstanceentityfieldentityuuid := new.template,
      create_entityfieldinstancevalue := null::text,
      create_entityfieldinstanceentityfieldname := new.name,
      create_entityfieldformatentityuuid := null::uuid,
      create_entityfieldformatentityname := null::text,
      create_entityfieldwidgetentityuuid := null::uuid,
      create_entityfieldwidgetentityname := null::text,
      create_entityfieldinstanceexternalid := null::text,
      create_entityfieldinstanceexternalsystemuuid := null::uuid,
      create_entityfieldinstancedeleted := new._deleted,
      create_entityfieldinstancedraft := new._draft,
      create_languagetypeuuid := null::uuid,
      create_modifiedbyid := 895::bigint,
      create_entityfieldinstanceentityuuid := ins_entity
  );

  select * into ins_row
  from api.instance_field
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end $$
language plpgsql
security definer;

create or replace trigger create_instance_field_tg
instead of insert on api.instance_field
for each row execute function api.create_instance_field();

--
-- UPDATE
--
create or replace function api.update_instance_field()
returns trigger
as $$
begin
  raise sqlstate 'PT405' using detail = 'not yet implemented';
end $$
language plpgsql
security definer;

create or replace trigger update_instance_field_tg
instead of update on api.instance_field
for each row execute function api.update_instance_field();

--
-- DELETE
--
create or replace function api.delete_instance_field()
returns trigger
as $$
declare
  del_row api.instance_field%rowtype;
begin
  call entity.crud_entityfieldinstance_delete(
      create_entityfieldinstanceownerentityuuid := old.owner,
      create_entityfieldinstanceentityuuid := old.id,
      create_modifiedbyid := 895
  );

  select * into del_row
  from api.instance_field
  where id = old.id;

  return del_row;
end $$
language plpgsql
security definer;

create or replace trigger delete_instance_field_tg
instead of delete on api.instance_field
for each row execute function api.delete_instance_field();

create or replace function api.display_name(api.instance_field)
returns setof api.localized
as $$
  select n.*
  from
      api.template_field as t,
      api.display_name(t.*) as n
  where t.id = $1.template;
$$
language sql
rows 1  -- n.b. one-to-one
security definer  -- fixme: precludes inlining
stable;

create or replace function api.parent(api.instance_field)
returns setof api.instance
as $$
  select *
  from api.instance
  where id = $1.instance;
$$
language sql
rows 1  -- n.b. one-to-one
security definer  -- fixme: precludes inlining
stable;

create or replace function api.template(api.instance_field)
returns setof api.template_field
as $$
  select *
  from api.template_field
  where id = $1.template;
$$
language sql
rows 1  -- n.b. one-to-one
security definer  -- fixme: precludes inlining
stable;

create or replace function api.value(api.instance_field)
returns setof text
as $$
  select coalesce(
      languagetranslationvalue,
      languagemastersource,
      entityfieldinstancevalue
  ) as value
  from entity.entityfieldinstance
  left join public.languagemaster
      on entityfieldinstancevaluelanguagemasteruuid = languagemasteruuid
  left join public.languagetranslations
      on languagemasterid = languagetranslationmasterid
      and languagetranslationtypeid = (
          select systagid
          from public.systag
          where systagparentid = 2 and systagtype = current_setting('user.preferred_language', true)
      )
  where entityfieldinstanceuuid = $1.id;
$$
language sql
rows 1  -- n.b. one-to-one
security definer  -- fixme: precludes inlining
stable;

create or replace function api.fields(api.instance)
returns setof api.instance_field
as $$
  select *
  from api.instance_field
  where instance = $1.id;
$$
language sql
security definer -- fixme: precludes inlining
stable;

commit;
