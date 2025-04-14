
-- Type: PROCEDURE ; Name: entity.crud_entitytemplate_update(uuid,uuid,uuid,text,uuid,text,text,text,integer,boolean,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entitytemplate_update(IN update_entitytemplateuuid uuid, IN update_entitytemplateownerentityuuid uuid, IN update_entitytemplateparententityuuid uuid, IN update_entitytemplateexternalid text, IN update_entitytemplateexternalsystementityuuid uuid, IN update_entitytemplatescanid text, IN update_entitytemplatenameuuid text, IN update_entitytemplatename text, IN update_entitytemplateorder integer, IN update_entitytemplateisprimary boolean, IN update_entitytemplatetypeentityuuid uuid, IN update_entitytemplatedeleted boolean, IN update_entitytemplatedraft boolean, IN update_entitytemplatestartdate timestamp with time zone, IN update_entitytemplateenddate timestamp with time zone, IN update_entitytemplatemodifiedbyuuid text, IN update_languagetypeuuid uuid)
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

 if update_entitytemplatedraft = true or ((select entitytemplatedraft 
										from entity.entitytemplate
										WHERE entitytemplateuuid = update_entitytemplateuuid ) = true)
	then -- let everything change
		UPDATE entity.entitytemplate
			SET entitytemplateownerentityuuid = case when update_entitytemplateownerentityuuid notnull 
												then update_entitytemplateownerentityuuid
												else entitytemplateownerentityuuid end,	
				entitytemplateparententityuuid = case when update_entitytemplateparententityuuid notnull 
												then update_entitytemplateparententityuuid
												else entitytemplateparententityuuid end,
				entitytemplatetypeentityuuid = case when update_entitytemplatetypeentityuuid notnull 
												then update_entitytemplatetypeentityuuid
												else entitytemplatetypeentityuuid end,
				entitytemplateexternalid = case when update_entitytemplateexternalid notnull 
												then update_entitytemplateexternalid
												else entitytemplateexternalid end,
				entitytemplateexternalsystementityuuid = case when update_entitytemplateexternalsystementityuuid notnull 
														then update_entitytemplateexternalsystementityuuid
														else entitytemplateexternalsystementityuuid end,
				entitytemplatescanid = case when update_entitytemplatescanid notnull 
												then update_entitytemplatescanid
												else entitytemplatescanid end,
 				entitytemplatename  = case when update_entitytemplatename notnull and (coalesce(update_entitytemplatename,'') <> '')
												then update_entitytemplatename
												else entitytemplatename end,
				entitytemplateorder = case when update_entitytemplateorder notnull 
												then update_entitytemplateorder
												else entitytemplateorder end,  
				entitytemplateisprimary = case when update_entitytemplateisprimary notnull 
												then update_entitytemplateisprimary
												else entitytemplateisprimary end,  
				entitytemplatedeleted = case when update_entitytemplatedeleted notnull 
										then update_entitytemplatedeleted
										else entitytemplatedeleted end, 
				entitytemplatedraft = case when update_entitytemplatedraft notnull 
										then update_entitytemplatedraft
										else entitytemplatedraft end,
				entitytemplatestartdate = case when update_entitytemplatestartdate notnull 
										then update_entitytemplatestartdate
										else entitytemplatestartdate end,
	 			entitytemplateenddate = update_entitytemplateenddate,
				entitytemplatemodifieddate=now(),
				entitytemplatemodifiedbyuuid = update_entitytemplatemodifiedbyuuid
		WHERE entitytemplateuuid = update_entitytemplateuuid;
	Else -- trim the update to fields allowed to change
		UPDATE entity.entitytemplate
			SET entitytemplatestartdate = case when update_entitytemplatestartdate notnull 
											then update_entitytemplatestartdate
											else entitytemplatestartdate end,
				entitytemplatetypeentityuuid = case when update_entitytemplatetypeentityuuid notnull 
												then update_entitytemplatetypeentityuuid
												else entitytemplatetypeentityuuid end,
 				entitytemplatename  = case when update_entitytemplatename notnull and (coalesce(update_entitytemplatename,'') <> '')
												then update_entitytemplatename
												else entitytemplatename end,
				entitytemplateorder = case when update_entitytemplateorder notnull 
												then update_entitytemplateorder
												else entitytemplateorder end, 
				entitytemplateexternalid = case when update_entitytemplateexternalid notnull 
												then update_entitytemplateexternalid
												else entitytemplateexternalid end,
				entitytemplateexternalsystementityuuid = case when update_entitytemplateexternalsystementityuuid notnull 
														then update_entitytemplateexternalsystementityuuid
														else entitytemplateexternalsystementityuuid end,
 				entitytemplateenddate = update_entitytemplateenddate,
				entitytemplatemodifieddate=now(),
				entitytemplatemodifiedbyuuid = update_entitytemplatemodifiedbyuuid
		WHERE entitytemplateuuid = update_entitytemplateuuid;
end if;


if  update_entitytemplatename notNull and (coalesce(update_entitytemplatename,'') <> '')
	then
		-- update the languagemaster if the name changed
	
		update languagemaster
		set languagemastersource = update_entitytemplatename,
			languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid =update_entitytemplatemodifiedbyuuid),
			languagemastersourcelanguagetypeid = (select entityinstanceoriginalid from entity.entityinstance where entityinstanceuuid = update_languagetypeuuid),
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'		
		from entity.entitytemplate
		where entitytemplateuuid = update_entitytemplateuuid
			and languagemasteruuid = entitytemplatenameuuid
			and languagemastersource <> update_entitytemplatename;
	
		-- update the languagemaster and entityinstance if the type changed
	
		update languagemaster
		set languagemastersource = update_entitytemplatename,
			languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid =update_entitytemplatemodifiedbyuuid),
			languagemastersourcelanguagetypeid = (select entityinstanceoriginalid from entity.entityinstance where entityinstanceuuid = update_languagetypeuuid),
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'		
		from entity.entityinstance
		where entityinstanceuuid = update_entitytemplatetypeentityuuid	
			and entityinstancenameuuid = languagemasteruuid
			and languagemastersource <> update_entitytemplatename;
	
		update entity.entityinstance
		set entityinstancetype = update_entitytemplatename,
			entityinstancemodifiedbyuuid = update_entitytemplatemodifiedbyuuid	
		where entityinstanceuuid = update_entitytemplatetypeentityuuid	
			and entityinstancetype <> update_entitytemplatename;
END IF;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entitytemplate_update(uuid,uuid,uuid,text,uuid,text,text,text,integer,boolean,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytemplate_update(uuid,uuid,uuid,text,uuid,text,text,text,integer,boolean,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytemplate_update(uuid,uuid,uuid,text,uuid,text,text,text,integer,boolean,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) TO tendreladmin WITH GRANT OPTION;
