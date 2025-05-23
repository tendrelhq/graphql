
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
