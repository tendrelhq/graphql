
-- Type: PROCEDURE ; Name: entity.crud_entityfield_delete(uuid,uuid,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entityfield_delete(IN create_entityfieldownerentityuuid uuid, IN create_entityfieldentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

Begin

/*

-- tests needed
	-- no owner isNull
		call entity.crud_entityfield_delete(
			null, -- IN create_entityfieldownerentityuuid uuid,
			'c77db174-7b16-4f47-b138-b56766375449', -- IN create_entityfieldentityuuid uuid,	
			337)

	-- no field entity isNull
		call entity.crud_entityfield_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfieldownerentityuuid uuid,
			null, -- IN create_entityfieldentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_entityfield_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfieldownerentityuuid uuid,
			'c77db174-7b16-4f47-b138-b56766375449', -- IN create_entityfieldentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_entityfield_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldownerentityuuid uuid,
			'c77db174-7b16-4f47-b138-b56766375449', -- IN create_entityfieldentityuuid uuid,	
			337)

	-- reset the field
		update entity.entityinstance
		set entityinstancedeleted = false
		where entityinstanceuuid = 'c77db174-7b16-4f47-b138-b56766375449'

-- use this to find fields to work with
select entityfieldname, * from  entity.entityfield order by entityfieldcreateddate desc

-- how to check if the update was successful
select * from entity.entityfield where entityfielddeleted = true

*/

-- check for owner 

if create_entityfieldownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for field

if create_entityfieldentityuuid isNull
	then return;   -- need an error code here
end if;

-- update the field record to deleted

update entity.entityfield
set entityfielddeleted = true,
	entityfieldmodifieddate = now(),
	entityfieldmodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
where entityfieldownerentityuuid = create_entityfieldownerentityuuid
	and entityfielduuid = create_entityfieldentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entityfield_delete(uuid,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfield_delete(uuid,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfield_delete(uuid,uuid,bigint) TO tendreladmin WITH GRANT OPTION;
