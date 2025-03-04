CREATE OR REPLACE PROCEDURE entity.crud_entityfieldinstance_create(
  IN create_entityfieldinstanceownerentityuuid uuid,
  IN create_entityfieldinstanceentityinstanceentityuuid uuid,
  IN create_entityfieldinstanceentityfieldentityuuid uuid,
  IN create_entityfieldinstancevalue text,
  IN create_entityfieldinstanceentityfieldname text,
  IN create_entityfieldformatentityuuid uuid,
  IN create_entityfieldformatentityname text,
  IN create_entityfieldwidgetentityuuid uuid,
  IN create_entityfieldwidgetentityname text,
  IN create_entityfieldinstanceexternalid text,
  IN create_entityfieldinstanceexternalsystemuuid uuid,
  IN create_entityfieldinstancedeleted boolean,
  IN create_entityfieldinstancedraft boolean,
  OUT create_entityfieldinstanceentityuuid uuid,
  IN create_languagetypeuuid uuid,
  IN create_modifiedbyid bigint
)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tendreluuid uuid;
	tempentityfieldinstanceownerentityuuid uuid;
	tempentityfieldinstanceentityinstanceentityuuid uuid;
	tempentityfieldinstanceentityfieldentityuuid uuid;
	tempcustagid bigint;
	tempcustaguuid text;
	tempentityinstanceownerentityuuid uuid;
	tempentityinstanceentitytemplateentityuuid uuid;
	tempentityfieldinstanceentitytemplateentityuuid uuid;
	templanguagetypeentityuuid uuid;
	tempentityfieldinstanceentityuuid uuid;  -- return value
	tempentityinstancedeleted boolean;
	tempentityinstancedraft boolean;
	tempentityfieldinstanceentityfieldname text;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
 	templanguagemasteruuid text;
	tempcustomerid bigint;
	tempcustomeruuid text;	
	tempentityinstanceuuid uuid;

Begin

/*  Future New
-- Lazy init version
-- create_entityfieldinstancevalue validated?
-- Languagemaster create to be smarter than it is.  Maybe even a function.  (Should only do language master on strings)
-- Validate externalsystem
-- externalsystemuuid vs externalsystementityuuid - one is a systag, but we are not handling this well.  Keep both?  
-- Duplicate checking of field instance creation.

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

	-- success - valid entityinstanceownerentityuuid valid instance name valid templateuuid with tags no cutags
	-- might need to create a to the template created above.  

		call entity.crud_custag_create('70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', null, null, null, 	'templatetag'||now()::text, 
						null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, null, null, null, null, 337);

		call entity.crud_entitytag_create(
				'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entitytagownerentityuuid uuid,
				null, -- IN create_entitytagentityinstanceuuid uuid,
				'3a86bda0-2c85-482f-ae84-4ca5e5e32f0d', -- IN create_entitytagentitytemplateuuid uuid,	
				'5ef190d1-2a73-48e5-a80f-d351065f6692', -- IN create_entitytagcustaguuid uuid,
				null,
				null,
				null, -- IN create_languagetypeuuid uuid,
				null, -- OUT create_entitytaguuid uuid,
				337::bigint)	
	
		call entity.crud_entityinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityinstanceownerentityuuid uuid,
			'3a86bda0-2c85-482f-ae84-4ca5e5e32f0d', -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			'8271230c-9d18-45e6-b37b-149746c63507', -- IN create_entityinstancetaguuid uuid,
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

/*
-- invalid customer/instance/field
call entity.crud_entityfieldinstance_create(
	'e62e67f3-9bd6-4be8-b379-e22d61b51c91', -- IN create_entityfieldinstanceownerentityuuid uuid,
	'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
	'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldinstanceentityfieldentityuuid uuid, 
	null, -- IN create_entityfieldinstancevalue text,
	null, -- IN create_entityfieldinstanceentityfieldname text,  -- needed for lazy init
	null, -- IN create_entityfieldformatentityuuid uuid, -- needed for lazy init
	null, -- IN create_entityfieldformatentityname text, -- needed for lazy init
	null, -- IN create_entityfieldwidgetentityuuid uuid, -- needed for lazy init
	null, -- IN create_entityfieldwidgetentityname text, -- needed for lazy init
	null, -- null, -- IN create_entityfieldinstanceexternalid text,
	null, -- IN create_entityfieldinstanceexternalsystemuuid uuid,
	null, -- IN create_entityfieldinstancedeleted boolean,
	null, -- IN create_entityfieldinstancedraft boolean,
	null, -- OUT create_entityfieldinstanceentityuuid uuid,
	null, -- IN create_languagetypeuuid uuid,
	337)

-- valid customer invalid instance/field
call entity.crud_entityfieldinstance_create(
	'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldinstanceownerentityuuid uuid,
	'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
	'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfieldinstanceentityfieldentityuuid uuid, 
	null, -- IN create_entityfieldinstancevalue text,
	null, -- IN create_entityfieldinstanceentityfieldname text,  -- needed for lazy init
	null, -- IN create_entityfieldformatentityuuid uuid, -- needed for lazy init
	null, -- IN create_entityfieldformatentityname text, -- needed for lazy init
	null, -- IN create_entityfieldwidgetentityuuid uuid, -- needed for lazy init
	null, -- IN create_entityfieldwidgetentityname text, -- needed for lazy init
	null, -- null, -- IN create_entityfieldinstanceexternalid text,
	null, -- IN create_entityfieldinstanceexternalsystemuuid uuid,
	null, -- IN create_entityfieldinstancedeleted boolean,
	null, -- IN create_entityfieldinstancedraft boolean,
	null, -- OUT create_entityfieldinstanceentityuuid uuid,
	null, -- IN create_languagetypeuuid uuid,
	337)

-- valid customer/instance invalid field
call entity.crud_entityfieldinstance_create(
	'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldinstanceownerentityuuid uuid,
	'277e5a92-04f6-4f53-abff-ed798c32658b', -- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
	'1b29e7b0-0800-4366-b79e-424dd9bafa71', -- IN create_entityfieldinstanceentityfieldentityuuid uuid, 
	null, -- IN create_entityfieldinstancevalue text,
	null, -- IN create_entityfieldinstanceentityfieldname text,  -- needed for lazy init
	null, -- IN create_entityfieldformatentityuuid uuid, -- needed for lazy init
	null, -- IN create_entityfieldformatentityname text, -- needed for lazy init
	null, -- IN create_entityfieldwidgetentityuuid uuid, -- needed for lazy init
	null, -- IN create_entityfieldwidgetentityname text, -- needed for lazy init
	null, -- null, -- IN create_entityfieldinstanceexternalid text,
	null, -- IN create_entityfieldinstanceexternalsystemuuid uuid,
	null, -- IN create_entityfieldinstancedeleted boolean,
	null, -- IN create_entityfieldinstancedraft boolean,
	null, -- OUT create_entityfieldinstanceentityuuid uuid,
	null, -- IN create_languagetypeuuid uuid,
	337)

-- valid customer/instance/field - value is null
call entity.crud_entityfieldinstance_create(
	'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldinstanceownerentityuuid uuid,
	'277e5a92-04f6-4f53-abff-ed798c32658b', -- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
	'7530f263-324e-4ca1-8c08-6b6d31ab2802', -- IN create_entityfieldinstanceentityfieldentityuuid uuid, 
	null, -- IN create_entityfieldinstancevalue text,
	null, -- IN create_entityfieldinstanceentityfieldname text,  -- needed for lazy init
	null, -- IN create_entityfieldformatentityuuid uuid, -- needed for lazy init
	null, -- IN create_entityfieldformatentityname text, -- needed for lazy init
	null, -- IN create_entityfieldwidgetentityuuid uuid, -- needed for lazy init
	null, -- IN create_entityfieldwidgetentityname text, -- needed for lazy init
	null, -- null, -- IN create_entityfieldinstanceexternalid text,
	null, -- IN create_entityfieldinstanceexternalsystemuuid uuid,
	null, -- IN create_entityfieldinstancedeleted boolean,
	null, -- IN create_entityfieldinstancedraft boolean,
	null, -- OUT create_entityfieldinstanceentityuuid uuid,
	null, -- IN create_languagetypeuuid uuid,
	337)

-- valid customer/instance/field - value is 'Test'
call entity.crud_entityfieldinstance_create(
	'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldinstanceownerentityuuid uuid,
	'277e5a92-04f6-4f53-abff-ed798c32658b', -- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
	'7530f263-324e-4ca1-8c08-6b6d31ab2802', -- IN create_entityfieldinstanceentityfieldentityuuid uuid, 
	'Test', -- IN create_entityfieldinstancevalue text,
	null, -- IN create_entityfieldinstanceentityfieldname text,  -- needed for lazy init
	null, -- IN create_entityfieldformatentityuuid uuid, -- needed for lazy init
	null, -- IN create_entityfieldformatentityname text, -- needed for lazy init
	null, -- IN create_entityfieldwidgetentityuuid uuid, -- needed for lazy init
	null, -- IN create_entityfieldwidgetentityname text, -- needed for lazy init
	null, -- null, -- IN create_entityfieldinstanceexternalid text,
	null, -- IN create_entityfieldinstanceexternalsystemuuid uuid,
	null, -- IN create_entityfieldinstancedeleted boolean,
	null, -- IN create_entityfieldinstancedraft boolean,
	null, -- OUT create_entityfieldinstanceentityuuid uuid,
	null, -- IN create_languagetypeuuid uuid,
	337)

*/

-- constanneeded when looking up entity templates and fields 
-- entity templatse and field are owned by the customer and tendrel
tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

-- validate mandatory fields  
-- might want to split this into 3 checks so each retun can be a unique error
if (create_entityfieldinstanceownerentityuuid isNull
		or create_entityfieldinstanceentityinstanceentityuuid isNull
		or create_entityfieldinstanceentityfieldentityuuid isNull)
	then return; -- need an error code  
	else tempentityfieldinstanceownerentityuuid = create_entityfieldinstanceownerentityuuid;
		tempentityfieldinstanceentityinstanceentityuuid = create_entityfieldinstanceentityinstanceentityuuid;
		tempentityfieldinstanceentityfieldentityuuid = create_entityfieldinstanceentityfieldentityuuid;
end if;

-- Return an error if the entity is not set to a customer.  
-- We need the customerid when dealing with languagemaster
select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,tempentityfieldinstanceownerentityuuid,null,false,null,null,null, null);

if tempcustomerid isNull
	then return; -- need an error code  
end if;

-- Is the instance valid and the owner the same as what was sent in 
select entityinstanceownerentityuuid, entityinstanceentitytemplateentityuuid 
into tempentityinstanceownerentityuuid, tempentityinstanceentitytemplateentityuuid
from entity.crud_entityinstance_read_min(tempentityfieldinstanceownerentityuuid, tempentityfieldinstanceentityinstanceentityuuid, null, null, null, null, false, null, null, null, null, null);

if tempentityinstanceownerentityuuid isNull or tempentityinstanceownerentityuuid <> tempentityfieldinstanceownerentityuuid	
	then return ; -- need an error code  
end if;

-- Is the field valid for the template 
-- FUTURE: handle lazy init here.  If fielduuid is null and field name is not null.

select entityfieldentitytemplateentityuuid, entityfieldname
into tempentityfieldinstanceentitytemplateentityuuid, tempentityfieldinstanceentityfieldname
from entity.crud_entityfield_read_min(tempentityfieldinstanceownerentityuuid,null,tempentityfieldinstanceentityfieldentityuuid,null, null, null,null);

-- check if this is a primary template
if tempentityfieldinstanceentitytemplateentityuuid isNull
	then  select entityfieldentitytemplateentityuuid, entityfieldname
			into tempentityfieldinstanceentitytemplateentityuuid, tempentityfieldinstanceentityfieldname
			from entity.crud_entityfield_read_min(tendreluuid,null,tempentityfieldinstanceentityfieldentityuuid,null, null, null,null);
end if;

if tempentityfieldinstanceentitytemplateentityuuid isnull 
	or tempentityfieldinstanceentitytemplateentityuuid <> tempentityinstanceentitytemplateentityuuid	
	then return; -- need an error code  
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

-- set default values

If create_entityfieldinstancedeleted isNull
	then tempentityinstancedeleted = false;
	else tempentityinstancedeleted = create_entityinstancedeleted;
end if;

If create_entityfieldinstancedraft isNull
	then tempentityinstancedraft = false;
	else tempentityinstancedraft = create_entityinstancedraft;
end if;

-- this needs to be smarter.  
-- Leverage the result type and the field to know if this is needed and is translatable.  
-- insert value into languagemaster

if create_entityfieldinstancevalue notNull
	then	insert into public.languagemaster
				(languagemastercustomerid,
				languagemastersourcelanguagetypeid,
				languagemastersource,
				languagemastermodifiedby)
			values(tempcustomerid,
				templanguagetypeid, 	
				create_entityfieldinstancevalue,    
				create_modifiedbyid)
			Returning languagemasteruuid into templanguagemasteruuid;
	else templanguagemasteruuid = null;
end if;

-- now let's create the field instance  

	INSERT INTO entity.entityfieldinstance(
		entityfieldinstanceentityinstanceentityuuid,  
		entityfieldinstanceownerentityuuid, 
		entityfieldinstancevalue,  
		entityfieldinstancevaluelanguagemasteruuid, 
		entityfieldinstancecreateddate,
		entityfieldinstancemodifieddate, 
		entityfieldinstancestartdate, 
		entityfieldinstancecompleteddate, 
		entityfieldinstanceentityfieldentityuuid, 
		entityfieldinstancemodifiedbyuuid, 
		entityfieldinstancerefid, 
		entityfieldinstancerefuuid, 
		entityfieldinstanceentityfieldname,  
		entityfieldinstancevaluelanguagetypeentityuuid, 
		entityfieldinstancedeleted, 
		entityfieldinstancedraft )
	values (
		tempentityfieldinstanceentityinstanceentityuuid,
		tempentityfieldinstanceownerentityuuid,  
		create_entityfieldinstancevalue,
		templanguagemasteruuid,
		now(),
		now(), 
		now(), 
		null, 
		tempentityfieldinstanceentityfieldentityuuid,
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		null,
		null,
		tempentityfieldinstanceentityfieldname,
		templanguagetypeentityuuid,
		tempentityinstancedeleted,
		tempentityinstancedraft
		) 	Returning entityfieldinstanceuuid into tempentityinstanceuuid;

create_entityfieldinstanceentityuuid = tempentityinstanceuuid;

End;

$procedure$
