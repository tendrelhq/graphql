BEGIN;

/*
DROP FUNCTION api.delete_systag(uuid,uuid);
DROP FUNCTION api.delete_reason_code(uuid,uuid,text,text);
DROP FUNCTION api.delete_location(uuid,uuid);
DROP FUNCTION api.delete_entity_template(uuid,uuid);
DROP FUNCTION api.delete_entity_tag(uuid,uuid);
DROP FUNCTION api.delete_entity_instance_file(uuid,uuid);
DROP FUNCTION api.delete_entity_instance_field(uuid,uuid);
DROP FUNCTION api.delete_entity_instance(uuid,uuid);
DROP FUNCTION api.delete_entity_field(uuid,uuid);
DROP FUNCTION api.delete_entity_description(uuid,uuid);
DROP FUNCTION api.delete_customer_requested_language(uuid,text);
DROP FUNCTION api.delete_customer(uuid,uuid);
DROP FUNCTION api.delete_custag(uuid,uuid);
DROP TRIGGER update_location_tg ON api.location;
DROP TRIGGER update_systag_tg ON api.systag;
DROP TRIGGER update_entity_tag_tg ON api.entity_tag;
DROP TRIGGER update_entity_template_tg ON api.entity_template;
DROP TRIGGER create_location_tg ON api.location;
DROP TRIGGER create_systag_tg ON api.systag;
DROP TRIGGER create_runtime_upload_tg ON api.runtime_upload;
DROP TRIGGER update_entity_instance_field_tg ON api.entity_instance_field;
DROP TRIGGER update_entity_instance_file_tg ON api.entity_instance_file;
DROP TRIGGER create_entity_template_tg ON api.entity_template;
DROP TRIGGER create_entity_tag_tg ON api.entity_tag;
DROP TRIGGER update_entity_instance_tg ON api.entity_instance;
DROP TRIGGER create_entity_instance_file_tg ON api.entity_instance_file;
DROP TRIGGER update_entity_field_tg ON api.entity_field;
DROP TRIGGER create_entity_instance_field_tg ON api.entity_instance_field;
DROP TRIGGER update_entity_description_tg ON api.entity_description;
DROP TRIGGER update_customer_requested_language_tg ON api.customer_requested_language;
DROP TRIGGER create_entity_instance_tg ON api.entity_instance;
DROP TRIGGER update_customer_tg ON api.customer;
DROP TRIGGER create_entity_field_tg ON api.entity_field;
DROP TRIGGER create_entity_description_tg ON api.entity_description;
DROP TRIGGER create_customer_requested_language_tg ON api.customer_requested_language;
DROP TRIGGER create_customer_tg ON api.customer;
DROP TRIGGER update_custag_tg ON api.custag;
DROP TRIGGER create_custag_tg ON api.custag;
DROP FUNCTION api.token(api.grant_type,text,api.token_type,text);
DROP VIEW api.timezone;
DROP VIEW api.runtime_upload;
DROP VIEW api.language;
DROP VIEW api.entity_instance_field_ux;
DROP VIEW api.alltag;
DROP FUNCTION api.update_systag();
DROP FUNCTION api.update_location();
DROP FUNCTION api.update_entity_template();
DROP FUNCTION api.update_entity_tag();
DROP FUNCTION api.update_entity_instance_file();
DROP FUNCTION api.update_entity_instance_field();
DROP FUNCTION api.update_entity_instance();
DROP FUNCTION api.update_entity_field();
DROP FUNCTION api.update_entity_description();
DROP FUNCTION api.update_customer_requested_language();
DROP FUNCTION api.update_customer();
DROP FUNCTION api.update_custag();
DROP FUNCTION api.token_introspect(text);
DROP VIEW api.systag;
DROP VIEW api.reason_code;
DROP VIEW api.location;
DROP VIEW api.entity_template;
DROP VIEW api.entity_tag;
DROP VIEW api.entity_instance_file;
DROP VIEW api.entity_instance_field;
DROP VIEW api.entity_instance;
DROP VIEW api.entity_field;
DROP VIEW api.entity_description;
DROP VIEW api.customer_requested_language;
DROP VIEW api.customer;
DROP VIEW api.custag;
DROP FUNCTION api.create_systag();
DROP FUNCTION api.create_runtime_upload();
DROP FUNCTION api.create_reason_code();
DROP FUNCTION api.create_location();
DROP FUNCTION api.create_entity_template();
DROP FUNCTION api.create_entity_tag();
DROP FUNCTION api.create_entity_instance_file();
DROP FUNCTION api.create_entity_instance_field();
DROP FUNCTION api.create_entity_instance();
DROP FUNCTION api.create_entity_field();
DROP FUNCTION api.create_entity_description();
DROP FUNCTION api.create_customer_requested_language();
DROP FUNCTION api.create_customer();
DROP FUNCTION api.create_custag();
DROP TYPE api.token_type;
DROP TYPE api.grant_type;

DROP SCHEMA api;
*/

CREATE SCHEMA api;
COMMENT ON SCHEMA api IS '
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
';

GRANT USAGE ON SCHEMA api TO anonymous;

-- DEPENDANTS

CREATE TYPE api.grant_type AS ENUM (
 'urn:ietf:params:oauth:grant-type:token-exchange'
);


GRANT USAGE ON TYPE api.grant_type TO PUBLIC;
CREATE TYPE api.token_type AS ENUM (
 'urn:ietf:params:oauth:token-type:jwt'
);


GRANT USAGE ON TYPE api.token_type TO PUBLIC;

-- Type: FUNCTION ; Name: api.create_custag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_custag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_bigint bigint;
  ins_text text;
  ins_entity uuid;
  ins_row api.custag%rowtype;
 	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
	ins_customerentityuuid uuid;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid);

if (select new.owner in (select * from _api.util_get_onwership()))
	then
	  call entity.crud_custag_create(
	  		create_custagownerentityuuid := new.owner, 
			create_custagparententityuuid := new.parent, 
			create_custagcornerstoneentityuuid := new.cornerstone, 
			create_custagcornerstoneorder := new._order, 
			create_custag := new.type, 
			create_languagetypeuuid := ins_languagetypeentityuuid, 
			create_custagexternalid := new.external_id, 
			create_custagexternalsystemuuid := new.external_system,
			create_custagdeleted := new._deleted, 
			create_custagdraft := new._draft, 
			create_custagid := ins_bigint, 
			create_custaguuid := ins_text, 
			create_custagentityuuid := ins_entity, 
			create_modifiedbyid := ins_userid  
	  );
end if;

  select * into ins_row
  from api.custag
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_custag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_custag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_custag() TO authenticated;

-- Type: FUNCTION ; Name: api.create_customer(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_customer()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_customeruuid text;
	ins_customerentityuuid uuid;
	ins_entity uuid;
	ins_row api.customer%rowtype;
	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
	
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();


select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid)   ;



if new.parent isNull 
	then new.parent = ins_customerentityuuid;
end if;

if (select new.parent in (select * from _api.util_get_onwership())) or (new.parent isNull)
	then
		call entity.crud_customer_create(
			create_customername := new.name,
			create_customeruuid := ins_customeruuid, 
			create_customerentityuuid := ins_entity, 
			create_customerparentuuid := new.parent,  
			create_customerowner := null::uuid,  
			create_customerbillingid :=  new.external_id,  
			create_customerbillingsystemid := new.external_system, 
			create_customerdeleted := new._deleted, 
			create_customerdraft := new._draft, 
			create_languagetypeuuids := Array[ins_languagetypeentityuuid],  
			create_modifiedby := ins_userid  
	  );
	else
		return null;  -- need an exception here
end if;

  select * into ins_row
  from api.customer
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_customer() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_customer() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_customer() TO authenticated;

-- Type: FUNCTION ; Name: api.create_customer_requested_language(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_customer_requested_language()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_customeruuid text;
	ins_customerentityuuid uuid;
	ins_entity bigint;
	ins_row api.customer_requested_language%rowtype;
	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
	
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (select new.owner in (select * from _api.util_get_onwership())) or (new.languagetype_id notNull)
	then
		call entity.crud_customerrequestedlanguage_create(
			create_customerrequestedlanguageownerentityuuid := new.owner,
			create_languagetype_id  := new.languagetype_id,
			create_customerrequestedlanguagedeleted := null::boolean,
			create_customerrequestedlanguagedraft := null::boolean,
			create_customerrequestedlanguageid := ins_entity,
			create_modifiedbyid  := ins_userid 
	  	);
	else
		return null;  -- need an exception here
end if;

  select * into ins_row
  from api.customer_requested_language
  where id = (select customerrequestedlanguageuuid from public.customerrequestedlanguage where customerrequestedlanguageid = ins_entity);

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.create_customer_requested_language() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_customer_requested_language() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_customer_requested_language() TO authenticated;

-- Type: FUNCTION ; Name: api.create_entity_description(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_description()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_description%rowtype;
    ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;

begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (select new.owner in (select * from _api.util_get_onwership()))
	then
	call entity.crud_entitydescription_create(
		create_entitydescriptionownerentityuuid  := new.owner, 
		create_entitytemplateentityuuid  := new.template, 
		create_entityfieldentityuuid  := new.field, 
		create_entitydescriptionname  := new.description, 
		create_entitydescriptionsoplink  := new.sop_link, 
		create_entitydescriptionfile  := new.file_link, 
		create_entitydescriptionicon  := new.icon_link, 
		create_entitydescriptionmimetypeuuid  := new.file_mime_type, 
		create_languagetypeuuid  := ins_languagetypeentityuuid, 
		create_entitydescriptiondeleted  := false, 
		create_entitydescriptiondraft  := new._draft,  
		create_entitydescriptionentityuuid  := ins_entity, 
		create_modifiedbyid :=ins_userid  
  	);
end if;

  select * into ins_row
  from api.entity_description
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_description() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_description() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_description() TO authenticated;

-- Type: FUNCTION ; Name: api.create_entity_field(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_field%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

  	if new.owner = 'f90d618d-5de7-4126-8c65-0afb700c6c61' and new._primary = true
  		then new._primary = true;
		else new._primary = false;
	end if;

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (select new.owner in (select * from _api.util_get_onwership()))
	then
  call entity.crud_entityfield_create(
      create_entityfieldownerentityuuid := new.owner,
      create_entityfieldparententityuuid := new.parent,
      create_entityfieldtemplateentityuuid := new.template,
      create_entityfieldcornerstoneorder := new._order,
      create_entityfieldname := new.name,
      create_entityfieldtypeentityuuid := new.type,
      create_entityfieldentityparenttypeentityuuid := new.parent_type,
      create_entityfieldentitytypeentityuuid := new.entity_type,
      create_entityfielddefaultvalue := new.default_value,
      create_entityfieldformatentityuuid := new.format,
      create_entityfieldformatentityname := null::text,  -- save for an all in rpc
      create_entityfieldwidgetentityuuid := new.widget,
      create_entityfieldwidgetentityname := null::text,  -- save for an all in rpc
      create_entityfieldiscalculated := new._calculated::boolean,
      create_entityfieldiseditable := new._editable::boolean,
      create_entityfieldisvisible := new._visible::boolean,
      create_entityfieldisrequired := new._required::boolean,
      create_entityfieldisprimary := new._primary,
      create_entityfieldtranslate := new._translate::boolean,
      create_entityfieldexternalid := new.external_id::text,
      create_entityfieldexternalsystemuuid := new.external_system::uuid,
      create_languagetypeuuid := ins_languagetypeentityuuid,
      create_entityfielddeleted := new._deleted,
      create_entityfielddraft := new._draft,
      create_modifiedbyid := ins_userid,
      create_entityfieldentityuuid := ins_entity
  );
end if;

  select * into ins_row
  from api.entity_field
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_field() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_field() TO authenticated;

-- Type: FUNCTION ; Name: api.create_entity_instance(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_instance()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance%rowtype;
    	ins_customeruuid text;
	ins_customerentityuuid uuid;
	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid)   ;


if (select new.owner in (select * from _api.util_get_onwership()))
	then
  call entity.crud_entityinstance_create(
      create_entityinstanceownerentityuuid := new.owner,
      create_entityinstanceentitytemplateentityuuid := new.template,
      create_entityinstanceentitytemplateentityname := null::text,   -- save for an all in rpc
      create_entityinstanceparententityuuid := new.parent,
      create_entityinstanceecornerstoneentityuuid := new.cornerstone,  
      create_entityinstancecornerstoneorder := new._order,
      create_entityinstancetaguuid := null::uuid,   -- save for an all in rpc
      create_entityinstancetag := null::text,   -- save for an all in rpc
      create_entityinstancename := new.name,
      create_entityinstancescanid := new.scan_code,
      create_entityinstancetypeuuid := new.type,
      create_entityinstanceexternalid := new.external_id,
      create_entityinstanceexternalsystemuuid := new.external_system,
      create_entityinstancedeleted := new._deleted,
      create_entityinstancedraft := new._draft,
      create_languagetypeuuid := ins_languagetypeentityuuid,  
      create_modifiedbyid := ins_userid,  
      create_entityinstanceentityuuid := ins_entity
  );
end if;

  select * into ins_row
  from api.entity_instance
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_instance() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_instance() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_instance() TO authenticated;

-- Type: FUNCTION ; Name: api.create_entity_instance_field(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_instance_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance_field%rowtype;
begin

if (select new.owner in (select * from _api.util_get_onwership()))
	then
  call entity.crud_entityfieldinstance_create(
      create_entityfieldinstanceownerentityuuid := new.owner,
      create_entityfieldinstanceentityinstanceentityuuid := new.instance,
      create_entityfieldinstanceentityfieldentityuuid := new.field,
      create_entityfieldinstancevalue := new.value,
      create_entityfieldinstanceentityfieldname := null::text,  -- saved for SP in the future
      create_entityfieldformatentityuuid := null::uuid,  -- saved for SP in the future
      create_entityfieldformatentityname := null::text,  -- saved for SP in the future
      create_entityfieldwidgetentityuuid := null::uuid,  -- saved for SP in the future
      create_entityfieldwidgetentityname := null::text,  -- saved for SP in the future
      create_entityfieldinstanceexternalid := null::text,
      create_entityfieldinstanceexternalsystemuuid := null::uuid,
      create_entityfieldinstancedeleted := new._deleted,
      create_entityfieldinstancedraft := new._draft,
      create_languagetypeuuid := ins_languagetypeentityuuid,  
      create_modifiedbyid := ins_userid,  
      create_entityfieldinstanceentityuuid := ins_entity
  );
 end if;

  select * into ins_row
  from api.entity_instance_field
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_instance_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_instance_field() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_instance_field() TO authenticated;

-- Type: FUNCTION ; Name: api.create_entity_instance_file(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_instance_file()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance_file%rowtype;
begin

if (select new.owner in (select * from _api.util_get_onwership()))
	then
	call entity.crud_entityfileinstance_create(
		create_entityfileinstanceownerentityuuid := new.owner, 
		create_entityfileinstanceentityentityinstanceentityuuid := new.instance, 
		create_entityfileinstanceentityfieldinstanceentityuuid := new.field_instance, 
		create_entityfileinstancestoragelocation := new.file_link, 
		create_entityfileinstancemimetypeuuid := new.file_mime_type, 
		create_languagetypeuuid := ins_languagetypeentityuuid,  
		create_entityfileinstancedeleted := new._deleted, 
		create_entityfileinstancedraft := new._draft, 
		create_entityfileinstanceentityuuid := ins_entity, 
		create_modifiedbyid := ins_userid  
  );
end if;

  select * into ins_row
  from api.entity_instance_file
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_instance_file() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_instance_file() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_instance_file() TO authenticated;

-- Type: FUNCTION ; Name: api.create_entity_tag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_tag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_entity uuid;
	ins_row api.entity_tag%rowtype;
	ins_customeruuid text;
	ins_customerentityuuid uuid;
	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;

begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid)   ;

if (select new.owner in (select * from _api.util_get_onwership()))
	then
	call entity.crud_entitytag_create(
		create_entitytagownerentityuuid := new.owner, 
		create_entitytagentityinstanceuuid := new.instance, 
		create_entitytagentitytemplateuuid := new.template , 
		create_entitytagcustaguuid := new.customer_tag, 
		create_languagetypeuuid := ins_languagetypeentityuuid,    
		create_entitytagdeleted := false,  
		create_entitytagdraft := false,  
		create_entitytaguuid := ins_entity, 
		create_modifiedbyid :=ins_userid 
	);
end if;

  select * into ins_row
  from api.entity_tag
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_tag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_tag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_tag() TO authenticated;

-- Type: FUNCTION ; Name: api.create_entity_template(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_template()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_template%rowtype;
  	ins_customeruuid text;
	ins_customerentityuuid uuid;
	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;

begin

-- only tendrel can have primary templates

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid)   ;

  	if new.owner = 'f90d618d-5de7-4126-8c65-0afb700c6c61' and new._primary = true
  		then new._primary = true;
		else new._primary = false;
	end if;
	
if (select new.owner in (select * from _api.util_get_onwership()) )
	then
	  call entity.crud_entitytemplate_create(
	      create_entitytemplatecornerstoneorder := new._order,   
	      create_entitytemplatedeleted := false, 
	      create_entitytemplatedraft := new._draft,  
	      create_entitytemplateexternalid := new.external_id,  
	      create_entitytemplateexternalsystemuuid := new.external_system,  
	      create_entitytemplateisprimary := new._primary, 
	      create_entitytemplatename := new.name,  
	      create_entitytemplateownerentityuuid := new.owner, 
	      create_entitytemplateparententityuuid := new.parent, 
	      create_entitytemplatescanid := new.scan_code,  
	      create_entitytemplatetag := null::text,  -- save for an all in rpc
	      create_entitytemplatetaguuid := null::uuid, -- save for an all in rpc
	      create_languagetypeuuid := ins_languagetypeentityuuid,  -- Fix this later
	      create_modifiedbyid :=ins_userid,  -- Fix this later
	      create_entitytemplateentityuuid := ins_entity
	  );
end if;

  select * into ins_row
  from api.entity_template
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_template() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_template() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_template() TO authenticated;

-- Type: FUNCTION ; Name: api.create_location(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_location()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_entity uuid;
	ins_row api.location%rowtype;
	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (select new.owner in (select * from _api.util_get_onwership()) )
	then
	  call entity.crud_location_create(
	  		create_locationownerentityuuid := new.owner, 
			create_locationparententityuuid := new.parent, 
			create_locationcornerstoneentityuuid := new.cornerstone,  
			create_locationcornerstoneorder := new._order,  
			create_locationtaguuid := null::uuid,  
			create_locationtag := null::text,  
			create_locationname := new.name, 
			create_locationdisplayname := new.displayname, 
			create_locationscanid := new.scan_code, 
			create_locationtimezone := new.timezone, 
			create_languagetypeuuid := ins_languagetypeentityuuid, 
			create_locationexternalid := new.external_id, 
			create_locationexternalsystemuuid := new.external_system, 
			create_locationlatitude := new.latitude::text, 
			create_locationlongitude := new.longitude::text, 
			create_locationradius := new.radius::text, 
			create_locationdeleted := new._deleted, 
			create_locationdraft := new._draft, 
			create_locationentityuuid := ins_entity, 
			create_modifiedbyid := ins_userid  
	  );
	else
		return null;  -- need an exception here
end if;
			


  select * into ins_row
  from api.location
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_location() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_location() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_location() TO authenticated;

-- Type: FUNCTION ; Name: api.create_reason_code(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_reason_code()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_bigint bigint;
  ins_text text;
  ins_entity uuid;
  ins_row api.custag%rowtype;
 	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
	ins_customerentityuuid uuid;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid);

if (select new.owner in (select * from _api.util_get_onwership()))
	then
	  call entity.crud_custag_create(
	  		create_custagownerentityuuid := new.owner, 
			create_custagparententityuuid := 'f875b28c-ccc9-4c69-b5b4-9f10ad89d23b', 
			create_custagcornerstoneentityuuid := new.cornerstone, 
			create_custagcornerstoneorder := new._order, 
			create_custag := new.type, 
			create_languagetypeuuid := ins_languagetypeentityuuid, 
			create_custagexternalid := new.external_id, 
			create_custagexternalsystemuuid := new.external_system,
			create_custagdeleted := new._deleted, 
			create_custagdraft := new._draft, 
			create_custagid := ins_bigint, 
			create_custaguuid := ins_text, 
			create_custagentityuuid := ins_entity, 
			create_modifiedbyid := ins_userid  
	  );
	-- NEED TO MAKE SURE CREATE RETURNS THE ID IF IT ALREADT EXISTS
	-- Now add the constraint

	if new.work_template notNull
		then
			INSERT INTO public.worktemplateconstraint(
				worktemplateconstraintcreateddate, 
				worktemplateconstraintmodifieddate, 
				worktemplateconstraintmodifiedby, 
				worktemplateconstraintrefid, 
				worktemplateconstraintrefuuid, 
				worktemplateconstraintconstrainedtypeid, 
				worktemplateconstraintconstraintid, 
				worktemplateconstrainttemplateid, 
				worktemplateconstraintresultid, 
				worktemplateconstraintcustomerid, 
				worktemplateconstraintcustomeruuid)
			select 
				now(),
				now(),
				ins_userid,
				null,
				null,
				'systag_4bbc3e18-de10-4f93-aabb-b1d051a2923d',
				ins_text,
				work_template,
				wr.id,
				wt.worktemplatecustomerid,
				(select customeruuid from public.customer where customerid = worktemplatecustomerid)
			from worktemplate wt
				inner join view_workresult wr
					on  workresultworktemplateid = worktemplateid
						and worktemplateid = work_template
						and languagetranslationtypeid = 20
						and workresultname = 'Reason Code'
				left join public.worktemplateconstraint
					on worktemplateconstrainttemplateid = wt.id
						and worktemplateconstraintresultid = wr.id
						and custagsystaguuid = worktemplateconstraintconstrainedtypeid
						and custaguuid = worktemplateconstraintconstraintid
						and custagcustomerid = worktemplateconstraintcustomerid
			where worktemplateconstraintid isNull;
	end if;  
end if;

  select * into ins_row
  from api.reason_code
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_reason_code() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_reason_code() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_reason_code() TO authenticated;

-- Type: FUNCTION ; Name: api.create_runtime_upload(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_runtime_upload()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.runtime_upload%rowtype;
    	ins_customeruuid text;
	ins_customerentityuuid uuid;
	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid)   ;

if (select new.owner_tendrel_id in (select * from _api.util_get_onwership()))
	then
		INSERT INTO entity.runtime_upload_staging(
			uploadowneruuid, 
			uploadbatchid, 
			uploadrecordid, 
			uploadpreviousrecordid, 
			uploadparentuuid, 
			uploadparentname, 
			uploadlocationuuid, 
			uploadlocationname, 
			uploadstartdate, 
			uploadenddate, 
			uploadduration, 
			uploademployee, 
			uploademployeeid, 
			uploademployeetendreluuid, 
			uploadactivityuuid, 
			uploadactivityname, 
			uploadreasoncodeuuid, 
			uploadreasoncodename, 
		    uploadunitrunoutput,	
		    uploadunitrejectcount,
			uploadresultuuid, 
			uploadresultname, 
			uploadunittypename, 
			uploadunittypeuuid, 
			uploadunitvalue,
			uploadrunid,
			languageid
			)
		values(
			new.owner_tendrel_id, 
			new.batch_id, 
			new.record_id, 
			new.previous_record_id, 
			new.parent_location_tendrel_id, 
			new.parent_location_name, 
			new.location_tendrel_id, 
			new.location_name, 
			new.start_date, 
			new.end_date, 
			new.duration, 
			new.worker, 
			new.worker_id, 
			new.worker_tendrel_id, 
			new.work_tendrel_id, 
			new.work_name, 
			new.reasoncode_tendrel_id, 
			new.reasoncode_name, 
			new.run_output,
		    new.reject_count,
			new.result_tendrel_id, 
			new.result_name, 
			null::text, 
			null::uuid, 
			new.value,
			new.run_id,
			ins_languagetypeid
			);
end if;

  select * into ins_row
  from api.runtime_upload
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_runtime_upload() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_runtime_upload() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_runtime_upload() TO authenticated;

-- Type: FUNCTION ; Name: api.create_systag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_systag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_bigint bigint;
  ins_text text;
  ins_entity uuid;
  ins_row api.systag%rowtype;
 	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
	ins_customerentityuuid uuid;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid);

if (select new.owner in (select * from _api.util_get_onwership()))
	then
		call entity.crud_systag_create(
			create_systagownerentityuuid := new.owner, 
			create_systagparententityuuid := new.parent, 
			create_systagcornerstoneentityuuid := new.cornerstone, 
			create_systagcornerstoneorder := new._order, 
			create_systag := new.type, 
			create_languagetypeuuid := ins_languagetypeentityuuid, 
			create_systagexternalid := new.external_id, 
			create_systagexternalsystemuuid := new.external_system,
			create_systagdeleted := new._deleted, 
			create_systagdraft := new._draft, 
			create_systagid := ins_bigint, 
			create_systaguuid := ins_text, 
			create_systagentityuuid := ins_entity, 
			create_modifiedbyid :=ins_userid  
			  );
end if;

  select * into ins_row
  from api.systag
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_systag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_systag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_systag() TO authenticated;

-- Type: VIEW ; Name: custag; Owner: tendreladmin

CREATE OR REPLACE VIEW api.custag AS
 SELECT custagentityuuid AS id,
    custagid AS legacy_id,
    custaguuid AS legacy_uuid,
    custagownerentityuuid AS owner,
    custagownerentityname AS owner_name,
    custagparententityuuid AS parent,
    custagparentname AS parent_name,
    custagcornerstoneentityid AS cornerstone,
    custagnameuuid AS name_id,
    custagname AS name,
    custagdisplaynameuuid AS displayname_id,
    custagdisplayname AS displayname,
    custagtype AS type,
    custagcreateddate AS created_at,
    custagmodifieddate AS updated_at,
    custagstartdate AS activated_at,
    custagenddate AS deactivated_at,
    custagexternalid AS external_id,
    custagexternalsystementityuuid AS external_system,
    custagmodifiedbyuuid AS modified_by,
    custagorder AS _order,
    systagsenddeleted AS _deleted,
    systagsenddrafts AS _draft,
    systagsendinactive AS _active
   FROM ( SELECT crud_custag_read_api.languagetranslationtypeentityuuid,
            crud_custag_read_api.custagid,
            crud_custag_read_api.custaguuid,
            crud_custag_read_api.custagentityuuid,
            crud_custag_read_api.custagownerentityuuid,
            crud_custag_read_api.custagownerentityname,
            crud_custag_read_api.custagparententityuuid,
            crud_custag_read_api.custagparentname,
            crud_custag_read_api.custagcornerstoneentityid,
            crud_custag_read_api.custagcustomerid,
            crud_custag_read_api.custagcustomeruuid,
            crud_custag_read_api.custagcustomerentityuuid,
            crud_custag_read_api.custagcustomername,
            crud_custag_read_api.custagnameuuid,
            crud_custag_read_api.custagname,
            crud_custag_read_api.custagdisplaynameuuid,
            crud_custag_read_api.custagdisplayname,
            crud_custag_read_api.custagtype,
            crud_custag_read_api.custagcreateddate,
            crud_custag_read_api.custagmodifieddate,
            crud_custag_read_api.custagstartdate,
            crud_custag_read_api.custagenddate,
            crud_custag_read_api.custagexternalid,
            crud_custag_read_api.custagexternalsystementityuuid,
            crud_custag_read_api.custagexternalsystemenname,
            crud_custag_read_api.custagmodifiedbyuuid,
            crud_custag_read_api.custagabbreviationentityuuid,
            crud_custag_read_api.custagabbreviationname,
            crud_custag_read_api.custagorder,
            crud_custag_read_api.systagsenddeleted,
            crud_custag_read_api.systagsenddrafts,
            crud_custag_read_api.systagsendinactive
           FROM entity.crud_custag_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_custag_read_api(languagetranslationtypeentityuuid, custagid, custaguuid, custagentityuuid, custagownerentityuuid, custagownerentityname, custagparententityuuid, custagparentname, custagcornerstoneentityid, custagcustomerid, custagcustomeruuid, custagcustomerentityuuid, custagcustomername, custagnameuuid, custagname, custagdisplaynameuuid, custagdisplayname, custagtype, custagcreateddate, custagmodifieddate, custagstartdate, custagenddate, custagexternalid, custagexternalsystementityuuid, custagexternalsystemenname, custagmodifiedbyuuid, custagabbreviationentityuuid, custagabbreviationname, custagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)) custag
  WHERE (custagownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.custag IS '
## Custag

A description of what an entity tempalte is and why it is used

### get {baseUrl}/custag

A bunch of comments explaining get

### del {baseUrl}/custag

A bunch of comments explaining del

### patch {baseUrl}/custag

A bunch of comments explaining patch
';

CREATE TRIGGER create_custag_tg INSTEAD OF INSERT ON api.custag FOR EACH ROW EXECUTE FUNCTION api.create_custag();
CREATE TRIGGER update_custag_tg INSTEAD OF UPDATE ON api.custag FOR EACH ROW EXECUTE FUNCTION api.update_custag();

GRANT INSERT ON api.custag TO authenticated;
GRANT SELECT ON api.custag TO authenticated;
GRANT UPDATE ON api.custag TO authenticated;

-- Type: VIEW ; Name: customer; Owner: tendreladmin

CREATE OR REPLACE VIEW api.customer AS
 SELECT customer.customerid AS legacy_id,
    customer.customeruuid AS legacy_uuid,
    customer.customerentityuuid AS id,
    customer.customerownerentityuuid AS owner,
    customer.customerparententityuuid AS parent,
    parent.customername AS parent_name,
    customer.customercornerstoneentityuuid AS cornerstonename_id,
    customer.customercornerstoneorder AS _order,
    customer.customernameuuid AS name_id,
    customer.customername AS name,
    customer.customerdisplaynameuuid AS displayname_id,
    customer.customerdisplayname AS displayname,
    customer.customertypeentityuuid AS type_id,
    customer.customertype AS type,
    customer.customercreateddate AS created_at,
    customer.customermodifieddate AS updated_at,
    customer.customerstartdate AS activated_at,
    customer.customerenddate AS deactivated_at,
    customer.customermodifiedbyuuid AS modified_by,
    customer.customerexternalid AS external_id,
    customer.customerexternalsystementityuuid AS external_system,
    customer.customersenddeleted AS _deleted,
    customer.customersenddrafts AS _draft,
    customer.customersendinactive AS _active
   FROM entity.crud_customer_read_full(NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) customer(customerid, customeruuid, customerentityuuid, customerownerentityuuid, customerparententityuuid, customercornerstoneentityuuid, customercornerstoneorder, customernameuuid, customername, customerdisplaynameuuid, customerdisplayname, customertypeentityuuid, customertype, customercreateddate, customermodifieddate, customerstartdate, customerenddate, customermodifiedbyuuid, customerexternalid, customerexternalsystementityuuid, customerexternalsystemname, customerrefid, customerrefuuid, customerlanguagetypeentityuuid, customersenddeleted, customersenddrafts, customersendinactive)
     JOIN entity.crud_customer_read_full(NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) parent(customerid, customeruuid, customerentityuuid, customerownerentityuuid, customerparententityuuid, customercornerstoneentityuuid, customercornerstoneorder, customernameuuid, customername, customerdisplaynameuuid, customerdisplayname, customertypeentityuuid, customertype, customercreateddate, customermodifieddate, customerstartdate, customerenddate, customermodifiedbyuuid, customerexternalid, customerexternalsystementityuuid, customerexternalsystemname, customerrefid, customerrefuuid, customerlanguagetypeentityuuid, customersenddeleted, customersenddrafts, customersendinactive) ON customer.customerparententityuuid = parent.customerentityuuid
  WHERE (customer.customerownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.customer IS '
## Entity Template

A description of what an customer is and why it is used

### get {baseUrl}/customer

A bunch of comments explaining get

### del {baseUrl}/customer

A bunch of comments explaining del

### patch {baseUrl}/customer

A bunch of comments explaining patch
';

CREATE TRIGGER create_customer_tg INSTEAD OF INSERT ON api.customer FOR EACH ROW EXECUTE FUNCTION api.create_customer();
CREATE TRIGGER update_customer_tg INSTEAD OF UPDATE ON api.customer FOR EACH ROW EXECUTE FUNCTION api.update_customer();

GRANT INSERT ON api.customer TO authenticated;
GRANT SELECT ON api.customer TO authenticated;
GRANT UPDATE ON api.customer TO authenticated;

-- Type: VIEW ; Name: customer_requested_language; Owner: tendreladmin

CREATE OR REPLACE VIEW api.customer_requested_language AS
 SELECT crl.customerrequestedlanguageid AS legacy_id,
    crl.customerrequestedlanguagecustomerid AS legacy_customer_id,
    customer.customerentityuuid AS owner,
    customer.customerdisplayname AS owner_name,
    lang.systagentityuuid AS languagetype_id,
    lang.systagname AS name,
    lang.systagdisplayname AS displayname,
    crl.customerrequestedlanguagestartdate AS activated_at,
    crl.customerrequestedlanguageenddate AS deactivated_at,
    crl.customerrequestedlanguagecreateddate AS created_at,
    crl.customerrequestedlanguagemodifieddate AS updated_at,
    crl.customerrequestedlanguageexternalid AS external_id,
    crl.customerrequestedlanguageexternalsystemid AS external_system,
        CASE
            WHEN crl.customerrequestedlanguagestartdate IS NULL THEN true
            ELSE false
        END AS customerrequestedlanguagedraft,
        CASE
            WHEN crl.customerrequestedlanguageenddate::date < now()::date THEN true
            ELSE false
        END AS customerrequestedlanguagedeleted,
        CASE
            WHEN (crl.customerrequestedlanguageenddate::date > now()::date OR crl.customerrequestedlanguageenddate::date IS NULL) AND crl.customerrequestedlanguagestartdate < now() THEN true
            ELSE false
        END AS customerrequestedlanguageactive,
    crl.customerrequestedlanguagemodifiedby AS modified_by,
    crl.customerrequestedlanguageuuid AS id
   FROM customerrequestedlanguage crl
     JOIN ( SELECT crud_customer_read_full.customerid,
            crud_customer_read_full.customeruuid,
            crud_customer_read_full.customerentityuuid,
            crud_customer_read_full.customerownerentityuuid,
            crud_customer_read_full.customerparententityuuid,
            crud_customer_read_full.customercornerstoneentityuuid,
            crud_customer_read_full.customercornerstoneorder,
            crud_customer_read_full.customernameuuid,
            crud_customer_read_full.customername,
            crud_customer_read_full.customerdisplaynameuuid,
            crud_customer_read_full.customerdisplayname,
            crud_customer_read_full.customertypeentityuuid,
            crud_customer_read_full.customertype,
            crud_customer_read_full.customercreateddate,
            crud_customer_read_full.customermodifieddate,
            crud_customer_read_full.customerstartdate,
            crud_customer_read_full.customerenddate,
            crud_customer_read_full.customermodifiedbyuuid,
            crud_customer_read_full.customerexternalid,
            crud_customer_read_full.customerexternalsystementityuuid,
            crud_customer_read_full.customerexternalsystemname,
            crud_customer_read_full.customerrefid,
            crud_customer_read_full.customerrefuuid,
            crud_customer_read_full.customerlanguagetypeentityuuid,
            crud_customer_read_full.customersenddeleted,
            crud_customer_read_full.customersenddrafts,
            crud_customer_read_full.customersendinactive
           FROM entity.crud_customer_read_full(NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_customer_read_full(customerid, customeruuid, customerentityuuid, customerownerentityuuid, customerparententityuuid, customercornerstoneentityuuid, customercornerstoneorder, customernameuuid, customername, customerdisplaynameuuid, customerdisplayname, customertypeentityuuid, customertype, customercreateddate, customermodifieddate, customerstartdate, customerenddate, customermodifiedbyuuid, customerexternalid, customerexternalsystementityuuid, customerexternalsystemname, customerrefid, customerrefuuid, customerlanguagetypeentityuuid, customersenddeleted, customersenddrafts, customersendinactive)) customer ON customer.customerid = crl.customerrequestedlanguagecustomerid
     JOIN ( SELECT crud_systag_read_full.languagetranslationtypeentityuuid,
            crud_systag_read_full.systagid,
            crud_systag_read_full.systaguuid,
            crud_systag_read_full.systagentityuuid,
            crud_systag_read_full.systagcustomerid,
            crud_systag_read_full.systagcustomeruuid,
            crud_systag_read_full.systagcustomerentityuuid,
            crud_systag_read_full.systagcustomername,
            crud_systag_read_full.systagnameuuid,
            crud_systag_read_full.systagname,
            crud_systag_read_full.systagdisplaynameuuid,
            crud_systag_read_full.systagdisplayname,
            crud_systag_read_full.systagtype,
            crud_systag_read_full.systagcreateddate,
            crud_systag_read_full.systagmodifieddate,
            crud_systag_read_full.systagstartdate,
            crud_systag_read_full.systagenddate,
            crud_systag_read_full.systagexternalid,
            crud_systag_read_full.systagexternalsystementityuuid,
            crud_systag_read_full.systagexternalsystementname,
            crud_systag_read_full.systagmodifiedbyuuid,
            crud_systag_read_full.systagabbreviationentityuuid,
            crud_systag_read_full.systagabbreviationname,
            crud_systag_read_full.systagparententityuuid,
            crud_systag_read_full.systagparentname,
            crud_systag_read_full.systagorder,
            crud_systag_read_full.systagsenddeleted,
            crud_systag_read_full.systagsenddrafts,
            crud_systag_read_full.systagsendinactive
           FROM entity.crud_systag_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_systag_read_full(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagcustomername, systagnameuuid, systagname, systagdisplaynameuuid, systagdisplayname, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagexternalsystementname, systagmodifiedbyuuid, systagabbreviationentityuuid, systagabbreviationname, systagparententityuuid, systagparentname, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)) lang ON lang.systagid = crl.customerrequestedlanguagelanguageid
  WHERE (customer.customerownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.customer_requested_language IS '
## customer_requested_language

A description of what an customer is and why it is used

### get {baseUrl}/customer_requested_language

A bunch of comments explaining get

### del {baseUrl}/customer_requested_language

A bunch of comments explaining del

### patch {baseUrl}/customer_requested_language

A bunch of comments explaining patch
';

CREATE TRIGGER create_customer_requested_language_tg INSTEAD OF INSERT ON api.customer_requested_language FOR EACH ROW EXECUTE FUNCTION api.create_customer_requested_language();
CREATE TRIGGER update_customer_requested_language_tg INSTEAD OF UPDATE ON api.customer_requested_language FOR EACH ROW EXECUTE FUNCTION api.update_customer_requested_language();

GRANT INSERT ON api.customer_requested_language TO authenticated;
GRANT SELECT ON api.customer_requested_language TO authenticated;
GRANT UPDATE ON api.customer_requested_language TO authenticated;

-- Type: VIEW ; Name: entity_description; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_description AS
 SELECT entitydescriptionuuid AS id,
    entitydescriptionownerentityuuid AS owner,
    entitydescriptionownerentityname AS owner_name,
    entitydescriptionentitytemplateentityuuid AS template,
    entitydescriptionentitytemplateentityname AS template_name,
    entitydescriptionentityfieldentityduuid AS field,
    entitydescriptionentityfieldentitydname AS field_name,
    entitydescriptionlanguagemasteruuid AS description_id,
    entitydescriptionname AS description,
    entitydescriptionsoplink AS sop_link,
    entitydescriptionfile AS file_link,
    entitydescriptionmimetypeuuid AS file_mime_type,
    entitydescriptionicon AS icon_link,
    entitydescriptionexternalid AS external_id,
    entitydescriptionexternalsystementityuuid AS external_system,
    entitydescriptiondeleted AS _deleted,
    entitydescriptiondraft AS _draft,
    entitydescriptionactive AS _active,
    entitydescriptionstartdate AS activated_at,
    entitydescriptionenddate AS deactivated_at,
    entitydescriptioncreateddate AS created_at,
    entitydescriptionmodifieddate AS updated_at,
    entitydescriptionmodifiedby AS modified_by
   FROM ( SELECT crud_entitydescription_read_full.languagetranslationtypeuuid,
            crud_entitydescription_read_full.entitydescriptionuuid,
            crud_entitydescription_read_full.entitydescriptionownerentityuuid,
            crud_entitydescription_read_full.entitydescriptionownerentityname,
            crud_entitydescription_read_full.entitydescriptionentitytemplateentityuuid,
            crud_entitydescription_read_full.entitydescriptionentitytemplateentityname,
            crud_entitydescription_read_full.entitydescriptionentityfieldentityduuid,
            crud_entitydescription_read_full.entitydescriptionentityfieldentitydname,
            crud_entitydescription_read_full.entitydescriptionname,
            crud_entitydescription_read_full.entitydescriptionlanguagemasteruuid,
            crud_entitydescription_read_full.entitydescriptionsoplink,
            crud_entitydescription_read_full.entitydescriptionfile,
            crud_entitydescription_read_full.entitydescriptionicon,
            crud_entitydescription_read_full.entitydescriptiontranslatedname,
            crud_entitydescription_read_full.entitydescriptioncreateddate,
            crud_entitydescription_read_full.entitydescriptionmodifieddate,
            crud_entitydescription_read_full.entitydescriptionstartdate,
            crud_entitydescription_read_full.entitydescriptionenddate,
            crud_entitydescription_read_full.entitydescriptionmodifiedby,
            crud_entitydescription_read_full.entitydescriptionexternalid,
            crud_entitydescription_read_full.entitydescriptionexternalsystementityuuid,
            crud_entitydescription_read_full.entitydescriptionrefid,
            crud_entitydescription_read_full.entitydescriptionrefuuid,
            crud_entitydescription_read_full.entitydescriptiondraft,
            crud_entitydescription_read_full.entitydescriptiondeleted,
            crud_entitydescription_read_full.entitydescriptionactive,
            crud_entitydescription_read_full.entitydescriptionmimetypeuuid,
            crud_entitydescription_read_full.entitydescriptionmimetypename
           FROM entity.crud_entitydescription_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entitydescription_read_full(languagetranslationtypeuuid, entitydescriptionuuid, entitydescriptionownerentityuuid, entitydescriptionownerentityname, entitydescriptionentitytemplateentityuuid, entitydescriptionentitytemplateentityname, entitydescriptionentityfieldentityduuid, entitydescriptionentityfieldentitydname, entitydescriptionname, entitydescriptionlanguagemasteruuid, entitydescriptionsoplink, entitydescriptionfile, entitydescriptionicon, entitydescriptiontranslatedname, entitydescriptioncreateddate, entitydescriptionmodifieddate, entitydescriptionstartdate, entitydescriptionenddate, entitydescriptionmodifiedby, entitydescriptionexternalid, entitydescriptionexternalsystementityuuid, entitydescriptionrefid, entitydescriptionrefuuid, entitydescriptiondraft, entitydescriptiondeleted, entitydescriptionactive, entitydescriptionmimetypeuuid, entitydescriptionmimetypename)) entitydescription
  WHERE (entitydescriptionownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.entity_description IS '
## Entity Template

A description of what an entity tempalte is and why it is used

### get {baseUrl}/entity_template

A bunch of comments explaining get

### del {baseUrl}/entity_template

A bunch of comments explaining del

### patch {baseUrl}/entity_template

A bunch of comments explaining patch
';

CREATE TRIGGER create_entity_description_tg INSTEAD OF INSERT ON api.entity_description FOR EACH ROW EXECUTE FUNCTION api.create_entity_description();
CREATE TRIGGER update_entity_description_tg INSTEAD OF UPDATE ON api.entity_description FOR EACH ROW EXECUTE FUNCTION api.update_entity_description();

GRANT INSERT ON api.entity_description TO authenticated;
GRANT SELECT ON api.entity_description TO authenticated;
GRANT UPDATE ON api.entity_description TO authenticated;

-- Type: VIEW ; Name: entity_field; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_field AS
 SELECT entityfield.entityfielduuid AS id,
    entityfield.entityfieldownerentityuuid AS owner,
    entityfield.entityfieldcustomername AS owner_name,
    entityfield.entityfieldparententityuuid AS parent,
    entityfield.entityfieldsitename AS parent_name,
    entityfield.entityfieldentityparenttypeentityuuid AS parent_type,
    entityfield.entityfieldentitytypeentityuuid AS entity_type,
    entityfield.entityfieldentitytypename AS entity_type_name,
    entityfield.entityfieldexternalid AS external_id,
    entityfield.entityfieldexternalsystementityuuid AS external_system,
    entityfield.entityfieldentitytemplateentityuuid AS template,
    entitytemplate.entitytemplatename AS template_name,
    entityfield.entityfieldtypeentityuuid AS type,
    entityfield.entityfieldtypename AS type_name,
    entityfield.entityfieldlanguagemasteruuid AS name_id,
    entityfield.entityfieldname AS name,
    entityfield.entityfieldformatentityuuid AS format,
    entityfield.entityfieldformatname AS format_name,
    entityfield.entityfieldwidgetentityuuid AS widget,
    entityfield.entityfieldwidgetname AS widget_name,
    entityfield.entityfieldorder::integer AS _order,
    entityfield.entityfielddefaultvalue AS default_value,
    entityfield.entityfieldisprimary AS _primary,
    entityfield.entityfieldiscalculated AS _calculated,
    entityfield.entityfieldiseditable AS _editable,
    entityfield.entityfieldisvisible AS _visible,
    entityfield.entityfieldisrequired AS _required,
    entityfield.entityfieldtranslate AS _translate,
    entityfield.entityfielddeleted AS _deleted,
    entityfield.entityfielddraft AS _draft,
        CASE
            WHEN entityfield.entityfieldenddate IS NOT NULL AND entityfield.entityfieldenddate::date < now()::date THEN false
            ELSE true
        END AS _active,
    entityfield.entityfieldstartdate AS activated_at,
    entityfield.entityfieldenddate AS deactivated_at,
    entityfield.entityfieldcreateddate AS created_at,
    entityfield.entityfieldmodifieddate AS updated_at,
    entityfield.entityfieldmodifiedbyuuid AS modified_by
   FROM ( SELECT crud_entityfield_read_full.languagetranslationtypeuuid,
            crud_entityfield_read_full.entityfielduuid,
            crud_entityfield_read_full.entityfieldentitytemplateentityuuid,
            crud_entityfield_read_full.entityfieldcreateddate,
            crud_entityfield_read_full.entityfieldmodifieddate,
            crud_entityfield_read_full.entityfieldstartdate,
            crud_entityfield_read_full.entityfieldenddate,
            crud_entityfield_read_full.entityfieldlanguagemasteruuid,
            crud_entityfield_read_full.entityfieldtranslatedname,
            crud_entityfield_read_full.entityfieldorder,
            crud_entityfield_read_full.entityfielddefaultvalue,
            crud_entityfield_read_full.entityfieldiscalculated,
            crud_entityfield_read_full.entityfieldiseditable,
            crud_entityfield_read_full.entityfieldisvisible,
            crud_entityfield_read_full.entityfieldisrequired,
            crud_entityfield_read_full.entityfieldformatentityuuid,
            crud_entityfield_read_full.entityfieldformatname,
            crud_entityfield_read_full.entityfieldwidgetentityuuid,
            crud_entityfield_read_full.entityfieldwidgetname,
            crud_entityfield_read_full.entityfieldexternalid,
            crud_entityfield_read_full.entityfieldexternalsystementityuuid,
            crud_entityfield_read_full.entityfieldexternalsystemname,
            crud_entityfield_read_full.entityfieldmodifiedbyuuid,
            crud_entityfield_read_full.entityfieldmodifiedby,
            crud_entityfield_read_full.entityfieldrefid,
            crud_entityfield_read_full.entityfieldrefuuid,
            crud_entityfield_read_full.entityfieldisprimary,
            crud_entityfield_read_full.entityfieldtranslate,
            crud_entityfield_read_full.entityfieldname,
            crud_entityfield_read_full.entityfieldownerentityuuid,
            crud_entityfield_read_full.entityfieldcustomername,
            crud_entityfield_read_full.entityfieldtypeentityuuid,
            crud_entityfield_read_full.entityfieldtypename,
            crud_entityfield_read_full.entityfieldparententityuuid,
            crud_entityfield_read_full.entityfieldsitename,
            crud_entityfield_read_full.entityfieldentitytypeentityuuid,
            crud_entityfield_read_full.entityfieldentitytypename,
            crud_entityfield_read_full.entityfieldentityparenttypeentityuuid,
            crud_entityfield_read_full.entityfieldparenttypename,
            crud_entityfield_read_full.entityfielddeleted,
            crud_entityfield_read_full.entityfielddraft,
            crud_entityfield_read_full.entityfieldactive
           FROM entity.crud_entityfield_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entityfield_read_full(languagetranslationtypeuuid, entityfielduuid, entityfieldentitytemplateentityuuid, entityfieldcreateddate, entityfieldmodifieddate, entityfieldstartdate, entityfieldenddate, entityfieldlanguagemasteruuid, entityfieldtranslatedname, entityfieldorder, entityfielddefaultvalue, entityfieldiscalculated, entityfieldiseditable, entityfieldisvisible, entityfieldisrequired, entityfieldformatentityuuid, entityfieldformatname, entityfieldwidgetentityuuid, entityfieldwidgetname, entityfieldexternalid, entityfieldexternalsystementityuuid, entityfieldexternalsystemname, entityfieldmodifiedbyuuid, entityfieldmodifiedby, entityfieldrefid, entityfieldrefuuid, entityfieldisprimary, entityfieldtranslate, entityfieldname, entityfieldownerentityuuid, entityfieldcustomername, entityfieldtypeentityuuid, entityfieldtypename, entityfieldparententityuuid, entityfieldsitename, entityfieldentitytypeentityuuid, entityfieldentitytypename, entityfieldentityparenttypeentityuuid, entityfieldparenttypename, entityfielddeleted, entityfielddraft, entityfieldactive)) entityfield
     JOIN ( SELECT crud_entitytemplate_read_full.languagetranslationtypeuuid,
            crud_entitytemplate_read_full.entitytemplateuuid,
            crud_entitytemplate_read_full.entitytemplateownerentityuuid,
            crud_entitytemplate_read_full.entitytemplatecustomername,
            crud_entitytemplate_read_full.entitytemplateparententityuuid,
            crud_entitytemplate_read_full.entitytemplatesitename,
            crud_entitytemplate_read_full.entitytemplatetypeentityuuid,
            crud_entitytemplate_read_full.entitytemplatetype,
            crud_entitytemplate_read_full.entitytemplateisprimary,
            crud_entitytemplate_read_full.entitytemplatescanid,
            crud_entitytemplate_read_full.entitytemplatenameuuid,
            crud_entitytemplate_read_full.entitytemplatename,
            crud_entitytemplate_read_full.entitytemplateorder,
            crud_entitytemplate_read_full.entitytemplatemodifiedbyuuid,
            crud_entitytemplate_read_full.entitytemplatemodifiedby,
            crud_entitytemplate_read_full.entitytemplatestartdate,
            crud_entitytemplate_read_full.entitytemplateenddate,
            crud_entitytemplate_read_full.entitytemplatecreateddate,
            crud_entitytemplate_read_full.entitytemplatemodifieddate,
            crud_entitytemplate_read_full.entitytemplateexternalid,
            crud_entitytemplate_read_full.entitytemplaterefid,
            crud_entitytemplate_read_full.entitytemplaterefuuid,
            crud_entitytemplate_read_full.entitytemplateexternalsystementityuuid,
            crud_entitytemplate_read_full.entitytemplateexternalsystem,
            crud_entitytemplate_read_full.entitytemplatedeleted,
            crud_entitytemplate_read_full.entitytemplatedraft,
            crud_entitytemplate_read_full.entitytemplateactive
           FROM entity.crud_entitytemplate_read_full(NULL::uuid, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entitytemplate_read_full(languagetranslationtypeuuid, entitytemplateuuid, entitytemplateownerentityuuid, entitytemplatecustomername, entitytemplateparententityuuid, entitytemplatesitename, entitytemplatetypeentityuuid, entitytemplatetype, entitytemplateisprimary, entitytemplatescanid, entitytemplatenameuuid, entitytemplatename, entitytemplateorder, entitytemplatemodifiedbyuuid, entitytemplatemodifiedby, entitytemplatestartdate, entitytemplateenddate, entitytemplatecreateddate, entitytemplatemodifieddate, entitytemplateexternalid, entitytemplaterefid, entitytemplaterefuuid, entitytemplateexternalsystementityuuid, entitytemplateexternalsystem, entitytemplatedeleted, entitytemplatedraft, entitytemplateactive)) entitytemplate ON entitytemplate.entitytemplateuuid = entityfield.entityfieldentitytemplateentityuuid
  WHERE (entityfield.entityfieldownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership))) OR entityfield.entityfieldownerentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid AND entitytemplate.entitytemplateisprimary = true;

COMMENT ON VIEW api.entity_field IS '
### Entity fields

TODO describe what Entity fields are.
';

CREATE TRIGGER create_entity_field_tg INSTEAD OF INSERT ON api.entity_field FOR EACH ROW EXECUTE FUNCTION api.create_entity_field();
CREATE TRIGGER update_entity_field_tg INSTEAD OF UPDATE ON api.entity_field FOR EACH ROW EXECUTE FUNCTION api.update_entity_field();

GRANT INSERT ON api.entity_field TO authenticated;
GRANT SELECT ON api.entity_field TO authenticated;
GRANT UPDATE ON api.entity_field TO authenticated;

-- Type: VIEW ; Name: entity_instance; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_instance AS
 SELECT entityinstanceuuid AS id,
    entityinstanceownerentityuuid AS owner,
    entityinstanceownerentityname AS owner_name,
    entityinstanceparententityuuid AS parent,
    entityinstanceparententityname AS parent_name,
    entityinstanceentitytemplateentityuuid AS template,
    entityinstanceentitytemplatetranslatedname AS template_name,
    entityinstanceexternalid AS external_id,
    entityinstanceexternalsystementityuuid AS external_system,
    entityinstancescanid AS scan_code,
    entityinstancenameuuid AS name_id,
    entityinstancename AS name,
    entityinstancetypeentityuuid AS type,
    entityinstancetypeentityuuid AS type_name,
    entityinstancecornerstoneentityuuid AS cornerstone,
    entityinstancecornerstoneentitname AS cornerstone_name,
    entityinstancecornerstoneorder AS _order,
    entityinstancedeleted AS _deleted,
    entityinstancedraft AS _draft,
    entityinstanceactive AS _active,
    entityinstancestartdate AS activated_at,
    entityinstanceenddate AS deactivated_at,
    entityinstancecreateddate AS created_at,
    entityinstancemodifieddate AS updated_at,
    entityinstancemodifiedbyuuid AS modified_by
   FROM ( SELECT crud_entityinstance_read_api.languagetranslationtypeentityuuid,
            crud_entityinstance_read_api.entityinstanceoriginalid,
            crud_entityinstance_read_api.entityinstanceoriginaluuid,
            crud_entityinstance_read_api.entityinstanceuuid,
            crud_entityinstance_read_api.entityinstanceownerentityuuid,
            crud_entityinstance_read_api.entityinstanceownerentityname,
            crud_entityinstance_read_api.entityinstanceparententityuuid,
            crud_entityinstance_read_api.entityinstanceparententityname,
            crud_entityinstance_read_api.entityinstancecornerstoneentityuuid,
            crud_entityinstance_read_api.entityinstancecornerstoneentitname,
            crud_entityinstance_read_api.entityinstancecornerstoneorder,
            crud_entityinstance_read_api.entityinstanceentitytemplateentityuuid,
            crud_entityinstance_read_api.entityinstanceentitytemplatename,
            crud_entityinstance_read_api.entityinstanceentitytemplatetranslatedname,
            crud_entityinstance_read_api.entityinstancetypeentityuuid,
            crud_entityinstance_read_api.entityinstancetype,
            crud_entityinstance_read_api.entityinstancenameuuid,
            crud_entityinstance_read_api.entityinstancename,
            crud_entityinstance_read_api.entityinstancescanid,
            crud_entityinstance_read_api.entityinstancesiteentityuuid,
            crud_entityinstance_read_api.entityinstancecreateddate,
            crud_entityinstance_read_api.entityinstancemodifieddate,
            crud_entityinstance_read_api.entityinstancemodifiedbyuuid,
            crud_entityinstance_read_api.entityinstancestartdate,
            crud_entityinstance_read_api.entityinstanceenddate,
            crud_entityinstance_read_api.entityinstanceexternalid,
            crud_entityinstance_read_api.entityinstanceexternalsystementityuuid,
            crud_entityinstance_read_api.entityinstanceexternalsystementityname,
            crud_entityinstance_read_api.entityinstancerefid,
            crud_entityinstance_read_api.entityinstancerefuuid,
            crud_entityinstance_read_api.entityinstancedeleted,
            crud_entityinstance_read_api.entityinstancedraft,
            crud_entityinstance_read_api.entityinstanceactive,
            crud_entityinstance_read_api.entityinstancetagentityuuid
           FROM entity.crud_entityinstance_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entityinstance_read_api(languagetranslationtypeentityuuid, entityinstanceoriginalid, entityinstanceoriginaluuid, entityinstanceuuid, entityinstanceownerentityuuid, entityinstanceownerentityname, entityinstanceparententityuuid, entityinstanceparententityname, entityinstancecornerstoneentityuuid, entityinstancecornerstoneentitname, entityinstancecornerstoneorder, entityinstanceentitytemplateentityuuid, entityinstanceentitytemplatename, entityinstanceentitytemplatetranslatedname, entityinstancetypeentityuuid, entityinstancetype, entityinstancenameuuid, entityinstancename, entityinstancescanid, entityinstancesiteentityuuid, entityinstancecreateddate, entityinstancemodifieddate, entityinstancemodifiedbyuuid, entityinstancestartdate, entityinstanceenddate, entityinstanceexternalid, entityinstanceexternalsystementityuuid, entityinstanceexternalsystementityname, entityinstancerefid, entityinstancerefuuid, entityinstancedeleted, entityinstancedraft, entityinstanceactive, entityinstancetagentityuuid)) entityinstance;


CREATE TRIGGER create_entity_instance_tg INSTEAD OF INSERT ON api.entity_instance FOR EACH ROW EXECUTE FUNCTION api.create_entity_instance();
CREATE TRIGGER update_entity_instance_tg INSTEAD OF UPDATE ON api.entity_instance FOR EACH ROW EXECUTE FUNCTION api.update_entity_instance();

GRANT INSERT ON api.entity_instance TO authenticated;
GRANT SELECT ON api.entity_instance TO authenticated;
GRANT UPDATE ON api.entity_instance TO authenticated;

-- Type: VIEW ; Name: entity_instance_field; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_instance_field AS
 SELECT entityfieldinstanceuuid AS id,
    entityfieldinstanceentityinstanceentityuuid AS instance,
    entityfieldinstanceownerentityuuid AS owner,
    entityfieldinstanceentityfieldentityuuid AS field,
    entityfieldinstancevalue AS value,
    entityfieldinstancevaluelanguagemasteruuid AS value_id,
    entityfieldinstancevaluelanguagetypeentityuuid AS value_language_type,
    entityfieldinstancedeleted AS _deleted,
    entityfieldinstancedraft AS _draft,
        CASE
            WHEN entityfieldinstanceenddate IS NOT NULL AND entityfieldinstanceenddate::date < now()::date THEN false
            ELSE true
        END AS _active,
    entityfieldinstancestartdate AS activated_at,
    entityfieldinstanceenddate AS deactivated_at,
    entityfieldinstancecreateddate AS created_at,
    entityfieldinstancemodifieddate AS updated_at,
    entityfieldinstancemodifiedbyuuid AS modified_by
   FROM entity.entityfieldinstance
  WHERE (entityfieldinstanceownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.entity_instance_field IS '
### Instance fields

TODO describe what instance fields are.
';

CREATE TRIGGER create_entity_instance_field_tg INSTEAD OF INSERT ON api.entity_instance_field FOR EACH ROW EXECUTE FUNCTION api.create_entity_instance_field();
CREATE TRIGGER update_entity_instance_field_tg INSTEAD OF UPDATE ON api.entity_instance_field FOR EACH ROW EXECUTE FUNCTION api.update_entity_instance_field();

GRANT INSERT ON api.entity_instance_field TO authenticated;
GRANT SELECT ON api.entity_instance_field TO authenticated;
GRANT UPDATE ON api.entity_instance_field TO authenticated;

-- Type: VIEW ; Name: entity_instance_file; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_instance_file AS
 SELECT entityfileinstanceuuid AS id,
    entityfileinstanceownerentityuuid AS owner,
    entityfileinstanceentityentityinstanceentityuuid AS instance,
    entityfileinstanceentityfieldinstanceentityuuid AS field_instance,
    entityfileinstancestoragelocation AS file_link,
    entityfileinstancemimetypeuuid AS file_mime_type,
    entityfileinstanceexternalid AS external_id,
    entityfileinstanceexternalsystemuuid AS external_system,
    entityfileinstancedraft AS _draft,
    entityfileinstancedeleted AS _deleted,
    entityfileinstancecreateddate AS created_at,
    entityfileinstancemodifieddate AS updated_at,
    entityfileinstancemodifiedby AS modified_by
   FROM entity.entityfileinstance
  WHERE (entityfileinstanceownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.entity_instance_file IS '
### Instance fields

TODO describe what instance fields are.
';

CREATE TRIGGER create_entity_instance_file_tg INSTEAD OF INSERT ON api.entity_instance_file FOR EACH ROW EXECUTE FUNCTION api.create_entity_instance_file();
CREATE TRIGGER update_entity_instance_file_tg INSTEAD OF UPDATE ON api.entity_instance_file FOR EACH ROW EXECUTE FUNCTION api.update_entity_instance_file();

GRANT INSERT ON api.entity_instance_file TO authenticated;
GRANT SELECT ON api.entity_instance_file TO authenticated;
GRANT UPDATE ON api.entity_instance_file TO authenticated;

-- Type: VIEW ; Name: entity_tag; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_tag AS
 SELECT entitytaguuid AS id,
    entitytagownerentityuuid AS owner,
    entitytagownername AS owner_name,
    entitytagentityinstanceentityuuid AS instance,
    entitytagentityinstanceentityname AS instance_name,
    entitytagentitytemplateentityuuid AS template,
    entitytagentitytemplatename AS template_name,
    entitytagcustagparententityuuid AS parent,
    entitytagparentcustagtype AS parent_name,
    entitytagcustagentityuuid AS customer_tag,
    entitytagcustagtype AS customer_tag_name,
    entitytagsenddeleted AS _deleted,
    entitytagsenddrafts AS _draft,
    entitytagsendinactive AS _active,
    entitytagstartdate AS activated_at,
    entitytagenddate AS deactivated_at,
    entitytagcreateddate AS created_at,
    entitytagmodifieddate AS updated_at,
    entitytagmodifiedbyuuid AS modified_by
   FROM ( SELECT crud_entitytag_read_api.languagetranslationtypeentityuuid,
            crud_entitytag_read_api.entitytaguuid,
            crud_entitytag_read_api.entitytagownerentityuuid,
            crud_entitytag_read_api.entitytagownername,
            crud_entitytag_read_api.entitytagentityinstanceentityuuid,
            crud_entitytag_read_api.entitytagentityinstanceentityname,
            crud_entitytag_read_api.entitytagentitytemplateentityuuid,
            crud_entitytag_read_api.entitytagentitytemplatename,
            crud_entitytag_read_api.entitytagcreateddate,
            crud_entitytag_read_api.entitytagmodifieddate,
            crud_entitytag_read_api.entitytagstartdate,
            crud_entitytag_read_api.entitytagenddate,
            crud_entitytag_read_api.entitytagrefid,
            crud_entitytag_read_api.entitytagrefuuid,
            crud_entitytag_read_api.entitytagmodifiedbyuuid,
            crud_entitytag_read_api.entitytagcustagparententityuuid,
            crud_entitytag_read_api.entitytagparentcustagtype,
            crud_entitytag_read_api.entitytagcustagentityuuid,
            crud_entitytag_read_api.entitytagcustagtype,
            crud_entitytag_read_api.entitytagsenddeleted,
            crud_entitytag_read_api.entitytagsenddrafts,
            crud_entitytag_read_api.entitytagsendinactive
           FROM entity.crud_entitytag_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entitytag_read_api(languagetranslationtypeentityuuid, entitytaguuid, entitytagownerentityuuid, entitytagownername, entitytagentityinstanceentityuuid, entitytagentityinstanceentityname, entitytagentitytemplateentityuuid, entitytagentitytemplatename, entitytagcreateddate, entitytagmodifieddate, entitytagstartdate, entitytagenddate, entitytagrefid, entitytagrefuuid, entitytagmodifiedbyuuid, entitytagcustagparententityuuid, entitytagparentcustagtype, entitytagcustagentityuuid, entitytagcustagtype, entitytagsenddeleted, entitytagsenddrafts, entitytagsendinactive)) entitytag
  WHERE (entitytagownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.entity_tag IS '
## Entity tag

A description of what an entity tag is and why it is used

';

CREATE TRIGGER create_entity_tag_tg INSTEAD OF INSERT ON api.entity_tag FOR EACH ROW EXECUTE FUNCTION api.create_entity_tag();
CREATE TRIGGER update_entity_tag_tg INSTEAD OF UPDATE ON api.entity_tag FOR EACH ROW EXECUTE FUNCTION api.update_entity_tag();

GRANT INSERT ON api.entity_tag TO authenticated;
GRANT SELECT ON api.entity_tag TO authenticated;
GRANT UPDATE ON api.entity_tag TO authenticated;

-- Type: VIEW ; Name: entity_template; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_template AS
 SELECT entitytemplateuuid AS id,
    entitytemplateownerentityuuid AS owner,
    entitytemplatecustomername AS owner_name,
    entitytemplateparententityuuid AS parent,
    entitytemplatesitename AS parent_name,
    entitytemplateexternalid AS external_id,
    entitytemplateexternalsystementityuuid AS external_system,
    entitytemplatescanid AS scan_code,
    entitytemplatenameuuid AS name_id,
    entitytemplatename AS name,
    entitytemplatetypeentityuuid AS type,
    entitytemplatetype AS type_name,
    entitytemplateorder AS _order,
    entitytemplateisprimary AS _primary,
    entitytemplatedeleted AS _deleted,
    entitytemplatedraft AS _draft,
    entitytemplateactive AS _active,
    entitytemplatestartdate AS activated_at,
    entitytemplateenddate AS deactivated_at,
    entitytemplatecreateddate AS created_at,
    entitytemplatemodifieddate AS updated_at,
    entitytemplatemodifiedbyuuid AS modified_by
   FROM ( SELECT crud_entitytemplate_read_full.languagetranslationtypeuuid,
            crud_entitytemplate_read_full.entitytemplateuuid,
            crud_entitytemplate_read_full.entitytemplateownerentityuuid,
            crud_entitytemplate_read_full.entitytemplatecustomername,
            crud_entitytemplate_read_full.entitytemplateparententityuuid,
            crud_entitytemplate_read_full.entitytemplatesitename,
            crud_entitytemplate_read_full.entitytemplatetypeentityuuid,
            crud_entitytemplate_read_full.entitytemplatetype,
            crud_entitytemplate_read_full.entitytemplateisprimary,
            crud_entitytemplate_read_full.entitytemplatescanid,
            crud_entitytemplate_read_full.entitytemplatenameuuid,
            crud_entitytemplate_read_full.entitytemplatename,
            crud_entitytemplate_read_full.entitytemplateorder,
            crud_entitytemplate_read_full.entitytemplatemodifiedbyuuid,
            crud_entitytemplate_read_full.entitytemplatemodifiedby,
            crud_entitytemplate_read_full.entitytemplatestartdate,
            crud_entitytemplate_read_full.entitytemplateenddate,
            crud_entitytemplate_read_full.entitytemplatecreateddate,
            crud_entitytemplate_read_full.entitytemplatemodifieddate,
            crud_entitytemplate_read_full.entitytemplateexternalid,
            crud_entitytemplate_read_full.entitytemplaterefid,
            crud_entitytemplate_read_full.entitytemplaterefuuid,
            crud_entitytemplate_read_full.entitytemplateexternalsystementityuuid,
            crud_entitytemplate_read_full.entitytemplateexternalsystem,
            crud_entitytemplate_read_full.entitytemplatedeleted,
            crud_entitytemplate_read_full.entitytemplatedraft,
            crud_entitytemplate_read_full.entitytemplateactive
           FROM entity.crud_entitytemplate_read_full(NULL::uuid, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entitytemplate_read_full(languagetranslationtypeuuid, entitytemplateuuid, entitytemplateownerentityuuid, entitytemplatecustomername, entitytemplateparententityuuid, entitytemplatesitename, entitytemplatetypeentityuuid, entitytemplatetype, entitytemplateisprimary, entitytemplatescanid, entitytemplatenameuuid, entitytemplatename, entitytemplateorder, entitytemplatemodifiedbyuuid, entitytemplatemodifiedby, entitytemplatestartdate, entitytemplateenddate, entitytemplatecreateddate, entitytemplatemodifieddate, entitytemplateexternalid, entitytemplaterefid, entitytemplaterefuuid, entitytemplateexternalsystementityuuid, entitytemplateexternalsystem, entitytemplatedeleted, entitytemplatedraft, entitytemplateactive)) entitytemplate
  WHERE (entitytemplateownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership))) OR entitytemplateownerentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid AND entitytemplateisprimary = true;

COMMENT ON VIEW api.entity_template IS '
## Entity Template

A description of what an entity tempalte is and why it is used

### get {baseUrl}/entity_template

A bunch of comments explaining get

### del {baseUrl}/entity_template

A bunch of comments explaining del

### patch {baseUrl}/entity_template

A bunch of comments explaining patch
';

CREATE TRIGGER create_entity_template_tg INSTEAD OF INSERT ON api.entity_template FOR EACH ROW EXECUTE FUNCTION api.create_entity_template();
CREATE TRIGGER update_entity_template_tg INSTEAD OF UPDATE ON api.entity_template FOR EACH ROW EXECUTE FUNCTION api.update_entity_template();

GRANT INSERT ON api.entity_template TO authenticated;
GRANT SELECT ON api.entity_template TO authenticated;
GRANT UPDATE ON api.entity_template TO authenticated;

-- Type: VIEW ; Name: location; Owner: tendreladmin

CREATE OR REPLACE VIEW api.location AS
 SELECT location.locationid AS legacy_id,
    location.locationuuid AS legacy_uuid,
    location.locationentityuuid AS id,
    location.locationownerentityuuid AS owner,
    location.locationcustomername AS owner_name,
    location.locationparententityuuid AS parent,
    COALESCE(lt.languagetranslationvalue, lm.languagemastersource) AS parent_name,
    location.locationcornerstoneentityuuid AS cornerstone,
    location.locationnameuuid AS name_id,
    location.locationname AS name,
    location.locationdisplaynameuuid AS displayname_id,
    location.locationdisplayname AS displayname,
    location.locationscanid AS scan_code,
    location.locationcreateddate AS created_at,
    location.locationmodifieddate AS updated_at,
    location.locationmodifiedbyuuid AS modified_by,
    location.locationstartdate AS activated_at,
    location.locationenddate AS deactivated_at,
    location.locationexternalid AS external_id,
    location.locationexternalsystementityuuid AS external_system,
    location.locationcornerstoneorder AS _order,
    location.locationlatitude AS latitude,
    location.locationlongitude AS longitude,
    location.locationradius AS radius,
    location.locationtimezone AS timezone,
    location.locationtagentityuuid AS tag_id,
    location.locationsenddeleted AS _deleted,
    location.locationsenddrafts AS _draft,
    location.locationsendinactive AS _active,
        CASE
            WHEN location.locationparententityuuid = location.locationentityuuid THEN true
            ELSE false
        END AS _is_site,
        CASE
            WHEN location.locationcornerstoneentityuuid = location.locationentityuuid THEN true
            ELSE false
        END AS _is_cornerstone
   FROM entity.crud_location_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) location(languagetranslationtypeentityuuid, locationid, locationuuid, locationentityuuid, locationownerentityuuid, locationparententityuuid, locationcornerstoneentityuuid, locationcustomerid, locationcustomeruuid, locationcustomerentityuuid, locationcustomername, locationnameuuid, locationname, locationdisplaynameuuid, locationdisplayname, locationscanid, locationcreateddate, locationmodifieddate, locationmodifiedbyuuid, locationstartdate, locationenddate, locationexternalid, locationexternalsystementityuuid, locationexternalsystementname, locationcornerstoneorder, locationlatitude, locationlongitude, locationradius, locationtimezone, locationtagentityuuid, locationtagname, locationsenddeleted, locationsenddrafts, locationsendinactive)
     LEFT JOIN ( SELECT crud_location_read_min.languagetranslationtypeentityuuid,
            crud_location_read_min.locationid,
            crud_location_read_min.locationuuid,
            crud_location_read_min.locationentityuuid,
            crud_location_read_min.locationownerentityuuid,
            crud_location_read_min.locationparententityuuid,
            crud_location_read_min.locationcornerstoneentityuuid,
            crud_location_read_min.locationcustomerid,
            crud_location_read_min.locationcustomeruuid,
            crud_location_read_min.locationcustomerentityuuid,
            crud_location_read_min.locationnameuuid,
            crud_location_read_min.locationdisplaynameuuid,
            crud_location_read_min.locationscanid,
            crud_location_read_min.locationcreateddate,
            crud_location_read_min.locationmodifieddate,
            crud_location_read_min.locationmodifiedbyuuid,
            crud_location_read_min.locationstartdate,
            crud_location_read_min.locationenddate,
            crud_location_read_min.locationexternalid,
            crud_location_read_min.locationexternalsystementityuuid,
            crud_location_read_min.locationcornerstoneorder,
            crud_location_read_min.locationlatitude,
            crud_location_read_min.locationlongitude,
            crud_location_read_min.locationradius,
            crud_location_read_min.locationtimezone,
            crud_location_read_min.locationtagentityuuid,
            crud_location_read_min.locationsenddeleted,
            crud_location_read_min.locationsenddrafts,
            crud_location_read_min.locationsendinactive
           FROM entity.crud_location_read_min(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid) crud_location_read_min(languagetranslationtypeentityuuid, locationid, locationuuid, locationentityuuid, locationownerentityuuid, locationparententityuuid, locationcornerstoneentityuuid, locationcustomerid, locationcustomeruuid, locationcustomerentityuuid, locationnameuuid, locationdisplaynameuuid, locationscanid, locationcreateddate, locationmodifieddate, locationmodifiedbyuuid, locationstartdate, locationenddate, locationexternalid, locationexternalsystementityuuid, locationcornerstoneorder, locationlatitude, locationlongitude, locationradius, locationtimezone, locationtagentityuuid, locationsenddeleted, locationsenddrafts, locationsendinactive)) parent ON parent.locationentityuuid = location.locationparententityuuid
     LEFT JOIN languagemaster lm ON lm.languagemasteruuid = parent.locationnameuuid
     LEFT JOIN languagetranslations lt ON lt.languagetranslationmasterid = (( SELECT languagemaster.languagemasterid
           FROM languagemaster
          WHERE languagemaster.languagemasteruuid = parent.locationnameuuid)) AND lt.languagetranslationtypeid = (( SELECT crud_systag_read_min.systagid
           FROM entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid, NULL::uuid, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid)), NULL::uuid, false, NULL::boolean, NULL::boolean, NULL::boolean, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid) crud_systag_read_min(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagnameuuid, systagdisplaynameuuid, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagmodifiedbyuuid, systagabbreviationentityuuid, systagparententityuuid, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)))
  WHERE (location.locationownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.location IS '
## Location

A description of what an location is and why it is used

### get {baseUrl}/location

A bunch of comments explaining get

### del {baseUrl}/location

A bunch of comments explaining del

### patch {baseUrl}/location

A bunch of comments explaining patch
';

CREATE TRIGGER create_location_tg INSTEAD OF INSERT ON api.location FOR EACH ROW EXECUTE FUNCTION api.create_location();
CREATE TRIGGER update_location_tg INSTEAD OF UPDATE ON api.location FOR EACH ROW EXECUTE FUNCTION api.update_location();

GRANT INSERT ON api.location TO authenticated;
GRANT SELECT ON api.location TO authenticated;
GRANT UPDATE ON api.location TO authenticated;

-- Type: VIEW ; Name: reason_code; Owner: tendreladmin

CREATE OR REPLACE VIEW api.reason_code AS
 SELECT custag.custagentityuuid AS id,
    custag.custagid AS legacy_id,
    custag.custaguuid AS legacy_uuid,
    custag.custagownerentityuuid AS owner,
    custag.custagownerentityname AS owner_name,
    custag.custagparententityuuid AS parent,
    custag.custagparentname AS parent_name,
    custag.custagcornerstoneentityid AS cornerstone,
    custag.custagnameuuid AS name_id,
    custag.custagname AS name,
    custag.custagdisplaynameuuid AS displayname_id,
    custag.custagdisplayname AS displayname,
    custag.custagtype AS type,
    custag.custagcreateddate AS created_at,
    custag.custagmodifieddate AS updated_at,
    custag.custagstartdate AS activated_at,
    custag.custagenddate AS deactivated_at,
    custag.custagexternalid AS external_id,
    custag.custagexternalsystementityuuid AS external_system,
    custag.custagmodifiedbyuuid AS modified_by,
    custag.custagorder AS _order,
    custag.systagsenddeleted AS _deleted,
    custag.systagsenddrafts AS _draft,
    custag.systagsendinactive AS _active,
    wtc.worktemplateconstraintid AS work_template_constraint,
    wt.id AS work_template,
    COALESCE(lt.languagetranslationvalue, lm.languagemastersource) AS work_template_name
   FROM ( SELECT crud_custag_read_api.languagetranslationtypeentityuuid,
            crud_custag_read_api.custagid,
            crud_custag_read_api.custaguuid,
            crud_custag_read_api.custagentityuuid,
            crud_custag_read_api.custagownerentityuuid,
            crud_custag_read_api.custagownerentityname,
            crud_custag_read_api.custagparententityuuid,
            crud_custag_read_api.custagparentname,
            crud_custag_read_api.custagcornerstoneentityid,
            crud_custag_read_api.custagcustomerid,
            crud_custag_read_api.custagcustomeruuid,
            crud_custag_read_api.custagcustomerentityuuid,
            crud_custag_read_api.custagcustomername,
            crud_custag_read_api.custagnameuuid,
            crud_custag_read_api.custagname,
            crud_custag_read_api.custagdisplaynameuuid,
            crud_custag_read_api.custagdisplayname,
            crud_custag_read_api.custagtype,
            crud_custag_read_api.custagcreateddate,
            crud_custag_read_api.custagmodifieddate,
            crud_custag_read_api.custagstartdate,
            crud_custag_read_api.custagenddate,
            crud_custag_read_api.custagexternalid,
            crud_custag_read_api.custagexternalsystementityuuid,
            crud_custag_read_api.custagexternalsystemenname,
            crud_custag_read_api.custagmodifiedbyuuid,
            crud_custag_read_api.custagabbreviationentityuuid,
            crud_custag_read_api.custagabbreviationname,
            crud_custag_read_api.custagorder,
            crud_custag_read_api.systagsenddeleted,
            crud_custag_read_api.systagsenddrafts,
            crud_custag_read_api.systagsendinactive
           FROM entity.crud_custag_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, 'f875b28c-ccc9-4c69-b5b4-9f10ad89d23b'::uuid, false, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_custag_read_api(languagetranslationtypeentityuuid, custagid, custaguuid, custagentityuuid, custagownerentityuuid, custagownerentityname, custagparententityuuid, custagparentname, custagcornerstoneentityid, custagcustomerid, custagcustomeruuid, custagcustomerentityuuid, custagcustomername, custagnameuuid, custagname, custagdisplaynameuuid, custagdisplayname, custagtype, custagcreateddate, custagmodifieddate, custagstartdate, custagenddate, custagexternalid, custagexternalsystementityuuid, custagexternalsystemenname, custagmodifiedbyuuid, custagabbreviationentityuuid, custagabbreviationname, custagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)) custag
     LEFT JOIN worktemplateconstraint wtc ON wtc.worktemplateconstraintconstrainedtypeid = 'systag_4bbc3e18-de10-4f93-aabb-b1d051a2923d'::text AND wtc.worktemplateconstraintconstraintid = custag.custaguuid
     LEFT JOIN worktemplate wt ON wtc.worktemplateconstrainttemplateid = wt.id
     LEFT JOIN languagemaster lm ON wt.worktemplatenameid = lm.languagemasterid
     LEFT JOIN languagetranslations lt ON lm.languagemasterid = lt.languagetranslationmasterid
  WHERE (custag.custagownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.reason_code IS '
## Reason Code

A description of what an entity tempalte is and why it is used

### get {baseUrl}/custag

A bunch of comments explaining get

### del {baseUrl}/custag

A bunch of comments explaining del

### patch {baseUrl}/custag

A bunch of comments explaining patch
';

GRANT INSERT ON api.reason_code TO authenticated;
GRANT SELECT ON api.reason_code TO authenticated;
GRANT UPDATE ON api.reason_code TO authenticated;

-- Type: VIEW ; Name: systag; Owner: tendreladmin

CREATE OR REPLACE VIEW api.systag AS
 SELECT systagentityuuid AS id,
    systagid AS legacy_id,
    systaguuid AS legacy_uuid,
    systagownerentityuuid AS owner,
    systagownerentityname AS owner_name,
    systagparententityuuid AS parent,
    systagparentname AS parent_name,
    NULL::uuid AS cornerstone,
    systagnameuuid AS name_id,
    systagname AS name,
    systagdisplaynameuuid AS displayname_id,
    systagdisplayname AS displayname,
    systagtype AS type,
    systagcreateddate AS created_at,
    systagmodifieddate AS updated_at,
    systagstartdate AS activated_at,
    systagenddate AS deactivated_at,
    systagexternalid AS external_id,
    systagexternalsystementityuuid AS external_system,
    systagmodifiedbyuuid AS modified_by,
    systagorder AS _order,
    systagsenddeleted AS _deleted,
    systagsenddrafts AS _draft,
    systagsendinactive AS _active
   FROM ( SELECT crud_systag_read_api.languagetranslationtypeentityuuid,
            crud_systag_read_api.systagid,
            crud_systag_read_api.systaguuid,
            crud_systag_read_api.systagentityuuid,
            crud_systag_read_api.systagownerentityuuid,
            crud_systag_read_api.systagownerentityname,
            crud_systag_read_api.systagparententityuuid,
            crud_systag_read_api.systagparentname,
            crud_systag_read_api.systagcornerstoneentityid,
            crud_systag_read_api.systagcustomerid,
            crud_systag_read_api.systagcustomeruuid,
            crud_systag_read_api.systagcustomerentityuuid,
            crud_systag_read_api.systagcustomername,
            crud_systag_read_api.systagnameuuid,
            crud_systag_read_api.systagname,
            crud_systag_read_api.systagdisplaynameuuid,
            crud_systag_read_api.systagdisplayname,
            crud_systag_read_api.systagtype,
            crud_systag_read_api.systagcreateddate,
            crud_systag_read_api.systagmodifieddate,
            crud_systag_read_api.systagstartdate,
            crud_systag_read_api.systagenddate,
            crud_systag_read_api.systagexternalid,
            crud_systag_read_api.systagexternalsystementityuuid,
            crud_systag_read_api.systagexternalsystemenname,
            crud_systag_read_api.systagmodifiedbyuuid,
            crud_systag_read_api.systagabbreviationentityuuid,
            crud_systag_read_api.systagabbreviationname,
            crud_systag_read_api.systagorder,
            crud_systag_read_api.systagsenddeleted,
            crud_systag_read_api.systagsenddrafts,
            crud_systag_read_api.systagsendinactive
           FROM entity.crud_systag_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_systag_read_api(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagownerentityuuid, systagownerentityname, systagparententityuuid, systagparentname, systagcornerstoneentityid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagcustomername, systagnameuuid, systagname, systagdisplaynameuuid, systagdisplayname, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagexternalsystemenname, systagmodifiedbyuuid, systagabbreviationentityuuid, systagabbreviationname, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)) systag;

COMMENT ON VIEW api.systag IS '
## language
';

CREATE TRIGGER create_systag_tg INSTEAD OF INSERT ON api.systag FOR EACH ROW EXECUTE FUNCTION api.create_systag();
CREATE TRIGGER update_systag_tg INSTEAD OF UPDATE ON api.systag FOR EACH ROW EXECUTE FUNCTION api.update_systag();

GRANT INSERT ON api.systag TO authenticated;
GRANT SELECT ON api.systag TO authenticated;
GRANT UPDATE ON api.systag TO authenticated;

-- Type: FUNCTION ; Name: api.token_introspect(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.token_introspect(token text)
 RETURNS jsonb
 LANGUAGE sql
 IMMUTABLE SECURITY DEFINER
AS $function$
  with jwt as (select * from auth.jwt_verify(token))
  select '{"active":false}'
  from jwt
  where jwt.valid = false
  union all
  select '{"active":true}' || jwt.payload::jsonb
  from jwt
  where jwt.valid = true
$function$;


REVOKE ALL ON FUNCTION api.token_introspect(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.token_introspect(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.token_introspect(text) TO authenticated;

-- Type: FUNCTION ; Name: api.update_custag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_custag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_entity uuid;
	ins_row api.custag%rowtype;
  	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
	tempcustomerid bigint;
	tempcustomeruuid text;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,new.owner,null,false,null,null,null, null);

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_custag_update(
			update_custagentityuuid := new.id,
			update_custagownerentityuuid := new.owner,
			update_custagparententityuuid := new.parent,
			update_custagcornerstoneentityuuid := new.cornerstone,
			update_custagcornerstoneorder := new._order,
			update_custag := new.type,
			update_custag_name := new.name,
			update_custag_displayname := new.displayname,	
			update_languagetypeuuid := ins_languagetypeentityuuid,
			update_custagexternalid := new.external_id,
			update_custagexternalsystemuuid := new.external_system,
			update_custagdeleted := new._deleted,
			update_custagdraft := new._draft,
			update_custagstartdate := new.activated_at,
			update_custagenddate := new.deactivated_at,
			update_custagmodifiedbyuuid := ins_useruuid);

		-- NEED TO UPDATE ALL REASON CODES IN RESULT VALUES.  
		-- MOVE THIS TO A FUNCTION
		-- MIGHT NEED TO MAKE THIS A BATCH IF IT IS A LARGE CHANGE
		-- find the work result values.  3 step modify, translation, source, then value?

		if (old.name <> new.name) 
			then
				update public.languagetranslations
				set languagetranslationvalue = new.name
				from workresultinstance
					inner join view_workresult
						on workresultinstancevalue = old.name				
							and workresultinstanceworkresultid = workresultid
							and workresultcustomerid = tempcustomerid
							and languagetranslationtypeid = 20
							and workresultname = 'Reason Code'
				where languagetranslationmasterid = workresultinstancevaluelanguagemasterid;

				update public.languagemaster
				set languagemastersourcelanguagetypeid = get_languagetypeid,
					languagemastersource = new.name,
					languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = ins_useruuid),
					languagemastermodifieddate = now(),
					languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'	
				from workresultinstance
					inner join view_workresult
						on workresultinstancevalue = old.name				
							and workresultinstanceworkresultid = workresultid
							and workresultcustomerid = tempcustomerid
							and languagetranslationtypeid = 20
							and workresultname = 'Reason Code'
				where languagemasterid = workresultinstancevaluelanguagemasterid;
				
				update public.workresultinstance
				set workresultinstancevalue = new.name, 
					workresultinstancemodifieddate = now(),
					workresultinstancemodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = ins_useruuid)
				from view_workresult wr
				where workresultinstancevalue = old.name				
					and workresultinstanceworkresultid = workresultid
					and workresultcustomerid = tempcustomerid
					and languagetranslationtypeid = 20
					and workresultname = 'Reason Code';
		end if;
		
	else  
		return null;
end if;

  select * into ins_row
  from api.custag
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_custag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_custag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_custag() TO authenticated;

-- Type: FUNCTION ; Name: api.update_customer(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_customer()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_entity uuid;
	ins_row api.customer%rowtype;
  	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_customer_update(
			update_customername := new.name,
			update_customerdisplayname := new.displayname,	
			update_customeruuid := null::text,
			update_customerentityuuid := new.id,
			update_customerparentuuid := new.parent,
			update_customerowner := new.owner,
			update_customerbillingid := new.external_id,
			update_customerbillingsystemid := new.external_system,
			update_customerdeleted := new._deleted,
			update_customerdraft := new._draft,
			update_customerstartdate  := new.activated_at,
			update_customerenddate := new.deactivated_at,
			update_languagetypeuuid := ins_languagetypeentityuuid,
			update_modifiedby := ins_useruuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.customer
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_customer() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_customer() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_customer() TO authenticated;

-- Type: FUNCTION ; Name: api.update_customer_requested_language(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_customer_requested_language()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_legacy_id bigint;
  ins_id text;
  ins_entity uuid;
  ins_row api.customer_requested_language%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();


if new.legacy_id isNull 
	then 
		ins_legacy_id = (select customerrequestedlanguageid from public.customerrequestedlanguage where customerrequestedlanguageuuid = new.id);
	else ins_legacy_id = new.legacy_id;
end if;

if (old.legacy_id = ins_legacy_id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_customerrequestedlanguage_update(
			update_customerrequestedlanguageid := ins_legacy_id,
			update_customerrequestedlanguageownerentityuuid := new.owner, 
			update_languagetype_id := new.languagetype_id,
			update_customerrequestedlanguagedeleted := null::boolean,
			update_customerrequestedlanguagedraft := null::boolean,
			update_customerrequestedlanguagestartdate := new.activated_at,
			update_customerrequestedlanguageenddate := new.deactivated_at,
			update_modifiedbyid := new.modified_by
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.customer_requested_language
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 

$function$;


REVOKE ALL ON FUNCTION api.update_customer_requested_language() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_customer_requested_language() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_customer_requested_language() TO authenticated;

-- Type: FUNCTION ; Name: api.update_entity_description(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_description()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_description%rowtype;
    ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_entitydescription_update(
			update_entitydescriptionuuid := new.id,
			update_entitydescriptionownerentityuuid := new.owner,
			update_entitydescriptionentitytemplateentityuuid := new.template,
			update_entitydescriptionentityfieldentityuuid := new.field,
			update_entitydescriptionname := new.description,
			update_entitydescriptionsoplink := new.sop_link,
			update_entitydescriptionfile := new.file_link,
			update_entitydescriptionicon := new.icon_link,
			update_entitydescriptionmimetypeuuid := new.file_mime_type,
			update_entitydescriptionexternalid := new.external_id,
			update_entitydescriptionexternalsystementityuuid := new.external_system,
			update_entitydescriptiondeleted := new._deleted,
			update_entitydescriptiondraft := new._draft,
			update_entitydescriptionstartdate := new.activated_at,
			update_entitydescriptionenddate := new.deactivated_at,	
			update_entitydescriptionmodifiedbyuuid := ins_useruuid,
			update_languagetypeuuid := ins_languagetypeentityuuid
			);
	else  
		return null;
end if;

  select * into ins_row
  from api.entity_description
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_description() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_description() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_description() TO authenticated;

-- Type: FUNCTION ; Name: api.update_entity_field(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_field%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

  	if new.owner = 'f90d618d-5de7-4126-8c65-0afb700c6c61' and new._primary = true
  		then new._primary = true;
		else new._primary = false;
	end if;

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_entityfield_update(
			update_entityfielduuid := new.id, 
			update_entityfieldownerentityuuid := new.owner, 
			update_entityfieldparententityuuid := new.parent,
			update_entityfieldtemplateentityuuid := new.template,
			update_entityfieldcornerstoneorder := new._order,
			update_entityfieldname := new.name,
			update_entityfieldtypeentityuuid := new.type,
			update_entityfieldentityparenttypeentityuuid := new.parent_type,
			update_entityfieldentitytypeentityuuid := new.entity_type,
			update_entityfielddefaultvalue := new.default_value,
			update_entityfieldformatentityuuid := new.format,
			update_entityfieldwidgetentityuuid := new.widget,
			update_entityfieldiscalculated := new._calculated,
			update_entityfieldiseditable := new._editable,
			update_entityfieldisvisible := new._visible,
			update_entityfieldisrequired := new._required,
			update_entityfieldisprimary := new._primary,
			update_entityfieldtranslate := new._translate,
			update_entityfieldexternalid := new.external_id,
			update_entityfieldexternalsystemuuid := new.external_system,
			update_entityfielddeleted := new._deleted,
			update_entityfielddraft := new._draft,
			update_entityfieldstartdate := new.activated_at,
			update_entityfieldenddate := new.deactivated_at,
			update_entityfieldmodifiedbyuuid := ins_useruuid,
			update_languagetypeuuid :=  ins_languagetypeentityuuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.entity_field
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_field() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_field() TO authenticated;

-- Type: FUNCTION ; Name: api.update_entity_instance(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_instance()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_entityinstance_update(
			update_entityinstanceentityuuid := new.id,
			update_entityinstanceownerentityuuid := new.owner,
			update_entityinstanceentitytemplateentityuuid := new.template,
			update_entityinstanceentitytemplateentityname := null::text,
			update_entityinstanceparententityuuid := new.parent,
			update_entityinstanceecornerstoneentityuuid := new.cornerstone,
			update_entityinstancecornerstoneorder := new._order,
			update_entityinstancename := new.name,
			update_entityinstancenameuuid := new.name_id,
			update_entityinstancescanid := new.scan_code,
			update_entityinstancetypeuuid := new.type,
			update_entityinstanceexternalid := new.external_id,
			update_entityinstanceexternalsystemuuid := new.external_system,
			update_entityinstancedeleted := new._deleted,
			update_entityinstancedraft := new._draft,
			update_entityinstancestartdate := new.activated_at,
			update_entityinstanceenddate := new.deactivated_at,
			update_entityinstancemodifiedbyuuid := null::text,
			update_languagetypeuuid := null::uuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.entity_instance
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_instance() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_instance() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_instance() TO authenticated;

-- Type: FUNCTION ; Name: api.update_entity_instance_field(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_instance_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance_field%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_entityfieldinstance_update(
			update_entityfieldinstanceentityuuid := new.id,
			update_entityfieldinstanceownerentityuuid := new.owner,
			update_entityfieldinstanceentityinstanceentityuuid := new.instance,
			update_entityfieldinstanceentityfieldentityuuid := new.field,
			update_entityfieldinstancevalue := new.value,
			update_entityfieldinstanceentityfieldname := null::text,
			update_entityfieldinstanceexternalid := new.external_id,
			update_entityfieldinstanceexternalsystemuuid := null::uuid,
			update_entityfieldinstancedeleted := new._deleted,
			update_entityfieldinstancedraft := new._draft,
			update_entityfieldinstancestartdate := new.activated_at,
			update_entityfieldinstanceenddate := new.deactivated_at,
			update_entityfieldinstancemodifiedbyuuid := ins_useruuid,
			update_languagetypeuuid := ins_languagetypeentityuuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.entity_instance_field
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_instance_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_instance_field() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_instance_field() TO authenticated;

-- Type: FUNCTION ; Name: api.update_entity_instance_file(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_instance_file()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance_file%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_entityfileinstance_update(
			update_entityfileinstanceentityuuid := new.id,
			update_entityfileinstanceownerentityuuid := new.owner,
			update_entityfileinstanceentityentityinstanceentityuuid := new.instance,
			update_entityfileinstanceentityfieldinstanceentityuuid := new.field_instance,
			update_entityfileinstancestoragelocation := new.file_link,
			update_entityfileinstancemimetypeuuid := new.file_mime_type,
			update_entityfileinstancedeleted := new._deleted,
			update_entityfileinstancedraft := new._draft,
			update_entityfileinstancemodifiedbyuuid := ins_useruuid,
			update_languagetypeuuid := ins_languagetypeentityuuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.entity_instance_file
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_instance_file() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_instance_file() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_instance_file() TO authenticated;

-- Type: FUNCTION ; Name: api.update_entity_tag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_tag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_tag%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_entitytag_update(
			update_entitytaguuid := new.id, 
			update_entitytagownerentityuuid := new.owner, 
			update_entitytagentityinstanceuuid := new.instance, 
			update_entitytagentitytemplateuuid := new.template, 
			update_entitytagcustaguuid := new.customer_tag, 
			update_languagetypeuuid := ins_languagetypeentityuuid,  
			update_entitytagdeleted := new._deleted, 
			update_entitytagdraft := new._draft, 
			update_entitytagstartdate := new.activated_at, 
			update_entitytagenddate := new.deactivated_at, 
			update_modifiedbyid :=  ins_userid 
		);
	else  
		return null;
end if;


  select * into ins_row
  from api.entity_tag
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_tag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_tag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_tag() TO authenticated;

-- Type: FUNCTION ; Name: api.update_entity_template(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_template()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_template%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

  	if new.owner = 'f90d618d-5de7-4126-8c65-0afb700c6c61' and new._primary = true
  		then new._primary = true;
		else new._primary = false;
	end if;

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_entitytemplate_update(
		    update_entitytemplateuuid := new.id, 
		    update_entitytemplateownerentityuuid := new.owner, 
		    update_entitytemplateparententityuuid := new.parent,	
		    update_entitytemplateexternalid := new.external_id,
		    update_entitytemplateexternalsystementityuuid := new.external_system,
		    update_entitytemplatescanid := new.scan_code,
		    update_entitytemplatenameuuid := new.name_id,
		    update_entitytemplatename := new.name,
		    update_entitytemplateorder := new._order,
		    update_entitytemplateisprimary := new._primary,
		    update_entitytemplatetypeentityuuid := new.type,
		    update_entitytemplatedeleted := new._deleted,
		    update_entitytemplatedraft := new._draft,
		    update_entitytemplatestartdate := new.activated_at,
		    update_entitytemplateenddate := new.deactivated_at,
		    update_entitytemplatemodifiedbyuuid := ins_useruuid,  
			update_languagetypeuuid :=  ins_languagetypeentityuuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.entity_template
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_template() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_template() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_template() TO authenticated;

-- Type: FUNCTION ; Name: api.update_location(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_location()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_entity uuid;
	ins_row api.location%rowtype;
  	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_location_update(
			update_locationentityuuid := new.id, 
			update_locationownerentityuuid := new.owner, 
			update_locationparententityuuid := new.parent, 
			update_locationcornerstoneentityuuid := new.cornerstone, 
			update_locationcornerstoneorder := new._order, 
			update_locationtaguuid := null::uuid, 
			update_locationtag := null::text, 
			update_locationname := new.name, 
			update_locationdisplayname := new.displayname, 
			update_locationscanid := new.scan_code, 
			update_locationtimezone := new.timezone, 
			update_languagetypeuuid := ins_languagetypeentityuuid, 
			update_locationexternalid := new.external_id, 
			update_locationexternalsystemuuid := new.external_system, 
			update_locationlatitude := (new.latitude)::text, 
			update_locationlongitude := new.longitude::text, 
			update_locationradius := new.radius::text, 
			update_locationstartdate := new.activated_at, 
			update_locationenddate := new.deactivated_at, 
			update_locationdeleted := new._deleted, 
			update_locationdraft := new._draft, 
			update_modifiedby := ins_useruuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.location
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_location() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_location() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_location() TO authenticated;

-- Type: FUNCTION ; Name: api.update_systag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_systag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.systag%rowtype;
  	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_systag_update(
			update_systagentityuuid := new.id,
			update_systagownerentityuuid := new.owner,
			update_systagparententityuuid := new.parent,
			update_systagcornerstoneentityuuid := new.cornerstone,
			update_systagcornerstoneorder := new._order,
			update_systag := new.type,
			update_systag_name := new.name,
			update_systag_displayname := new.displayname,			
			update_languagetypeuuid := ins_languagetypeentityuuid,
			update_systagexternalid := new.external_id,
			update_systagexternalsystemuuid := new.external_system,
			update_systagdeleted := new._deleted,
			update_systagdraft := new._draft,
			update_systagstartdate := new.activated_at,
			update_systagenddate := new.deactivated_at,
			update_systagmodifiedbyuuid := ins_useruuid);
	else  
		return null;
end if;

  select * into ins_row
  from api.systag
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_systag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_systag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_systag() TO authenticated;

-- Type: VIEW ; Name: alltag; Owner: tendreladmin

CREATE OR REPLACE VIEW api.alltag AS
 SELECT systag.systagentityuuid AS id,
    systag.systagid AS legacy_id,
    systag.systaguuid AS legacy_uuid,
    systag.systagcustomerentityuuid AS owner,
    systag.systagcustomername AS owner_name,
    systag.systagparententityuuid AS parent,
    systag.systagparentname AS parent_name,
    NULL::uuid AS cornerstone,
    systag.systagnameuuid AS name_id,
    systag.systagname AS name,
    systag.systagdisplaynameuuid AS displayname_id,
    systag.systagdisplayname AS displayname,
    systag.systagtype AS type,
    systag.systagcreateddate AS created_at,
    systag.systagmodifieddate AS modified_at,
    systag.systagstartdate AS activated_at,
    systag.systagenddate AS deactivated_at,
    systag.systagexternalid AS external_id,
    systag.systagexternalsystementityuuid AS external_system,
    systag.systagmodifiedbyuuid AS modified_by,
    systag.systagorder AS _order,
    systag.systagsenddeleted AS _deleted,
    systag.systagsenddrafts AS _draft,
    systag.systagsendinactive AS _active
   FROM entity.crud_systag_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) systag(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagcustomername, systagnameuuid, systagname, systagdisplaynameuuid, systagdisplayname, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagexternalsystementname, systagmodifiedbyuuid, systagabbreviationentityuuid, systagabbreviationname, systagparententityuuid, systagparentname, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)
  WHERE (systag.systagcustomerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership))) OR systag.systagcustomerentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid
UNION
 SELECT custag.custagentityuuid AS id,
    custag.custagid AS legacy_id,
    custag.custaguuid AS legacy_uuid,
    custag.custagownerentityuuid AS owner,
    custag.custagownerentityname AS owner_name,
    custag.custagparententityuuid AS parent,
    custag.custagparentname AS parent_name,
    custag.custagcornerstoneentityid AS cornerstone,
    custag.custagnameuuid AS name_id,
    custag.custagname AS name,
    custag.custagdisplaynameuuid AS displayname_id,
    custag.custagdisplayname AS displayname,
    custag.custagtype AS type,
    custag.custagcreateddate AS created_at,
    custag.custagmodifieddate AS modified_at,
    custag.custagstartdate AS activated_at,
    custag.custagenddate AS deactivated_at,
    custag.custagexternalid AS external_id,
    custag.custagexternalsystementityuuid AS external_system,
    custag.custagmodifiedbyuuid AS modified_by,
    custag.custagorder AS _order,
    custag.systagsenddeleted AS _deleted,
    custag.systagsenddrafts AS _draft,
    custag.systagsendinactive AS _active
   FROM entity.crud_custag_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) custag(languagetranslationtypeentityuuid, custagid, custaguuid, custagentityuuid, custagownerentityuuid, custagownerentityname, custagparententityuuid, custagparentname, custagcornerstoneentityid, custagcustomerid, custagcustomeruuid, custagcustomerentityuuid, custagcustomername, custagnameuuid, custagname, custagdisplaynameuuid, custagdisplayname, custagtype, custagcreateddate, custagmodifieddate, custagstartdate, custagenddate, custagexternalid, custagexternalsystementityuuid, custagexternalsystemenname, custagmodifiedbyuuid, custagabbreviationentityuuid, custagabbreviationname, custagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)
  WHERE (custag.custagownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.alltag IS '
## language
';

GRANT INSERT ON api.alltag TO authenticated;
GRANT SELECT ON api.alltag TO authenticated;
GRANT UPDATE ON api.alltag TO authenticated;

-- Type: VIEW ; Name: entity_instance_field_ux; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_instance_field_ux AS
 SELECT entityfieldinstanceuuid AS id,
    entityfieldinstanceentityinstanceentityuuid AS instance,
    entityfieldinstanceentityinstanceentityname AS instance_name,
    entityfieldinstanceownerentityuuid AS owner,
    entityfieldinstanceownerentityname AS owner_name,
    entityfieldinstancetemplateentityuuid AS template,
    entityfieldinstancetemplateentityname AS template_name,
    entityfieldinstancetemplateprimary AS template_primary,
    entityfieldinstanceentityfieldentityuuid AS field,
    entityfieldinstancetranslatedname AS field_name,
    entityfieldinstancetypeentityuuid AS type,
    entityfieldinstancetypename AS type_name,
    entityfieldinstanceentitytypeentityuuid AS entity_type,
    entityfieldinstanceentitytypename AS entity_type_name,
    entityfieldinstancevalue AS value,
    entityfieldinstancevaluelanguagemasteruuid AS value_id,
    entityfieldinstanceorder AS "order",
    entityfieldinstanceformatentityuuid AS format,
    entityfieldinstanceformatname AS format_name,
    entityfieldinstancewidgetentityuuid AS widget,
    entityfieldinstancewidgetname AS widget_name,
    entityfieldinstanceiscalculated AS _calculated,
    entityfieldinstanceiseditable AS _editable,
    entityfieldinstanceisvisible AS _visible,
    entityfieldinstanceisrequired AS _required,
    entityfieldinstanceisprimary AS _primary,
    entityfieldinstancetranslate AS _translate,
    entityfieldinstancedeleted AS _deleted,
    entityfieldinstancedraft AS _draft,
    entityfieldinstanceactive AS _active,
    entityfieldinstancestartdate AS activated_at,
    entityfieldinstanceenddate AS deactivated_at,
    entityfieldinstancecreateddate AS created_at,
    entityfieldinstancemodifieddate AS updated_at,
    entityfieldinstancemodifiedbyuuid AS modified_by
   FROM ( SELECT crud_entityfieldinstance_read_api.languagetranslationtypeentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceentityinstanceentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceentityinstanceentityname,
            crud_entityfieldinstance_read_api.entityfieldinstanceownerentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceownerentityname,
            crud_entityfieldinstance_read_api.entityfieldinstancetemplateentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancetemplateentityname,
            crud_entityfieldinstance_read_api.entityfieldinstancetemplateprimary,
            crud_entityfieldinstance_read_api.entityfieldinstanceentityfieldentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancetranslatedname,
            crud_entityfieldinstance_read_api.entityfieldinstancetypeentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancetypename,
            crud_entityfieldinstance_read_api.entityfieldinstanceentitytypeentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceentitytypename,
            crud_entityfieldinstance_read_api.entityfieldinstanceformatentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceformatname,
            crud_entityfieldinstance_read_api.entityfieldinstancewidgetentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancewidgetname,
            crud_entityfieldinstance_read_api.entityfieldinstancevalue,
            crud_entityfieldinstance_read_api.entityfieldinstancevaluelanguagemasteruuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceorder,
            crud_entityfieldinstance_read_api.entityfieldinstanceiscalculated,
            crud_entityfieldinstance_read_api.entityfieldinstanceiseditable,
            crud_entityfieldinstance_read_api.entityfieldinstanceisvisible,
            crud_entityfieldinstance_read_api.entityfieldinstanceisrequired,
            crud_entityfieldinstance_read_api.entityfieldinstanceisprimary,
            crud_entityfieldinstance_read_api.entityfieldinstancetranslate,
            crud_entityfieldinstance_read_api.entityfieldinstancecreateddate,
            crud_entityfieldinstance_read_api.entityfieldinstancemodifieddate,
            crud_entityfieldinstance_read_api.entityfieldinstancestartdate,
            crud_entityfieldinstance_read_api.entityfieldinstanceenddate,
            crud_entityfieldinstance_read_api.entityfieldinstancemodifiedbyuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancerefid,
            crud_entityfieldinstance_read_api.entityfieldinstancerefuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancevaluelanguagetypeentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancedeleted,
            crud_entityfieldinstance_read_api.entityfieldinstancedraft,
            crud_entityfieldinstance_read_api.entityfieldinstanceactive
           FROM entity.crud_entityfieldinstance_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entityfieldinstance_read_api(languagetranslationtypeentityuuid, entityfieldinstanceuuid, entityfieldinstanceentityinstanceentityuuid, entityfieldinstanceentityinstanceentityname, entityfieldinstanceownerentityuuid, entityfieldinstanceownerentityname, entityfieldinstancetemplateentityuuid, entityfieldinstancetemplateentityname, entityfieldinstancetemplateprimary, entityfieldinstanceentityfieldentityuuid, entityfieldinstancetranslatedname, entityfieldinstancetypeentityuuid, entityfieldinstancetypename, entityfieldinstanceentitytypeentityuuid, entityfieldinstanceentitytypename, entityfieldinstanceformatentityuuid, entityfieldinstanceformatname, entityfieldinstancewidgetentityuuid, entityfieldinstancewidgetname, entityfieldinstancevalue, entityfieldinstancevaluelanguagemasteruuid, entityfieldinstanceorder, entityfieldinstanceiscalculated, entityfieldinstanceiseditable, entityfieldinstanceisvisible, entityfieldinstanceisrequired, entityfieldinstanceisprimary, entityfieldinstancetranslate, entityfieldinstancecreateddate, entityfieldinstancemodifieddate, entityfieldinstancestartdate, entityfieldinstanceenddate, entityfieldinstancemodifiedbyuuid, entityfieldinstancerefid, entityfieldinstancerefuuid, entityfieldinstancevaluelanguagetypeentityuuid, entityfieldinstancedeleted, entityfieldinstancedraft, entityfieldinstanceactive)) entityfieldinstance;


GRANT INSERT ON api.entity_instance_field_ux TO authenticated;
GRANT SELECT ON api.entity_instance_field_ux TO authenticated;
GRANT UPDATE ON api.entity_instance_field_ux TO authenticated;

-- Type: VIEW ; Name: language; Owner: tendreladmin

CREATE OR REPLACE VIEW api.language AS
 SELECT systagentityuuid AS id,
    systagid AS legacy_id,
    systaguuid AS legacy_uuid,
    systagnameuuid AS name_id,
    systagname AS name,
    systagdisplaynameuuid AS displayname_id,
    systagdisplayname AS displayname,
    systagtype AS type,
    systagcreateddate AS created_at,
    systagmodifieddate AS modified_at,
    systagstartdate AS activated_at,
    systagenddate AS deactivated_at,
    systagmodifiedbyuuid AS modified_by,
    systagorder AS _order,
    systagsenddeleted AS _deleted,
    systagsenddrafts AS _draft,
    systagsendinactive AS _active
   FROM entity.crud_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid, NULL::uuid, NULL::uuid, '580f6ee2-42ca-4a5b-9e18-9ea0c168845a'::uuid, false, NULL::boolean, NULL::boolean, NULL::boolean, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid) systag(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagcustomername, systagnameuuid, systagname, systagdisplaynameuuid, systagdisplayname, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagexternalsystementname, systagmodifiedbyuuid, systagabbreviationentityuuid, systagabbreviationname, systagparententityuuid, systagparentname, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive);


GRANT INSERT ON api.language TO authenticated;
GRANT SELECT ON api.language TO authenticated;
GRANT UPDATE ON api.language TO authenticated;

-- Type: VIEW ; Name: runtime_upload; Owner: tendreladmin

CREATE OR REPLACE VIEW api.runtime_upload AS
 SELECT uploaduuid AS id,
    uploadowneruuid AS owner_tendrel_id,
    uploadbatchid AS batch_id,
    uploadrecordid AS record_id,
    uploadpreviousrecordid AS previous_record_id,
    uploadparentuuid AS parent_location_tendrel_id,
    uploadparentname AS parent_location_name,
    uploadlocationuuid AS location_tendrel_id,
    uploadlocationname AS location_name,
    uploadstartdate AS start_date,
    uploadenddate AS end_date,
    uploadduration AS duration,
    uploademployee AS worker,
    uploademployeeid AS worker_id,
    uploademployeetendreluuid AS worker_tendrel_id,
    uploadactivityuuid AS work_tendrel_id,
    uploadactivityname AS work_name,
    uploadreasoncodeuuid AS reasoncode_tendrel_id,
    uploadreasoncodename AS reasoncode_name,
    uploadunitrunoutput AS run_output,
    uploadunitrejectcount AS reject_count,
    uploadresultuuid AS result_tendrel_id,
    uploadresultname AS result_name,
    uploadunitvalue AS value,
    uploadrunid AS run_id
   FROM entity.runtime_upload_staging
  WHERE (uploadowneruuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.runtime_upload IS '
# 📘 API Specification – `POST /runtime_upload`

## Overview

The `runtime_upload` endpoint records machine-level runtime activity in Tendrel’s execution system. Each entry corresponds to a stateful unit of time — tracked per machine, per location — and optionally unified via a `batch_id` that spans multiple machines or runs.

- **Endpoint**: `POST /runtime_upload`  
- **Method**: `POST`  
- **Content-Type**: `application/json`  
- **Authentication**: Bearer JWT

---

## 🧭 Runtime Concepts & Relationships

| Concept     | Description |
|-------------|-------------|
| **Run**     | A continuous operational span at a **specific machine or location** |
| **Batch**   | A high-level grouping that spans **multiple Runs**, either across: <ul><li>Multiple Runs at the same location</li><li>Runs at different locations</li></ul> |
| **Record**  | Any `Run`, `Pulse`, `Downtime`, or `Idle Time` event |
| **Worker**  | Operator or machine controller performing the action |

> A `Run` is **machine-specific**, and identified by its `record_id`. A `batch_id` is **optional**, but allows you to **group runs** across one or many locations into a cohesive production block.

---

## 🔁 Record Lifecycle

| Type         | Start/End Required? | Can Be In-Progress? | Auto-Closable? | Notes |
|--------------|---------------------|----------------------|----------------|-------|
| `Run`        | `start` required; `end` optional | ✅ Yes | ✅ Yes (same `record_id`) | Scoped to 1 location |
| `Pulse`      | Both `start` and `end` required | ❌ No | ❌ No | Must be complete; supports `output` and `reject` |
| `Downtime`   | `start` required; `end` optional | ✅ Yes | ✅ Yes | Represents machine down state |
| `Idle Time`  | `start` required; `end` optional | ✅ Yes | ✅ Yes | Machine is on, but idle |

---

## 🔒 Logical Constraints

| Rule | Applies To |
|------|------------|
| `Pulse`, `Downtime`, `Idle Time` must occur within a valid `Run` (`run_id` must reference a `Run.record_id`) | All non-Run records |
| No overlap between `Pulse`, `Downtime`, and `Idle Time` per `Run` | Enforced by `run_id` |
| A `Run` is tied to a single location | All `Run` records |
| `batch_id` is used to **group multiple Runs**, across one or many locations | Optional field, highly recommended for full traceability |

---

## ✨ Auto-Creation Rules

The platform will automatically create referenced records for:

- `location_name`
- `worker_id`
- `reasoncode_name`

All other `_tendrel_id` values must refer to existing entities.

---

## 🌍 Parent Location

If `parent_location_tendrel_id` is not specified, the platform will **automatically associate the location to the site-level location**.

---

## 🧾 Required Fields

| Field              | Type   | Notes |
|-------------------|--------|-------|
| `owner_tendrel_id`| UUID   | Owning org or tenant |
| `run_id`          | string | For `Run`, equals `record_id`; for others, must reference a valid `Run.record_id` |
| `record_id`       | string | Unique ID for this runtime entry |
| `location_name`   | string | Auto-creates location if needed |
| `start`           | string | Required for all |
| `worker_id`       | string | Auto-creates worker if new |
| `work_name`       | string | Must be one of: `Run`, `Pulse`, `Downtime`, `Idle Time` |

---

## 🧩 Optional Fields

| Field                        | Type     | Notes |
|-----------------------------|----------|-------|
| `batch_id`                  | string   | Optional. Used to group related Runs across locations |
| `end`                       | string   | Required for `Pulse`; optional otherwise |
| `duration`                  | integer  | Optional, inferred from timestamps |
| `output`                    | integer  | For `Pulse` only |
| `reject`                    | integer  | For `Pulse` only |
| `id`                        | UUID     | DB-generated ID |
| `previous_record_id`        | string   | Optional sequence reference |
| `location_tendrel_id`       | UUID     | Must exist if supplied |
| `parent_location_tendrel_id`| UUID     | Optional, defaults to site |
| `worker`                    | string   | Display label for worker |
| `worker_tendrel_id`         | UUID     | Internal worker reference |
| `work_tendrel_id`           | UUID     | Internal work definition |
| `reasoncode_tendrel_id`     | UUID     | Must exist if used |
| `reasoncode_name`           | string   | Auto-created if new |
| `result_tendrel_id`         | UUID     | Optional |
| `result_name`               | string   | Optional |
| `value`                     | string   | Any feedback or note |

---

## 🧠 Example: Multi-Run Batch Across Two Locations

### Run at Machine A

```json
{
  "record_id": "run-001",
  "run_id": "run-001",
  "batch_id": "batch-789",
  "owner_tendrel_id": "org-001",
  "location_name": "Press Line A",
  "start": "2025-05-20T08:00:00Z",
  "worker_id": "worker-001",
  "work_name": "Run"
}
```

### Run at Machine B

```json
{
  "record_id": "run-002",
  "run_id": "run-002",
  "batch_id": "batch-789",
  "owner_tendrel_id": "org-001",
  "location_name": "Press Line B",
  "start": "2025-05-20T08:05:00Z",
  "worker_id": "worker-002",
  "work_name": "Run"
}
```

> These two `Run` records are tied together via `batch_id` but occur at different machines.

---

## ✅ Summary

| Topic | Behavior |
|-------|----------|
| `Run` is machine/location-specific | ✅ |
| `batch_id` groups Runs across machines or times | ✅ |
| `Pulse` is atomic and complete-only | ✅ |
| `Downtime` / `Idle Time` can be in-progress | ✅ |
| Only `location_name`, `worker_id`, `reasoncode_name` are auto-created | ✅ |
| Parent defaults to site if unset | ✅ |

';

CREATE TRIGGER create_runtime_upload_tg INSTEAD OF INSERT ON api.runtime_upload FOR EACH ROW EXECUTE FUNCTION api.create_runtime_upload();

GRANT INSERT ON api.runtime_upload TO authenticated;
GRANT SELECT ON api.runtime_upload TO authenticated;
GRANT UPDATE ON api.runtime_upload TO authenticated;

-- Type: VIEW ; Name: timezone; Owner: tendreladmin

CREATE OR REPLACE VIEW api.timezone AS
 SELECT name,
    abbrev,
    utc_offset,
    is_dst
   FROM pg_timezone_names
  WHERE name !~ 'posix'::text
  ORDER BY name;

COMMENT ON VIEW api.timezone IS '
## TimeZone

A description of what TimeZone are accetable

';

GRANT INSERT ON api.timezone TO authenticated;
GRANT SELECT ON api.timezone TO authenticated;
GRANT UPDATE ON api.timezone TO authenticated;

-- Type: FUNCTION ; Name: api.token(api.grant_type,text,api.token_type,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.token(grant_type api.grant_type, subject_token text, subject_token_type api.token_type, requested_token_lifetime text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  role text;
  token text;
begin
  if grant_type != 'urn:ietf:params:oauth:grant-type:token-exchange' then
    raise sqlstate 'PGRST' using
      message = '{code:unsupported_grant_type,message:The authorization grant type is not supported by the authorization server.}',
      detail = '{status:400,headers:{Cache-Control:no-store,Pragma:no-cache}}'
    ;
  end if;

  if subject_token_type != 'urn:ietf:params:oauth:token-type:jwt' then
    raise sqlstate 'PGRST' using
      message = '{code:invalid_request,message:The subject token type is not supported by the authorization server.}',
      detail = '{status:400,headers:{Cache-Control:no-store,Pragma:no-cache}}'
    ;
  end if;

  select 'god' into role
  from public.worker
  inner join public.workerinstance
    on workerid = workerinstanceworkerid
    and workerinstancecustomerid = 0
  where workeridentityid is not null
    and workeridentityid = current_setting('request.jwt.claims')::jsonb ->> 'sub'
  limit 1;

  -- TODO: This needs to consult the entity model, not the legacy model.
  select
    auth.jwt_sign(
      json_build_object(
        'owner', current_setting('request.jwt.claims')::jsonb ->> 'owner',
        'role', coalesce(role, 'authenticated'),
        'scope', string_agg(systagtype, ' '),
        'exp', extract(epoch from now() + requested_token_lifetime::interval),
        'iat', extract(epoch from now()),
        'iss', 'urn:tendrel:test',
        'nbf', extract(epoch from now() - '30s'::interval),
        'sub', current_setting('request.jwt.claims')::jsonb ->> 'sub'
      )
    ) into token
  from public.worker
  left join public.customer
    on customeruuid = current_setting('request.jwt.claims')::jsonb ->> 'owner'
  left join public.workerinstance
    on workerid = workerinstanceworkerid
    and customerid = workerinstancecustomerid
  left join public.systag
    on workerinstanceuserroleid = systagid
  where
    workeridentityid is not null
    and workeridentityid = current_setting('request.jwt.claims')::jsonb ->> 'sub'
    and (workerenddate is null or workerenddate > now())
  ;

  if not found then
    raise exception 'token exchange failed';
  end if;

  return jsonb_build_object(
      'access_token', token,
      'issued_token_type', 'urn:ietf:params:oauth:token-type:jwt',
      'token_type', 'Bearer'
  );
end $function$;


REVOKE ALL ON FUNCTION api.token(api.grant_type,text,api.token_type,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.token(api.grant_type,text,api.token_type,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.token(api.grant_type,text,api.token_type,text) TO anonymous;
GRANT EXECUTE ON FUNCTION api.token(api.grant_type,text,api.token_type,text) TO authenticated;
CREATE TRIGGER create_custag_tg INSTEAD OF INSERT ON api.custag FOR EACH ROW EXECUTE FUNCTION api.create_custag();

CREATE TRIGGER update_custag_tg INSTEAD OF UPDATE ON api.custag FOR EACH ROW EXECUTE FUNCTION api.update_custag();

CREATE TRIGGER create_customer_tg INSTEAD OF INSERT ON api.customer FOR EACH ROW EXECUTE FUNCTION api.create_customer();

CREATE TRIGGER create_customer_requested_language_tg INSTEAD OF INSERT ON api.customer_requested_language FOR EACH ROW EXECUTE FUNCTION api.create_customer_requested_language();

CREATE TRIGGER create_entity_description_tg INSTEAD OF INSERT ON api.entity_description FOR EACH ROW EXECUTE FUNCTION api.create_entity_description();

CREATE TRIGGER create_entity_field_tg INSTEAD OF INSERT ON api.entity_field FOR EACH ROW EXECUTE FUNCTION api.create_entity_field();

CREATE TRIGGER update_customer_tg INSTEAD OF UPDATE ON api.customer FOR EACH ROW EXECUTE FUNCTION api.update_customer();

CREATE TRIGGER create_entity_instance_tg INSTEAD OF INSERT ON api.entity_instance FOR EACH ROW EXECUTE FUNCTION api.create_entity_instance();

CREATE TRIGGER update_customer_requested_language_tg INSTEAD OF UPDATE ON api.customer_requested_language FOR EACH ROW EXECUTE FUNCTION api.update_customer_requested_language();

CREATE TRIGGER update_entity_description_tg INSTEAD OF UPDATE ON api.entity_description FOR EACH ROW EXECUTE FUNCTION api.update_entity_description();

CREATE TRIGGER create_entity_instance_field_tg INSTEAD OF INSERT ON api.entity_instance_field FOR EACH ROW EXECUTE FUNCTION api.create_entity_instance_field();

CREATE TRIGGER update_entity_field_tg INSTEAD OF UPDATE ON api.entity_field FOR EACH ROW EXECUTE FUNCTION api.update_entity_field();

CREATE TRIGGER create_entity_instance_file_tg INSTEAD OF INSERT ON api.entity_instance_file FOR EACH ROW EXECUTE FUNCTION api.create_entity_instance_file();

CREATE TRIGGER update_entity_instance_tg INSTEAD OF UPDATE ON api.entity_instance FOR EACH ROW EXECUTE FUNCTION api.update_entity_instance();

CREATE TRIGGER create_entity_tag_tg INSTEAD OF INSERT ON api.entity_tag FOR EACH ROW EXECUTE FUNCTION api.create_entity_tag();

CREATE TRIGGER create_entity_template_tg INSTEAD OF INSERT ON api.entity_template FOR EACH ROW EXECUTE FUNCTION api.create_entity_template();

CREATE TRIGGER update_entity_instance_file_tg INSTEAD OF UPDATE ON api.entity_instance_file FOR EACH ROW EXECUTE FUNCTION api.update_entity_instance_file();

CREATE TRIGGER update_entity_instance_field_tg INSTEAD OF UPDATE ON api.entity_instance_field FOR EACH ROW EXECUTE FUNCTION api.update_entity_instance_field();

CREATE TRIGGER create_runtime_upload_tg INSTEAD OF INSERT ON api.runtime_upload FOR EACH ROW EXECUTE FUNCTION api.create_runtime_upload();

CREATE TRIGGER create_systag_tg INSTEAD OF INSERT ON api.systag FOR EACH ROW EXECUTE FUNCTION api.create_systag();

CREATE TRIGGER create_location_tg INSTEAD OF INSERT ON api.location FOR EACH ROW EXECUTE FUNCTION api.create_location();

CREATE TRIGGER update_entity_template_tg INSTEAD OF UPDATE ON api.entity_template FOR EACH ROW EXECUTE FUNCTION api.update_entity_template();

CREATE TRIGGER update_entity_tag_tg INSTEAD OF UPDATE ON api.entity_tag FOR EACH ROW EXECUTE FUNCTION api.update_entity_tag();

CREATE TRIGGER update_systag_tg INSTEAD OF UPDATE ON api.systag FOR EACH ROW EXECUTE FUNCTION api.update_systag();

CREATE TRIGGER update_location_tg INSTEAD OF UPDATE ON api.location FOR EACH ROW EXECUTE FUNCTION api.update_location();


-- Type: FUNCTION ; Name: api.delete_custag(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_custag(owner uuid, id uuid)
 RETURNS SETOF api.custag
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_custag_delete(
	      create_custagownerentityuuid := owner,
	      create_custagentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
end if;

  return query
    select *
    from api.custag t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_custag(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_custag(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_custag(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_customer(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_customer(owner uuid, id uuid)
 RETURNS SETOF api.customer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.
  
select get_workerinstanceid
into ins_userid
from _api.util_user_details();

--if (select owner in (select * from _api.util_get_onwership()) )
--	then  
	  call entity.crud_customer_delete(
	      create_customerownerentityuuid := owner,
	      create_customerentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
--	else
--		return;  -- need an exception here
--end if;

  return query
    select *
    from api.customer t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_customer(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_customer(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_customer(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_customer_requested_language(uuid,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_customer_requested_language(owner uuid, id text)
 RETURNS SETOF api.customer_requested_language
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
	templanguagetypeid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.
  
select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
		call entity.crud_customerrequestedlanguage_delete(
			create_customerownerentityuuid := owner,
			create_language_id := id,
			create_modifiedbyid := ins_userid
	);
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.customer_requested_language t
    where t.owner = $1  and 
		t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_customer_requested_language(uuid,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_customer_requested_language(uuid,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_customer_requested_language(uuid,text) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_entity_description(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_description(owner uuid, id uuid)
 RETURNS SETOF api.entity_description
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.

  
select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_entitydescription_delete(
	      create_entitydescriptionownerentityuuid := owner,
	      create_entitydescriptionentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_description t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_description(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_description(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_description(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_entity_field(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_field(owner uuid, id uuid)
 RETURNS SETOF api.entity_field
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.
select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_entityfield_delete(
	      create_entityfieldownerentityuuid := owner,
	      create_entityfieldentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_field t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_field(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_field(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_field(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_entity_instance(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_instance(owner uuid, id uuid)
 RETURNS SETOF api.entity_instance
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.
select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_entityinstance_delete(
	      create_entityinstanceownerentityuuid := owner,
	      create_entityinstanceentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_instance t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_instance(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_instance(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_instance(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_entity_instance_field(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_instance_field(owner uuid, id uuid)
 RETURNS SETOF api.entity_instance_field
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_entityfieldinstance_delete(
	      create_entityfieldinstanceownerentityuuid := owner,
	      create_entityfieldinstanceentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;	  

  return query
    select *
    from api.entity_instance_field t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_instance_field(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_instance_field(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_instance_field(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_entity_instance_file(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_instance_file(owner uuid, id uuid)
 RETURNS SETOF api.entity_instance_file
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_entityfileinstance_delete(
	      create_entityfileinstanceownerentityuuid := owner,
	      create_entityfileinstanceentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_instance_file t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_instance_file(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_instance_file(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_instance_file(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_entity_tag(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_tag(owner uuid, id uuid)
 RETURNS SETOF api.entity_tag
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_entitytag_delete(
	      create_entitytagownerentityuuid := owner,
	      create_entitytagentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_tag t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_tag(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_tag(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_tag(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_entity_template(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_template(owner uuid, id uuid)
 RETURNS SETOF api.entity_template
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.
select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_entitytemplate_delete(
	      create_entitytemplateownerentityuuid := owner,
	      create_entitytemplateentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_template t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_template(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_template(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_template(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_location(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_location(owner uuid, id uuid)
 RETURNS SETOF api.location
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_location_delete(
	      create_locationownerentityuuid := owner,
	      create_locationentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.location t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_location(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_location(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_location(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_reason_code(uuid,uuid,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_reason_code(owner uuid, id uuid, work_template_constraint text, work_template text)
 RETURNS SETOF api.reason_code
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

-- NEED TO ADD MORE CONDITIONS.  
-- DO WE ALLOW THE CONSTRAINT TO BE DELETED OR JUST THE CUSTAG TO BE DEACTIVATED.
-- VERSION BELOW JUST DEACTIVATES THE CUSTAG, BUT THAT IS FOR ALL TEMPLATES.

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_custag_delete(
	      create_custagownerentityuuid := owner,
	      create_custagentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
end if;

  return query
    select *
    from api.reason_code t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_systag(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_systag(owner uuid, id uuid)
 RETURNS SETOF api.systag
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_systag_delete(
	      create_systagownerentityuuid := owner,
	      create_systagentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.systag t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_systag(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_systag(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_systag(uuid,uuid) TO authenticated;

END;
