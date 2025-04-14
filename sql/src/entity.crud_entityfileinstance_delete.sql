
-- Type: PROCEDURE ; Name: entity.crud_entityfileinstance_delete(uuid,uuid,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entityfileinstance_delete(IN create_entityfileinstanceownerentityuuid uuid, IN create_entityfileinstanceentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	
Begin

/*

-- tests needed
	-- no owner isNull
		call entity.crud_entityfileinstance_delete(
			null, -- IN create_entityfileinstanceownerentityuuid uuid,
			'f6aad9bf-d98d-43c6-8a2c-e3c076f4089d', -- IN create_entityfileinstanceentityuuid uuid,	
			337)

	-- no field entity isNull
		call entity.crud_entityfileinstance_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfileinstanceownerentityuuid uuid,
			null, -- IN create_entityfileinstanceentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_entityfileinstance_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfileinstanceownerentityuuid uuid,
			'f6aad9bf-d98d-43c6-8a2c-e3c076f4089d', -- IN create_entityfileinstanceentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_entityfileinstance_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfileinstanceownerentityuuid uuid,
			'f6aad9bf-d98d-43c6-8a2c-e3c076f4089d', -- IN create_entityfileinstanceentityuuid uuid,	
			337)

-- how to check if the update was successful
select * from entity.entityfileinstance where entityfileinstancedeleted = true

*/

-- check for owner 

if create_entityfileinstanceownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for file instance

if create_entityfileinstanceentityuuid isNull
	then return;   -- need an error code here
end if;

-- update the file instance record to deleted

update entity.entityfileinstance
set entityfileinstancedeleted = true,
	entityfileinstancemodifieddate = now(),
	entityfileinstancemodifiedby = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
where entityfileinstanceownerentityuuid = create_entityfileinstanceownerentityuuid
	and entityfileinstanceuuid = create_entityfileinstanceentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entityfileinstance_delete(uuid,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfileinstance_delete(uuid,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfileinstance_delete(uuid,uuid,bigint) TO tendreladmin WITH GRANT OPTION;
