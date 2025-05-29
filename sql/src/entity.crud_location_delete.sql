BEGIN;

/*
DROP PROCEDURE entity.crud_location_delete(uuid,uuid,bigint);
*/


-- Type: PROCEDURE ; Name: entity.crud_location_delete(uuid,uuid,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_location_delete(IN create_locationownerentityuuid uuid, IN create_locationentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	
Begin

/*

FUTURE:  Just have this call entity.crud_entityinstance_delete(create_entityinstanceownerentityuuid, create_entityinstanceentityuuid, create_modifiedbyid)

-- tests needed
	-- no owner isNull
		call entity.crud_location_delete(
			null, -- IN create_locationownerentityuuid uuid,
			'47fa1d8d-eba5-40b8-8caa-13d5d59fd636', -- IN create_locationentityuuid uuid,	
			337)

	-- no field entity isNull
		call entity.crud_location_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_locationownerentityuuid uuid,
			null, -- IN create_locationentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_location_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_locationownerentityuuid uuid,
			'3c04bedf-bcd8-40de-ae35-3a650146f7d7', -- IN create_locationentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_location_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_locationownerentityuuid uuid,
			'47fa1d8d-eba5-40b8-8caa-13d5d59fd636', -- IN create_locationentityuuid uuid,	
			337)



	-- reset the location
		update entity.entityinstance
		set entityinstancedeleted = false
		where entityinstanceuuid = '47fa1d8d-eba5-40b8-8caa-13d5d59fd636'

-- use this to find fields to work with
select * 
from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
where locationownerentityuuid = '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'

-- how to check if the update was successful
select * from entity.entityinstance where entityinstancedeleted = true

*/

-- check for owner 

if create_locationownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for field

if create_locationentityuuid isNull
	then return;   -- need an error code here
end if;

-- update the field record to deleted

update entity.entityinstance
set entityinstancedeleted = true,
	entityinstancemodifieddate = now(),
	entityinstancemodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
where entityinstanceownerentityuuid = create_locationownerentityuuid
	and entityinstanceuuid = create_locationentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_location_delete(uuid,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_location_delete(uuid,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_location_delete(uuid,uuid,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_location_delete(uuid,uuid,bigint) TO graphql;

END;
