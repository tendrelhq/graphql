BEGIN;

/*
DROP FUNCTION api.delete_entity_instance(uuid,uuid);
DROP VIEW api.entity_instance;

DROP FUNCTION entity.crud_entityinstance_read_api(uuid[],uuid,uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_entityinstance_read_api(uuid[],uuid,uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entityinstance_read_api(read_entityinstanceownerentityuuid uuid[], read_entityinstanceentityuuid uuid, read_entityinstanceparententityuuid uuid, read_entityinstancecornerstoneentityuuid uuid, read_entityinstanceentitytemplateentityuuid uuid, read_entityinstancetypeentityuuid uuid, read_allentityinstances boolean, read_entityinstancetag uuid, read_entityinstancesenddeleted boolean, read_entityinstancesenddrafts boolean, read_entityinstancesendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, entityinstanceoriginalid bigint, entityinstanceoriginaluuid text, entityinstanceuuid uuid, entityinstanceownerentityuuid uuid, entityinstanceownerentityname text, entityinstanceparententityuuid uuid, entityinstanceparententityname text, entityinstancecornerstoneentityuuid uuid, entityinstancecornerstoneentitname text, entityinstancecornerstoneorder integer, entityinstanceentitytemplateentityuuid uuid, entityinstanceentitytemplatename text, entityinstanceentitytemplatetranslatedname text, entityinstancetypeentityuuid uuid, entityinstancetype text, entityinstancenameuuid text, entityinstancename text, entityinstancescanid text, entityinstancesiteentityuuid uuid, entityinstancecreateddate timestamp with time zone, entityinstancemodifieddate timestamp with time zone, entityinstancemodifiedbyuuid text, entityinstancestartdate timestamp with time zone, entityinstanceenddate timestamp with time zone, entityinstanceexternalid text, entityinstanceexternalsystementityuuid uuid, entityinstanceexternalsystementityname text, entityinstancerefid bigint, entityinstancerefuuid text, entityinstancedeleted boolean, entityinstancedraft boolean, entityinstanceactive boolean, entityinstancetagentityuuid uuid)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allcustomers boolean; 
	tempentityinstancesenddeleted boolean[];
	tempentityinstancesenddrafts boolean[];
	tempentityinstancesendinactive boolean[];
	tempentityinstanceparententityuuid uuid[];
	tempentityinstancecornerstoneentityuuid uuid[];
	tempentityinstanceentitytemplateentityuuid uuid[];
	tempentityinstancetypeentityuuid uuid[];
	tempentityinstancetag uuid[];
	templanguagetranslationtypeid bigint;
BEGIN

-- Curently ignores language translation.  We should change this in the future for location. 
-- Might want to add a parameter to send in active as a boolean
-- probably should move this to use arrays for in parameters

/*  examples

-- call entity.test_entity()

-- all customers all entities all tags
select * from entity.crud_entityinstance_read_full(null,null,null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
limit 100

-- specific customer all entities all tags
select * from entity.crud_entityinstance_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
limit 100

-- specific instance

select * from entity.crud_entityinstance_read_full(
	'd7995576-8354-4aea-b052-1ce61052bd2e', --read_entityinstanceownerentityuuid uuid,
	'0ce5be8d-2bec-4219-be97-07dc154b2e3b', --read_entityinstanceentityuuid uuid,
	'24855715-9228-4f41-bfe6-493f4c374a6e', --read_entityinstanceparententityuuid uuid,
	'2ab5461d-ad96-4560-a36d-d0fa53bce0f0', --read_entityinstancecornerstoneentityuuid uuid,
	'0b9f3142-e7ed-4f78-8504-ccd2eb505075', --read_entityinstanceentitytemplateentityuuid uuid,
	'67af22cb-3183-4e6e-8542-7968f744965a', --read_entityinstancetypeentityuuid uuid,
	false,
	'f3fe9cae-c21e-4dba-9a10-008cfa6dca39', --read_entityinstancetag uuid,
	null, --read_entityinstancesenddeleted boolean,
	null, --read_entityinstancesenddrafts boolean,
	null, --read_entityinstancesendinactive boolean,
	null)

-- specific parent
select entityinstanceparententityuuid,* from entity.crud_entityinstance_read_full(
	'd7995576-8354-4aea-b052-1ce61052bd2e', --read_entityinstanceownerentityuuid uuid,
	null, --read_entityinstanceentityuuid uuid,
	'24855715-9228-4f41-bfe6-493f4c374a6e', --read_entityinstanceparententityuuid uuid,
	null, --read_entityinstancecornerstoneentityuuid uuid,
	null, --read_entityinstanceentitytemplateentityuuid uuid,
	null, --read_entityinstancetypeentityuuid uuid,
	false,
	null, --read_entityinstancetag uuid,
	null, --read_entityinstancesenddeleted boolean,
	null, --read_entityinstancesenddrafts boolean,
	null, --read_entityinstancesendinactive boolean,
	null)

-- specific cornerstone 
select * from entity.crud_entityinstance_read_full(
	'd7995576-8354-4aea-b052-1ce61052bd2e', --read_entityinstanceownerentityuuid uuid,
	null, --read_entityinstanceentityuuid uuid,
	null, --read_entityinstanceparententityuuid uuid,
	'2ab5461d-ad96-4560-a36d-d0fa53bce0f0', --read_entityinstancecornerstoneentityuuid uuid,
	null, --read_entityinstanceentitytemplateentityuuid uuid,
	null, --read_entityinstancetypeentityuuid uuid,
	false,
	null, --read_entityinstancetag uuid,
	null, --read_entityinstancesenddeleted boolean,
	null, --read_entityinstancesenddrafts boolean,
	null, --read_entityinstancesendinactive boolean,
	null)

-- specific template 
select * from entity.crud_entityinstance_read_full(
	'd7995576-8354-4aea-b052-1ce61052bd2e', --read_entityinstanceownerentityuuid uuid,
	null, --read_entityinstanceentityuuid uuid,
	null, --read_entityinstanceparententityuuid uuid,
	null, --read_entityinstancecornerstoneentityuuid uuid,
	'0b9f3142-e7ed-4f78-8504-ccd2eb505075', --read_entityinstanceentitytemplateentityuuid uuid,
	null, --read_entityinstancetypeentityuuid uuid,
	false,
	null, --read_entityinstancetag uuid,
	null, --read_entityinstancesenddeleted boolean,
	null, --read_entityinstancesenddrafts boolean,
	null, --read_entityinstancesendinactive boolean,
	null)

-- specific tag 
select * from entity.crud_entityinstance_read_full(
	'd7995576-8354-4aea-b052-1ce61052bd2e', --read_entityinstanceownerentityuuid uuid,
	null, --read_entityinstanceentityuuid uuid,
	null, --read_entityinstanceparententityuuid uuid,
	null, --read_entityinstancecornerstoneentityuuid uuid,
	null, --read_entityinstanceentitytemplateentityuuid uuid,
	null, --read_entityinstancetypeentityuuid uuid,
	false,
	'f3fe9cae-c21e-4dba-9a10-008cfa6dca39', --read_entityinstancetag uuid,
	null, --read_entityinstancesenddeleted boolean,
	null, --read_entityinstancesenddrafts boolean,
	null, --read_entityinstancesendinactive boolean,
	null)

select * from entity.entitytag where entitytagentityinstanceentityuuid = '0ce5be8d-2bec-4219-be97-07dc154b2e3b'

select * from entity.entityinstance where entityinstanceuuid = ??

select * from entity.entityinstance limit 100

*/

if read_languagetranslationtypeentityuuid isNull
	then read_languagetranslationtypeentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'; 
end if;

templanguagetranslationtypeid =  (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, read_languagetranslationtypeentityuuid, null, false,read_entityinstancesenddeleted, read_entityinstancesenddrafts, read_entityinstancesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'));

-- all entities

	return query 
		SELECT 
			read_languagetranslationtypeentityuuid,
			ei.entityinstanceoriginalid,
			ei.entityinstanceoriginaluuid,
			ei.entityinstanceuuid,
			ei.entityinstanceownerentityuuid,
			COALESCE(ltowner.languagetranslationvalue,lmowner.languagemastersource),
			ei.entityinstanceparententityuuid,	
			COALESCE(ltparent.languagetranslationvalue,lmparent.languagemastersource),
			ei.entityinstancecornerstoneentityuuid,
			COALESCE(ltcorner.languagetranslationvalue,lmcorner.languagemastersource),
			ei.entityinstancecornerstoneorder, 
			ei.entityinstanceentitytemplateentityuuid,			
			ei.entityinstanceentitytemplatename, 
			COALESCE(lttemplate.languagetranslationvalue,lmtemplate.languagemastersource),
			ei.entityinstancetypeentityuuid,
			ei.entityinstancetype, 
			ei.entityinstancenameuuid,  -- eliminate the field once things ae fixed.  
			COALESCE(ltname.languagetranslationvalue,lmname.languagemastersource),
			ei.entityinstancescanid, 
			ei.entityinstancesiteentityuuid,  
			ei.entityinstancecreateddate,
			ei.entityinstancemodifieddate,
			ei.entityinstancemodifiedbyuuid,
			ei.entityinstancestartdate ,	
			ei.entityinstanceenddate,
			ei.entityinstanceexternalid, 
			null::uuid, 
			null::text, 
			ei.entityinstancerefid, 
			ei.entityinstancerefuuid, 
			ei.entityinstancedeleted, 
			ei.entityinstancedraft,
			case when ei.entityinstancedeleted then false
					when ei.entityinstancedraft then false
					when ei.entityinstanceenddate::Date > now()::date 
						and ei.entityinstancestartdate < now() then false
					else true
			end as entityinstanceactive,
			null::uuid as entityinstancetagentityuuid			
		from entity.entityinstance ei
		inner join entity.entityinstance customer
			on customer.entityinstanceuuid = ei.entityinstanceownerentityuuid
				and ei.entityinstanceownerentityuuid = ANY(read_entityinstanceownerentityuuid)
		inner join public.languagemaster lmowner
			on customer.entityinstancenameuuid = lmowner.languagemasteruuid
		left join public.languagetranslations ltowner
			on lmowner.languagemasterid = ltowner.languagetranslationmasterid
				and ltowner.languagetranslationtypeid  = templanguagetranslationtypeid
			join  entity.entityinstance eiparent
				on ei.entityinstanceparententityuuid = eiparent.entityinstanceuuid
			join languagemaster lmparent
				on eiparent.entityinstancenameuuid = lmparent.languagemasteruuid
			left join public.languagetranslations ltparent
				on ltparent.languagetranslationmasterid  = lmparent.languagemasterid
					and ltparent.languagetranslationtypeid = templanguagetranslationtypeid 
			join  entity.entityinstance eicorner
				on ei.entityinstancecornerstoneentityuuid = eicorner.entityinstanceuuid
			join languagemaster lmcorner
				on eicorner.entityinstancenameuuid = lmcorner.languagemasteruuid
			left join public.languagetranslations ltcorner
				on ltcorner.languagetranslationmasterid  = lmcorner.languagemasterid
					and ltcorner.languagetranslationtypeid = templanguagetranslationtypeid 
			join  entity.entitytemplate eitemplate
				on eitemplate.entitytemplateuuid = ei.entityinstanceentitytemplateentityuuid
			join languagemaster lmtemplate
				on eitemplate.entitytemplatenameuuid = lmtemplate.languagemasteruuid
			left join public.languagetranslations lttemplate
				on lttemplate.languagetranslationmasterid  = lmtemplate.languagemasterid
					and lttemplate.languagetranslationtypeid = templanguagetranslationtypeid 
			join languagemaster lmname
				on ei.entityinstancenameuuid = lmname.languagemasteruuid
			left join public.languagetranslations ltname
				on ltname.languagetranslationmasterid  = lmname.languagemasterid
					and ltname.languagetranslationtypeid = templanguagetranslationtypeid
			left join  entity.entityinstance eisystem
				on ei.entityinstanceexternalsystementityuuid = eisystem.entityinstanceuuid
			left join languagemaster lmsystem
				on eisystem.entityinstancenameuuid = lmsystem.languagemasteruuid
			left join public.languagetranslations ltsystem
				on ltsystem.languagetranslationmasterid  = lmsystem.languagemasterid
					and ltsystem.languagetranslationtypeid = templanguagetranslationtypeid;
		return;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entityinstance_read_api(uuid[],uuid,uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityinstance_read_api(uuid[],uuid,uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityinstance_read_api(uuid[],uuid,uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entityinstance_read_api(uuid[],uuid,uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) TO graphql;

-- DEPENDANTS


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

END;
