
-- Type: PROCEDURE ; Name: entity.crud_entityfieldinstance_update(uuid,uuid,uuid,uuid,text,text,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entityfieldinstance_update(IN update_entityfieldinstanceentityuuid uuid, IN update_entityfieldinstanceownerentityuuid uuid, IN update_entityfieldinstanceentityinstanceentityuuid uuid, IN update_entityfieldinstanceentityfieldentityuuid uuid, IN update_entityfieldinstancevalue text, IN update_entityfieldinstanceentityfieldname text, IN update_entityfieldinstanceexternalid text, IN update_entityfieldinstanceexternalsystemuuid uuid, IN update_entityfieldinstancedeleted boolean, IN update_entityfieldinstancedraft boolean, IN update_entityfieldinstancestartdate timestamp with time zone, IN update_entityfieldinstanceenddate timestamp with time zone, IN update_entityfieldinstancemodifiedbyuuid text, IN update_languagetypeuuid uuid)
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

 if update_entityfieldinstancedraft = true or ((select entityfieldinstancedraft 
										from entity.entityfieldinstance
										WHERE entityfieldinstanceuuid = update_entityfieldinstanceentityuuid ) = true)
	then -- let everything change
		UPDATE entity.entityfieldinstance
			SET entityfieldinstancevalue = case when update_entityfieldinstancevalue notnull 
												then update_entityfieldinstancevalue
												else entityfieldinstancevalue end, 
				entityfieldinstancevaluelanguagetypeentityuuid = case when update_entityfieldinstancevalue notnull 
																		then update_languagetypeuuid
																		else entityfieldinstancevaluelanguagetypeentityuuid end,
				entityfieldinstancestartdate = case when update_entityfieldinstancestartdate notnull 
												then update_entityfieldinstancestartdate
												else entityfieldinstancestartdate end,
				entityfieldinstanceenddate = update_entityfieldinstanceenddate,
				entityfieldinstancedeleted = case when update_entityfieldinstancedeleted notnull 
										then update_entityfieldinstancedeleted
										else entityfieldinstancedeleted end, 
				entityfieldinstancedraft = case when update_entityfieldinstancedraft notnull 
										then update_entityfieldinstancedraft
										else entityfieldinstancedraft end,	
				entityfieldinstancemodifieddate=now(),
				entityfieldinstancemodifiedbyuuid = update_entityfieldinstancemodifiedbyuuid
		WHERE entityfieldinstanceuuid = update_entityfieldinstanceentityuuid;
	Else -- trim the update to fields allowed to change
		UPDATE entity.entityfieldinstance
			SET entityfieldinstancevalue = case when update_entityfieldinstancevalue notnull 
												then update_entityfieldinstancevalue
												else entityfieldinstancevalue end, 
				entityfieldinstancevaluelanguagetypeentityuuid = case when update_entityfieldinstancevalue notnull 
																		then update_languagetypeuuid
																		else entityfieldinstancevaluelanguagetypeentityuuid end,
				entityfieldinstancestartdate = case when update_entityfieldinstancestartdate notnull 
												then update_entityfieldinstancestartdate
												else entityfieldinstancestartdate end,
				entityfieldinstanceenddate = update_entityfieldinstanceenddate,
				entityfieldinstancedeleted = case when update_entityfieldinstancedeleted notnull 
										then update_entityfieldinstancedeleted
										else entityfieldinstancedeleted end, 
				entityfieldinstancedraft = case when update_entityfieldinstancedraft notnull 
										then update_entityfieldinstancedraft
										else entityfieldinstancedraft end,	
				entityfieldinstancemodifieddate=now(),
				entityfieldinstancemodifiedbyuuid = update_entityfieldinstancemodifiedbyuuid
		WHERE entityfieldinstanceuuid = update_entityfieldinstanceentityuuid;
end if;

if  update_entityfieldinstancevalue notNull and (coalesce(update_entityfieldinstancevalue,'') <> '')
	then
		-- update the languagemaster if the name changed
	
		update languagemaster
		set languagemastersource = update_entityfieldinstancevalue,
			languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid =update_entityfieldinstancemodifiedbyuuid),
			languagemastersourcelanguagetypeid = (select entityinstanceoriginalid from entity.entityinstance where entityfieldinstanceuuid = update_languagetypeuuid),
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'		
		from entity.entityfieldinstance
		where entityfieldinstanceuuid = update_entityfieldinstanceentityuuid
			and languagemasteruuid = entityfieldinstancevaluelanguagetypeentityuuid
			and languagemastersource <> update_entityfieldinstancevalue;

END IF;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entityfieldinstance_update(uuid,uuid,uuid,uuid,text,text,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfieldinstance_update(uuid,uuid,uuid,uuid,text,text,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfieldinstance_update(uuid,uuid,uuid,uuid,text,text,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) TO tendreladmin WITH GRANT OPTION;
