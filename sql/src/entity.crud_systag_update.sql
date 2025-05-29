BEGIN;

/*
DROP PROCEDURE entity.crud_systag_update(uuid,uuid,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text);
*/


-- Type: PROCEDURE ; Name: entity.crud_systag_update(uuid,uuid,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_systag_update(IN update_systagentityuuid uuid, IN update_systagownerentityuuid uuid, IN update_systagparententityuuid uuid, IN update_systagcornerstoneentityuuid uuid, IN update_systagcornerstoneorder integer, IN update_systag text, IN update_systag_name text, IN update_systag_displayname text, IN update_languagetypeuuid uuid, IN update_systagexternalid text, IN update_systagexternalsystemuuid uuid, IN update_systagdeleted boolean, IN update_systagdraft boolean, IN update_systagstartdate timestamp with time zone, IN update_systagenddate timestamp with time zone, IN update_systagmodifiedbyuuid text)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	tempcustomeruuid text;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
Begin

/*
Needs tests
	
*/

if update_languagetypeuuid isNull 
	then update_languagetypeuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
End if;

 if update_systagdraft = true or ((select entityinstancedraft 
										from entity.entityinstance
										WHERE entityinstanceuuid = update_systagentityuuid ) = true)
	then -- let everything change
		UPDATE entity.entityinstance
			SET entityinstanceownerentityuuid = case when update_systagownerentityuuid notnull 
												then update_systagownerentityuuid
												else entityinstanceownerentityuuid end,	
				entityinstanceparententityuuid = case when update_systagparententityuuid notnull 
												then update_systagparententityuuid
												else entityinstanceparententityuuid end,
				entityinstancecornerstoneorder = case when update_systagcornerstoneorder notnull 
												then update_systagcornerstoneorder
												else entityinstancecornerstoneorder end, 
				entityinstancetype = case when update_systag notnull and (coalesce(update_systag,'') <> '')
												then update_systag
												else entityinstancetype end,
				entityinstanceexternalid = update_systagexternalid,												
				entityinstanceexternalsystementityuuid = case when update_systagexternalsystemuuid notnull 
														then update_systagexternalsystemuuid
														else entityinstanceexternalsystementityuuid end,
				entityinstancedeleted = case when update_systagdeleted notnull 
										then update_systagdeleted
										else entityinstancedeleted end, 
				entityinstancedraft = case when update_systagdraft notnull 
										then update_systagdraft
										else entityinstancedraft end,
				entityinstancestartdate = case when update_systagstartdate notnull 
										then update_systagstartdate
										else entityinstancestartdate end,
				entityinstanceenddate = case 	when update_systagdeleted = true 
									and entityinstanceenddate isNull
									and update_systagenddate isNull then now()
								when update_systagdeleted = true 
									and entityinstanceenddate isNull
									and update_systagenddate notNull then update_systagenddate 
								when update_systagdeleted = true 
									and entityinstanceenddate notNull
									and update_systagenddate isNull then entityinstanceenddate
								when update_systagdeleted = true and entityinstanceenddate notNull
									and update_systagenddate notNull and update_systagenddate <> entityinstanceenddate
									then update_systagenddate	
								else null
							end,						
				entityinstancemodifieddate=now(),
				entityinstancemodifiedbyuuid = update_systagmodifiedbyuuid
		WHERE entityinstanceuuid = update_systagentityuuid;
	Else -- trim the update to fields allowed to change
		UPDATE entity.entityinstance
			SET entityinstanceparententityuuid = case when update_systagparententityuuid notnull 
												then update_systagparententityuuid
												else entityinstanceparententityuuid end,
				entityinstancecornerstoneorder = case when update_systagcornerstoneorder notnull 
												then update_systagcornerstoneorder
												else entityinstancecornerstoneorder end, 
				entityinstancetype = case when update_systag notnull and (coalesce(update_systag,'') <> '')
												then update_systag
												else entityinstancetype end,
				entityinstanceexternalid = update_systagexternalid,												
				entityinstanceexternalsystementityuuid = case when update_systagexternalsystemuuid notnull 
														then update_systagexternalsystemuuid
														else entityinstanceexternalsystementityuuid end,
				entityinstancestartdate = case when update_systagstartdate notnull 
										then update_systagstartdate
										else entityinstancestartdate end,
				entityinstancedeleted = case when update_systagdeleted notnull 
										then update_systagdeleted
										else entityinstancedeleted end, 
				entityinstanceenddate = case 	when update_systagdeleted = true 
									and entityinstanceenddate isNull
									and update_systagenddate isNull then now()
								when update_systagdeleted = true 
									and entityinstanceenddate isNull
									and update_systagenddate notNull then update_systagenddate 
								when update_systagdeleted = true 
									and entityinstanceenddate notNull
									and update_systagenddate isNull then entityinstanceenddate
								when update_systagdeleted = true and entityinstanceenddate notNull
									and update_systagenddate notNull and update_systagenddate <> entityinstanceenddate
									then update_systagenddate	
								else null
							end,
				entityinstancemodifieddate=now(),
				entityinstancemodifiedbyuuid = update_systagmodifiedbyuuid
		WHERE entityinstanceuuid = update_systagentityuuid;
end if;

update_systagownerentityuuid = (select owner from api.entity_instance where id = update_systagentityuuid);

-- update the language master

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,update_systagownerentityuuid,null,false,null,null,null, null);

select systagid,systaguuid into templanguagetypeid,templanguagetypeuuid
	from entity.crud_systag_read_min(null, null, update_languagetypeuuid, null, false,null,null, null,update_languagetypeuuid);

if update_systag_displayname notnull and (coalesce(update_systag_displayname,'') <> '')
	then

	-- update name in languagetranslations (Temp until the retranslate runs)	
		update public.languagetranslations
			set languagetranslationvalue = update_systag_displayname
		from entity.entityinstance
		where languagetranslationmasterid = (select languagemasterid 
												from languagemaster 
												where languagemasteruuid = (select entityfieldinstancevaluelanguagemasteruuid 
																			from entity.entityfieldinstance
																			where entityfieldinstanceentityinstanceentityuuid = update_systagentityuuid
																				and  entityfieldinstanceentityfieldentityuuid = 'cf94ce9c-edd3-4c7b-8128-ab598fc9710a'))
				and languagetranslationtypeid = templanguagetypeid
				and languagetranslationvalue <> update_systag_displayname;
	
	-- update displayname in languagemaster
		update public.languagemaster
			set languagemastersourcelanguagetypeid = templanguagetypeid,
				languagemastersource = update_systag_displayname,
				languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = update_systagmodifiedbyuuid),
				languagemastermodifieddate = now(),
				languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'	
		where languagemasteruuid = (select entityfieldinstancevaluelanguagemasteruuid 
									from entity.entityfieldinstance
									where entityfieldinstanceentityinstanceentityuuid = update_systagentityuuid
										and  entityfieldinstanceentityfieldentityuuid = 'cf94ce9c-edd3-4c7b-8128-ab598fc9710a')
				and languagemastersource <> update_systag_displayname;

	-- update the field instance

		update entity.entityfieldinstance
			set entityfieldinstancevalue = update_systag_displayname,
				entityfieldinstancevaluelanguagetypeentityuuid = update_languagetypeuuid,
				entityfieldinstancemodifieddate = now(),
				entityfieldinstancemodifiedbyuuid = update_systagmodifiedbyuuid
		where entityfieldinstanceentityinstanceentityuuid = update_systagentityuuid
				and  entityfieldinstanceentityfieldentityuuid = 'cf94ce9c-edd3-4c7b-8128-ab598fc9710a'
				and entityfieldinstancevalue <> update_systag_displayname; 

end if;

if update_systag_name notnull and (coalesce(update_systag_name,'') <> '')
	then

	-- update name in languagetranslations (Temp until the retranslate runs)	
		update public.languagetranslations
			set languagetranslationvalue = update_systag_name
		from entity.entityinstance
			where entityinstanceuuid = update_systagentityuuid
				and languagetranslationmasterid = (select languagemasterid from languagemaster where languagemasteruuid = entityinstancenameuuid)
				and languagetranslationtypeid = templanguagetypeid
				and languagetranslationvalue <> update_systag_name;

	-- update name in languagemaster
		update public.languagemaster
			set languagemastersourcelanguagetypeid = templanguagetypeid,
				languagemastersource = update_systag_name,
				languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = update_systagmodifiedbyuuid),
				languagemastermodifieddate = now(),
				languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'	
		from entity.entityinstance
			where entityinstanceuuid = update_systagentityuuid
				and languagemasteruuid = entityinstancenameuuid
				and languagemastersource <> update_systag_name;
				
end if;

-- update systag

update public.systag
		set systagstartdate = case when update_systagstartdate notnull 
									then update_systagstartdate
									else systagstartdate end,
			systagenddate  = update_systagenddate, 
			systagmodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = update_systagmodifiedbyuuid)
where systagid = (select systagid from entity.crud_systag_read_min(update_systagownerentityuuid, 
							null, update_systagentityuuid, null, false,null,null, null,update_languagetypeuuid));

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_systag_update(uuid,uuid,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_systag_update(uuid,uuid,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_systag_update(uuid,uuid,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_systag_update(uuid,uuid,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text) TO graphql;

END;
