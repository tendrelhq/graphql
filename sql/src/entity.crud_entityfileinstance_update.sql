
-- Type: PROCEDURE ; Name: entity.crud_entityfileinstance_update(uuid,uuid,uuid,uuid,text,uuid,boolean,boolean,text,uuid); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entityfileinstance_update(IN update_entityfileinstanceentityuuid uuid, IN update_entityfileinstanceownerentityuuid uuid, IN update_entityfileinstanceentityentityinstanceentityuuid uuid, IN update_entityfileinstanceentityfieldinstanceentityuuid uuid, IN update_entityfileinstancestoragelocation text, IN update_entityfileinstancemimetypeuuid uuid, IN update_entityfileinstancedeleted boolean, IN update_entityfileinstancedraft boolean, IN update_entityfileinstancemodifiedbyuuid text, IN update_languagetypeuuid uuid)
 LANGUAGE plpgsql
AS $procedure$
Declare

Begin

-- Once created, the only things that can change after something is publsihed are ???

/*
-- Add testing here

*/

-- remove this once language issues are passed through

if update_languagetypeuuid isNull
	then update_languagetypeuuid = (select systaguuid from systag where systagid = 20);
End if;




 if update_entityfileinstancedraft = true or ((select entityfileinstancedraft 
										from entity.entityfileinstance
										WHERE entityfileinstanceuuid = update_entityfileinstanceentityuuid ) = true)
	then -- let everything change
		UPDATE entity.entityfileinstance
			SET entityfileinstancestoragelocation = case when update_entityfileinstancestoragelocation notnull 
														then update_entityfileinstancestoragelocation
														else entityfileinstancestoragelocation end,
				entityfileinstancemimetypeuuid = case when update_entityfileinstancemimetypeuuid notnull 
														then update_entityfileinstancemimetypeuuid
														else entityfileinstancemimetypeuuid end,
				entityfileinstancedeleted = case when update_entityfileinstancedeleted notnull 
										then update_entityfileinstancedeleted
										else entityfileinstancedeleted end, 
				entityfileinstancedraft = case when update_entityfileinstancedraft notnull 
										then update_entityfileinstancedraft
										else entityfileinstancedraft end,	
				entityfileinstancemodifieddate=now(),
				entityfileinstancemodifiedby = update_entityfileinstancemodifiedbyuuid
		WHERE entityfileinstanceuuid = update_entityfileinstanceentityuuid;
	Else -- trim the update to fields allowed to change
		UPDATE entity.entityfileinstance
			SET entityfileinstancestoragelocation = case when update_entityfileinstancestoragelocation notnull 
														then update_entityfileinstancestoragelocation
														else entityfileinstancestoragelocation end,
				entityfileinstancemimetypeuuid = case when update_entityfileinstancemimetypeuuid notnull 
														then update_entityfileinstancemimetypeuuid
														else entityfileinstancemimetypeuuid end,
				entityfileinstancemodifieddate=now(),
				entityfileinstancemodifiedby = update_entityfileinstancemodifiedbyuuid
		WHERE entityfileinstanceuuid = update_entityfileinstanceentityuuid;
end if;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entityfileinstance_update(uuid,uuid,uuid,uuid,text,uuid,boolean,boolean,text,uuid) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfileinstance_update(uuid,uuid,uuid,uuid,text,uuid,boolean,boolean,text,uuid) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfileinstance_update(uuid,uuid,uuid,uuid,text,uuid,boolean,boolean,text,uuid) TO tendreladmin WITH GRANT OPTION;
