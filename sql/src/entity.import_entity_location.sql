
-- Type: PROCEDURE ; Name: entity.import_entity_location(text); Owner: bombadil

CREATE OR REPLACE PROCEDURE entity.import_entity_location(IN intervaltype text)
 LANGUAGE plpgsql
AS $procedure$
Declare
   location_start timestamp with time zone;
	maxdate timestamp with time zone;
--	updatedate timestamp with time zone;
	insertdate timestamp with time zone;
	englishuuid uuid;
	
Begin

	englishuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
	
-- Start the timer on this function
	location_start = clock_timestamp();
	maxdate = 	(select max(locationmodifieddate) 
					from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,englishuuid));

	insertdate = 
		case
			when intervaltype = '5 minute' and maxdate notNull
				Then (select (max(locationmodifieddate)- interval '1 hour') 
						from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,englishuuid))
			when intervaltype = '1 hour' and maxdate notNull
				Then (select (max(locationmodifieddate)- interval '2 hour') 
						from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,englishuuid))			
			Else '01/01/1900'
		end;	

--------- move parent and cornerstone joins to left then reset them if they are null to self.  

INSERT INTO entity.entityinstance(
	entityinstanceoriginalid, 
	entityinstanceoriginaluuid, 
	entityinstanceownerentityuuid, 
	entityinstanceparententityuuid,
	entityinstancecornerstoneentityuuid,
	entityinstancecornerstoneorder,
	entityinstancescanid,
	entityinstanceentitytemplateentityuuid, 
	entityinstancetypeentityuuid, 
	entityinstancecreateddate, 
	entityinstancemodifieddate, 
	entityinstancestartdate, 
	entityinstanceenddate, 
	entityinstanceexternalid, 
	entityinstanceexternalsystementityuuid,
	entityinstancemodifiedbyuuid, 
	entityinstancerefid,
	entityinstancerefuuid,
	entityinstanceentitytemplatename,
	entityinstancetype,
	entityinstancenameuuid
	)
SELECT 
	loc.locationid,
	loc.locationuuid,
	(select entityinstanceuuid from entity.entityinstance 
		where entityinstanceoriginalid = loc.locationcustomerid 
			and entityinstanceentitytemplatename = 'Customer'),
	parent.locationentityuuid,
	corner.locationentityuuid,	
	loc.locationcornerstoneorder::integer,
	loc.locationscanid,	
	(select entitytemplateuuid from entity.entitytemplate where entitytemplatescanid = 'Location'),
	(select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatescanid = 'Location'),
	loc.locationcreateddate, 
	loc.locationmodifieddate, 	
	loc.locationstartdate, 
	loc.locationenddate, 
	loc.locationexternalid, 
	sys.systagentityuuid,
	(select workerinstanceuuid from workerinstance where workerinstanceid = locationcreatedby), 
	loc.locationrefid, 
	loc.locationrefuuid,
	'Location',
	(select languagemastersource from languagemaster where languagemasterid = locationnameid),
	(select languagemasteruuid from languagemaster where languagemasterid = locationnameid)
FROM public.location loc
	left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,englishuuid)) parent
		on parent.locationid = loc.locationparentid
	left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,englishuuid)) corner
		on corner.locationid = loc.locationcornerstoneid
	left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,englishuuid)) existing
		on existing.locationid = loc.locationid
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)) as sys
		on sys.systagid = loc.locationexternalsystemid
where existing.locationentityuuid isNull 
	and loc.locationmodifieddate > insertdate
	and loc.locationmodifieddate < (now() - interval '10 minutes');

-- set parent and cornerstone to self if they are null

update entity.entityinstance
	set entityinstanceparententityuuid = entityinstanceuuid
	where entityinstanceparententityuuid isNull
		and entityinstanceentitytemplatename = 'Location';

update entity.entityinstance
	set entityinstancecornerstoneentityuuid = entityinstanceuuid
	where entityinstancecornerstoneentityuuid isNull
		and entityinstanceentitytemplatename = 'Location';		

-- locationdisplayname

insert into public.languagemaster
    (languagemastercustomerid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
	 languagemasterrefuuid,
     languagemastermodifiedby)
select
	locationcustomerid,
	20,
    locationlookupname,	
	ent.entityinstanceuuid||'-locationdisplayname',
	337
from entity.entityinstance ent
	inner join location
		on locationid = ent.entityinstanceoriginalid
			and ent.entityinstanceentitytemplatename = 'Location'
			and locationmodifieddate > insertdate
	inner join entity.entitytemplate
		on ent.entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'locationdisplayname'
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = ent.entityinstanceuuid
			and entityfieldinstanceentityfieldentityuuid = entityfielduuid
where entityfieldinstanceuuid isNull;

INSERT INTO entity.entityfieldinstance(
	entityfieldinstanceentityinstanceentityuuid, 
	entityfieldinstanceownerentityuuid, 
	entityfieldinstancevalue, 
	entityfieldinstancevaluelanguagemasteruuid, 
	entityfieldinstancevaluelanguagetypeentityuuid, 
	entityfieldinstancecreateddate, 
	entityfieldinstancemodifieddate, 
	entityfieldinstanceentityfieldentityuuid, 
	entityfieldinstancemodifiedbyuuid,
	entityfieldinstanceentityfieldname)
select 
	entityinstanceuuid,
	entityinstanceownerentityuuid,
	languagemastersource,
	languagemasteruuid,
	(select entityinstanceuuid from entity.entityinstance 
		where entityinstanceoriginalid in 
								(select languagemastersourcelanguagetypeid 
									from languagemaster where languagemasterid = locationnameid)
			and entityinstanceentitytemplatename = 'System Tag'),
	locationcreateddate,
	locationmodifieddate,
	entityfielduuid,
	entityinstancemodifiedbyuuid,
	entityfieldname
from entity.entityinstance
	inner join location
		on locationid = entityinstanceoriginalid
			and entityinstanceentitytemplatename = 'Location'
			and locationmodifieddate > insertdate
	inner join entity.entitytemplate
		on entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'locationdisplayname'
	inner join languagemaster
		on languagemasterrefuuid = entityinstanceuuid||'-locationdisplayname'
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = entityinstanceuuid
			and entityfieldinstanceentityfieldentityuuid = entityfielduuid
where entityfieldinstanceuuid isNull;

-- locationtimezone

insert into public.languagemaster
    (languagemastercustomerid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
	 languagemasterrefuuid,
     languagemastermodifiedby,
	 languagemasterstatus)
select
	locationcustomerid,
	20,
    locationtimezone,	
	ent.entityinstanceuuid||'-locationtimezone',
	337,
	'NEVER_TRANSLATE'
from entity.entityinstance ent
	inner join location
		on locationid = ent.entityinstanceoriginalid
			and ent.entityinstanceentitytemplatename = 'Location'
			and locationmodifieddate > insertdate
	inner join entity.entitytemplate
		on ent.entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'locationtimezone' 
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = ent.entityinstanceuuid
			and entityfieldinstanceentityfieldentityuuid = entityfielduuid
where entityfieldinstanceuuid isNull;

INSERT INTO entity.entityfieldinstance(
	entityfieldinstanceentityinstanceentityuuid, 
	entityfieldinstanceownerentityuuid, 
	entityfieldinstancevalue, 
	entityfieldinstancevaluelanguagemasteruuid, 
	entityfieldinstancevaluelanguagetypeentityuuid, 
	entityfieldinstancecreateddate, 
	entityfieldinstancemodifieddate, 
	entityfieldinstanceentityfieldentityuuid, 
	entityfieldinstancemodifiedbyuuid,
	entityfieldinstanceentityfieldname)
select 
	entityinstanceuuid,
	entityinstanceownerentityuuid,
	languagemastersource,
	languagemasteruuid,
	(select entityinstanceuuid from entity.entityinstance 
		where entityinstanceoriginalid in 
								(select languagemastersourcelanguagetypeid 
									from languagemaster where languagemasterid = locationnameid)
			and entityinstanceentitytemplatename = 'System Tag'),
	locationcreateddate,
	locationmodifieddate,
	entityfielduuid,
	entityinstancemodifiedbyuuid,
	entityfieldname
from entity.entityinstance
	inner join location
		on locationid = entityinstanceoriginalid
			and entityinstanceentitytemplatename = 'Location'
			and locationmodifieddate > insertdate
	inner join entity.entitytemplate
		on entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'locationtimezone'
	inner join languagemaster
		on languagemasterrefuuid = entityinstanceuuid||'-locationtimezone'  
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = entityinstanceuuid
			and entityfieldinstanceentityfieldentityuuid = entityfielduuid
where entityfieldinstanceuuid isNull;

-- locationlatitude

INSERT INTO entity.entityfieldinstance(
	entityfieldinstanceentityinstanceentityuuid, 
	entityfieldinstanceownerentityuuid, 
	entityfieldinstancevalue, 
	entityfieldinstancecreateddate, 
	entityfieldinstancemodifieddate, 
	entityfieldinstanceentityfieldentityuuid, 
	entityfieldinstancemodifiedbyuuid,
	entityfieldinstanceentityfieldname)
select 
	ent.entityinstanceuuid,
	ent.entityinstanceownerentityuuid,
	loc.locationlatitude::text,
	loc.locationcreateddate,
	loc.locationmodifieddate,
	entityfielduuid,
	ent.entityinstancemodifiedbyuuid,
	entityfieldname
from entity.entityinstance ent
	inner join location loc
		on loc.locationid = ent.entityinstanceoriginalid
			and ent.entityinstanceentitytemplatename = 'Location'
			and locationmodifieddate > insertdate
	inner join entity.entitytemplate
		on ent.entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'locationlatitude'  
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = ent.entityinstanceuuid
			and entityfieldinstanceentityfieldentityuuid = entityfielduuid
where entityfieldinstanceuuid isNull;

-- locationlongitude

INSERT INTO entity.entityfieldinstance(
	entityfieldinstanceentityinstanceentityuuid, 
	entityfieldinstanceownerentityuuid, 
	entityfieldinstancevalue, 
	entityfieldinstancecreateddate, 
	entityfieldinstancemodifieddate, 
	entityfieldinstanceentityfieldentityuuid, 
	entityfieldinstancemodifiedbyuuid,
	entityfieldinstanceentityfieldname)
select 
	ent.entityinstanceuuid,
	ent.entityinstanceownerentityuuid,
	loc.locationlatitude::text,
	loc.locationcreateddate,
	loc.locationmodifieddate,
	entityfielduuid,
	ent.entityinstancemodifiedbyuuid,
	entityfieldname
from entity.entityinstance ent
	inner join location loc
		on loc.locationid = ent.entityinstanceoriginalid
			and ent.entityinstanceentitytemplatename = 'Location'
			and locationmodifieddate > insertdate
	inner join entity.entitytemplate
		on ent.entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'locationlongitude' 
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = ent.entityinstanceuuid
			and entityfieldinstanceentityfieldentityuuid = entityfielduuid
where entityfieldinstanceuuid isNull;

-- locationradius

INSERT INTO entity.entityfieldinstance(
	entityfieldinstanceentityinstanceentityuuid, 
	entityfieldinstanceownerentityuuid, 
	entityfieldinstancevalue, 
	entityfieldinstancecreateddate, 
	entityfieldinstancemodifieddate, 
	entityfieldinstanceentityfieldentityuuid, 
	entityfieldinstancemodifiedbyuuid,
	entityfieldinstanceentityfieldname)
select 
	ent.entityinstanceuuid,
	ent.entityinstanceownerentityuuid,
	loc.locationlatitude::text,
	loc.locationcreateddate,
	loc.locationmodifieddate,
	entityfielduuid,
	ent.entityinstancemodifiedbyuuid,
	entityfieldname
from entity.entityinstance ent
	inner join location loc
		on loc.locationid = ent.entityinstanceoriginalid
			and ent.entityinstanceentitytemplatename = 'Location'
			and locationmodifieddate > insertdate
	inner join entity.entitytemplate
		on ent.entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'locationradius'  
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = ent.entityinstanceuuid
			and entityfieldinstanceentityfieldentityuuid = entityfielduuid
where entityfieldinstanceuuid isNull;

--	locationcategoryid 

INSERT INTO entity.entitytag(
	entitytagownerentityuuid, 
	entitytagentityinstanceentityuuid,
	entitytagentitytemplateentityuuid,
	entitytagcreateddate, 
	entitytagmodifieddate, 
	entitytagstartdate, 
	entitytagenddate, 
	entitytagmodifiedbyuuid,
	entitytagcustagentityuuid)
select 
	ent.entityinstanceownerentityuuid,
	ent.entityinstanceuuid,
	ent.entityinstanceentitytemplateentityuuid,
	loc.locationcreateddate,
	loc.locationmodifieddate,
	loc.locationstartdate,
	loc.locationenddate,
	ent.entityinstancemodifiedbyuuid,
	eitag.entityinstanceuuid
from entity.entityinstance ent
	inner join location loc
		on loc.locationid = ent.entityinstanceoriginalid
			and ent.entityinstanceentitytemplatename = 'Location'  
			and locationmodifieddate > insertdate
	inner join entity.entityinstance eitag
		on loc.locationcategoryid = eitag.entityinstanceoriginalid
			and eitag.entityinstanceentitytemplatename = 'Customer Tag'
	left join entity.entitytag tag
		on  tag.entitytagentityinstanceentityuuid = ent.entityinstanceuuid
			and eitag.entityinstanceoriginalid = (select custagid from custag where custagid = loc.locationcategoryid)
where entitytaguuid isNull;

-- update any modified locations

-------  TRIM THIS TABLE TO NEEDED DATA>  RIGHT NOW I GRAB EVERYTHING ------

create temp table locmodified  as
(select loc.*,
	ent.languagetranslationtypeentityuuid as ent_languagetranslationtypeuuid, 
	ent.locationid as ent_locationid, 
	ent.locationuuid as ent_locationuuid, 
	ent.locationownerentityuuid as ent_locationownerentityuuid,
	ent.locationparententityuuid as ent_locationparententityuuid, 
	ent.locationcornerstoneentityuuid as ent_locationcornerstoneentityuuid, 
	ent.locationentityuuid as ent_locationentityuuid, 
	ent.locationcustomerid as ent_locationcustomerid, 	
	ent.locationcustomeruuid as ent_locationcustomeruuid, 
	ent.locationcustomerentityuuid as ent_locationcustomerentityuuid, 
	ent.locationnameuuid as ent_locationnameuuid, 
	ent.locationdisplaynameuuid as ent_locationdisplaynameuuid, 
	ent.locationscanid as ent_locationscanid, 
	ent.locationcreateddate as ent_locationcreateddate, 
	ent.locationmodifieddate as ent_locationmodifieddate, 
	ent.locationmodifiedbyuuid as ent_locationmodifiedbyuuid, 
	ent.locationstartdate as ent_locationstartdate, 
	ent.locationenddate as ent_locationenddate, 
	ent.locationexternalid as ent_locationexternalid, 
	ent.locationexternalsystementityuuid as ent_locationexternalsystementityuuid, 	
	ent.locationcornerstoneorder as ent_locationcornerstoneorder, 
	ent.locationlatitude as ent_locationlatitude, 
	ent.locationlongitude as ent_locationlongitude, 
	ent.locationradius as ent_locationradius, 
	ent.locationtimezone as ent_locationtimezone, 
	ent.locationtagentityuuid as ent_locationtagentityuuid 
from view_location loc 
		inner join (select * 
					from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,englishuuid)) as ent
			on loc.locationid = ent.locationid
				and languagetranslationtypeid = 20
	where loc.locationmodifieddate <> ent.locationmodifieddate);

if (select count(*) from locmodified) > 0
	then
		
		-- locationdisplayname
		
		update languagemaster
		set languagemastersource = locationfullname,
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
			languagemastermodifieddate = now()
		from locmodified 
		where languagemasteruuid = ent_locationdisplaynameuuid;
		
		-- locationtimezone
		
		update entity.entityfieldinstance
		set entityfieldinstancevalue = locationtimezone,
			entityfieldinstancemodifieddate = locationmodifieddate
		from locmodified loc
		where entityfieldinstanceentityinstanceentityuuid = loc.ent_locationentityuuid
			and entityfieldinstanceentityfieldname = 'locationtimezone';

		update languagemaster
		set languagemastersource = loc.locationtimezone,
			languagemasterstatus = 'NEVER_TRANSLATE',
			languagemastermodifieddate = now()
		from locmodified loc
			inner join entity.entityfieldinstance efitz
				on efitz.entityfieldinstanceentityinstanceentityuuid = loc.ent_locationentityuuid
					and efitz.entityfieldinstanceentityfieldname = 'locationtimezone'
		where languagemasteruuid = efitz.entityfieldinstancevaluelanguagemasteruuid;		
		

		-- locationlatitude
		
		update entity.entityfieldinstance
		set entityfieldinstancevalue = locationlatitude::text,
			entityfieldinstancemodifieddate = locationmodifieddate
		from locmodified loc
		where entityfieldinstanceentityinstanceentityuuid = loc.ent_locationentityuuid
			and entityfieldinstanceentityfieldname = 'locationlatitude';
		
		
		-- locationlongitude
		
		update entity.entityfieldinstance
		set entityfieldinstancevalue = locationlongitude::text,
			entityfieldinstancemodifieddate = locationmodifieddate
		from locmodified loc
		where entityfieldinstanceentityinstanceentityuuid = loc.ent_locationentityuuid
			and entityfieldinstanceentityfieldname = 'locationlongitude';
		
		-- locationradius
		
		update entity.entityfieldinstance
		set entityfieldinstancevalue = locationradius::text,
			entityfieldinstancemodifieddate = locationmodifieddate
		from locmodified loc
		where entityfieldinstanceentityinstanceentityuuid = loc.ent_locationentityuuid
			and entityfieldinstanceentityfieldname = 'locationradius';
		

		--	locationcategoryid 

		update entity.entitytag
		set --entitytagcustaguuid = (select custaguuid from custag where custagid = loc.locationcategoryid),
			entitytagmodifieddate = locationmodifieddate,
			entitytagcustagentityuuid = eitag.entityinstanceuuid
		from locmodified loc
			inner join entity.entityinstance eitag
				on loc.locationcategoryid = eitag.entityinstanceoriginalid
					and eitag.entityinstanceentitytemplatename = 'Customer Tag'
		where entitytagentityinstanceentityuuid = loc.ent_locationentityuuid;
		
		-- entity

		update entity.entityinstance
		set entityinstancemodifieddate = loc.locationmodifieddate,
			entityinstanceenddate = loc.locationenddate,
			entityinstancecornerstoneorder = loc.locationcornerstoneorder::integer,
			entityinstancescanid = loc.locationscanid,
			entityinstanceparententityuuid = parent.locationentityuuid,
			entityinstancecornerstoneentityuuid = corner.locationentityuuid,
			entityinstancetype = (select languagemastersource from languagemaster where languagemasterid = loc.locationnameid)
		from locmodified loc
			inner join (select * from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,englishuuid)) parent
				on parent.locationid = loc.locationparentid
			inner join (select * from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,englishuuid)) corner
				on corner.locationid = loc.locationcornerstoneid			
		where entityinstanceuuid = loc.ent_locationentityuuid
			and entityinstanceentitytemplatename = 'Location';
		
end if;

drop table locmodified;

  if exists (select 1 from pg_namespace where nspname = 'datawarehouse') then
    if  (select dwlogginglevel4 from datawarehouse.dw_logginglevels) = false
      Then Return;
    end if;

    call datawarehouse.insert_tendy_tracker(0, 2521, 12496, 811, 844, 20786, 18068, 20787,20785, customer_start);
  end if;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.import_entity_location(text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_entity_location(text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_entity_location(text) TO bombadil WITH GRANT OPTION;
