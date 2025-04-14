
-- Type: PROCEDURE ; Name: entity.crud_entityinstance_create(uuid,uuid,text,uuid,uuid,integer,uuid,text,text,text,uuid,text,uuid,boolean,boolean,uuid,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entityinstance_create(IN create_entityinstanceownerentityuuid uuid, IN create_entityinstanceentitytemplateentityuuid uuid, IN create_entityinstanceentitytemplateentityname text, IN create_entityinstanceparententityuuid uuid, IN create_entityinstanceecornerstoneentityuuid uuid, IN create_entityinstancecornerstoneorder integer, IN create_entityinstancetaguuid uuid, IN create_entityinstancetag text, IN create_entityinstancename text, IN create_entityinstancescanid text, IN create_entityinstancetypeuuid uuid, IN create_entityinstanceexternalid text, IN create_entityinstanceexternalsystemuuid uuid, IN create_entityinstancedeleted boolean, IN create_entityinstancedraft boolean, OUT create_entityinstanceentityuuid uuid, IN create_languagetypeuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
 	templanguagemasteruuid text;
	tempcustomerid bigint;
	tempcustomeruuid text;	
	tempentityinstanceuuid uuid;
	tempcustagid bigint;
  	tempcustaguuid text;
	tempcustagentityuuid uuid;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
	tempcornerstoneorder integer;
	tempentityinstanceownerentityuuid uuid;
	templanguagetypeentityuuid uuid;
	tempentitytemplateuuid uuid;
	tempentitytemplatetypeentityuuid uuid; 
	tempentitytemplatetype text; 
	tempentitytemplateisprimary boolean;
	tempentitytagcustagentityuuid uuid[];
	tempentityinstancedeleted boolean;
	tempentityinstancedraft boolean;
	tempentitytaguuid uuid;

Begin

/*  Future 
-- Validate externalsystem, cornerstone, and parent?  Possible validations - same level - same customer - etc
-- externalsystemuuid vs externalsystementityuuid - one is a systag, but we are not handling this well.  Keep both?  
-- Duplicate checking of tag creation, tempalte creation, and instance type
-- Create languagemaster function - probably all things having to do with language
-- testing should use a created customer with all the bells and whistles

interesting sql:
-- 	select unnest(array['test','test2'])
--	FOREACH tempcustagentityuuid IN ARRAY tempentitytagcustagentityuuid
	LOOP 
		call entity.crud_entitytag_create(tempentityinstanceownerentityuuid,tempentityinstanceuuid,tempcustagentityuuid,tempentitytagcustagentityuuid, null, null, null, null, create_modifiedbyid);
	END LOOP;
*/

/*  Testing

-- during create

-- Using customer '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'
-- test return -- create_entityinstanceentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

-- tests
	-- error - no entityinstanceownerentityuuid
		call entity.crud_entityinstance_create(
			null, -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			null, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337)

	-- error - invalid entityinstanceownerentityuuid not a customer
		call entity.crud_entityinstance_create(	
			'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			null, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337)

	-- error - valid entityinstanceownerentityuuid no instance name or empty string
		call entity.crud_entityinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'', -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337)

	-- error - valid entityinstanceownerentityuuid valid instance name no templateuuid no template name

		call entity.crud_entityinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||now()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337)

	-- error - primary template valid instance name

		call entity.crud_entityinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityinstanceownerentityuuid uuid,
			'0b9f3142-e7ed-4f78-8504-ccd2eb505075', -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||now()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337)

	-- error - entityinstanceownerentityuuid valid instance name template/owner mismatch
	
		call entity.crud_entityinstance_create(
			'4e294bf5-115a-42f2-bf37-aaf4655ef8d6', -- IN create_entityinstanceownerentityuuid uuid,
			'e62e67f3-9bd6-4be8-b379-e22d61b51c91', -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||now()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337)	

	-- success - valid entityinstanceownerentityuuid valid instance name no templateuuid valid template name	no tags no cutags

		call entity.crud_entityinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			'newtemplate'||now()::text, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||now()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337)

-------------------------------------------

	-- success - valid entityinstanceownerentityuuid valid instance name valid templateuuid with tags no cutags
	-- might need to create a to the template created above.  

		call entity.crud_custag_create('70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', null, null, null, 'templatetag'||now()::text, 
									'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, null, null, null, null, null, null, 	337);

		call entity.crud_entitytag_create(
				'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entitytagownerentityuuid uuid,
				null, -- IN create_entitytagentityinstanceuuid uuid,
				'274541f8-5c9f-4e8c-9982-08c35b79e2b3', -- IN create_entitytagentitytemplateuuid uuid,	
				'c2d5ecdd-a657-4448-aef2-54467045134a', -- IN create_entitytagcustaguuid uuid,
				null,
				null,
				null, -- IN create_languagetypeuuid uuid,
				null, -- OUT create_entitytaguuid uuid,
				337::bigint)	

---------------------------------------------------
		call entity.crud_entityinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityinstanceownerentityuuid uuid,
			'274541f8-5c9f-4e8c-9982-08c35b79e2b3', -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			'c2d5ecdd-a657-4448-aef2-54467045134a', -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||now()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337)

	-- success - valid entityinstanceownerentityuuid valid instance name valid templateuuid no tags invalid custtaguuid

		call entity.crud_entityinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityinstanceownerentityuuid uuid,
			'e62e67f3-9bd6-4be8-b379-e22d61b51c91', -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||now()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337)	

	-- success - valid entityinstanceownerentityuuid valid templateuuid with tags no custtaguuid with custtagname

		call entity.crud_entityinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityinstanceownerentityuuid uuid,
			'e62e67f3-9bd6-4be8-b379-e22d61b51c91', -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			'newtag'||now()::text, -- IN create_entityinstancetag text,
			'instance'||now()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337)	

	-- success - valid entityinstanceownerentityuuid valid templateuuid no tags valid custtaguuid	
		call entity.crud_entityinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityinstanceownerentityuuid uuid,
			'e62e67f3-9bd6-4be8-b379-e22d61b51c91', -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			'5ef190d1-2a73-48e5-a80f-d351065f6692', -- IN create_entityinstancetaguuid uuid,  grab the test one just generated
			null, -- IN create_entityinstancetag text,
			'instance'||now()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337) 

-- possible future tests
	-- dupe checking for custag creation (Maybe put this in custag create and return the existing tag.)
	-- dupe checking on entityinstancename??? 

*/

-- setup customer info
if create_entityinstanceownerentityuuid isNull
	then 
		return; -- need an error code  
	else tempentityinstanceownerentityuuid = create_entityinstanceownerentityuuid;
end if;

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,tempentityinstanceownerentityuuid,null,false,null,null,null, null);

-- probably return an error if the entity is not set to a customer.  Need to sort this out.  
if tempcustomerid isNull
	then  
		return;
end if;

-- instances need a name
if (create_entityinstancename isNull or coalesce(create_entityinstancename,'')= ''	)
	then return; -- need error code
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

-- Block Primary templates from creation
if create_entityinstanceentitytemplateentityuuid notNull
	then select entitytemplateuuid, entitytemplatetypeentityuuid, entitytemplateisprimary 
			into tempentitytemplateuuid, tempentitytemplatetypeentityuuid, tempentitytemplateisprimary
			from entity.crud_entitytemplate_read_min(tempentityinstanceownerentityuuid, create_entityinstanceentitytemplateentityuuid, null, null, null, templanguagetypeentityuuid)
			group by entitytemplateuuid, entitytemplatetypeentityuuid, entitytemplateisprimary;
			tempentitytemplatetype = create_entityinstanceentitytemplateentityname; 
	else tempentitytemplateuuid = null;
end if;

-- Instances with no template uuid sent in but a name, create the template
-- Check that the name is not empty/null -- if uuid is null and name is not we cand do lazy initialization of template

if tempentitytemplateuuid isnull 
	and (create_entityinstanceentitytemplateentityname isNull or coalesce(create_entityinstanceentitytemplateentityname,'')= '')
	then return; -- need error code
end if;

-- if we still have no templateuuid but have a template name we need to create this using lazy init
-- We will want to later add the tag to this template.  
-- Have not decided yet if the tag will be an the isntance or template level
if tempentitytemplateuuid isNull and (create_entityinstanceentitytemplateentityname notNull and coalesce(create_entityinstanceentitytemplateentityname, '')<>'')
	then call entity.crud_entitytemplate_create( tempentityinstanceownerentityuuid, null, null, null, null, create_entityinstanceentitytemplateentityname, false, create_entityinstanceentitytemplateentityname, templanguagetypeentityuuid, null, null, null, null, tempentitytemplateuuid, 337::bigint); 
		tempentitytemplatetype = create_entityinstanceentitytemplateentityname;
		tempentitytemplatetypeentityuuid = (select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplateuuid = tempentitytemplateuuid);
end if;

-- pull any tags that exist on the template.  
tempentitytagcustagentityuuid = Array(
		select entitytagcustagentityuuid
		from entity.crud_entitytag_read_min(tempentityinstanceownerentityuuid, null, null, tempentitytemplateuuid, null, false, null, null, null, templanguagetypeentityuuid));

-- validate, create, or skip the tag

if create_entityinstancetaguuid notnull
	and create_entityinstancetaguuid in ( select custagentityuuid 
								from entity.crud_custag_read_min(tempentityinstanceownerentityuuid,null,null, null, true,null,null, null,templanguagetypeentityuuid) )
	then tempentitytagcustagentityuuid = tempentitytagcustagentityuuid||create_entityinstancetaguuid; 
end if;

If array_length(tempentitytagcustagentityuuid, 1) = 0 and (create_entityinstancetag notNull and coalesce(create_entityinstancetag, '')<>'')
	then call entity.crud_custag_create(
		tempentityinstanceownerentityuuid, 
		null, 
		null, 
		null, 
		create_entityinstancetag, 
		templanguagetypeentityuuid, 
		null, 
		null, 
		null, 
		null, 		
		tempcustagid, 
		tempcustaguuid, 
		tempcustagentityuuid, 	
		null);
end if;

-- create cornerstone order

if create_entityinstancecornerstoneorder is Null
	then tempcornerstoneorder = 1::integer;
	else tempcornerstoneorder = create_entityinstancecornerstoneorder::integer;
end if;

If create_entityinstancedeleted isNull
	then tempentityinstancedeleted = false;
	else tempentityinstancedeleted = create_entityinstancedeleted;
end if;

If create_entityinstancedraft isNull
	then tempentityinstancedraft = false;
	else tempentityinstancedraft = create_entityinstancedraft;
end if;

-- insert name into languagemaster
	insert into public.languagemaster
		(languagemastercustomerid,
		languagemastersourcelanguagetypeid,
		languagemastersource,
		languagemastermodifiedby)
	values(tempcustomerid,
		templanguagetypeid, 	
		create_entityinstancename,    
		create_modifiedbyid)
	Returning languagemasteruuid into templanguagemasteruuid;

-- now let's create the instance entity 

	INSERT INTO entity.entityinstance(
		entityinstanceoriginalid, 
		entityinstanceoriginaluuid, 
		entityinstanceownerentityuuid, 
		entityinstanceentitytemplateentityuuid, 
		entityinstancetypeentityuuid,   -- this is the entity systag
		entityinstanceentitytemplatename, 		
		entityinstancesiteentityuuid, 
		entityinstanceparententityuuid, 
		entityinstancecornerstoneentityuuid, 
		entityinstancecornerstoneorder, 
		entityinstancescanid, 
		entityinstancetype, -- this is the name of the instance in the smae way we do custag/systag
		entityinstancenameuuid,
		entityinstancedeleted, 
		entityinstancedraft, 
		entityinstanceexternalid, 		
		entityinstanceexternalsystemuuid, -- deprecate???
		entityinstanceexternalsystementityuuid, 
		entityinstancerefid, 
		entityinstancerefuuid,		
		entityinstancecreateddate, 
		entityinstancemodifieddate, 
		entityinstancestartdate, 
		entityinstanceenddate, 
		entityinstancemodifiedbyuuid)
values(
		null,
		null,
		tempentityinstanceownerentityuuid,
		tempentitytemplateuuid,
		tempentitytemplatetypeentityuuid,   
		tempentitytemplatetype,
		null,
		create_entityinstanceparententityuuid,  -- insert the parent id sent in.  If null fix it later with self.  
		create_entityinstanceecornerstoneentityuuid,  -- insert the cornerstone id sent in.  If null fix it later with self.
		tempcornerstoneorder,	
		create_entityinstancename, 
		create_entityinstancename,
		templanguagemasteruuid,
		tempentityinstancedeleted, 
		tempentityinstancedraft, 
		create_entityinstanceexternalid, 		
		null, -- deprecate???
		create_entityinstanceexternalsystemuuid, 
		null,
		null,
		now(),
		now(),
		now(),
		null,
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
	)
	Returning entityinstanceuuid into tempentityinstanceuuid;

	update entity.entityinstance
	set entityinstanceparententityuuid = tempentityinstanceuuid
	where entityinstanceparententityuuid isNull
		and entityinstanceuuid = tempentityinstanceuuid;

	update entity.entityinstance
	set entityinstancecornerstoneentityuuid = tempentityinstanceuuid
	where entityinstancecornerstoneentityuuid isNull
		and entityinstanceuuid = tempentityinstanceuuid;

	-- insert tags

if tempcustagentityuuid notNull
	then call entity.crud_entitytag_create(
			tempentityinstanceownerentityuuid, -- IN create_entitytagownerentityuuid uuid,
			tempentityinstanceuuid, -- IN create_entitytagentityinstanceuuid uuid,
			tempentitytemplateuuid, -- IN create_entitytagentitytemplateuuid uuid,	
			tempcustagentityuuid, -- IN create_entitytagcustaguuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null, -- create_entitytagdraft 
			null, -- create_entitytagdeleted
			tempentitytaguuid, -- OUT create_entitytaguuid uuid,
			337::bigint);
end if;

if array_length(tempentitytagcustagentityuuid, 1) > 0
	then 
		FOREACH tempcustagentityuuid IN ARRAY tempentitytagcustagentityuuid
			LOOP 
				call entity.crud_entitytag_create(
					tempentityinstanceownerentityuuid, -- IN create_entitytagownerentityuuid uuid,
					tempentityinstanceuuid, -- IN create_entitytagentityinstanceuuid uuid,
					tempentitytemplateuuid, -- IN create_entitytagentitytemplateuuid uuid,	
					tempcustagentityuuid, -- IN create_entitytagcustaguuid uuid,
					null, -- IN create_languagetypeuuid uuid,
					null, -- create_entitytagdraft
					null, -- create_entitytagdeleted
					tempentitytaguuid, -- OUT create_entitytaguuid uuid,
					337::bigint);
			END LOOP;
end if;

create_entityinstanceentityuuid = tempentityinstanceuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entityinstance_create(uuid,uuid,text,uuid,uuid,integer,uuid,text,text,text,uuid,text,uuid,boolean,boolean,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityinstance_create(uuid,uuid,text,uuid,uuid,integer,uuid,text,text,text,uuid,text,uuid,boolean,boolean,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityinstance_create(uuid,uuid,text,uuid,uuid,integer,uuid,text,text,text,uuid,text,uuid,boolean,boolean,uuid,bigint) TO tendreladmin WITH GRANT OPTION;
