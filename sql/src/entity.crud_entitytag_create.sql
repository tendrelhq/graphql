
-- Type: PROCEDURE ; Name: entity.crud_entitytag_create(uuid,uuid,uuid,uuid,uuid,boolean,boolean,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entitytag_create(IN create_entitytagownerentityuuid uuid, IN create_entitytagentityinstanceuuid uuid, IN create_entitytagentitytemplateuuid uuid, IN create_entitytagcustaguuid uuid, IN create_languagetypeuuid uuid, IN create_entitytagdeleted boolean, IN create_entitytagdraft boolean, OUT create_entitytaguuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempentitytagentitytemplateuuid uuid;
	tempentitytaguuid uuid;
	tempentitytagdeleted boolean;
	tempentitytagdraft boolean; 
Begin

/*
-- Customer for testing -- '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'
select * 
from  entity.entitytag 
where entitytagownerentityuuid = '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'

-- tests 
	-- create a tag to work with.  - Parent
		call entity.crud_custag_create(
				'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --create_custagownerentityuuid
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
		
	-- child we will use
	
		call entity.crud_custag_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --create_custagownerentityuuid
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

-- create entity tag for template and instance - correct template
	call entity.crud_entitytag_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entitytagownerentityuuid uuid,
		'f7dbd1a0-bf4b-434d-9c13-73e0038230b7', -- IN create_entitytagentityinstanceuuid uuid,
		'0b9f3142-e7ed-4f78-8504-ccd2eb505075', -- IN create_entitytagentitytemplateuuid uuid,	
		'ffb11912-cde2-46a1-ad07-bd03c4805097', -- IN create_entitytagcustaguuid uuid,
		null,
		null,
		null, -- IN create_languagetypeuuid uuid,
		null, -- OUT create_entitytaguuid uuid,
		337::bigint)

	-- create entity tag for template and instance - incorrect template overridden
	call entity.crud_entitytag_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entitytagownerentityuuid uuid,
		'f7dbd1a0-bf4b-434d-9c13-73e0038230b7', -- IN create_entitytagentityinstanceuuid uuid,
		'b124da10-be8a-4d32-9f68-7f4e6e8b24e9', -- IN create_entitytagentitytemplateuuid uuid,	
		'461ca421-8651-4c9d-9591-af3bd859459c', -- IN create_entitytagcustaguuid uuid,
		null,
		null,
		null, -- IN create_languagetypeuuid uuid,
		null, -- OUT create_entitytaguuid uuid,
		337::bigint)
		
	-- create entit tag for template
	call entity.crud_entitytag_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entitytagownerentityuuid uuid,
		null, -- IN create_entitytagentityinstanceuuid uuid,
		'b124da10-be8a-4d32-9f68-7f4e6e8b24e9', -- IN create_entitytagentitytemplateuuid uuid,	
		'461ca421-8651-4c9d-9591-af3bd859459c', -- IN create_entitytagcustaguuid uuid,
		null,
		null,
		null, -- IN create_languagetypeuuid uuid,
		null, -- OUT create_entitytaguuid uuid,
		337::bigint)
	
*/

-- FUTURE:
	-- Check Instance and Template are of the same entity type.
	-- Use generic Entity Instance Read
	-- block duplicates or allow?  
	-- check for nulls in template

-- override the template with the template type from the instance

if create_entitytagentityinstanceuuid notNull
	then tempentitytagentitytemplateuuid = (select entityinstanceentitytemplateentityuuid 
											from entity.entityinstance 
											where entityinstanceuuid = create_entitytagentityinstanceuuid);
		tempentitytaguuid = (select entitytaguuid 
							from entity.crud_entitytag_read_min(create_entitytagownerentityuuid,null,create_entitytagentityinstanceuuid,null, create_entitytagcustaguuid, false, null,null,null, create_languagetypeuuid));									
	else tempentitytaguuid = (select entitytaguuid 
							from entity.crud_entitytag_read_min(create_entitytagownerentityuuid, null, null, create_entitytagentitytemplateuuid, create_entitytagcustaguuid, false, null,null,null,create_languagetypeuuid));				
		tempentitytagentitytemplateuuid = create_entitytagentitytemplateuuid;
end if;

If create_entitytagdeleted isNull
	then tempentitytagdeleted = false;
	else tempentitytagdeleted = create_entitytagdeleted;
end if;

If create_entitytagdraft isNull
	then tempentitytagdraft = false;
	else tempentitytagdraft = create_entitytagdraft;
end if;

if  tempentitytaguuid isNull
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
			entitytagcustagentityuuid,
			entitytagdeleted,
			entitytagdraft
			)
		values (
			create_entitytagownerentityuuid,
			create_entitytagentityinstanceuuid ,
			tempentitytagentitytemplateuuid ,
			now(),
			now(),
			now(),
			null,
			(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
			create_entitytagcustaguuid,
			create_entitytagdeleted,
			create_entitytagdraft
		)
		Returning entitytaguuid into create_entitytaguuid;
	else create_entitytaguuid = tempentitytaguuid;
End if;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entitytag_create(uuid,uuid,uuid,uuid,uuid,boolean,boolean,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytag_create(uuid,uuid,uuid,uuid,uuid,boolean,boolean,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytag_create(uuid,uuid,uuid,uuid,uuid,boolean,boolean,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytag_create(uuid,uuid,uuid,uuid,uuid,boolean,boolean,bigint) TO graphql;
