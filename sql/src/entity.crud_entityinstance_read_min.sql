
-- Type: FUNCTION ; Name: entity.crud_entityinstance_read_min(uuid,uuid,uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entityinstance_read_min(read_entityinstanceownerentityuuid uuid, read_entityinstanceentityuuid uuid, read_entityinstanceparententityuuid uuid, read_entityinstancecornerstoneentityuuid uuid, read_entityinstanceentitytemplateentityuuid uuid, read_entityinstancetypeentityuuid uuid, read_allentityinstances boolean, read_entityinstancetag uuid, read_entityinstancesenddeleted boolean, read_entityinstancesenddrafts boolean, read_entityinstancesendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, entityinstanceoriginalid bigint, entityinstanceoriginaluuid text, entityinstanceuuid uuid, entityinstanceownerentityuuid uuid, entityinstanceparententityuuid uuid, entityinstancecornerstoneentityuuid uuid, entityinstancecornerstoneorder integer, entityinstanceentitytemplateentityuuid uuid, entityinstanceentitytemplatename text, entityinstancetypeentityuuid uuid, entityinstancetype text, entityinstancenameuuid text, entityinstancescanid text, entityinstancesiteentityuuid uuid, entityinstancecreateddate timestamp with time zone, entityinstancemodifieddate timestamp with time zone, entityinstancemodifiedbyuuid text, entityinstancestartdate timestamp with time zone, entityinstanceenddate timestamp with time zone, entityinstanceexternalid text, entityinstanceexternalsystementityuuid uuid, entityinstancerefid bigint, entityinstancerefuuid text, entityinstancedeleted boolean, entityinstancedraft boolean, entityinstanceactive boolean, entityinstancetagentityuuid uuid)
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
BEGIN

-- Curently ignores language translation.  We should change this in the future for location. 
-- Might want to add a parameter to send in active as a boolean
-- probably should move this to use arrays for in parameters

/*  examples

-- call entity.test_entity()

-- all customers all entities all tags
select * from entity.crud_entityinstance_read_min(null,null,null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
limit 100

-- specific customer all entities all tags
select * from entity.crud_entityinstance_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
limit 100

-- specific instance

select * from entity.crud_entityinstance_read_min(
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
select entityinstanceparententityuuid,* from entity.crud_entityinstance_read_min(
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
select * from entity.crud_entityinstance_read_min(
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
select * from entity.crud_entityinstance_read_min(
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
select * from entity.crud_entityinstance_read_min(
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

select * from entity.crud_entityinstance_read_min(
	'd7995576-8354-4aea-b052-1ce61052bd2e', --read_entityinstanceownerentityuuid uuid,
	'0ce5be8d-2bec-4219-be97-07dc154b2e3b', --read_entityinstanceentityuuid uuid,
	null, --read_entityinstanceparententityuuid uuid,
	null, --read_entityinstancecornerstoneentityuuid uuid,
	null, --read_entityinstanceentitytemplateentityuuid uuid,
	null, --read_entityinstancetypeentityuuid uuid,
	false,
	null, --read_entityinstancetag uuid,
	null, --read_entityinstancesenddeleted boolean,
	null, --read_entityinstancesenddrafts boolean,
	null, --read_entityinstancesendinactive boolean,
	null)

*/

if read_entityinstanceownerentityuuid isNull
	then allcustomers = true;
	else allcustomers = false;
end if;

if read_languagetranslationtypeentityuuid isNull
	then read_languagetranslationtypeentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'; 
end if;

if read_entityinstancesenddeleted isNull and read_entityinstancesenddeleted = false
	then tempentityinstancesenddeleted = Array[false];
	else tempentityinstancesenddeleted = Array[true,false];
end if;

if read_entityinstancesenddrafts isNull and read_entityinstancesenddrafts = false
	then tempentityinstancesenddrafts = Array[false];
	else tempentityinstancesenddrafts = Array[true,false];
end if;

if read_entityinstancesendinactive isNull and read_entityinstancesendinactive = false
	then tempentityinstancesendinactive = Array[true];
	else tempentityinstancesendinactive = Array[true,false];
end if;

-- all entities

if allcustomers = true and read_allentityinstances = true 
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			ei.entityinstanceoriginalid,
			ei.entityinstanceoriginaluuid,
			ei.entityinstanceuuid,
			ei.entityinstanceownerentityuuid,
			ei.entityinstanceparententityuuid,	
			ei.entityinstancecornerstoneentityuuid,
			ei.entityinstancecornerstoneorder, 
			ei.entityinstanceentitytemplateentityuuid,
			ei.entityinstanceentitytemplatename, 
			ei.entityinstancetypeentityuuid,
			ei.entityinstancetype, 
			ei.entityinstancenameuuid,  -- eliminate the field once things ae fixed.  
			ei.entityinstancescanid, 
			ei.entityinstancesiteentityuuid,  -- deprecate this
			ei.entityinstancecreateddate,
			ei.entityinstancemodifieddate,
			ei.entityinstancemodifiedbyuuid,
			ei.entityinstancestartdate ,	
			ei.entityinstanceenddate,
			ei.entityinstanceexternalid, 
			ei.entityinstanceexternalsystementityuuid, 
			ei.entityinstancerefid, 
			ei.entityinstancerefuuid, 
			ei.entityinstancedeleted, 
			ei.entityinstancedraft,
			case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
				then false
				else true
			end as entityinstanceactive,
			enttag.entitytagcustagentityuuid as entityinstancetagentityuuid			
		from entity.entityinstance ei
			Join (select customerid,customeruuid, customerentityuuid  
					from entity.crud_customer_read_min(read_entityinstanceownerentityuuid,null,null,allcustomers, read_entityinstancesenddeleted,read_entityinstancesenddrafts,read_entityinstancesendinactive,null)) as cust
				on cust.customerentityuuid = ei.entityinstanceownerentityuuid
					and ei.entityinstancedeleted = ANY (tempentityinstancesenddeleted)
				 	and ei.entityinstancedraft = ANY (tempentityinstancesenddrafts)
			left join entity.entitytag enttag
				on enttag.entitytagentityinstanceentityuuid = ei.entityinstanceuuid ) as foo
		where foo.entityinstanceactive = Any (tempentityinstancesendinactive) ;
		return;
				
end if;

-- all entities for a customer

if allcustomers = false and read_allentityinstances = true 
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			ei.entityinstanceoriginalid,
			ei.entityinstanceoriginaluuid,
			ei.entityinstanceuuid,
			ei.entityinstanceownerentityuuid,
			ei.entityinstanceparententityuuid,	
			ei.entityinstancecornerstoneentityuuid,
			ei.entityinstancecornerstoneorder, 
			ei.entityinstanceentitytemplateentityuuid,
			ei.entityinstanceentitytemplatename, 
			ei.entityinstancetypeentityuuid,
			ei.entityinstancetype, 
			ei.entityinstancenameuuid,  -- eliminate the field once things ae fixed.  
			ei.entityinstancescanid, 
			ei.entityinstancesiteentityuuid,  -- deprecate this
			ei.entityinstancecreateddate,
			ei.entityinstancemodifieddate,
			ei.entityinstancemodifiedbyuuid,
			ei.entityinstancestartdate ,	
			ei.entityinstanceenddate,
			ei.entityinstanceexternalid, 
			ei.entityinstanceexternalsystementityuuid, 
			ei.entityinstancerefid, 
			ei.entityinstancerefuuid, 
			ei.entityinstancedeleted, 
			ei.entityinstancedraft,
			case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
				then false
				else true
			end as entityinstanceactive,
			enttag.entitytagcustagentityuuid as entityinstancetagentityuuid			
		from entity.entityinstance ei
			Join (select customerid,customeruuid, customerentityuuid  
					from entity.crud_customer_read_min(read_entityinstanceownerentityuuid,null,null,allcustomers, read_entityinstancesenddeleted,read_entityinstancesenddrafts,read_entityinstancesendinactive,null)) as cust
				on cust.customerentityuuid = ei.entityinstanceownerentityuuid
					and ei.entityinstanceownerentityuuid = read_entityinstanceownerentityuuid
					and ei.entityinstancedeleted = ANY (tempentityinstancesenddeleted)
				 	and ei.entityinstancedraft = ANY (tempentityinstancesenddrafts)
			left join entity.entitytag enttag
				on enttag.entitytagentityinstanceentityuuid = ei.entityinstanceuuid ) as foo
		where foo.entityinstanceactive = Any (tempentityinstancesendinactive) ;
		return;			
end if;

-- do individual instance first then all the params. 

if read_entityinstanceentityuuid notNull
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			ei.entityinstanceoriginalid,
			ei.entityinstanceoriginaluuid,
			ei.entityinstanceuuid,
			ei.entityinstanceownerentityuuid,
			ei.entityinstanceparententityuuid,	
			ei.entityinstancecornerstoneentityuuid,
			ei.entityinstancecornerstoneorder, 
			ei.entityinstanceentitytemplateentityuuid,
			ei.entityinstanceentitytemplatename, 
			ei.entityinstancetypeentityuuid,
			ei.entityinstancetype, 
			ei.entityinstancenameuuid,  -- eliminate the field once things ae fixed.  
			ei.entityinstancescanid, 
			ei.entityinstancesiteentityuuid,  -- deprecate this
			ei.entityinstancecreateddate,
			ei.entityinstancemodifieddate,
			ei.entityinstancemodifiedbyuuid,
			ei.entityinstancestartdate ,	
			ei.entityinstanceenddate,
			ei.entityinstanceexternalid, 
			ei.entityinstanceexternalsystementityuuid, 
			ei.entityinstancerefid, 
			ei.entityinstancerefuuid, 
			ei.entityinstancedeleted, 
			ei.entityinstancedraft,
			case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
				then false
				else true
			end as entityinstanceactive,
			enttag.entitytagcustagentityuuid as entityinstancetagentityuuid			
		from entity.entityinstance ei
			Join (select customerid,customeruuid, customerentityuuid  
					from entity.crud_customer_read_min(read_entityinstanceownerentityuuid,null,null,allcustomers, read_entityinstancesenddeleted,read_entityinstancesenddrafts,read_entityinstancesendinactive,null)) as cust
				on cust.customerentityuuid = ei.entityinstanceownerentityuuid
					and ei.entityinstanceownerentityuuid = read_entityinstanceownerentityuuid
					and ei.entityinstancedeleted = ANY (tempentityinstancesenddeleted)
				 	and ei.entityinstancedraft = ANY (tempentityinstancesenddrafts)
					and ei.entityinstanceuuid = read_entityinstanceentityuuid
			left join entity.entitytag enttag
				on enttag.entitytagentityinstanceentityuuid = ei.entityinstanceuuid ) as foo
		where foo.entityinstanceactive = Any (tempentityinstancesendinactive) ;
		return;		
end if;

if 	read_entityinstanceparententityuuid isNull
	then tempentityinstanceparententityuuid = ARRAY(select tei.entityinstanceparententityuuid 
															from entity.entityinstance tei
															where tei.entityinstanceownerentityuuid = read_entityinstanceownerentityuuid
															group by tei.entityinstanceparententityuuid);
	else tempentityinstanceparententityuuid = ARRAY[read_entityinstanceparententityuuid];
end if;

if 	read_entityinstancecornerstoneentityuuid isNull
	then tempentityinstancecornerstoneentityuuid = ARRAY(select tei.entityinstancecornerstoneentityuuid 
															from entity.entityinstance tei
															where tei.entityinstanceownerentityuuid = read_entityinstanceownerentityuuid
															group by tei.entityinstancecornerstoneentityuuid);
	else tempentityinstancecornerstoneentityuuid = ARRAY[read_entityinstancecornerstoneentityuuid];
end if;

if 	read_entityinstanceentitytemplateentityuuid isNull
	then tempentityinstanceentitytemplateentityuuid = ARRAY(select tei.entityinstanceentitytemplateentityuuid 
															from entity.entityinstance tei
															where tei.entityinstanceownerentityuuid = read_entityinstanceownerentityuuid
															group by tei.entityinstanceentitytemplateentityuuid);
	else tempentityinstanceentitytemplateentityuuid = ARRAY[read_entityinstanceentitytemplateentityuuid];
end if;

if 	read_entityinstancetypeentityuuid isNull
	then tempentityinstancetypeentityuuid =  ARRAY(select tei.entityinstancetypeentityuuid 
															from entity.entityinstance tei
															where tei.entityinstanceownerentityuuid = read_entityinstanceownerentityuuid
															group by tei.entityinstancetypeentityuuid);
	else tempentityinstancetypeentityuuid = ARRAY[read_entityinstancetypeentityuuid];
end if;

if 	read_entityinstancetag isNull
	then tempentityinstancetag =  ARRAY(select tei.entitytagcustagentityuuid 
												from entity.entitytag tei
												where tei.entitytagownerentityuuid = read_entityinstanceownerentityuuid
												group by tei.entitytagcustagentityuuid);
	else tempentityinstancetag = ARRAY[read_entityinstancetag];
end if;

return query 
	select *
	from (SELECT 
		read_languagetranslationtypeentityuuid,
		ei.entityinstanceoriginalid,
		ei.entityinstanceoriginaluuid,
		ei.entityinstanceuuid,
		ei.entityinstanceownerentityuuid,
		ei.entityinstanceparententityuuid,	
		ei.entityinstancecornerstoneentityuuid,
		ei.entityinstancecornerstoneorder, 
		ei.entityinstanceentitytemplateentityuuid,
		ei.entityinstanceentitytemplatename, 
		ei.entityinstancetypeentityuuid,
		ei.entityinstancetype, 
		ei.entityinstancenameuuid,  -- eliminate the field once things ae fixed.  
		ei.entityinstancescanid, 
		ei.entityinstancesiteentityuuid,  -- deprecate this
		ei.entityinstancecreateddate,
		ei.entityinstancemodifieddate,
		ei.entityinstancemodifiedbyuuid,
		ei.entityinstancestartdate ,	
		ei.entityinstanceenddate,
		ei.entityinstanceexternalid, 
		ei.entityinstanceexternalsystementityuuid, 
		ei.entityinstancerefid, 
		ei.entityinstancerefuuid, 
		ei.entityinstancedeleted, 
		ei.entityinstancedraft,
		case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
			then false
			else true
		end as entityinstanceactive,
		enttag.entitytagcustagentityuuid as entityinstancetagentityuuid			
	from entity.entityinstance ei
		Join (select customerid,customeruuid, customerentityuuid  
				from entity.crud_customer_read_min(read_entityinstanceownerentityuuid,null,null,allcustomers,read_entityinstancesenddeleted,read_entityinstancesenddrafts,read_entityinstancesendinactive, null)) as cust
			on cust.customerentityuuid = ei.entityinstanceownerentityuuid
				and ei.entityinstanceownerentityuuid = read_entityinstanceownerentityuuid
				and ei.entityinstancedeleted = ANY (tempentityinstancesenddeleted)
				and ei.entityinstancedraft = ANY (tempentityinstancesenddrafts)
				and ei.entityinstanceparententityuuid  = ANY (tempentityinstanceparententityuuid) 
				and ei.entityinstancecornerstoneentityuuid  = ANY (tempentityinstancecornerstoneentityuuid)
				and ei.entityinstanceentitytemplateentityuuid  = ANY (tempentityinstanceentitytemplateentityuuid )
				and ei.entityinstancetypeentityuuid  = ANY (tempentityinstancetypeentityuuid )
		left join entity.entitytag enttag
			on enttag.entitytagentityinstanceentityuuid = ei.entityinstanceuuid
				and enttag.entitytagcustagentityuuid  = ANY (tempentityinstancetag)) as foo
	where foo.entityinstanceactive = Any (tempentityinstancesendinactive) ;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entityinstance_read_min(uuid,uuid,uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityinstance_read_min(uuid,uuid,uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityinstance_read_min(uuid,uuid,uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entityinstance_read_min(uuid,uuid,uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) TO graphql;
