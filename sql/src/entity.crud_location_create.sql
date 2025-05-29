BEGIN;

/*
DROP PROCEDURE entity.crud_location_create(uuid,uuid,uuid,integer,uuid,text,text,text,text,text,uuid,text,uuid,text,text,text,boolean,boolean,bigint);
*/


-- Type: PROCEDURE ; Name: entity.crud_location_create(uuid,uuid,uuid,integer,uuid,text,text,text,text,text,uuid,text,uuid,text,text,text,boolean,boolean,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_location_create(IN create_locationownerentityuuid uuid, IN create_locationparententityuuid uuid, IN create_locationcornerstoneentityuuid uuid, IN create_locationcornerstoneorder integer, IN create_locationtaguuid uuid, IN create_locationtag text, IN create_locationname text, IN create_locationdisplayname text, IN create_locationscanid text, IN create_locationtimezone text, IN create_languagetypeuuid uuid, IN create_locationexternalid text, IN create_locationexternalsystemuuid uuid, IN create_locationlatitude text, IN create_locationlongitude text, IN create_locationradius text, IN create_locationdeleted boolean, IN create_locationdraft boolean, OUT create_locationentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
 	templanguagemasterid bigint;
	templanguagemasteruuid text;
	tempdisplaylanguagemasterid bigint;
	temptypelanguagemasterid bigint;
	temptzlanguagemasterid bigint;
	tempcustomerid bigint;
	tempcustagentityuuid uuid;
	templocationentityuuid uuid;
	tempcustomeruuid text;
	tempcustagid bigint;
	tempcustaguuid text;
	templocationtimezone text;
	templanguagetypeid bigint;
	templanguagetypeuuid uuid;
	templocationcornerstoneorder integer;
	templocationid bigint;
	templocationuuid text;
	templocationdeleted boolean;
	templocationdraft boolean;
	templocationownerentityuuid uuid;
	englishuuid uuid;
	tendreluuid uuid;
	templanguagetypeentityuuid uuid;
Begin

/*
-- Customer for testing -- '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'

select * from entity.crud_location_read_min('70f200bd-1c92-481d-9f5c-e6cf6cd92cd0',null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

select * from entity.entityinstance where entityinstanceuuid = 'f5491785-0dc0-4746-8180-a26c1798b5d0'

----------------------------------------------

-- tests 
  	-- New site new location type no parent no cornerstone
	  
	call entity.crud_location_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --create_locationownerentityuuid
		null,	--create_locationparententityuuid
		null,   --create_locationcornerstoneentityuuid
		null, --create_locationcornerstoneorder 
		null, -- create_locationtaguuid,
		'locationtag'||now(),  -- create_locationtag
		'sitename'||now(),  -- create_locationname
		'sitedisplayname'||now(), -- locationdisplayname 
		'sitescanid'||now(), -- locationscanid	
		'America/Los_Angeles',  -- locationtimezone
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- languagetypeuuid  
		null,  -- locationexternalid
		null, -- locationexternalsystemuuid
		null, -- locationlatitude 
		null, -- locationlongitude
		null, -- locationradius
		null,
		null,
		null, -- OUT create_locationentityuuid
		337::bigint)	

	-- New location existing parent new location tag

	call entity.crud_location_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --create_locationownerentityuuid
		????,	--create_locationparententityuuid
		null,   --create_locationcornerstoneentityuuid
		null, --create_locationcornerstoneorder 
		null, -- create_locationtaguuid,
		'locationsubtag'||now(),  -- create_locationtag
		'locationname'||now(),  -- create_locationname
		'locationdisplayname'||now(), -- locationdisplayname 
		'locationscanid'||now(), -- locationscanid	
		'America/Los_Angeles',  -- locationtimezone
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- languagetypeuuid  
		null,  -- locationexternalid
		null, -- locationexternalsystemuuid
		null, -- locationlatitude 
		null, -- locationlongitude
		null, -- locationradius
		null,
		null,
		null, -- OUT create_locationentityuuid
		337::bigint)	

	-- New location existing parent existing location tag

	call entity.crud_location_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --create_locationownerentityuuid
		???,	--create_locationparententityuuid
		null,   --create_locationcornerstoneentityuuid
		null, --create_locationcornerstoneorder 
		'f5491785-0dc0-4746-8180-a26c1798b5d0', -- create_locationtaguuid,
		null,  -- create_locationtag
		'sitename'||now(),  -- create_locationname
		'sitedisplayname'||now(), -- locationdisplayname 
		'sitescanid'||now(), -- locationscanid	
		'America/Los_Angeles',  -- locationtimezone
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- languagetypeuuid  
		null,  -- locationexternalid
		null, -- locationexternalsystemuuid
		null, -- locationlatitude 
		null, -- locationlongitude
		null, -- locationradius
		null,
		null,
		null, -- OUT create_locationentityuuid
		337::bigint)	

	-- New location existing cornerstone

	call entity.crud_location_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --create_locationownerentityuuid
		???,	--create_locationparententityuuid
		???,   --create_locationcornerstoneentityuuid
		2, --create_locationcornerstoneorder 
		'f5491785-0dc0-4746-8180-a26c1798b5d0', -- create_locationtaguuid,
		null,  -- create_locationtag
		'sitename'||now(),  -- create_locationname
		'sitedisplayname'||now(), -- locationdisplayname 
		'sitescanid'||now(), -- locationscanid	
		'America/Los_Angeles',  -- locationtimezone
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- languagetypeuuid  
		null,  -- locationexternalid
		null, -- locationexternalsystemuuid
		null, -- locationlatitude 
		null, -- locationlongitude
		null, -- locationradius
		null,
		null,
		null, -- OUT create_locationentityuuid
		337::bigint)	

-- We could harden this by checking for valid data at the beginning of this call.  Will do this as phase 2.  
	-- Must have a valid customerid or customerexternalid
	-- Site Name and Site type can not be null or ''
	-- languagetype id must be a valid languagetypeid
	-- locationtimezone must be a legit timezone
	-- modified by id gets defaulted if it is not passed in (Maybe validate this)
	-- Could check all this and return null if any of these fail

-- Use owner instead of customer and paretn instead of site
*/

englishuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';

-- setup customer info
if create_locationownerentityuuid isNull
	then return;
	else templocationownerentityuuid = create_locationownerentityuuid;
end if;

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,templocationownerentityuuid,null,false,null,null,null, null);

-- probably return an error if the entity is not set to a customer.  Need to sort this out.  
if tempcustomerid isNull
	then  return;
end if;

-- locations need a name
if (create_locationname isNull or coalesce(create_locationname,'')= '')
	then return;  -- need error code
end if;

-- setup location order
if create_locationcornerstoneorder isNull
	then templocationcornerstoneorder = 1::integer;
	else templocationcornerstoneorder = create_locationcornerstoneorder::integer;
end if;

If create_locationdeleted isNull
	then templocationdeleted = false;
	else templocationdeleted = create_locationdeleted;
end if;

If create_locationdraft isNull
	then templocationdraft = false;
	else templocationdraft = create_locationdraft;
end if;

-- setup the language type
if create_languagetypeuuid isNull
	then templanguagetypeentityuuid = englishuuid;
	else templanguagetypeentityuuid = create_languagetypeuuid;
end if;

select systagid,systaguuid into templanguagetypeid,templanguagetypeuuid
	from entity.crud_systag_read_min(null, null, templanguagetypeentityuuid, null, false,null,null, null,templanguagetypeentityuuid);

if templanguagetypeid isNull
	then return;
end if;

--------------------------------------
-- Switch to create custag vs having it embedded here.  Parent is Location Category.
-- 2 checks, is the uuid a valid location category.

if create_locationtaguuid isNull
	then
		tempcustagentityuuid = (select custagentityuuid 
					from entity.crud_custag_read_min(create_locationownerentityuuid,null,null, null, true,null,null, null,englishuuid)
					where create_locationtag = custagtype);
	else
		tempcustagentityuuid = create_locationtaguuid;
end if;

if tempcustagentityuuid isNull and (create_locationtag notNull or coalesce(create_locationtag,'')<> '')
	then 
		call entity.crud_custag_create(
				templocationownerentityuuid, --create_custagownerentityuuid
				'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', --create_custagparententityuuid - This is location Category
				null,   --create_custagcornerstoneentityuuid
				null, --create_custagcornerstoneorder 
				create_locationtag,  -- create_custag
				englishuuid, -- templanguagetypeentityuuid  
				null,  -- 	create_custagexternalid text,
				null, -- create_custagexternalsystemuuid
				null, 
				null, 
				tempcustagid , -- OUT create_custagid
				tempcustaguuid , -- OUT create_custaguuid text,
				tempcustagentityuuid, -- OUT create_custagentityuuid uuid
				337::bigint);
	else
		select custagid, custagid 
		into tempcustagid, tempcustagid
		from entity.crud_custag_read_min(templocationownerentityuuid, null,tempcustagentityuuid , null, false,null,null, null,englishuuid);
end if;

-- Custag is now created for location type.  Time to insert into location

-- create_locationtimezone
if (create_locationtimezone notNull and coalesce(create_locationtimezone,'')<> '')
	then templocationtimezone = create_locationtimezone;
	else templocationtimezone = (select locationtimezone 
		from entity.crud_location_read_full(create_locationownerentityuuid,create_locationparententityuuid,null,null,false,null,null,null,null,englishuuid));
end if;

if templocationtimezone isNull 
	then templocationtimezone = 'UTC';
end if;

-- insert name into languagemaster
	insert into public.languagemaster
		(languagemastercustomerid,
		languagemastersourcelanguagetypeid,
		languagemastersource,
		languagemastermodifiedby)
	values(tempcustomerid,
		templanguagetypeid, 	
		create_locationname,    
		create_modifiedbyid)
	Returning languagemasterid,languagemasteruuid into templanguagemasterid,templanguagemasteruuid;

-- insert displayname into languagemaster
	insert into public.languagemaster
		(languagemastercustomerid,
		languagemastersourcelanguagetypeid,
		languagemastersource,
		languagemastermodifiedby)
	values(tempcustomerid,
		templanguagetypeid, 	
		case when create_locationdisplayname notnull or (coalesce(create_locationdisplayname, '') <> '')
			then create_locationdisplayname
			else create_locationname
		end,   
		create_modifiedbyid)
	Returning languagemasterid into tempdisplaylanguagemasterid;

-- locationtimezone

	insert into public.languagemaster
		(languagemastercustomerid,
		languagemastersourcelanguagetypeid,
		languagemastersource,
		languagemastermodifiedby,
		languagemasterstatus)
	values(tempcustomerid,
		templanguagetypeid, 	
		templocationtimezone,   
		create_modifiedbyid,
		'NEVER_TRANSLATE')
	Returning languagemasterid into temptzlanguagemasterid;

-- now let's create the location entity then the location itself

	INSERT INTO entity.entityinstance(
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
		entityinstancedeleted,
		entityinstancedraft,
		entityinstancenameuuid
		)
	values( 
		create_locationownerentityuuid,
		create_locationparententityuuid,  -- insert the parent id sent in.  If it is null we need to fix it later with self.  
		create_locationcornerstoneentityuuid,	-- insert the cornerstone sent in.  If it is null we need to fix it later with self.
		templocationcornerstoneorder, 
		create_locationscanid,
		(select entitytemplateuuid from entity.entitytemplate where entitytemplatescanid = 'Location'),
		(select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatescanid = 'Location'),
		now(), 
		now(), 	
		now(), 
		null, 
		create_locationexternalid,
		create_locationexternalsystemuuid,
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid), 
		null, 
		null,
		'Location',
		create_locationname,
		templocationdeleted,
		templocationdraft,
		templanguagemasteruuid
		)
	Returning entityinstanceuuid into templocationentityuuid;	

	update entity.entityinstance
	set entityinstanceparententityuuid = templocationentityuuid
	where entityinstanceparententityuuid isNull
		and entityinstanceuuid = templocationentityuuid;

	update entity.entityinstance
	set entityinstancecornerstoneentityuuid = templocationentityuuid
	where entityinstancecornerstoneentityuuid isNull
		and entityinstanceuuid = templocationentityuuid;

	-- locationdisplayname

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
	values( 
		templocationentityuuid,
		create_locationownerentityuuid,
		case when create_locationdisplayname notnull or (coalesce(create_locationdisplayname, '') <> '')
			then create_locationdisplayname
			else create_locationname
		end,
		(select languagemasteruuid from languagemaster where languagemasterid = tempdisplaylanguagemasterid),
		templanguagetypeentityuuid,
		now(),
		now(),		
		(select entityfielduuid
			from entity.entityfield
			where entityfieldname = 'locationdisplayname'),
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		'locationdisplayname');
	
	-- locationtimezone

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
	values( 
		templocationentityuuid,
		create_locationownerentityuuid,
		templocationtimezone,
		(select languagemasteruuid from languagemaster where languagemasterid = temptzlanguagemasterid),
		templanguagetypeentityuuid,
		now(),
		now(),		
		(select entityfielduuid
			from entity.entityfield
			where entityfieldname = 'locationtimezone'),
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		'locationtimezone');
	
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
	values( 
		templocationentityuuid,
		create_locationownerentityuuid,
		create_locationlatitude,
		now(),
		now(),		
		(select entityfielduuid
			from entity.entityfield
			where entityfieldname = 'locationlatitude'),
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		'locationlatitude');		
	
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
	values( 
		templocationentityuuid,
		create_locationownerentityuuid,
		create_locationlongitude,
		now(),
		now(),		
		(select entityfielduuid
			from entity.entityfield
			where entityfieldname = 'locationlongitude'),
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		'locationlongitude');	
	
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
	values( 
		templocationentityuuid,
		create_locationownerentityuuid,
		create_locationradius,
		now(),
		now(),		
		(select entityfielduuid
			from entity.entityfield
			where entityfieldname = 'locationradius'),
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		'locationradius');

	--	locationcategoryid 
if tempcustagentityuuid notNull
	then
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
		values (
			create_locationownerentityuuid,
			templocationentityuuid,
			(select entitytemplateuuid from entity.entitytemplate where entitytemplatescanid = 'Location'),
			now(),
			now(),
			now(),
			null,
			(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
			tempcustagentityuuid
		);
end if;

-- now load the location table

	INSERT INTO public.location(
		locationcustomerid,
		locationsiteid,
		locationparentid,
		locationcornerstoneid,
		locationcornerstoneorder,
		locationiscornerstone,
		locationlookupname,
		locationscanid,
		locationistop,
		locationcategoryid,
		locationstartdate,
		locationnameid,
		locationtimezone,
		locationexternalid,
		locationexternalsystemid,			
		locationmodifiedby)
	values(	
		tempcustomerid,
		(select locationid from entity.crud_location_read_min(create_locationownerentityuuid ,create_locationparententityuuid ,null,null,false,null,null,null,null,englishuuid)),
		(select locationid from entity.crud_location_read_min(create_locationownerentityuuid ,create_locationparententityuuid ,null,null,false,null,null,null,null,englishuuid)),
		(select locationid from entity.crud_location_read_min(create_locationownerentityuuid ,create_locationcornerstoneentityuuid ,null,null,false,null,null,null,null,englishuuid)),
		templocationcornerstoneorder,
		false,  
		create_locationname,
		create_locationscanid,			
		false,  
		tempcustagid,
		clock_timestamp(),  
		templanguagemasterid,
		templocationtimezone,   -- https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
		create_locationexternalid,	
		(select systagid from entity.crud_systag_read_min(create_locationownerentityuuid, null,create_locationexternalsystemuuid, null, false,null,null, null,englishuuid)),
		create_modifiedbyid)
	returning locationid,locationuuid into  templocationid, templocationuuid;

	update public.location
	set locationsiteid = locationid,
		locationistop = true
	where locationsiteid isNull
		and locationid = templocationid;

	update public.location
	set locationparentid = locationid
	where locationparentid isNull
		and locationid = templocationid;

	update public.location
	set locationcornerstoneid = locationid,
		locationiscornerstone = true
	where locationcornerstoneid isNull
		and locationid = templocationid;

	update entity.entityinstance
	set entityinstanceoriginalid = templocationid,
		entityinstanceoriginaluuid = templocationuuid
	where entityinstanceuuid = templocationentityuuid;

create_locationentityuuid = templocationentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_location_create(uuid,uuid,uuid,integer,uuid,text,text,text,text,text,uuid,text,uuid,text,text,text,boolean,boolean,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_location_create(uuid,uuid,uuid,integer,uuid,text,text,text,text,text,uuid,text,uuid,text,text,text,boolean,boolean,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_location_create(uuid,uuid,uuid,integer,uuid,text,text,text,text,text,uuid,text,uuid,text,text,text,boolean,boolean,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_location_create(uuid,uuid,uuid,integer,uuid,text,text,text,text,text,uuid,text,uuid,text,text,text,boolean,boolean,bigint) TO graphql;

END;
