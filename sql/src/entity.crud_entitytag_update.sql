BEGIN;

/*
DROP PROCEDURE entity.crud_entitytag_update(uuid,uuid,uuid,uuid,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint);
*/


-- Type: PROCEDURE ; Name: entity.crud_entitytag_update(uuid,uuid,uuid,uuid,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entitytag_update(IN update_entitytaguuid uuid, IN update_entitytagownerentityuuid uuid, IN update_entitytagentityinstanceuuid uuid, IN update_entitytagentitytemplateuuid uuid, IN update_entitytagcustaguuid uuid, IN update_languagetypeuuid uuid, IN update_entitytagdeleted boolean, IN update_entitytagdraft boolean, IN update_entitytagstartdate timestamp with time zone, IN update_entitytagenddate timestamp with time zone, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

Begin

-- Once created, the only things that can change after something is publsihed are entitytagstartdate and entitytagenddate

/*
-- Add testing here

*/

if update_entitytagdraft = true or ((select entitytagdraft 
										from entity.entitytag
										WHERE entitytaguuid = update_entitytaguuid ) = true)
	then -- let everything change
		UPDATE entity.entitytag
			SET entitytagentityinstanceentityuuid = case when update_entitytagentityinstanceuuid notnull 
														then update_entitytagentityinstanceuuid
														else entitytagentityinstanceentityuuid end,   
				entitytagentitytemplateentityuuid = case when update_entitytagentitytemplateuuid notnull 
														then update_entitytagentitytemplateuuid
														else entitytagentitytemplateentityuuid end,  
				entitytagcustagentityuuid = case when update_entitytagcustaguuid notnull 
												then update_entitytagcustaguuid
												else entitytagcustagentityuuid end,  
				entitytagdeleted = case when update_entitytagdeleted notnull 
										then update_entitytagdeleted
										else entitytagdeleted end, 
				entitytagdraft = case when update_entitytagdraft notnull 
										then update_entitytagdraft
										else entitytagdraft end,
				entitytagstartdate = case when update_entitytagstartdate notnull 
										then update_entitytagstartdate
										else entitytagstartdate end,
	 			entitytagenddate = case 	when entitytagdeleted = true 
											and entitytagenddate isNull
											and update_entitytagenddate isNull then now()
										when entitytagdeleted = true 
											and entitytagenddate isNull
											and update_entitytagenddate notNull then update_entitytagenddate 
										when entitytagdeleted = true 
											and entitytagenddate notNull
											and update_entitytagenddate isNull then entitytagenddate
										when entitytagdeleted = true and entitytagenddate notNull
											and update_entitytagenddate notNull and update_entitytagenddate <> entitytagenddate
											then update_entitytagenddate	
										else null
									end,		
				entitytagmodifieddate=now(),
				entitytagmodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = update_modifiedbyid)
		WHERE entitytaguuid = update_entitytaguuid;
	Else -- trim the update to fields allowed to change
		UPDATE entity.entitytag
			SET entitytagstartdate = case when update_entitytagstartdate notnull 
											then update_entitytagstartdate
											else entitytagstartdate end,
				entitytagdeleted = case when update_entitytagdeleted notnull 
										then update_entitytagdeleted
										else entitytagdeleted end,							
	 			entitytagenddate = case 	when entitytagdeleted = true 
											and entitytagenddate isNull
											and update_entitytagenddate isNull then now()
										when entitytagdeleted = true 
											and entitytagenddate isNull
											and update_entitytagenddate notNull then update_entitytagenddate 
										when entitytagdeleted = true 
											and entitytagenddate notNull
											and update_entitytagenddate isNull then entitytagenddate
										when entitytagdeleted = true and entitytagenddate notNull
											and update_entitytagenddate notNull and update_entitytagenddate <> entitytagenddate
											then update_entitytagenddate	
										else null
									end,	
				entitytagmodifieddate=now(),
				entitytagmodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = update_modifiedbyid)
		WHERE entitytaguuid = update_entitytaguuid;
end if;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entitytag_update(uuid,uuid,uuid,uuid,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytag_update(uuid,uuid,uuid,uuid,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytag_update(uuid,uuid,uuid,uuid,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_entitytag_update(uuid,uuid,uuid,uuid,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint) TO graphql;

END;
