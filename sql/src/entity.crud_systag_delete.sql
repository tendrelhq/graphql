
-- Type: PROCEDURE ; Name: entity.crud_systag_delete(uuid,uuid,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_systag_delete(IN create_systagownerentityuuid uuid, IN create_systagentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	
Begin

/*

-- tests needed
	-- no owner isNull
		call entity.crud_systag_delete(
			null, -- IN create_systagownerentityuuid uuid,
			'e1ef97cc-6d08-4855-9d57-834ed3c6e467', -- IN create_systagentityuuid uuid,	
			337)

	-- no field entity isNull
		call entity.crud_systag_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_systagownerentityuuid uuid,
			null, -- IN create_systagentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_systag_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_systagownerentityuuid uuid,
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_systagentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_systag_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_systagownerentityuuid uuid,
			'e1ef97cc-6d08-4855-9d57-834ed3c6e467', -- IN create_systagentityuuid uuid,	
			337)
			
	-- reset the cutag
		update entity.entityinstance
		set entityinstancedeleted = false
		where entityinstanceuuid = 'e1ef97cc-6d08-4855-9d57-834ed3c6e467'

-- use this to find fields to work with
select * from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- how to check if the update was successful
select * from entity.entityinstance where entityinstancedeleted = true

*/

-- check for owner 

if create_systagownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for field

if create_systagentityuuid isNull
	then return;   -- need an error code here
end if;

-- update the field record to deleted

update entity.entityinstance
set entityinstancedeleted = true,
	entityinstancemodifieddate = now(),
	entityinstancemodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
where entityinstanceownerentityuuid = create_systagownerentityuuid
	and entityinstanceuuid = create_systagentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_systag_delete(uuid,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_systag_delete(uuid,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_systag_delete(uuid,uuid,bigint) TO tendreladmin WITH GRANT OPTION;
