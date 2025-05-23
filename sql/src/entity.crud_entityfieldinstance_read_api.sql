
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
