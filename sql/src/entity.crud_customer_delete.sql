
-- Type: PROCEDURE ; Name: entity.crud_customer_delete(uuid,uuid,bigint); Owner: bombadil

CREATE OR REPLACE PROCEDURE entity.crud_customer_delete(IN create_customerownerentityuuid uuid, IN create_customerentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	
Begin

/*

FUTURE:  Just have this call entity.crud_entityinstance_delete(create_entityinstanceownerentityuuid, create_entityinstanceentityuuid, create_modifiedbyid)

-- tests needed
	-- no owner isNull
		call entity.crud_customer_delete(
			null, -- IN create_customerownerentityuuid uuid,
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_customerentityuuid uuid,	
			337)

	-- no field entity isNull
		call entity.crud_customer_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_customerownerentityuuid uuid,
			null, -- IN create_customerentityuuid uuid,	
			337)

	-- owner and field combo do not exist
		call entity.crud_customer_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_customerownerentityuuid uuid,
			'39709647-4012-4a49-977c-45286e565419', -- IN create_customerentityuuid uuid,	
			337)		
			
	-- valid owner and field
		call entity.crud_customer_delete(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_customerownerentityuuid uuid,
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_customerentityuuid uuid,	
			337)

	-- reset the customer
		update entity.entityinstance
		set entityinstancedeleted = false
		where entityinstanceuuid = '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'

-- use this to find customers to work with
select * 
from entity.crud_customer_read_full(null,null, null, true, null,null, null,null)
order by customerid asc

-- how to check if the update was successful
select * from entity.entityinstance where entityinstancedeleted = true

*/

-- check for owner 

if create_customerownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for field

if create_customerentityuuid isNull
	then return;   -- need an error code here
end if;

-- update the field record to deleted

update entity.entityinstance
set entityinstancedeleted = true,
	entityinstancemodifieddate = now(),
	entityinstancemodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid)
where entityinstanceownerentityuuid = create_customerownerentityuuid
	and entityinstanceuuid = create_customerentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_customer_delete(uuid,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customer_delete(uuid,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customer_delete(uuid,uuid,bigint) TO bombadil WITH GRANT OPTION;
