
-- Type: PROCEDURE ; Name: entity.crud_entitydescription_update(uuid,uuid,uuid,uuid,text,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entitydescription_update(IN update_entitydescriptionuuid uuid, IN update_entitydescriptionownerentityuuid uuid, IN update_entitydescriptionentitytemplateentityuuid uuid, IN update_entitydescriptionentityfieldentityuuid uuid, IN update_entitydescriptionname text, IN update_entitydescriptionsoplink text, IN update_entitydescriptionfile text, IN update_entitydescriptionicon text, IN update_entitydescriptionmimetypeuuid uuid, IN update_entitydescriptionexternalid text, IN update_entitydescriptionexternalsystementityuuid uuid, IN update_entitydescriptiondeleted boolean, IN update_entitydescriptiondraft boolean, IN update_entitydescriptionstartdate timestamp with time zone, IN update_entitydescriptionenddate timestamp with time zone, IN update_entitydescriptionmodifiedbyuuid text, IN update_languagetypeuuid uuid)
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

 if update_entitydescriptiondraft = true or ((select entitydescriptiondraft 
										from entity.entitydescription
										WHERE entitydescriptionuuid = update_entitydescriptionuuid ) = true)
	then -- let everything change
		UPDATE entity.entitydescription
			SET entitydescriptionownerentityuuid = case when update_entitydescriptionownerentityuuid notnull 
												then update_entitydescriptionownerentityuuid
												else entitydescriptionownerentityuuid end,	
				entitydescriptionentitytemplateentityuuid = case when update_entitydescriptionentitytemplateentityuuid notnull 
												then update_entitydescriptionentitytemplateentityuuid
												else entitydescriptionentitytemplateentityuuid end,
				entitydescriptionentityfieldentityduuid = case when update_entitydescriptionentityfieldentityuuid notnull 
												then update_entitydescriptionentityfieldentityuuid
												else entitydescriptionentityfieldentityduuid end,
 				entitydescriptionname  = case when update_entitydescriptionname notnull and (coalesce(update_entitydescriptionname,'') <> '')
												then update_entitydescriptionname
												else entitydescriptionname end,
 				entitydescriptionsoplink  = case when update_entitydescriptionsoplink notnull 
												then update_entitydescriptionname
												else entitydescriptionsoplink end,
 				entitydescriptionfile  = case when update_entitydescriptionname notnull 
												then update_entitydescriptionname
												else entitydescriptionfile end,
 				entitydescriptionicon  = case when update_entitydescriptionname notnull 
												then update_entitydescriptionname
												else entitydescriptionicon end,												
 				entitydescriptionmimetypeuuid  = case when update_entitydescriptionmimetypeuuid notnull 
												then update_entitydescriptionmimetypeuuid
												else entitydescriptionmimetypeuuid end,
				entitydescriptionexternalid = case when update_entitydescriptionexternalid notnull 
												then update_entitydescriptionexternalid
												else entitydescriptionexternalid end,
				entitydescriptionexternalsystementityuuid = case when update_entitydescriptionexternalsystementityuuid notnull 
														then update_entitydescriptionexternalsystementityuuid
														else entitydescriptionexternalsystementityuuid end,
				entitydescriptiondeleted = case when update_entitydescriptiondeleted notnull 
										then update_entitydescriptiondeleted
										else entitydescriptiondeleted end, 
				entitydescriptiondraft = case when update_entitydescriptiondraft notnull 
										then update_entitydescriptiondraft
										else entitydescriptiondraft end,

				entitydescriptionstartdate = case when update_entitydescriptionstartdate notnull 
										then update_entitydescriptionstartdate
										else entitydescriptionstartdate end,
	 			entitydescriptionenddate = update_entitydescriptionenddate,
				entitydescriptionmodifieddate=now(),
				entitydescriptionmodifiedby = update_entitydescriptionmodifiedbyuuid
		WHERE entitydescriptionuuid = update_entitydescriptionuuid;
	Else -- trim the update to fields allowed to change
		UPDATE entity.entitydescription
			SET entitydescriptionname  = case when update_entitydescriptionname notnull and (coalesce(update_entitydescriptionname,'') <> '')
												then update_entitydescriptionname
												else entitydescriptionname end,
 				entitydescriptionsoplink  = case when update_entitydescriptionsoplink notnull 
												then update_entitydescriptionname
												else entitydescriptionsoplink end,
 				entitydescriptionfile  = case when update_entitydescriptionname notnull 
												then update_entitydescriptionname
												else entitydescriptionfile end,
 				entitydescriptionicon  = case when update_entitydescriptionname notnull 
												then update_entitydescriptionname
												else entitydescriptionicon end,												
 				entitydescriptionmimetypeuuid  = case when update_entitydescriptionmimetypeuuid notnull 
												then update_entitydescriptionmimetypeuuid
												else entitydescriptionmimetypeuuid end,
				entitydescriptionexternalid = case when update_entitydescriptionexternalid notnull 
												then update_entitydescriptionexternalid
												else entitydescriptionexternalid end,
				entitydescriptionexternalsystementityuuid = case when update_entitydescriptionexternalsystementityuuid notnull 
														then update_entitydescriptionexternalsystementityuuid
														else entitydescriptionexternalsystementityuuid end,
				entitydescriptionstartdate = case when update_entitydescriptionstartdate notnull 
										then update_entitydescriptionstartdate
										else entitydescriptionstartdate end,
	 			entitydescriptionenddate = update_entitydescriptionenddate,
				entitydescriptionmodifieddate=now(),
				entitydescriptionmodifiedby = update_entitydescriptionmodifiedbyuuid
		WHERE entitydescriptionuuid = update_entitydescriptionuuid;
end if;

-- update the languagemaster if the name changed

if update_entitydescriptionname notNull and (coalesce(update_entitydescriptionname,'') <> '') 
	then
		update languagemaster
		set languagemastersource = update_entitydescriptionname,
			languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid =update_entitydescriptionmodifiedbyuuid),
			languagemastersourcelanguagetypeid = (select entityinstanceoriginalid from entity.entityinstance where entityinstanceuuid = update_languagetypeuuid),
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'		
		from entity.entitydescription
		where entitydescriptionuuid = update_entitydescriptionuuid
			and languagemasteruuid = entitydescriptionlanguagemasteruuid
			and languagemastersource <> update_entitydescriptionname;
End if;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entitydescription_update(uuid,uuid,uuid,uuid,text,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitydescription_update(uuid,uuid,uuid,uuid,text,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitydescription_update(uuid,uuid,uuid,uuid,text,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) TO tendreladmin WITH GRANT OPTION;
