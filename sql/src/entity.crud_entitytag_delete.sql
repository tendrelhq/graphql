
-- Type: PROCEDURE ; Name: entity.crud_entitytag_delete(uuid,uuid,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entitytag_delete(IN create_entitytagownerentityuuid uuid, IN create_entitytagentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempentitytagentitytemplateuuid uuid;
	tempentitytaguuid uuid;
Begin

/*

-- tests needed
	-- no owner isNull
		call entity.crud_entitytag_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entitytagownerentityuuid uuid,
			null, -- IN create_entitytagentityuuid uuid,
			337)

	-- no field entity isNull
		call entity.crud_entitytag_delete(
			null, -- IN create_entitytagownerentityuuid uuid,
			'ff36e534-fbc3-44ea-80a4-1a149cf86753', -- IN create_entitytagentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_entitytag_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entitytagownerentityuuid uuid,
			'ff36e534-fbc3-44ea-80a4-1a149cf86753', -- IN create_entitytagentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_entitytag_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entitytagownerentityuuid uuid,
			'ff36e534-fbc3-44ea-80a4-1a149cf86753', -- IN create_entitytagentityuuid uuid,	
			337)

	-- 	update entity.entitytag
		set entitytagdeleted = false
		where entitytaguuid = 'ff36e534-fbc3-44ea-80a4-1a149cf86753'	

-- use this to find fields to work with
select * from  entity.entitytag where entitytagownerentityuuid = '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'

-- how to check if the update was successful
select * from entity.entitytag where entitytagdeleted = true

*/

-- check for owner 

if create_entitytagownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for field

if create_entitytagentityuuid isNull
	then return;   -- need an error code here
end if;

-- update the field record to deleted

update entity.entitytag
set entitytagdeleted = true,
	entitytagmodifieddate = now(),
	entitytagenddate = now(),
	entitytagmodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
where entitytagownerentityuuid = create_entitytagownerentityuuid
	and entitytaguuid = create_entitytagentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entitytag_delete(uuid,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytag_delete(uuid,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytag_delete(uuid,uuid,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytag_delete(uuid,uuid,bigint) TO graphql;
