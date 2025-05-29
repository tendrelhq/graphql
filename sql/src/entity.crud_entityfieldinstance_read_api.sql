BEGIN;

/*
DROP VIEW api.entity_instance_field_ux;

DROP FUNCTION entity.crud_entityfieldinstance_read_api(uuid[],uuid,uuid,boolean,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_entityfieldinstance_read_api(uuid[],uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entityfieldinstance_read_api(read_entityfieldinstanceownerentityuuid uuid[], read_entityfieldinstanceentityinstanceentityuuid uuid, read_entityfieldinstanceentityuuid uuid, read_allentityfieldinstances boolean, read_entityfieldinstancesenddeleted boolean, read_entityfieldinstancesenddrafts boolean, read_entityfieldinstancesendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, entityfieldinstanceuuid uuid, entityfieldinstanceentityinstanceentityuuid uuid, entityfieldinstanceentityinstanceentityname text, entityfieldinstanceownerentityuuid uuid, entityfieldinstanceownerentityname text, entityfieldinstancetemplateentityuuid uuid, entityfieldinstancetemplateentityname text, entityfieldinstancetemplateprimary boolean, entityfieldinstanceentityfieldentityuuid uuid, entityfieldinstancetranslatedname text, entityfieldinstancetypeentityuuid uuid, entityfieldinstancetypename text, entityfieldinstanceentitytypeentityuuid uuid, entityfieldinstanceentitytypename text, entityfieldinstanceformatentityuuid uuid, entityfieldinstanceformatname text, entityfieldinstancewidgetentityuuid uuid, entityfieldinstancewidgetname text, entityfieldinstancevalue text, entityfieldinstancevaluelanguagemasteruuid text, entityfieldinstanceorder integer, entityfieldinstanceiscalculated boolean, entityfieldinstanceiseditable boolean, entityfieldinstanceisvisible boolean, entityfieldinstanceisrequired boolean, entityfieldinstanceisprimary boolean, entityfieldinstancetranslate boolean, entityfieldinstancecreateddate timestamp with time zone, entityfieldinstancemodifieddate timestamp with time zone, entityfieldinstancestartdate timestamp with time zone, entityfieldinstanceenddate timestamp with time zone, entityfieldinstancemodifiedbyuuid text, entityfieldinstancerefid bigint, entityfieldinstancerefuuid text, entityfieldinstancevaluelanguagetypeentityuuid uuid, entityfieldinstancedeleted boolean, entityfieldinstancedraft boolean, entityfieldinstanceactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allcustomers boolean; 
	tempentityfieldinstancesenddeleted boolean[];
	tempentityfieldinstancesenddrafts boolean[];
	tempentityfieldinstancesendinactive boolean[];
	templanguagetranslationtypeid bigint;	
	templanguagetranslationtypeuuid text;
BEGIN

-- Curently ignores language translation.  We should change this in the future for location. 
-- Might want to add a parameter to send in active as a boolean
-- probably should move this to use arrays for in parameters

/*  examples

-- call entity.test_entity()

-- all customers all entities all tags
select * from entity.crud_entityfieldinstance_read_full(null,null,null,true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
limit 100

-- specific customer all entities all tags
select * from entity.crud_entityfieldinstance_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null,true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
limit 100

-- specific entity instance

select * from entity.crud_entityfieldinstance_read_full(
	'f90d618d-5de7-4126-8c65-0afb700c6c61', --read_entityfieldinstanceownerentityuuid uuid,
	'b6b8b170-954d-47cf-8d84-d925babd0987', --read_entityfieldinstanceentityinstanceentityuuid uuid,
	null, --read_entityfieldinstanceentityuuid uuid,
	false, --read_allentityfieldinstances boolean,
	null, --read_entityinstancesenddeleted boolean,
	null, --read_entityinstancesenddrafts boolean,
	null,
	null )

-- specific field instance

select * from entity.crud_entityfieldinstance_read_full(
	'f90d618d-5de7-4126-8c65-0afb700c6c61', --read_entityfieldinstanceownerentityuuid uuid,
	'b6b8b170-954d-47cf-8d84-d925babd0987', --read_entityfieldinstanceentityinstanceentityuuid uuid,
	'28e66975-b0d8-4420-ad44-8a4173e4e64f', --read_entityfieldinstanceentityuuid uuid,
	false, --read_allentityfieldinstances boolean,
	null, --read_entityinstancesenddeleted boolean,
	null, --read_entityinstancesenddrafts boolean,
	null,
	null )

select * from entity.entityfieldinstance limit 10

*/

if read_entityfieldinstanceownerentityuuid isNull
	then allcustomers = true;
	else allcustomers = false;
end if;

if read_languagetranslationtypeentityuuid isNull
	then read_languagetranslationtypeentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'; 
end if;

select systaguuid, systagid
into templanguagetranslationtypeuuid,templanguagetranslationtypeid
from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, read_languagetranslationtypeentityuuid, null, false,read_entityfieldinstancesenddeleted,read_entityfieldinstancesenddrafts, read_entityfieldinstancesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9');

-- all entities
 
return query 
SELECT 
		read_languagetranslationtypeentityuuid,
		efi.entityfieldinstanceuuid, 
		efi.entityfieldinstanceentityinstanceentityuuid, 
		efi.entityfieldinstanceentityinstanceentityname,			
		efi.entityfieldinstanceownerentityuuid,
		COALESCE(ltowner.languagetranslationvalue,lmowner.languagemastersource),	
		template.entitytemplateuuid as template,
		template.entitytemplatename as template_name,
		template.entitytemplateisprimary as template_primary,
		efi.entityfieldinstanceentityfieldentityuuid,
		field.entityfieldtranslatedname,
		field.entityfieldtypeentityuuid, 
		field.entityfieldtypename,
		field.entityfieldentitytypeentityuuid, 
		field.entityfieldentitytypename,
		field.entityfieldformatentityuuid, 
		field.entityfieldformatname, 
		field.entityfieldwidgetentityuuid, 
		field.entityfieldwidgetname,
		efi.entityfieldinstancevalue,    -- how do we determin this (should be a value, a string, or a uuid)
		efi.entityfieldinstancevaluelanguagemasteruuid,
		field.entityfieldorder::integer,
		field.entityfieldiscalculated, 
		field.entityfieldiseditable, 
		field.entityfieldisvisible, 
		field.entityfieldisrequired, 
		field.entityfieldisprimary, 
		field.entityfieldtranslate,
		efi.entityfieldinstancecreateddate, 
		efi.entityfieldinstancemodifieddate, 
		efi.entityfieldinstancestartdate, 
		efi.entityfieldinstanceenddate, 
		efi.entityfieldinstancemodifiedbyuuid, 
		efi.entityfieldinstancerefid, 
		efi.entityfieldinstancerefuuid, 
		efi.entityfieldinstancevaluelanguagetypeentityuuid, 
		efi.entityfieldinstancedeleted, 
		efi.entityfieldinstancedraft,
		case when efi.entityfieldinstancedeleted then false
				when efi.entityfieldinstancedraft then false
				when efi.entityfieldinstanceenddate::Date > now()::date 
					and efi.entityfieldinstancestartdate < now() then false
				else true
		end as entityfieldinstanceactive
	from (select * from entity.crud_entityfieldinstance_read_full(null,null,null,true,null,null,null,read_languagetranslationtypeentityuuid)) efi
		join  entity.entityinstance eiowner
			on efi.entityfieldinstanceownerentityuuid= eiowner.entityinstanceuuid  
				and efi.entityfieldinstanceownerentityuuid = ANY(read_entityfieldinstanceownerentityuuid)
		join languagemaster lmowner
			on eiowner.entityinstancenameuuid = lmowner.languagemasteruuid
		left join public.languagetranslations ltowner
			on ltowner.languagetranslationmasterid  = lmowner.languagemasterid
				and ltowner.languagetranslationtypeid = templanguagetranslationtypeid
		inner join (select * from entity.crud_entityfield_read_full(null, null, null,true, null, null,read_languagetranslationtypeentityuuid)) field
			on efi.entityfieldinstanceentityfieldentityuuid = entityfielduuid
		inner join (select * from entity.crud_entitytemplate_read_full(null, null, null, null, null,read_languagetranslationtypeentityuuid)) template
			on field.entityfieldentitytemplateentityuuid   = template.entitytemplateuuid; 		
	return;

end;
$function$;


REVOKE ALL ON FUNCTION entity.crud_entityfieldinstance_read_api(uuid[],uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfieldinstance_read_api(uuid[],uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfieldinstance_read_api(uuid[],uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entityfieldinstance_read_api(uuid[],uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO graphql;

-- DEPENDANTS


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

END;
