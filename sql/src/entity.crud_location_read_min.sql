BEGIN;

/*
DROP FUNCTION api.delete_location(uuid,uuid);
DROP VIEW api.location;

DROP FUNCTION entity.crud_location_read_min(uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_location_read_min(uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_location_read_min(read_locationownerentityuuid uuid, read_locationentityuuid uuid, read_locationparententityuuid uuid, read_locationcornerstoneentityuuid uuid, read_alllocations boolean, read_locationtag uuid, read_locationsenddeleted boolean, read_locationsenddrafts boolean, read_locationsendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, locationid bigint, locationuuid text, locationentityuuid uuid, locationownerentityuuid uuid, locationparententityuuid uuid, locationcornerstoneentityuuid uuid, locationcustomerid bigint, locationcustomeruuid text, locationcustomerentityuuid uuid, locationnameuuid text, locationdisplaynameuuid text, locationscanid text, locationcreateddate timestamp with time zone, locationmodifieddate timestamp with time zone, locationmodifiedbyuuid text, locationstartdate timestamp with time zone, locationenddate timestamp with time zone, locationexternalid text, locationexternalsystementityuuid uuid, locationcornerstoneorder integer, locationlatitude numeric, locationlongitude numeric, locationradius numeric, locationtimezone text, locationtagentityuuid uuid, locationsenddeleted boolean, locationsenddrafts boolean, locationsendinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allcustomers boolean; 
	templocationsenddeleted boolean[];
	templocationsenddrafts boolean[];
	templocationsendinactive boolean[];
	tendreluuid uuid;
BEGIN

-- Curently ignores language translation.  We should change this in the future for location. 
-- Might want to add a parameter to send in active as a boolean
-- probably should move this to use arrays for in parameters

/*  examples

-- call entity.test_entity()

-- all customers all locations all tags
select * from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
limit 10
-- all locations for a specific customer all tags
select * from entity.crud_location_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- all locations for a specific customer and specific tag
select * from entity.crud_location_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null,null,true,'1aefd363-45aa-4986-80e9-e8e212059a85',null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- specific parent
select * from entity.crud_location_read_min('92eba0ba-b271-40d0-8d64-6de19b3df6f7',null,'36a3c4ef-07ce-4295-9132-8c323099dcc4',null,false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- specific cornerstone
select * from entity.crud_location_read_min('58f4032b-d614-4f7d-97e7-e20240205229',null,null,'dceec0cf-f626-4775-807a-3bacc70de8eb',false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- specific location 

select * from entity.crud_location_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61','af4dc39d-7d4a-46a4-9ad0-980c23bff933',null,null,false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- negative test
-- ADD SOME.  DID NOT DO THIS YET. 

*/

-- A future version with all customers???
-- all locations ignore tags.  This can return duplicates.

if read_locationownerentityuuid isNull
	then allcustomers = true;
	else allcustomers = false;
end if;

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if  read_locationsenddeleted = false
	then templocationsenddeleted = Array[false];
	else templocationsenddeleted = Array[true,false];
end if;

if  read_locationsenddrafts = false
	then templocationsenddrafts = Array[false];
	else templocationsenddrafts = Array[true,false];
end if;

if  read_locationsendinactive = false
	then templocationsendinactive = Array[true];
	else templocationsendinactive = Array[true,false];
end if;

if allcustomers = true and read_alllocations = true and read_locationtag isNull
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			ei.entityinstanceoriginalid as locationid,
			ei.entityinstanceoriginaluuid as locationuuid,
			ei.entityinstanceuuid as locationentityuuid,
			ei.entityinstanceownerentityuuid as locationownerentityuuid,	
			ei.entityinstanceparententityuuid as locationparententityuuid,	
			ei.entityinstancecornerstoneentityuuid  as locationcornerstoneentityuuid,
			cust.customerid as locationcustomerid,	
			cust.customeruuid as locationcustomeruuid,
			cust.customerentityuuid as locationcustomerentityuuid,
			ei.entityinstancenameuuid as locationnameuuid,
			dn.entityfieldinstancevaluelanguagemasteruuid as locationdisplaynameuuid,
			ei.entityinstancescanid as locationscanid,
			ei.entityinstancecreateddate as locationcreateddate,
			ei.entityinstancemodifieddate as locationmodifieddate,
			ei.entityinstancemodifiedbyuuid as locationmodifiedbyuuid,
			ei.entityinstancestartdate as locationstartdate,	
			ei.entityinstanceenddate as locationenddate,
			ei.entityinstanceexternalid as locationexternalid,
			ei.entityinstanceexternalsystementityuuid as locationexternalsystementityuuid,
			ei.entityinstancecornerstoneorder as  locationcornerstoneorder,
			lat.entityfieldinstancevalue::numeric as locationlatitude,	
			lon.entityfieldinstancevalue::numeric as locationlongitude,
			rad.entityfieldinstancevalue::numeric as locationradius,	
			tz.entityfieldinstancevalue as locationtimezone,
			enttag.entitytagcustagentityuuid as locationtagentityuuid,
			ei.entityinstancedeleted, 
			ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
		from entity.entityinstance ei
			Join (select customerid,customeruuid, customerentityuuid  
					from entity.crud_customer_read_min(read_locationownerentityuuid,null,null,allcustomers, null,null,null,null)) as cust
				on cust.customerentityuuid = ei.entityinstanceownerentityuuid
					and ei.entityinstanceentitytemplatename = 'Location' 
					and ei.entityinstancedeleted = ANY (templocationsenddeleted)
					and ei.entityinstancedraft = ANY (templocationsenddrafts)
			join entity.entityfieldinstance dn
				on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
					and dn.entityfieldinstanceentityfieldname = 'locationdisplayname' 
			join entity.entityfieldinstance lat
				on ei.entityinstanceuuid = lat.entityfieldinstanceentityinstanceentityuuid
					and lat.entityfieldinstanceentityfieldname = 'locationlatitude' 
			join entity.entityfieldinstance lon
				on ei.entityinstanceuuid = lon.entityfieldinstanceentityinstanceentityuuid
					and lon.entityfieldinstanceentityfieldname = 'locationlongitude' 
			join entity.entityfieldinstance rad
				on ei.entityinstanceuuid = rad.entityfieldinstanceentityinstanceentityuuid
					and rad.entityfieldinstanceentityfieldname = 'locationradius' 
			join entity.entityfieldinstance tz
				on ei.entityinstanceuuid = tz.entityfieldinstanceentityinstanceentityuuid
					and tz.entityfieldinstanceentityfieldname = 'locationtimezone' 
			left join entity.entitytag enttag
				on enttag.entitytagentityinstanceentityuuid = ei.entityinstanceuuid) as foo
		where foo.entityinstanceactive = Any (templocationsendinactive) ; 
		return;
end if;

-- all locations for a customer

if allcustomers = false and read_alllocations = true and read_locationtag isNull
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			ei.entityinstanceoriginalid as locationid,
			ei.entityinstanceoriginaluuid as locationuuid,
			ei.entityinstanceuuid as locationentityuuid,
			ei.entityinstanceownerentityuuid as locationownerentityuuid,	
			ei.entityinstanceparententityuuid as locationparententityuuid,	
			ei.entityinstancecornerstoneentityuuid  as locationcornerstoneentityuuid,
			cust.customerid as locationcustomerid,	
			cust.customeruuid as locationcustomeruuid,
			cust.customerentityuuid as locationcustomerentityuuid,
			ei.entityinstancenameuuid as locationnameuuid,
			dn.entityfieldinstancevaluelanguagemasteruuid as locationdisplaynameuuid,
			ei.entityinstancescanid as locationscanid,
			ei.entityinstancecreateddate as locationcreateddate,
			ei.entityinstancemodifieddate as locationmodifieddate,
			ei.entityinstancemodifiedbyuuid as locationmodifiedbyuuid,
			ei.entityinstancestartdate as locationstartdate,	
			ei.entityinstanceenddate as locationenddate,
			ei.entityinstanceexternalid as locationexternalid,
			ei.entityinstanceexternalsystementityuuid as locationexternalsystementityuuid,
			ei.entityinstancecornerstoneorder as  locationcornerstoneorder,
			lat.entityfieldinstancevalue::numeric as locationlatitude,	
			lon.entityfieldinstancevalue::numeric as locationlongitude,
			rad.entityfieldinstancevalue::numeric as locationradius,	
			tz.entityfieldinstancevalue as locationtimezone,
			enttag.entitytagcustagentityuuid as locationtagentityuuid,
			ei.entityinstancedeleted, 
			ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
		from entity.entityinstance ei
			Join (select customerid,customeruuid, customerentityuuid  from entity.crud_customer_read_min(read_locationownerentityuuid,null,null,allcustomers, null,null,null,null)) as cust
				on cust.customerentityuuid = ei.entityinstanceownerentityuuid
					and ei.entityinstanceentitytemplatename = 'Location'  
					and ei.entityinstanceownerentityuuid = read_locationownerentityuuid
					and ei.entityinstancedeleted = ANY (templocationsenddeleted)
					and ei.entityinstancedraft = ANY (templocationsenddrafts)
			join entity.entityfieldinstance dn
				on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
					and dn.entityfieldinstanceentityfieldname = 'locationdisplayname' 
			join entity.entityfieldinstance lat
				on ei.entityinstanceuuid = lat.entityfieldinstanceentityinstanceentityuuid
					and lat.entityfieldinstanceentityfieldname = 'locationlatitude' 
			join entity.entityfieldinstance lon
				on ei.entityinstanceuuid = lon.entityfieldinstanceentityinstanceentityuuid
					and lon.entityfieldinstanceentityfieldname = 'locationlongitude' 
			join entity.entityfieldinstance rad
				on ei.entityinstanceuuid = rad.entityfieldinstanceentityinstanceentityuuid
					and rad.entityfieldinstanceentityfieldname = 'locationradius' 
			join entity.entityfieldinstance tz
				on ei.entityinstanceuuid = tz.entityfieldinstanceentityinstanceentityuuid
					and tz.entityfieldinstanceentityfieldname = 'locationtimezone' 
			left join entity.entitytag enttag
				on enttag.entitytagentityinstanceentityuuid = ei.entityinstanceuuid) as foo
		where foo.entityinstanceactive = Any (templocationsendinactive) ; 
			return;
end if;

-- all locations for a parent 

if allcustomers = false and read_alllocations = false 
	and read_locationparententityuuid notNull and read_locationtag isNull
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			ei.entityinstanceoriginalid as locationid,
			ei.entityinstanceoriginaluuid as locationuuid,
			ei.entityinstanceuuid as locationentityuuid,
			ei.entityinstanceownerentityuuid as locationownerentityuuid,	
			ei.entityinstanceparententityuuid as locationparententityuuid,	
			ei.entityinstancecornerstoneentityuuid  as locationcornerstoneentityuuid,
			cust.customerid as locationcustomerid,	
			cust.customeruuid as locationcustomeruuid,
			cust.customerentityuuid as locationcustomerentityuuid,
			ei.entityinstancenameuuid as locationnameuuid,
			dn.entityfieldinstancevaluelanguagemasteruuid as locationdisplaynameuuid,
			ei.entityinstancescanid as locationscanid,
			ei.entityinstancecreateddate as locationcreateddate,
			ei.entityinstancemodifieddate as locationmodifieddate,
			ei.entityinstancemodifiedbyuuid as locationmodifiedbyuuid,
			ei.entityinstancestartdate as locationstartdate,	
			ei.entityinstanceenddate as locationenddate,
			ei.entityinstanceexternalid as locationexternalid,
			ei.entityinstanceexternalsystementityuuid as locationexternalsystementityuuid,
			ei.entityinstancecornerstoneorder as  locationcornerstoneorder,
			lat.entityfieldinstancevalue::numeric as locationlatitude,	
			lon.entityfieldinstancevalue::numeric as locationlongitude,
			rad.entityfieldinstancevalue::numeric as locationradius,	
			tz.entityfieldinstancevalue as locationtimezone,
			enttag.entitytagcustagentityuuid as locationtagentityuuid,
			ei.entityinstancedeleted, 
			ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
		from entity.entityinstance ei
			Join (select customerid,customeruuid, customerentityuuid  from entity.crud_customer_read_min(read_locationownerentityuuid,null,null,allcustomers, null,null,null,null)) as cust
				on cust.customerentityuuid = ei.entityinstanceownerentityuuid
					and ei.entityinstanceentitytemplatename = 'Location'  
					and ei.entityinstanceownerentityuuid = read_locationownerentityuuid
					and ei.entityinstanceparententityuuid  = read_locationparententityuuid
					and ei.entityinstancedeleted = ANY (templocationsenddeleted)
					and ei.entityinstancedraft = ANY (templocationsenddrafts)
			join entity.entityfieldinstance dn
				on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
					and dn.entityfieldinstanceentityfieldname = 'locationdisplayname' 
			join entity.entityfieldinstance lat
				on ei.entityinstanceuuid = lat.entityfieldinstanceentityinstanceentityuuid
					and lat.entityfieldinstanceentityfieldname = 'locationlatitude' 
			join entity.entityfieldinstance lon
				on ei.entityinstanceuuid = lon.entityfieldinstanceentityinstanceentityuuid
					and lon.entityfieldinstanceentityfieldname = 'locationlongitude' 
			join entity.entityfieldinstance rad
				on ei.entityinstanceuuid = rad.entityfieldinstanceentityinstanceentityuuid
					and rad.entityfieldinstanceentityfieldname = 'locationradius' 
			join entity.entityfieldinstance tz
				on ei.entityinstanceuuid = tz.entityfieldinstanceentityinstanceentityuuid
					and tz.entityfieldinstanceentityfieldname = 'locationtimezone' 
			left join entity.entitytag enttag
				on enttag.entitytagentityinstanceentityuuid = ei.entityinstanceuuid) as foo
		where foo.entityinstanceactive = Any (templocationsendinactive) ; 
			return;
end if;

if allcustomers = false and read_alllocations = false 
	and read_locationcornerstoneentityuuid notNull and read_locationtag isNull
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			ei.entityinstanceoriginalid as locationid,
			ei.entityinstanceoriginaluuid as locationuuid,
			ei.entityinstanceuuid as locationentityuuid,
			ei.entityinstanceownerentityuuid as locationownerentityuuid,	
			ei.entityinstanceparententityuuid as locationparententityuuid,	
			ei.entityinstancecornerstoneentityuuid  as locationcornerstoneentityuuid,
			cust.customerid as locationcustomerid,	
			cust.customeruuid as locationcustomeruuid,
			cust.customerentityuuid as locationcustomerentityuuid,
			ei.entityinstancenameuuid as locationnameuuid,
			dn.entityfieldinstancevaluelanguagemasteruuid as locationdisplaynameuuid,
			ei.entityinstancescanid as locationscanid,
			ei.entityinstancecreateddate as locationcreateddate,
			ei.entityinstancemodifieddate as locationmodifieddate,
			ei.entityinstancemodifiedbyuuid as locationmodifiedbyuuid,
			ei.entityinstancestartdate as locationstartdate,	
			ei.entityinstanceenddate as locationenddate,
			ei.entityinstanceexternalid as locationexternalid,
			ei.entityinstanceexternalsystementityuuid as locationexternalsystementityuuid,
			ei.entityinstancecornerstoneorder as  locationcornerstoneorder,
			lat.entityfieldinstancevalue::numeric as locationlatitude,	
			lon.entityfieldinstancevalue::numeric as locationlongitude,
			rad.entityfieldinstancevalue::numeric as locationradius,	
			tz.entityfieldinstancevalue as locationtimezone,
			enttag.entitytagcustagentityuuid as locationtagentityuuid,
			ei.entityinstancedeleted, 
			ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
		from entity.entityinstance ei
			Join (select customerid,customeruuid, customerentityuuid  from entity.crud_customer_read_min(read_locationownerentityuuid,null,null,allcustomers, null,null,null,null)) as cust
				on cust.customerentityuuid = ei.entityinstanceownerentityuuid
					and ei.entityinstanceentitytemplatename = 'Location'  
					and ei.entityinstanceownerentityuuid = read_locationownerentityuuid
					and ei.entityinstancecornerstoneentityuuid  = read_locationcornerstoneentityuuid
					and ei.entityinstancedeleted = ANY (templocationsenddeleted)
					and ei.entityinstancedraft = ANY (templocationsenddrafts)
			join entity.entityfieldinstance dn
				on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
					and dn.entityfieldinstanceentityfieldname = 'locationdisplayname' 
			join entity.entityfieldinstance lat
				on ei.entityinstanceuuid = lat.entityfieldinstanceentityinstanceentityuuid
					and lat.entityfieldinstanceentityfieldname = 'locationlatitude' 
			join entity.entityfieldinstance lon
				on ei.entityinstanceuuid = lon.entityfieldinstanceentityinstanceentityuuid
					and lon.entityfieldinstanceentityfieldname = 'locationlongitude' 
			join entity.entityfieldinstance rad
				on ei.entityinstanceuuid = rad.entityfieldinstanceentityinstanceentityuuid
					and rad.entityfieldinstanceentityfieldname = 'locationradius' 
			join entity.entityfieldinstance tz
				on ei.entityinstanceuuid = tz.entityfieldinstanceentityinstanceentityuuid
					and tz.entityfieldinstanceentityfieldname = 'locationtimezone' 
			left join entity.entitytag enttag
				on enttag.entitytagentityinstanceentityuuid = ei.entityinstanceuuid) as foo
		where foo.entityinstanceactive = Any (templocationsendinactive) ; 
			return;
end if;

-- all locations for a specific customer and specific tag
if allcustomers = false and read_alllocations = true and read_locationtag notNull
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			ei.entityinstanceoriginalid as locationid,
			ei.entityinstanceoriginaluuid as locationuuid,
			ei.entityinstanceuuid as locationentityuuid,
			ei.entityinstanceownerentityuuid as locationownerentityuuid,	
			ei.entityinstanceparententityuuid as locationparententityuuid,	
			ei.entityinstancecornerstoneentityuuid  as locationcornerstoneentityuuid,
			cust.customerid as locationcustomerid,	
			cust.customeruuid as locationcustomeruuid,
			cust.customerentityuuid as locationcustomerentityuuid,
			ei.entityinstancenameuuid as locationnameuuid,
			dn.entityfieldinstancevaluelanguagemasteruuid as locationdisplaynameuuid,
			ei.entityinstancescanid as locationscanid,
			ei.entityinstancecreateddate as locationcreateddate,
			ei.entityinstancemodifieddate as locationmodifieddate,
			ei.entityinstancemodifiedbyuuid as locationmodifiedbyuuid,
			ei.entityinstancestartdate as locationstartdate,	
			ei.entityinstanceenddate as locationenddate,
			ei.entityinstanceexternalid as locationexternalid,
			ei.entityinstanceexternalsystementityuuid as locationexternalsystementityuuid,
			ei.entityinstancecornerstoneorder as  locationcornerstoneorder,
			lat.entityfieldinstancevalue::numeric as locationlatitude,	
			lon.entityfieldinstancevalue::numeric as locationlongitude,
			rad.entityfieldinstancevalue::numeric as locationradius,	
			tz.entityfieldinstancevalue as locationtimezone,
			read_locationtag as locationtagentityuuid,
			ei.entityinstancedeleted, 
			ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
		from entity.entityinstance ei
			Join (select customerid,customeruuid, customerentityuuid  from entity.crud_customer_read_min(read_locationownerentityuuid,null,null,allcustomers, null,null,null,null)) as cust
				on cust.customerentityuuid = ei.entityinstanceownerentityuuid
					and ei.entityinstanceentitytemplatename = 'Location'  
					and ei.entityinstanceownerentityuuid = read_locationownerentityuuid
					and ei.entityinstancedeleted = ANY (templocationsenddeleted)
					and ei.entityinstancedraft = ANY (templocationsenddrafts)
			join entity.entityfieldinstance dn
				on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
					and dn.entityfieldinstanceentityfieldname = 'locationdisplayname' 
			join entity.entityfieldinstance lat
				on ei.entityinstanceuuid = lat.entityfieldinstanceentityinstanceentityuuid
					and lat.entityfieldinstanceentityfieldname = 'locationlatitude' 
			join entity.entityfieldinstance lon
				on ei.entityinstanceuuid = lon.entityfieldinstanceentityinstanceentityuuid
					and lon.entityfieldinstanceentityfieldname = 'locationlongitude' 
			join entity.entityfieldinstance rad
				on ei.entityinstanceuuid = rad.entityfieldinstanceentityinstanceentityuuid
					and rad.entityfieldinstanceentityfieldname = 'locationradius' 
			join entity.entityfieldinstance tz
				on ei.entityinstanceuuid = tz.entityfieldinstanceentityinstanceentityuuid
					and tz.entityfieldinstanceentityfieldname = 'locationtimezone' 
			join entity.entitytag enttag  -- this filters to the correct tag.  Should I check by tempalte?
				on enttag.entitytagentityinstanceentityuuid = ei.entityinstanceuuid
					and enttag.entitytagcustagentityuuid = read_locationtag) as foo
		where foo.entityinstanceactive = Any (templocationsendinactive) ; 
		return;

end if;

-- specific location 
if allcustomers = false and read_alllocations = false and read_locationentityuuid notNull
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			ei.entityinstanceoriginalid as locationid,
			ei.entityinstanceoriginaluuid as locationuuid,
			ei.entityinstanceuuid as locationentityuuid,
			ei.entityinstanceownerentityuuid as locationownerentityuuid,	
			ei.entityinstanceparententityuuid as locationparententityuuid,	
			ei.entityinstancecornerstoneentityuuid  as locationcornerstoneentityuuid,
			cust.customerid as locationcustomerid,	
			cust.customeruuid as locationcustomeruuid,
			cust.customerentityuuid as locationcustomerentityuuid,
			ei.entityinstancenameuuid as locationnameuuid,
			dn.entityfieldinstancevaluelanguagemasteruuid as locationdisplaynameuuid,
			ei.entityinstancescanid as locationscanid,
			ei.entityinstancecreateddate as locationcreateddate,
			ei.entityinstancemodifieddate as locationmodifieddate,
			ei.entityinstancemodifiedbyuuid as locationmodifiedbyuuid,
			ei.entityinstancestartdate as locationstartdate,	
			ei.entityinstanceenddate as locationenddate,
			ei.entityinstanceexternalid as locationexternalid,
			ei.entityinstanceexternalsystementityuuid as locationexternalsystementityuuid,
			ei.entityinstancecornerstoneorder as  locationcornerstoneorder,
			lat.entityfieldinstancevalue::numeric as locationlatitude,	
			lon.entityfieldinstancevalue::numeric as locationlongitude,
			rad.entityfieldinstancevalue::numeric as locationradius,	
			tz.entityfieldinstancevalue as locationtimezone,
			enttag.entitytagcustagentityuuid as locationtagentityuuid,
			ei.entityinstancedeleted, 
			ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
		from entity.entityinstance ei
			Join (select customerid,customeruuid, customerentityuuid  from entity.crud_customer_read_min(read_locationownerentityuuid,null,null,allcustomers, null,null,null,null)) as cust
				on cust.customerentityuuid = ei.entityinstanceownerentityuuid
					and ei.entityinstanceentitytemplatename = 'Location'  
					and ei.entityinstanceownerentityuuid = read_locationownerentityuuid
					and ei.entityinstanceuuid = read_locationentityuuid
					and ei.entityinstancedeleted = ANY (templocationsenddeleted)
					and ei.entityinstancedraft = ANY (templocationsenddrafts)
			join entity.entityfieldinstance dn
				on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
					and dn.entityfieldinstanceentityfieldname = 'locationdisplayname' 
			join entity.entityfieldinstance lat
				on ei.entityinstanceuuid = lat.entityfieldinstanceentityinstanceentityuuid
					and lat.entityfieldinstanceentityfieldname = 'locationlatitude' 
			join entity.entityfieldinstance lon
				on ei.entityinstanceuuid = lon.entityfieldinstanceentityinstanceentityuuid
					and lon.entityfieldinstanceentityfieldname = 'locationlongitude' 
			join entity.entityfieldinstance rad
				on ei.entityinstanceuuid = rad.entityfieldinstanceentityinstanceentityuuid
					and rad.entityfieldinstanceentityfieldname = 'locationradius' 
			join entity.entityfieldinstance tz
				on ei.entityinstanceuuid = tz.entityfieldinstanceentityinstanceentityuuid
					and tz.entityfieldinstanceentityfieldname = 'locationtimezone'
			left join entity.entitytag enttag
				on enttag.entitytagentityinstanceentityuuid = ei.entityinstanceuuid) as foo
		where foo.entityinstanceactive = Any (templocationsendinactive) ; 
				return;
				
end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_location_read_min(uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_location_read_min(uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_location_read_min(uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_location_read_min(uuid,uuid,uuid,uuid,boolean,uuid,boolean,boolean,boolean,uuid) TO graphql;

-- DEPENDANTS


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

END;
