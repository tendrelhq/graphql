
-- Type: PROCEDURE ; Name: entity.crud_entitytemplate_create(uuid,uuid,integer,uuid,text,text,boolean,text,uuid,text,uuid,boolean,boolean,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entitytemplate_create(IN create_entitytemplateownerentityuuid uuid, IN create_entitytemplateparententityuuid uuid, IN create_entitytemplatecornerstoneorder integer, IN create_entitytemplatetaguuid uuid, IN create_entitytemplatetag text, IN create_entitytemplatename text, IN create_entitytemplateisprimary boolean, IN create_entitytemplatescanid text, IN create_languagetypeuuid uuid, IN create_entitytemplateexternalid text, IN create_entitytemplateexternalsystemuuid uuid, IN create_entitytemplatedeleted boolean, IN create_entitytemplatedraft boolean, OUT create_entitytemplateentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	templanguagetypeentityuuid uuid;	
	tempcustomeruuid text;
	tempcustomerid bigint;
	tempcustagentityuuid uuid;
	tempcustagid bigint;
	tempcustaguuid text;
	tempsystagid bigint;
	tempsystaguuid text;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
 	templanguagemasterid bigint;
	tempdisplaylanguagemasterid bigint;
	tempentitytemplatetype	text;
	tempentitytemplatetypeuuid uuid;
	tempcornerstoneorder integer; 
	templanguagemasteruuid text;
	tempentitytemplateownerentityuuid uuid;
	tempentitytaguuid uuid;
	tempentitytemplatedeleted boolean;
	tempentitytemplatedraft boolean;
	
Begin

/*
---------------------------------------------
HOW TO HANDLE ENTIY TYPE
Currently we control this and it is used for drop downs
-- Do we allow for systags that are not system controlled?  Going to start with allowing customers to create system tags for entities. 
-- Do we have a joined custag/systag version?  Not yet, so using systags.
-- Currently allowing duplicate types (Might want to stop this via a constraint on owner and type)
-- Will create a Type for that customer in systag with Systag Entity Types as the parent.

OTHER THINGS
-- This does not handle duplicate template names.  Maybe via a constraint. No duplicates for owner/template 
-- We could do inheritance from a parent template.  Right now parent does nothing.  

 select entitytemplatename,* from entity.crud_entitytemplate_read_full(null, null, null)

-- tests needed
	-- no name
	
	call entity.crud_entitytemplate_create(
		null,  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
		null,  -- merged site and parent.  Set to self if no parent sent in.
		null,  -- default is 1.
		null, -- Used to be only locations had a location category. 
		null,  -- If a tag is sent in that does not exist then we create one at the template level.
		null,  -- Name of the template 
		false, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
		null, -- create_entitytemplatescanid text,  
		null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
		null, -- create_entitytemplateexternalid text,
		null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
		null,-- create_entitytemplatedeleted boolean,
		null,-- create_entitytemplatedraft boolean,
		null, -- create_entitytemplateentityuuid uuid,
		337::bigint) -- IN create_modifiedbyid bigint
	
	-- no owner no parent no templatetaguuid no tag no languagetype = defaulted to tendrel and primary
	
	call entity.crud_entitytemplate_create(
		null,  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
		null,  -- merged site and parent.  Set to self if no parent sent in.
		null,  -- default is 1.
		null, -- Used to be only locations had a location category.
		null,  -- If a tag is sent in that does not exist then we create one at the template level.
		'entitytemplate'||now()::text,  -- Name of the template 
		false, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
		'scanid'||now()::text, -- create_entitytemplatescanid text,  
		null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
		null, -- create_entitytemplateexternalid text,
		null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
		null,-- create_entitytemplatedeleted boolean,
		null,-- create_entitytemplatedraft boolean,
		null, -- create_entitytemplateentityuuid uuid,
		337::bigint) 

	-- valid owner

	call entity.crud_entitytemplate_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0',  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
		null,  -- merged site and parent.  Set to self if no parent sent in.
		null,  -- default is 1.
		null, -- Used to be only locations had a location category.
		null,  -- If a tag is sent in that does not exist then we create one at the template level.
		'entitytemplate'||now()::text,  -- Name of the template 
		false, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
		'scanid'||now()::text, -- create_entitytemplatescanid text,  
		null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
		null, -- create_entitytemplateexternalid text,
		null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
		null,-- create_entitytemplatedeleted boolean,
		null,-- create_entitytemplatedraft boolean,
		null, -- create_entitytemplateentityuuid uuid,
		337::bigint) 
	
	-- invalid owner  -- not a customer (error)

	call entity.crud_entitytemplate_create(
		'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9',  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
		null,  -- merged site and parent.  Set to self if no parent sent in.
		null,  -- default is 1.
		null, -- Used to be only locations had a location category.
		null,  -- If a tag is sent in that does not exist then we create one at the template level.
		'entitytemplate'||now()::text,  -- Name of the template 
		false, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
		'scanid'||now()::text, -- create_entitytemplatescanid text,  
		null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
		null, -- create_entitytemplateexternalid text,
		null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
		null,-- create_entitytemplatedeleted boolean,
		null,-- create_entitytemplatedraft boolean,
		null, -- create_entitytemplateentityuuid uuid,
		337::bigint) 

	-- valid parent  -- parent needs to be an instance.

		Not implemented yet

	-- invalid parent  -- parent needs to be an instance.

		Not implemented yet

	-- valid taguuid  -- need to finish tag code.  :-(
	call entity.crud_entitytemplate_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0',  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
		null,  -- merged site and parent.  Set to self if no parent sent in.
		null,  -- default is 1.
		'bb05d944-f7ba-4e40-b1d7-f2e3c0608c4c', -- Used to be only locations had a location category.
		null,  -- If a tag is sent in that does not exist then we create one at the template level.
		'entitytemplate'||now()::text,  -- Name of the template 
		false, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
		'scanid'||now()::text, -- create_entitytemplatescanid text,  
		null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
		null, -- create_entitytemplateexternalid text,
		null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
		null,-- create_entitytemplatedeleted boolean,
		null,-- create_entitytemplatedraft boolean,
		null, -- create_entitytemplateentityuuid uuid,
		337::bigint) 

	-- invalid taguuid (becomes null) with a tag name

	call entity.crud_entitytemplate_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0',  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
		null,  -- merged site and parent.  Set to self if no parent sent in.
		null,  -- default is 1.
		'00014b06-73b8-464b-8881-0ef9dfb7b712', -- Used to be only locations had a location category.
		'Tag'||now()::text,  -- If a tag is sent in that does not exist then we create one at the template level.
		'entitytemplate'||now()::text,  -- Name of the template 
		false, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
		'scanid'||now()::text, -- create_entitytemplatescanid text,  
		null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
		null, -- create_entitytemplateexternalid text,
		null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
		null,-- create_entitytemplatedeleted boolean,
		null,-- create_entitytemplatedraft boolean,
		null, -- create_entitytemplateentityuuid uuid,
		337::bigint) 

*/

-- set up customer/owner  
-- Assumes customer until custag is cutover to entity 100%
-- Default to tendrel as custoemr if no customer is sent in
-- This should either come from the Auth token or somehow selected (Fillogic scenario)

if create_entitytemplateownerentityuuid isNull
	then tempentitytemplateownerentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid; -- default is customer 0.  Could look this up instead.  
	else tempentitytemplateownerentityuuid = create_entitytemplateownerentityuuid;
end if;

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
					from entity.crud_customer_read_min(null,tempentitytemplateownerentityuuid,null,false,null,null,null, null);

-- probably return an error if the entity is not set to a customer.  Need to sort this out.  
if tempcustomerid isNull
	then return;
end if;

-- setup the language type

if create_languagetypeuuid isNull
	then templanguagetypeentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
	else templanguagetypeentityuuid = create_languagetypeuuid;
end if;

select systagid,systaguuid into templanguagetypeid,templanguagetypeuuid
	from entity.crud_systag_read_min(null, null, templanguagetypeentityuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9');

-- create entity type -- if null use the name

if create_entitytemplatename isNull
	then return;
end if;

call entity.crud_systag_create(
		tempentitytemplateownerentityuuid, 
		'b07bf96e-0a35-4b01-bcc0-863dc7b3db0c'::uuid, --Entity Tag
		null::uuid,   --create_systagcornerstoneentityuuid
		null::integer, --create_systagcornerstoneorder 
		create_entitytemplatename,  -- create_systag
		templanguagetypeentityuuid, -- create_languagetypeuuid  
		create_entitytemplateexternalid, -- create_systagexternalid text,
		create_entitytemplateexternalsystemuuid, -- create_systagexternalsystemuuid
		null, --create_systagdeleted boolean,
		null, --create_systagdraft boolean,
		tempsystagid, -- OUT create_systagid
		tempsystaguuid, -- OUT create_systaguuid text,
		tempentitytemplatetypeuuid, -- OUT create_systagentityuuid uuid
		337::bigint);

-- setup entity tag and custag
-- Check if create_entitytemplatetaguuid exists.  If yes grab its custag and we can use it to create an new entity tag later.  

tempcustagentityuuid = (select entitytagcustagentityuuid 
				from entity.crud_entitytag_read_full(tempentitytemplateownerentityuuid,create_entitytemplatetaguuid,null,null,null, false, null,null,null, templanguagetypeentityuuid));

-- if the entity tag uuid is null and a tag was sent in we need to create a custag.  
-- If not, it just remains null.  Note, this will be a top most custag that points back to tag systag.
-- For now not checking for duplicates.  

if tempcustagentityuuid isNull and create_entitytemplatetag notNull
	then  --create custag  -- check if custag exists as well.  
		call entity.crud_custag_create(tempentitytemplateownerentityuuid, 
										null, 
										null, 
										null, 
										create_entitytemplatetag, 
										templanguagetypeentityuuid, 
										null, 
										create_entitytemplateexternalsystemuuid, 
										null, --create_custagdeleted boolean,
										null, --create_cusstagdraft boolean,
										tempcustagid, -- not sure I need this
										tempcustaguuid, -- not sure I need this
										tempcustagentityuuid, 
										create_modifiedbyid);
end if;

-- create cornerstone order

if create_entitytemplatecornerstoneorder is Null
	then tempcornerstoneorder = 1::integer;
	else tempcornerstoneorder = create_locationcornerstoneorder::integer;
end if;

If create_entitytemplatedeleted isNull
	then tempentitytemplatedeleted = false;
	else tempentitytemplatedeleted = create_entitytemplatedeleted;
end if;

If create_entitytemplatedraft isNull
	then tempentitytemplatedraft = false;
	else tempentitytemplatedraft = create_entitytemplatedraft;
end if;

-- time to insert the base entity template

-- insert name into languagemaster
	insert into public.languagemaster
		(languagemastercustomerid,
		languagemastersourcelanguagetypeid,
		languagemastersource,
		languagemastermodifiedby)
	values(tempcustomerid,
		templanguagetypeid, 	
		create_entitytemplatename,    
		create_modifiedbyid)  
	Returning languagemasteruuid into templanguagemasteruuid;

INSERT INTO entity.entitytemplate(
	entitytemplatestartdate, 
	entitytemplateenddate, 
	entitytemplatecreateddate, 
	entitytemplatemodifieddate, 
	entitytemplateexternalid, 
	entitytemplatescanid, 
	entitytemplatenameuuid, 
	entitytemplateorder, 
	entitytemplatemodifiedbyuuid, 
	entitytemplateisprimary, 
	entitytemplateownerentityuuid, 
	entitytemplatetypeentityuuid, 
	entitytemplateparententityuuid, 
	entitytemplateexternalsystementityuuid, 
	entitytemplatename,
	entitytemplatedeleted,
	entitytemplatedraft
	)
VALUES ( 
	now(), -- entitytemplatestartdate 
	null, -- entitytemplateenddate 
	now(), -- entitytemplatecreateddate
	now(), -- entitytemplatemodifieddate
	create_entitytemplateexternalid, 
	create_entitytemplatescanid, 
	templanguagemasteruuid,    
	tempcornerstoneorder, 
	(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid) , 
	create_entitytemplateisprimary,
	tempentitytemplateownerentityuuid, 
	tempentitytemplatetypeuuid, 
	create_entitytemplateparententityuuid, 
	create_entitytemplateexternalsystemuuid, 
	create_entitytemplatename,
	tempentitytemplatedeleted,
	tempentitytemplatedraft)
	Returning entitytemplateuuid into create_entitytemplateentityuuid;

update entity.entitytemplate
set entitytemplateparententityuuid = entitytemplateuuid
where entitytemplateparententityuuid isNull
	and entitytemplateuuid = create_entitytemplateentityuuid;

if tempcustagentityuuid notNull
	then 
		call entity.crud_entitytag_create(
			tempentitytemplateownerentityuuid, -- IN create_entitytagownerentityuuid uuid,
			null::uuid, -- IN create_entitytagentityinstanceuuid uuid,
			create_entitytemplateentityuuid, -- IN create_entitytagentitytemplateuuid uuid,	
			tempcustagentityuuid, -- IN create_entitytagcustaguuid uuid,
			templanguagetypeentityuuid, -- IN create_languagetypeuuid uuid,
			null, -- create_entitytagdeleted
			null, -- create_entitytagdraft
			tempentitytaguuid, -- OUT create_entitytaguuid uuid,
			create_modifiedbyid );	
end if;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entitytemplate_create(uuid,uuid,integer,uuid,text,text,boolean,text,uuid,text,uuid,boolean,boolean,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytemplate_create(uuid,uuid,integer,uuid,text,text,boolean,text,uuid,text,uuid,boolean,boolean,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytemplate_create(uuid,uuid,integer,uuid,text,text,boolean,text,uuid,text,uuid,boolean,boolean,bigint) TO tendreladmin WITH GRANT OPTION;
