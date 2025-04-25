
-- Type: PROCEDURE ; Name: entity.crud_custag_delete(uuid,uuid,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_custag_delete(IN create_custagownerentityuuid uuid, IN create_custagentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	
Begin

/*

FUTURE:  Just have this call entity.crud_entityinstance_delete(create_entityinstanceownerentityuuid, create_entityinstanceentityuuid, create_modifiedbyid)

-- tests needed -  first 3 are fails.  No changes.  
	-- no owner isNull
		call entity.crud_custag_delete(
			null, -- IN create_custagownerentityuuid uuid,
			'807ba22f-b068-4116-b684-623a1cb0fc1d', -- IN create_custagentityuuid uuid,	
			337)

	-- no field entity isNull
		call entity.crud_custag_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_custagownerentityuuid uuid,
			null, -- IN create_custagentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_custag_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_custagownerentityuuid uuid,
			'3c04bedf-bcd8-40de-ae35-3a650146f7d7', -- IN create_custagentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_custag_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_custagownerentityuuid uuid,
			'277e5a92-04f6-4f53-abff-ed798c32658b', -- IN create_custagentityuuid uuid,	
			337)

	-- reset the cutag
		update entity.entityinstance
		set entityinstancedeleted = false
		where entityinstanceuuid = '277e5a92-04f6-4f53-abff-ed798c32658b'

-- use this to find fields to work with
select * 
from entity.crud_custag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
where custagownerentityuuid = '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'

-- how to check if the update was successful
select * from entity.entityinstance where entityinstancedeleted = true

*/

-- check for owner 

if create_custagownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for field

if create_custagentityuuid isNull
	then return;   -- need an error code here
end if;

-- update the field record to deleted

update entity.entityinstance
set entityinstancedeleted = true,
	entityinstancemodifieddate = now(),
	entityinstanceenddate = now(),
	entityinstancemodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
where entityinstanceownerentityuuid = create_custagownerentityuuid
	and entityinstanceuuid = create_custagentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_custag_delete(uuid,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_custag_delete(uuid,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_custag_delete(uuid,uuid,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_custag_delete(uuid,uuid,bigint) TO graphql;
