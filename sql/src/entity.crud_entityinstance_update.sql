
-- Type: PROCEDURE ; Name: entity.crud_entityinstance_update(uuid,uuid,uuid,text,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entityinstance_update(IN update_entityinstanceentityuuid uuid, IN update_entityinstanceownerentityuuid uuid, IN update_entityinstanceentitytemplateentityuuid uuid, IN update_entityinstanceentitytemplateentityname text, IN update_entityinstanceparententityuuid uuid, IN update_entityinstanceecornerstoneentityuuid uuid, IN update_entityinstancecornerstoneorder integer, IN update_entityinstancename text, IN update_entityinstancenameuuid text, IN update_entityinstancescanid text, IN update_entityinstancetypeuuid uuid, IN update_entityinstanceexternalid text, IN update_entityinstanceexternalsystemuuid uuid, IN update_entityinstancedeleted boolean, IN update_entityinstancedraft boolean, IN update_entityinstancestartdate timestamp with time zone, IN update_entityinstanceenddate timestamp with time zone, IN update_entityinstancemodifiedbyuuid text, IN update_languagetypeuuid uuid)
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

 if update_entityinstancedraft = true or ((select entityinstancedraft 
										from entity.entityinstance
										WHERE entityinstanceuuid = update_entityinstanceentityuuid ) = true)
	then -- let everything change
		UPDATE entity.entityinstance
			SET entityinstanceownerentityuuid = case when update_entityinstanceownerentityuuid notnull 
												then update_entityinstanceownerentityuuid
												else entityinstanceownerentityuuid end,	
				entityinstanceparententityuuid = case when update_entityinstanceparententityuuid notnull 
												then update_entityinstanceparententityuuid
												else entityinstanceparententityuuid end,
				entityinstanceentitytemplateentityuuid = case when update_entityinstanceentitytemplateentityuuid notnull 
												then update_entityinstanceentitytemplateentityuuid
												else entityinstanceentitytemplateentityuuid end,
				entityinstancetype = case when update_entityinstancename notnull and (coalesce(update_entityinstancename,'') <> '')
												then update_entityinstancename
												else entityinstancetype end,
				entityinstanceexternalid = case when update_entityinstanceexternalid notnull 
												then update_entityinstanceexternalid
												else entityinstanceexternalid end,
				entityinstanceexternalsystementityuuid = case when update_entityinstanceexternalsystemuuid notnull 
														then update_entityinstanceexternalsystemuuid
														else entityinstanceexternalsystementityuuid end,
				entityinstancecornerstoneentityuuid = case when update_entityinstanceecornerstoneentityuuid notnull 
														then update_entityinstanceecornerstoneentityuuid
														else entityinstancecornerstoneentityuuid end,
				entityinstancecornerstoneorder = case when update_entityinstancecornerstoneorder notnull 
												then update_entityinstancecornerstoneorder
												else entityinstancecornerstoneorder end, 
				entityinstancescanid = case when update_entityinstancescanid notnull 
												then update_entityinstancescanid
												else entityinstancescanid end, 
				entityinstancetypeentityuuid  = case when update_entityinstancetypeuuid notnull 
												then update_entityinstancetypeuuid
												else entityinstancetypeentityuuid end, 
				entityinstancedeleted = case when update_entityinstancedeleted notnull 
										then update_entityinstancedeleted
										else entityinstancedeleted end, 
				entityinstancedraft = case when update_entityinstancedraft notnull 
										then update_entityinstancedraft
										else entityinstancedraft end,
				entityinstancestartdate = case when update_entityinstancestartdate notnull 
										then update_entityinstancestartdate
										else entityinstancestartdate end,
	 			entityinstanceenddate = update_entityinstanceenddate,
				entityinstancemodifieddate=now(),
				entityinstancemodifiedbyuuid = update_entityinstancemodifiedbyuuid
		WHERE entityinstanceuuid = update_entityinstanceentityuuid;
	Else -- trim the update to fields allowed to change
		UPDATE entity.entityinstance
			SET entityinstanceparententityuuid = case when update_entityinstanceparententityuuid notnull 
												then update_entityinstanceparententityuuid
												else entityinstanceparententityuuid end,
				entityinstancetype = case when update_entityinstancename notnull and (coalesce(update_entityinstancename,'') <> '')
												then update_entityinstancename
												else entityinstancetype end,
				entityinstanceexternalid = case when update_entityinstanceexternalid notnull 
												then update_entityinstanceexternalid
												else entityinstanceexternalid end,
				entityinstanceexternalsystementityuuid = case when update_entityinstanceexternalsystemuuid notnull 
														then update_entityinstanceexternalsystemuuid
														else entityinstanceexternalsystementityuuid end,
				entityinstancecornerstoneentityuuid = case when update_entityinstanceecornerstoneentityuuid notnull 
														then update_entityinstanceecornerstoneentityuuid
														else entityinstancecornerstoneentityuuid end,
				entityinstancecornerstoneorder = case when update_entityinstancecornerstoneorder notnull 
												then update_entityinstancecornerstoneorder
												else entityinstancecornerstoneorder end, 
				entityinstancescanid = case when update_entityinstancescanid notnull 
												then update_entityinstancescanid
												else entityinstancescanid end, 
				entityinstancestartdate = case when update_entityinstancestartdate notnull 
										then update_entityinstancestartdate
										else entityinstancestartdate end,
	 			entityinstanceenddate = update_entityinstanceenddate,
				entityinstancemodifieddate=now(),
				entityinstancemodifiedbyuuid = update_entityinstancemodifiedbyuuid
		WHERE entityinstanceuuid = update_entityinstanceentityuuid;
end if;

if  update_entityinstancename notNull and (coalesce(update_entityinstancename,'') <> '')
	then
		-- update the languagemaster if the name changed
	
		update languagemaster
		set languagemastersource = update_entityinstancename,
			languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid =update_entityinstancemodifiedbyuuid),
			languagemastersourcelanguagetypeid = (select entityinstanceoriginalid from entity.entityinstance where entityinstanceuuid = update_languagetypeuuid),
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'		
		from entity.entityinstance
		where entityinstanceuuid = update_entityinstanceentityuuid
			and languagemasteruuid = entityinstancenameuuid
			and languagemastersource <> update_entityinstancename;


----------------------
-- need to update tempaltename if templateuuid changes.  

END IF;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entityinstance_update(uuid,uuid,uuid,text,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityinstance_update(uuid,uuid,uuid,text,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityinstance_update(uuid,uuid,uuid,text,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_entityinstance_update(uuid,uuid,uuid,text,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) TO graphql;
