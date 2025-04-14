
-- Type: PROCEDURE ; Name: entity.crud_entitydescription_delete(uuid,uuid,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entitydescription_delete(IN create_entitydescriptionownerentityuuid uuid, IN create_entitydescriptionentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	
Begin

/*

-- tests needed

	-- may need to create some descriptions.
	
	-- no owner isNull
		call entity.crud_entitydescription_delete(
			null, -- IN create_entitytemplateownerentityuuid uuid,
			'4b04166f-4d91-4183-b0d4-e2072de41fc6', -- IN create_entitytemplateentityuuid uuid,	
			337)

	-- no field entity isNull
		call entity.crud_entitydescription_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entitytemplateownerentityuuid uuid,
			null, -- IN create_entitytemplateentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_entitydescription_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entitytemplateownerentityuuid uuid,
			'4b04166f-4d91-4183-b0d4-e2072de41fc6', -- IN create_entitytemplateentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_entitydescription_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entitytemplateownerentityuuid uuid,
			'4b04166f-4d91-4183-b0d4-e2072de41fc6', -- IN create_entitytemplateentityuuid uuid,	
			337)

	-- reset the field
		update entity.entitydescription
		set entitydescriptiondeleted = false
		where entitydescriptionuuid = '4b04166f-4d91-4183-b0d4-e2072de41fc6'	

-- use this to find fields to work with
select entitytemplatename, * from  entity.entitytemplate order by entitytemplatecreateddate desc

-- how to check if the update was successful
select * from entity.entitydescription where entitydescriptiondeleted = true

*/

-- check for owner 

if create_entitydescriptionownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for template

if create_entitydescriptionentityuuid isNull
	then return;   -- need an error code here
end if;

-- update the template record to deleted

update entity.entitydescription
set entitydescriptiondeleted = true,
	entitydescriptionmodifieddate = now(),
	entitydescriptionmodifiedby = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
where entitydescriptionownerentityuuid = create_entitydescriptionownerentityuuid
	and entitydescriptionuuid = create_entitydescriptionentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entitydescription_delete(uuid,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitydescription_delete(uuid,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitydescription_delete(uuid,uuid,bigint) TO tendreladmin WITH GRANT OPTION;
