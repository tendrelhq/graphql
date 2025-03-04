CREATE OR REPLACE PROCEDURE entity.crud_entityfieldinstance_delete(
  IN create_entityfieldinstanceownerentityuuid uuid,
  IN create_entityfieldinstanceentityuuid uuid,
  IN create_modifiedbyid bigint
)
 LANGUAGE plpgsql
AS $procedure$
Declare
	
Begin

/*

-- tests needed
	-- no owner isNull
		call entity.crud_entityfieldinstance_delete(
			null, -- IN create_entityinstanceownerentityuuid uuid,
			'aff040ac-3b27-4da0-91ce-3e81f88e9dec', -- IN create_entityfieldinstanceentityuuid uuid,	
			337)

	-- no field entity isNull
		call entity.crud_entityfieldinstance_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_entityfieldinstance_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldinstanceownerentityuuid uuid,
			'3c04bedf-bcd8-40de-ae35-3a650146f7d7', -- IN create_entityfieldinstanceentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_entityfieldinstance_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldinstanceownerentityuuid uuid,
			'aff040ac-3b27-4da0-91ce-3e81f88e9dec', -- IN create_entityfieldinstanceentityuuid uuid,	
			337)

-- use this to find fields to work with
select  * from  entity.entityfieldinstance order by entityfieldinstancecreateddate desc limit 100

-- how to check if the update was successful
select * from entity.entityfieldinstance where entityfieldinstancedeleted = true

*/

-- check for owner 

if create_entityfieldinstanceownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for field

if create_entityfieldinstanceentityuuid isNull
	then return;   -- need an error code here
end if;

-- update the field record to deleted

update entity.entityfieldinstance
set entityfieldinstancedeleted = true,
	entityfieldinstancemodifieddate = now(),
	entityfieldinstancemodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
where entityfieldinstanceownerentityuuid = create_entityfieldinstanceownerentityuuid
	and entityfieldinstanceuuid = create_entityfieldinstanceentityuuid;

End;

$procedure$
