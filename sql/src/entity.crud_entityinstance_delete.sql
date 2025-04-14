
-- Type: PROCEDURE ; Name: entity.crud_entityinstance_delete(uuid,uuid,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entityinstance_delete(IN create_entityinstanceownerentityuuid uuid, IN create_entityinstanceentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	
Begin

/*

-- tests needed
	-- create a template/instnace to work with
		call entity.crud_entityinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			'newtemplate'||now()::text, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||now()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			null, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			337)



	-- no owner isNull
		call entity.crud_entityinstance_delete(
			null, -- IN create_entityinstanceownerentityuuid uuid,
			'7a1c4a83-1364-4b3b-b78a-4d719ca4bebe', -- IN create_entityinstanceentityuuid uuid,	
			337)

	-- no field entity isNull
		call entity.crud_entityinstance_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_entityinstance_delete(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityinstanceownerentityuuid uuid,
			'7a1c4a83-1364-4b3b-b78a-4d719ca4bebe', -- IN create_entityinstanceentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_entityinstance_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityinstanceownerentityuuid uuid,
			'7a1c4a83-1364-4b3b-b78a-4d719ca4bebe', -- IN create_entityinstanceentityuuid uuid,	
			337)

	-- reset the data
		update entity.entityinstance
		set entityinstancedeleted = false
		where entityinstanceuuid = '7a1c4a83-1364-4b3b-b78a-4d719ca4bebe'

-- use this to find fields to work with
select  * from  entity.entityinstance order by entityinstancecreateddate desc limit 100

-- how to check if the update was successful
select * from entity.entityinstance where entityinstancedeleted = true

*/

-- check for owner 

if create_entityinstanceownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for field

if create_entityinstanceentityuuid isNull
	then return;   -- need an error code here
end if;

-- update the field record to deleted

update entity.entityinstance
set entityinstancedeleted = true,
	entityinstancemodifieddate = now(),
	entityinstancemodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
where entityinstanceownerentityuuid = create_entityinstanceownerentityuuid
	and entityinstanceuuid = create_entityinstanceentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entityinstance_delete(uuid,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityinstance_delete(uuid,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityinstance_delete(uuid,uuid,bigint) TO tendreladmin WITH GRANT OPTION;
