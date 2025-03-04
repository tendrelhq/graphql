CREATE OR REPLACE PROCEDURE entity.crud_location_create(IN create_locationownerentityuuid uuid, IN create_locationparententityuuid uuid, IN create_locationcornerstoneentityuuid uuid, IN create_locationcornerstoneorder integer, IN create_locationtaguuid uuid, IN create_locationtag text, IN create_locationname text, IN create_locationdisplayname text, IN create_locationscanid text, IN create_locationtimezone text, IN create_languagetypeuuid uuid, IN create_locationexternalid text, IN create_locationexternalsystemuuid uuid, IN create_locationlatitude text, IN create_locationlongitude text, IN create_locationradius text, OUT create_locationentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
 	templanguagemasterid bigint;
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
	templocationcornerstoneorder integer;
	templocationid bigint;
	templocationuuid text;
Begin

/*  Helper scripts for checking data post creates

-- customers to use

select * from entity.crud_customer_read_full(null,null, null, true,null,null, null, null)
order by customerid desc

-- location data
select * from location order by locationid desc   limit 10   

select * from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by locationid desc   limit 10

select * from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by locationid desc   limit 10

-- custag data
select * from custag order by custagid desc limit 10  

select * from entity.crud_custag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by custagid  desc limit 10  

select * from entity.crud_custag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by custagid  desc limit 10  

-- general

select * from languagemaster 
where languagemastercreateddate::date = now()::Date
order by languagemaster desc limit 100 

select * from entity.entityinstance
where entityinstancecreateddate::date = now()::date

*/

/*
-- Customer for testing -- 'cb56292b-8c20-4a9c-a70e-595d7b04c743'

-- tests 
  	-- New site new location type no parent no cornerstone
	  
	call entity.crud_location_create(
		'cb56292b-8c20-4a9c-a70e-595d7b04c743', --create_locationownerentityuuid
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
		null, -- OUT create_locationentityuuid
		337::bigint)	

	-- New location existing parent new location tag

	call entity.crud_location_create(
		'cb56292b-8c20-4a9c-a70e-595d7b04c743', --create_locationownerentityuuid
		'a253f8cf-2e56-4a5b-8369-641b0b200ad3',	--create_locationparententityuuid
		null,   --create_locationcornerstoneentityuuid
		null, --create_locationcornerstoneorder 
		null, -- create_locationtaguuid,
		'locationsubtag'||now(),  -- create_locationtag
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
		null, -- OUT create_locationentityuuid
		337::bigint)	
	
	-- New location existing parent existing location tag

	call entity.crud_location_create(
		'cb56292b-8c20-4a9c-a70e-595d7b04c743', --create_locationownerentityuuid
		'a253f8cf-2e56-4a5b-8369-641b0b200ad3',	--create_locationparententityuuid
		null,   --create_locationcornerstoneentityuuid
		null, --create_locationcornerstoneorder 
		'f5830da5-0184-4328-98e3-10c81cd2c32f', -- create_locationtaguuid,
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
		null, -- OUT create_locationentityuuid
		337::bigint)	

	-- New location existing cornerstone

	call entity.crud_location_create(
		'cb56292b-8c20-4a9c-a70e-595d7b04c743', --create_locationownerentityuuid
		'a253f8cf-2e56-4a5b-8369-641b0b200ad3',	--create_locationparententityuuid
		'34f2464e-caa3-4bc3-b1db-013d9d3d7e22',   --create_locationcornerstoneentityuuid
		2, --create_locationcornerstoneorder 
		'f5830da5-0184-4328-98e3-10c81cd2c32f', -- create_locationtaguuid,
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

tempcustomerid = (select customerid
					from entity.crud_customer_read_min(null,create_locationownerentityuuid,null,false, null,null, null,null));

tempcustomeruuid = (select customeruuid
					from entity.crud_customer_read_min(null,create_locationownerentityuuid,null,false,null,null, null, null));

-- Setup the Custag for the locationtype

templanguagetypeid = (select systagid 
					  from entity.crud_systag_read_min(null, null, create_languagetypeuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'));

if create_locationtaguuid isNull
	then
		tempcustagentityuuid = (select custagentityuuid 
					from entity.crud_custag_read_min(create_locationownerentityuuid,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
					where create_locationtag = custagtype);
	else
		tempcustagentityuuid = create_locationtaguuid;
end if;

------------------------- need to sort out parent before the inserts.  
------------------------- Need it for languagemaster and custag.  Maybe update after the fact.

-- swap in crud for custag once it is ready.  Fo now force it in.  
-- add the entity custag first then into the custag table

if tempcustagentityuuid isNull
	then 

	-- insert name into languagemaster
		insert into public.languagemaster
			(languagemastercustomerid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(tempcustomerid,
			templanguagetypeid, 	
			create_locationtag,
			create_modifiedbyid)
		Returning languagemasterid into templanguagemasterid;

	-- insert displayname into languagemaster
		insert into public.languagemaster
			(languagemastercustomerid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(tempcustomerid,
			templanguagetypeid, 	
			create_locationtag,
			create_modifiedbyid)
		Returning languagemasterid into tempdisplaylanguagemasterid;

	-- insert type into languagemaster
	
		insert into public.languagemaster
		    (languagemastercustomerid,
		     languagemastersourcelanguagetypeid,
		     languagemastersource,
			 languagemasterstatus, 
		     languagemastermodifiedby)
		values(tempcustomerid,
			templanguagetypeid,
			create_locationtag,
			'NEVER_TRANSLATE',
			create_modifiedbyid)
		Returning languagemasterid into temptypelanguagemasterid;

-- insert into entity custag
	-- insert into the entity table first
	
		INSERT INTO entity.entityinstance(
			entityinstanceownerentityuuid, 
			entityinstanceparententityuuid,	
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
			entityinstancecornerstoneorder,
			entityinstanceentitytemplatename,
			entityinstancetype
			)
		values(  
			create_locationownerentityuuid,
			'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'::uuid,  -- uuid for location category systag
			(select entitytemplateuuid from entity.entitytemplate where entitytemplatescanid = 'Customer Tag'),
			(select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatescanid = 'Customer Tag'),
			now(),
			now(), 
			now(), 
			null, 
			create_locationexternalid,
			create_locationexternalsystemuuid,
			(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
			null, 
			null,	
			1::integer,
			'Customer Tag',
			'Customer Tag')
		Returning entityinstanceuuid into tempcustagentityuuid;		
		
		-- cornerstone to self it they are null
		
		update entity.entityinstance
		set entityinstancecornerstoneentityuuid = entityinstanceuuid
		where entityinstanceentitytemplatename in ('Customer Tag') 
			and entityinstancecornerstoneentityuuid isNull
			and entityinstanceuuid = tempcustagentityuuid;
		
		-- custagname
		
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
		values
			(tempcustagentityuuid,
			create_locationownerentityuuid,	
			create_locationtag,
			(select languagemasteruuid from languagemaster where languagemasterid = templanguagemasterid),
			create_languagetypeuuid,
			now(),
			now(),
			(select entityfielduuid
				from entity.entityfield
				where entityfieldname = 'custagname'),
			(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
			'custagname');
		
		-- custagdisplayname
	
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
		values
			(tempcustagentityuuid,
			create_locationownerentityuuid,	
			create_locationtag,
			(select languagemasteruuid from languagemaster where languagemasterid = tempdisplaylanguagemasterid),
			create_languagetypeuuid,
			now(),
			now(),
			(select entityfielduuid
				from entity.entityfield
				where entityfieldname = 'custagdisplayname'),
			(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
			'custagdisplayname');
		
		-- custagtype
		
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
		values
			(tempcustagentityuuid,
			create_locationownerentityuuid,	
			create_locationtag,
			(select languagemasteruuid from languagemaster where languagemasterid = temptypelanguagemasterid),
			create_languagetypeuuid,
			now(),
			now(),
			(select entityfielduuid
				from entity.entityfield
				where entityfieldname = 'custagtype'),
			(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
			'custagtype');
		
		-- custagabbreviationentityuuid
		
		INSERT INTO entity.entityfieldinstance(
			entityfieldinstanceentityinstanceentityuuid, 
			entityfieldinstanceownerentityuuid, 
			entityfieldinstancevalue, 
			entityfieldinstancecreateddate, 
			entityfieldinstancemodifieddate, 
			entityfieldinstanceentityfieldentityuuid, 
			entityfieldinstancemodifiedbyuuid,
			entityfieldinstanceentityfieldname)
		values
			(tempcustagentityuuid,
			create_locationownerentityuuid,	
			null,
			now(),
			now(),
			(select entityfielduuid
				from entity.entityfield
				where entityfieldname = 'custagabbreviationentityuuid'),
			(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
			'custagabbreviationentityuuid');

		-- insert into regular custag table

		INSERT INTO public.custag(
				custagcustomerid, 
				custagcustomeruuid,
				custagsystagid, 
				custagsystaguuid,
				custagnameid, 
				custagtype,
				custagstartdate,
				custagmodifiedby
				)
		values (tempcustomerid,
				tempcustomeruuid,
				713,  -- Systagid for Location Category
				(select systaguuid from systag where systagid = 713),
				templanguagemasterid,
				create_locationtag,
				clock_timestamp(),
				create_modifiedbyid)
				Returning custaguuid, custagid into tempcustaguuid,tempcustagid;

		update entity.entityinstance
		set entityinstanceoriginalid = tempcustagid,
			entityinstanceoriginaluuid = tempcustaguuid
		where entityinstanceuuid = tempcustagentityuuid;

end if;

if tempcustagid isNull
	then tempcustagid = (select custagid 
						from entity.crud_custag_read_min(create_locationownerentityuuid, null, create_locationtaguuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'));
end if;

-- Custag is now created for location type.  Time to insert into location

-- create_locationtimezone
if create_locationtimezone notNull 
	then templocationtimezone = create_locationtimezone;
	else templocationtimezone = (select locationtimezone 
		from entity.crud_location_read_full(create_locationownerentityuuid,create_locationparententityuuid,null,null,false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'));
end if;

if templocationtimezone isNull 
	then templocationtimezone = 'UTC';
end if;

-- create cornerstone order

if create_locationcornerstoneorder is Null
	then templocationcornerstoneorder = 1::integer;
	else templocationcornerstoneorder = create_locationcornerstoneorder::integer;
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
	Returning languagemasterid into templanguagemasterid;

-- insert displayname into languagemaster
	insert into public.languagemaster
		(languagemastercustomerid,
		languagemastersourcelanguagetypeid,
		languagemastersource,
		languagemastermodifiedby)
	values(tempcustomerid,
		templanguagetypeid, 	
		create_locationdisplayname,   
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
		entityinstancetype
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
		'Location')
	Returning entityinstanceuuid into templocationentityuuid;	

	update entity.entityinstance
	set entityinstanceparententityuuid = templocationentityuuid
	where entityinstanceparententityuuid isNull
		and entityinstanceuuid = templocationentityuuid;

	update entity.entityinstance
	set entityinstancecornerstoneentityuuid = templocationentityuuid
	where entityinstancecornerstoneentityuuid isNull
		and entityinstanceuuid = templocationentityuuid;

	-- location name

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
		create_locationname,
		(select languagemasteruuid from languagemaster where languagemasterid = templanguagemasterid),
		create_languagetypeuuid,
		now(),
		now(),		
		(select entityfielduuid
			from entity.entityfield
			where entityfieldname = 'locationname'),
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		'locationname');
	
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
		create_locationdisplayname,
		(select languagemasteruuid from languagemaster where languagemasterid = tempdisplaylanguagemasterid),
		create_languagetypeuuid,
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
		create_languagetypeuuid,
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
	
	INSERT INTO entity.entitytag(
		entitytagownerentityuuid, 
--		entitytagsiteentityuuid, 
		entitytagentityinstanceentityuuid,
		entitytagentitytemplateentityuuid,
--		entitytagcustaguuid, -- eventually drop this
		entitytagcreateddate, 
		entitytagmodifieddate, 
		entitytagstartdate, 
		entitytagenddate, 
		entitytagmodifiedbyuuid,
		entitytagcustagentityuuid)
	values (
		create_locationownerentityuuid,
--		null,
		templocationentityuuid,
		(select entitytemplateuuid from entity.entitytemplate where entitytemplatescanid = 'Location'),
--		tempcustaguuid,  -- eventually drop this
		now(),
		now(),
		now(),
		null,
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		tempcustagentityuuid
	);

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
		(select locationid from entity.crud_location_read_min(create_locationownerentityuuid ,create_locationparententityuuid ,null,null,false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')),
		(select locationid from entity.crud_location_read_min(create_locationownerentityuuid ,create_locationparententityuuid ,null,null,false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')),
		(select locationid from entity.crud_location_read_min(create_locationownerentityuuid ,create_locationcornerstoneentityuuid ,null,null,false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')),
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
		(select systagid from entity.crud_systag_read_min(create_locationownerentityuuid, null,create_locationexternalsystemuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')),
		create_modifiedbyid)
	returning locationid,locationuuid into  templocationid, templocationuuid;

	update location
	set locationsiteid = locationid,
		locationistop = true
	where locationsiteid isNull
		and locationid = templocationid;

	update location
	set locationparentid = locationid
	where locationparentid isNull
		and locationid = templocationid;

	update location
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

$procedure$
