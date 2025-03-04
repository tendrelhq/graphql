CREATE OR REPLACE PROCEDURE entity.crud_entitytemplate_delete(IN create_entitytemplateownerentityuuid uuid, IN create_entitytemplateentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	
Begin

/*

-- tests needed
	-- no owner isNull
		call entity.crud_entitytemplate_delete(
			null, -- IN create_entitytemplateownerentityuuid uuid,
			'3c04bedf-bcd8-40de-ae35-3a650146f7d7', -- IN create_entitytemplateentityuuid uuid,	
			337)

	-- no field entity isNull
		call entity.crud_entitytemplate_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entitytemplateownerentityuuid uuid,
			null, -- IN create_entitytemplateentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_entitytemplate_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entitytemplateownerentityuuid uuid,
			'3c04bedf-bcd8-40de-ae35-3a650146f7d7', -- IN create_entitytemplateentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_entitytemplate_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entitytemplateownerentityuuid uuid,
			'3c04bedf-bcd8-40de-ae35-3a650146f7d7', -- IN create_entitytemplateentityuuid uuid,	
			337)

-- use this to find fields to work with
select entitytemplatename, * from  entity.entitytemplate order by entitytemplatecreateddate desc

-- how to check if the update was successful
select * from entity.entitytemplate where entitytemplatedeleted = true

*/

-- check for owner 

if create_entitytemplateownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for template

if create_entitytemplateentityuuid isNull
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

$procedure$
