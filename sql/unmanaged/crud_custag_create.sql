CREATE OR REPLACE PROCEDURE entity.crud_custag_create(IN create_custagownerentityuuid uuid, IN create_custagparententityuuid uuid, IN create_custagcornerstoneentityuuid uuid, IN create_custagcornerstoneorder integer, IN create_custag text, IN create_languagetypeuuid uuid, IN create_custagexternalid text, IN create_custagexternalsystemuuid uuid, IN create_custagdeleted boolean, IN create_custagdraft boolean, OUT create_custagid bigint, OUT create_custaguuid text, OUT create_custagentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
 	templanguagemasterid bigint;
	templanguagemasteruuid text;
	tempdisplaylanguagemasterid bigint;
	tempdisplaylanguagemasteruuid text;
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempcustagentityuuid uuid;
	tempcustagid bigint;
	tempcustaguuid text;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
	templanguagetypeentityuuid uuid;
	tempcustagcornerstoneorder integer;  -- cornerstone as well?
	tempcustagparententityuuid uuid;
	tempcustagownerentityuuid uuid;	
	tempcustagdeleted boolean;
	tempcustagdraft boolean;

Begin

/*  Helper scripts for checking data post creates

-- customers to use

select * from entity.crud_customer_read_full(null,null, null, true,null,null, null, null)
order by customerid desc

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

select * from entity.crud_systag_read_min(null,null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagtype

*/

/*
-- Customer for testing -- '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'

-- tests 
	-- add test.  If custag isNull then it should do nothing

	-- add test.  If custag is a duplicate then return the duplicate

	-- custag to a systag 	
			-- Do we allow for cystags and systags to be at the same level?
			-- Curent systags with custags

	call entity.crud_custag_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --create_custagownerentityuuid
		'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', --create_custagparententityuuid
		null,   --create_custagcornerstoneentityuuid
		null, --create_custagcornerstoneorder 
		'custag'||now(),  -- create_custag
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- create_languagetypeuuid  
		null,  -- 	create_custagexternalid text,
		null, -- create_custagexternalsystemuuid
		null, 
		null, 
		null, -- OUT create_custagid
		null, -- OUT create_custaguuid text,
		null, -- OUT create_custagentityuuid uuid
		337::bigint)

	-- custag that is the start of a tree 
			-- To start will assume there is always a parent.  Will use the generic one.  

	call entity.crud_custag_create(
		'cb56292b-8c20-4a9c-a70e-595d7b04c743', --create_custagownerentityuuid
		null,	--create_custagparententityuuid
		null,   --create_custagcornerstoneentityuuid
		null, --create_custagcornerstoneorder 
		'parentcustag'||now(),  -- create_custag
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- create_languagetypeuuid  
		null,  -- 	create_custagexternalid text,
		null, -- create_custagexternalsystemuuid
		null, 
		null, 
		null, -- OUT create_custagid
		null, -- OUT create_custaguuid text,
		null, -- OUT create_custagentityuuid uuid
		337::bigint)
		
	-- custag of a custag

	call entity.crud_custag_create(
		'cb56292b-8c20-4a9c-a70e-595d7b04c743', --create_custagownerentityuuid
		???,	--create_custagparententityuuid  -- use the rertun from the previous test.  
		null,   --create_custagcornerstoneentityuuid
		null, --create_custagcornerstoneorder 
		'subcustag'||now(),  -- create_custag
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- create_languagetypeuuid  
		null,  -- 	create_custagexternalid text,
		null, -- create_custagexternalsystemuuid
		null, 
		null, 
		null, -- OUT create_custagid
		null, -- OUT create_custaguuid text,
		null, -- OUT create_custagentityuuid uuid
		337::bigint)

	-- custag with cornerstone

	call entity.crud_custag_create(
		'cb56292b-8c20-4a9c-a70e-595d7b04c743', --create_custagownerentityuuid
		???,	--create_custagparententityuuid  -- use the return from generic test.  
		???,,   --create_custagcornerstoneentityuuid  -- use the previous test.  
		2::integer, --create_custagcornerstoneorder 
		'subcustag'||now(),  -- create_custag
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- create_languagetypeuuid  
		null,  -- 	create_custagexternalid text,
		null, -- create_custagexternalsystemuuid
		null, 
		null, 
		null, -- OUT create_custagid
		null, -- OUT create_custaguuid text,
		null, -- OUT create_custagentityuuid uuid
		337::bigint)
	
	-- New location existing parent new location tag

-- maybe a seperate SP for key custag types that exist today that the system needs.    

*/

-- setup customer info
if create_custagownerentityuuid isNull
	then return;
	else tempcustagownerentityuuid = create_custagownerentityuuid;
end if;

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,tempcustagownerentityuuid,null,false,null,null,null, null);

-- probably return an error if the entity is not set to a customer.  Need to sort this out.  
if tempcustomerid isNull
	then  return;
end if;

-- custags need a name
if (create_custag isNull or coalesce(create_custag,'')= '')
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
if create_custagparententityuuid isNull
	then -- set parent to the generic systag
		tempcustagparententityuuid = '86be74b7-40df-4c20-9467-d35fae610c52'::uuid;  -- this is the top most of the tag tree.
	else tempcustagparententityuuid = create_custagparententityuuid;
end if;

-- if custag already exists for the parent then return an error
if create_custag = any(	select custagtype 
		from entity.crud_custag_read_min(tempcustagownerentityuuid ,null,null, tempcustagparententityuuid, false,null,null, null,templanguagetypeentityuuid))
	then return; 
end if;	

-- setup custag order
if create_custagcornerstoneorder isNull
	then tempcustagcornerstoneorder = 1::integer;
	else tempcustagcornerstoneorder = create_custagcornerstoneorder::integer;
end if;

If create_custagdeleted isNull
	then tempcustagdeleted = false;
	else tempcustagdeleted = create_custagdeleted;
end if;

If create_custagdraft isNull
	then tempcustagdraft = false;
	else tempcustagdraft = create_custagdraft;
end if;

-- add the entity custag first then into the custag table

-- insert name into languagemaster
	insert into public.languagemaster
		(languagemastercustomerid,
		languagemastersourcelanguagetypeid,
		languagemastersource,
		languagemastermodifiedby)
	values(tempcustomerid,
		templanguagetypeid, 	
		create_custag,
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
		create_custag,
		create_modifiedbyid)
	Returning languagemasterid,languagemasteruuid into tempdisplaylanguagemasterid,tempdisplaylanguagemasteruuid;

-- insert custag
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
		entityinstanceexternalsystemuuid, -- deprecate???		
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
		create_custagownerentityuuid,
		tempcustagparententityuuid,  
		(select entitytemplateuuid from entity.entitytemplate where entitytemplatescanid = 'Customer Tag'),
		(select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatescanid = 'Customer Tag'),
		now(),
		now(), 
		now(), 
		null, 
		create_custagexternalid,
		null,  -- deprecate???
		create_custagexternalsystemuuid,  -- not handling this correctly right now.  Maybe a lookup or sent in?
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		null, 
		null,	
		tempcustagcornerstoneorder,
		'Customer Tag',
		create_custag,
		templanguagemasteruuid,
		tempcustagdeleted,
		tempcustagdraft)
	Returning entityinstanceuuid into tempcustagentityuuid;		
	
	-- cornerstone to self it they are null
	
	update entity.entityinstance
	set entityinstancecornerstoneentityuuid = entityinstanceuuid
	where  entityinstancecornerstoneentityuuid isNull
		and entityinstanceuuid = tempcustagentityuuid;
	
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
		create_custagownerentityuuid,	
		create_custag,
		(select languagemasteruuid from languagemaster where languagemasterid = tempdisplaylanguagemasterid),
		create_languagetypeuuid,
		now(),
		now(),
		(select entityfielduuid
			from entity.entityfield
			where entityfieldname = 'custagdisplayname'),
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		'custagdisplayname');
	
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
		create_custagownerentityuuid,	
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
			(select entityinstanceoriginalid from entity.entityinstance where entityinstanceuuid = tempcustagparententityuuid),
			(select entityinstanceoriginaluuid from entity.entityinstance where entityinstanceuuid = tempcustagparententityuuid),
			templanguagemasterid,
			create_custag,
			clock_timestamp(),
			create_modifiedbyid)
			Returning custaguuid, custagid into tempcustaguuid,tempcustagid;

	update entity.entityinstance
	set entityinstanceoriginalid = tempcustagid,
		entityinstanceoriginaluuid = tempcustaguuid
	where entityinstanceuuid = tempcustagentityuuid;

create_custagid = tempcustagid;
create_custaguuid = tempcustaguuid;
create_custagentityuuid = tempcustagentityuuid;

End;

$procedure$
