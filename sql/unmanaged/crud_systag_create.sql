CREATE OR REPLACE PROCEDURE entity.crud_systag_create(IN create_systagownerentityuuid uuid, IN create_systagparententityuuid uuid, IN create_systagcornerstoneentityuuid uuid, IN create_systagcornerstoneorder integer, IN create_systag text, IN create_languagetypeuuid uuid, IN create_systagexternalid text, IN create_systagexternalsystemuuid uuid, IN create_systagdeleted boolean, IN create_systagdraft boolean, OUT create_systagid bigint, OUT create_systaguuid text, OUT create_systagentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
 	templanguagemasterid bigint;
	templanguagemasteruuid text;
	tempdisplaylanguagemasterid bigint;
	tempdisplaylanguagemasteruuid text;
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempsystagentityuuid uuid;
	tempsystagid bigint;
	tempsystaguuid text;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
	templanguagetypeentityuuid uuid;
	tempsystagcornerstoneorder integer;  -- cornerstone as well?
	tempsystagparententityuuid uuid;
	tempsystagownerentityuuid uuid;	
	tempsystagdeleted boolean;
	tempsystagdraft boolean;

Begin

/*  Helper scripts for checking data post creates

-- customers to use

select * from entity.crud_customer_read_full(null,null, null, true, null,null, null,null)
order by customerid desc

-- systag data
select * from systag order by systagid desc limit 10  

select * from entity.crud_systag_read_full(null,null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid  desc limit 10  

select * from entity.crud_systag_read_min(null,null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid  desc limit 10  

-- general

select * from languagemaster 
where languagemastercreateddate::date = now()::Date
order by languagemaster desc limit 100 

select * from entity.entityinstance
where entityinstancecreateddate::date = now()::date

select * from entity.crud_systag_read_min(null,null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagtype

*/

/*
-- Customer for testing -- 'cb56292b-8c20-4a9c-a70e-595d7b04c743'

-- tests 

	-- systag to a systag 	
			-- Do we allow for cystags and systags to be at the same level?
			-- Curent systags with systags

	call entity.crud_systag_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --create_systagownerentityuuid
		'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', --create_systagparententityuuid
		null,   --create_systagcornerstoneentityuuid
		null, --create_systagcornerstoneorder 
		'systag'||now(),  -- create_systag
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- create_languagetypeuuid  
		null,  -- 	create_systagexternalid text,
		null, -- create_systagexternalsystemuuid
		null,
		null,
		null, -- OUT create_systagid
		null, -- OUT create_systaguuid text,
		null, -- OUT create_systagentityuuid uuid
		337::bigint)

-- FIX THESE TESTS
	-- systag that is the start of a tree 
			-- To start will assume there is always a parent.  Will use the generic one.  

	call entity.crud_systag_create(
		'cb56292b-8c20-4a9c-a70e-595d7b04c743', --create_systagownerentityuuid
		null,	--create_systagparententityuuid
		null,   --create_systagcornerstoneentityuuid
		null, --create_systagcornerstoneorder 
		'parentsystag'||now(),  -- create_systag
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- create_languagetypeuuid  
		null,  -- 	create_systagexternalid text,
		null, -- create_systagexternalsystemuuid
		null,
		null,
		null, -- OUT create_systagid
		null, -- OUT create_systaguuid text,
		null, -- OUT create_systagentityuuid uuid
		337::bigint)
		
	-- systag of a systag

	call entity.crud_systag_create(
		'cb56292b-8c20-4a9c-a70e-595d7b04c743', --create_systagownerentityuuid
		'3daf8c7d-f3c0-4d39-baae-bc6cabbb3174',	--create_systagparententityuuid  -- use the rertun from the previous test.  
		null,   --create_systagcornerstoneentityuuid
		null, --create_systagcornerstoneorder 
		'subsystag'||now(),  -- create_systag
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- create_languagetypeuuid  
		null,  -- 	create_systagexternalid text,
		null, -- create_systagexternalsystemuuid
		null,
		null,
		null, -- OUT create_systagid
		null, -- OUT create_systaguuid text,
		null, -- OUT create_systagentityuuid uuid
		337::bigint)

	-- systag with cornerstone

	call entity.crud_systag_create(
		'cb56292b-8c20-4a9c-a70e-595d7b04c743', --create_systagownerentityuuid
		'3daf8c7d-f3c0-4d39-baae-bc6cabbb3174',	--create_systagparententityuuid  -- use the return from generic test.  
		'bb76706d-fd32-4514-9545-dc5b39027c0b',   --create_systagcornerstoneentityuuid  -- use the previous test.  
		2::integer, --create_systagcornerstoneorder 
		'subsystag'||now(),  -- create_systag
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- create_languagetypeuuid  
		null,  -- 	create_systagexternalid text,
		null, -- create_systagexternalsystemuuid
		null,
		null,
		null, -- OUT create_systagid
		null, -- OUT create_systaguuid text,
		null, -- OUT create_systagentityuuid uuid
		337::bigint)
	
	-- New location existing parent new location tag

-- maybe a seperate SP for key systag types that exist today that the system needs.    

*/

-- setup customer info
if create_systagownerentityuuid isNull
	then return;
	else tempsystagownerentityuuid = create_systagownerentityuuid;
end if;

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,tempsystagownerentityuuid,null,false,null,null,null, null);

-- probably return an error if the entity is not set to a customer.  Need to sort this out.  
if tempcustomerid isNull
	then  return;
end if;

-- systags need a name
if (create_systag isNull or coalesce(create_systag,'')= '')
	then return;  -- need error code
end if;

-- setup the language type
if create_languagetypeuuid isNull
	then templanguagetypeentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
	else templanguagetypeentityuuid = create_languagetypeuuid;
end if;

select systagid,systaguuid into templanguagetypeid,templanguagetypeuuid
	from entity.crud_systag_read_min(null, null, templanguagetypeentityuuid, null, false,null,null, null,templanguagetypeentityuuid);

if templanguagetypeid isNull
	then return;
end if;

-- setup parent

if create_systagparententityuuid isNull
	then -- set parent to the generic systag
		tempsystagparententityuuid = '86be74b7-40df-4c20-9467-d35fae610c52'::uuid;  -- this is the top most of the tag tree.
	else tempsystagparententityuuid = create_systagparententityuuid;
end if;

-- if systag already exists for the parent then return an error
if create_systag = any(	select systagtype 
		from entity.crud_systag_read_min(tempsystagownerentityuuid ,null,null, tempsystagparententityuuid, false,null,null, null,templanguagetypeentityuuid))
	then return; 
end if;	

-- setup systag order

if create_systagcornerstoneorder isNull
	then tempsystagcornerstoneorder = 1::integer;
	else tempsystagcornerstoneorder = create_systagcornerstoneorder::integer;
end if;

If create_systagdeleted isNull
	then tempsystagdeleted = false;
	else tempsystagdeleted = create_systagdeleted;
end if;

If create_systagdraft isNull
	then tempsystagdraft = false;
	else tempsystagdraft = create_systagdraft;
end if;

-- add the entity systag first then into the systag table

-- insert name into languagemaster
	insert into public.languagemaster
		(languagemastercustomerid,
		languagemastersourcelanguagetypeid,
		languagemastersource,
		languagemastermodifiedby)
	values(tempcustomerid,
		templanguagetypeid, 	
		create_systag,
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
		create_systag,
		create_modifiedbyid)
	Returning languagemasterid,languagemasteruuid into tempdisplaylanguagemasterid,tempdisplaylanguagemasteruuid;

-- insert systag
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
		entityinstanceexternalsystemuuid,
		entityinstanceexternalsystementityuuid,
		entityinstancemodifiedbyuuid, 
		entityinstancerefid,
		entityinstancerefuuid,
		entityinstancecornerstoneorder,
		entityinstanceentitytemplatename,
		entityinstancetype,
		entityinstancenameuuid,
		entityinstancedeleted, 
		entityinstancedraft	
		)
	values(  
		create_systagownerentityuuid,
		tempsystagparententityuuid,  
		(select entitytemplateuuid from entity.entitytemplate where entitytemplatescanid = 'System Tag'),
		(select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatescanid = 'System Tag'),
		now(),
		now(), 
		now(), 
		null, 
		create_systagexternalid,
		null,
		create_systagexternalsystemuuid,
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		null, 
		null,	
		tempsystagcornerstoneorder,
		'System Tag',
		create_systag,
		templanguagemasteruuid,
		tempsystagdeleted,
		tempsystagdraft)
	Returning entityinstanceuuid into tempsystagentityuuid;		
	
	-- cornerstone to self it they are null
	
	update entity.entityinstance
	set entityinstancecornerstoneentityuuid = entityinstanceuuid
	where entityinstancetype in ('System Tag') 
		and entityinstancecornerstoneentityuuid isNull
		and entityinstanceuuid = tempsystagentityuuid;
	
	-- systagdisplayname

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
		(tempsystagentityuuid,
		create_systagownerentityuuid,	
		create_systag,
		tempdisplaylanguagemasteruuid,
		create_languagetypeuuid,
		now(),
		now(),
		(select entityfielduuid
			from entity.entityfield
			where entityfieldname = 'systagdisplayname'),
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		'systagdisplayname');
	
	-- systagabbreviationentityuuid
	
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
		(tempsystagentityuuid,
		create_systagownerentityuuid,	
		null,
		now(),
		now(),
		(select entityfielduuid
			from entity.entityfield
			where entityfieldname = 'systagabbreviationentityuuid'),
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		'systagabbreviationentityuuid');

	-- insert into regular systag table

	INSERT INTO public.systag(
			systagcustomerid, 
			systagparentid, 
			systagnameid, 
			systagtype,
			systagstartdate,
			systagmodifiedby
			)
	values (tempcustomerid,

			(select entityinstanceoriginalid from entity.entityinstance where entityinstanceuuid = tempsystagparententityuuid),
			templanguagemasterid,
			create_systag,
			clock_timestamp(),
			create_modifiedbyid)
			Returning systaguuid, systagid into tempsystaguuid,tempsystagid;

	update entity.entityinstance
	set entityinstanceoriginalid = tempsystagid,
		entityinstanceoriginaluuid = tempsystaguuid
	where entityinstanceuuid = tempsystagentityuuid;

create_systagid = tempsystagid;
create_systaguuid = tempsystaguuid;
create_systagentityuuid = tempsystagentityuuid;

End;

$procedure$
