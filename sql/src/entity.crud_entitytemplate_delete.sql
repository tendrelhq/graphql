
-- Type: PROCEDURE ; Name: entity.crud_entitytemplate_delete(uuid,uuid,bigint); Owner: bombadil

CREATE OR REPLACE PROCEDURE entity.crud_entitytemplate_delete(IN create_entitytemplateownerentityuuid uuid, IN create_entitytemplateentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	
Begin

/*

-- tests needed
	-- Need a test template
		call entity.crud_entitytemplate_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0',  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
			null,  -- merged site and parent.  Set to self if no parent sent in.
			null,  -- default is 1.
			null, -- Used to be only locations had a location category.
			null,  -- If a tag is sent in that does not exist then we create one at the template level.
			'entitytemplate'||now()::text,  -- Name of the template 
			true, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
			'scanid'||now()::text, -- create_entitytemplatescanid text,  
			null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
			null, -- create_entitytemplateexternalid text,
			null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
			null,-- create_entitytemplatedeleted boolean,
			null,-- create_entitytemplatedraft boolean,
			null, -- create_entitytemplateentityuuid uuid,
			337::bigint) 

	-- no owner isNull
		call entity.crud_entitytemplate_delete(
			null, -- IN create_entitytemplateownerentityuuid uuid,
			'957df2f9-051f-4af5-95ee-ea3760fbb83b', -- IN create_entitytemplateentityuuid uuid,	
			337)

	-- no field entity isNull
		call entity.crud_entitytemplate_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entitytemplateownerentityuuid uuid,
			null, -- IN create_entitytemplateentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_entitytemplate_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entitytemplateownerentityuuid uuid,
			'957df2f9-051f-4af5-95ee-ea3760fbb83b', -- IN create_entitytemplateentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_entitytemplate_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entitytemplateownerentityuuid uuid,
			'6b8e5e73-3791-4c4f-9fe5-20b1327615b6', -- IN create_entitytemplateentityuuid uuid,	
			337)

	-- reset the cutag
		update entity.entitytemplate
		set entitytemplatedeleted = false
		where entitytemplateuuid = '6b8e5e73-3791-4c4f-9fe5-20b1327615b6'

select entitytemplatedeleted, * from entity.entitytemplate

-- use this to find fields to work with
select entitytemplatename, * 
from  entity.entitytemplate 
where entitytemplateownerentityuuid = '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'

-- how to check if the update was successful
select * from entity.entitytemplate where entitytemplatedeleted = true

*/

-- check for owner 

if (create_entitytemplateownerentityuuid isNull or coalesce(create_entitytemplateownerentityuuid::text, '')='')
	then 
		return;   -- need an error code here
end if;

-- check for template

if (create_entitytemplateentityuuid isNull or coalesce(create_entitytemplateentityuuid::text, '')='')
	then return;   -- need an error code here
end if;

-- update the template record to deleted

update entity.entitytemplate
set entitytemplatedeleted = true,
	entitytemplatemodifieddate = now(),
	entitytemplatemodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
where entitytemplateownerentityuuid = create_entitytemplateownerentityuuid
	and entitytemplateuuid = create_entitytemplateentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entitytemplate_delete(uuid,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytemplate_delete(uuid,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytemplate_delete(uuid,uuid,bigint) TO bombadil WITH GRANT OPTION;
