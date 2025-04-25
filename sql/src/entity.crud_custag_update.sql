
-- Type: PROCEDURE ; Name: entity.crud_custag_update(uuid,uuid,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_custag_update(IN update_custagentityuuid uuid, IN update_custagownerentityuuid uuid, IN update_custagparententityuuid uuid, IN update_custagcornerstoneentityuuid uuid, IN update_custagcornerstoneorder integer, IN update_custag text, IN update_custag_name text, IN update_custag_displayname text, IN update_languagetypeuuid uuid, IN update_custagexternalid text, IN update_custagexternalsystemuuid uuid, IN update_custagdeleted boolean, IN update_custagdraft boolean, IN update_custagstartdate timestamp with time zone, IN update_custagenddate timestamp with time zone, IN update_custagmodifiedbyuuid text)
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

 if update_custagdraft = true or ((select entityinstancedraft 
										from entity.entityinstance
										WHERE entityinstanceuuid = update_custagentityuuid ) = true)
	then -- let everything change
		UPDATE entity.entityinstance
			SET entityinstanceownerentityuuid = case when update_custagownerentityuuid notnull 
												then update_custagownerentityuuid
												else entityinstanceownerentityuuid end,	
				entityinstanceparententityuuid = case when update_custagparententityuuid notnull 
												then update_custagparententityuuid
												else entityinstanceparententityuuid end,
				entityinstancecornerstoneorder = case when update_custagcornerstoneorder notnull 
												then update_custagcornerstoneorder
												else entityinstancecornerstoneorder end, 
				entityinstancetype = case when update_custag notnull and (coalesce(update_custag,'') <> '')
												then update_custag
												else entityinstancetype end,
				entityinstanceexternalid = case when update_custagexternalid notnull 
												then update_custagexternalid
												else entityinstanceexternalid end,												
				entityinstanceexternalsystementityuuid = case when update_custagexternalsystemuuid notnull 
														then update_custagexternalsystemuuid
														else entityinstanceexternalsystementityuuid end,
				entityinstancedeleted = case when update_custagdeleted notnull 
										then update_custagdeleted
										else entityinstancedeleted end, 
				entityinstancedraft = case when update_custagdraft notnull 
										then update_custagdraft
										else entityinstancedraft end,
				entityinstancestartdate = case when update_custagstartdate notnull 
										then update_custagstartdate
										else entityinstancestartdate end,
				entityinstanceenddate = case 	when update_custagdeleted = true 
									and entityinstanceenddate isNull
									and update_custagenddate isNull then now()
								when update_custagdeleted = true 
									and entityinstanceenddate isNull
									and update_custagenddate notNull then update_custagenddate 
								when update_custagdeleted = true 
									and entityinstanceenddate notNull
									and update_custagenddate isNull then entityinstanceenddate
								when update_custagdeleted = true and entityinstanceenddate notNull
									and update_custagenddate notNull and update_custagenddate <> entityinstanceenddate
									then update_custagenddate	
								else null
							end,	
				entityinstancemodifieddate=now(),
				entityinstancemodifiedbyuuid = update_custagmodifiedbyuuid
		WHERE entityinstanceuuid = update_custagentityuuid;
	Else -- trim the update to fields allowed to change
		UPDATE entity.entityinstance
			SET entityinstanceparententityuuid = case when update_custagparententityuuid notnull 
												then update_custagparententityuuid
												else entityinstanceparententityuuid end,
				entityinstancecornerstoneorder = case when update_custagcornerstoneorder notnull 
												then update_custagcornerstoneorder
												else entityinstancecornerstoneorder end, 
				entityinstancetype = case when update_custag notnull and (coalesce(update_custag,'') <> '')
												then update_custag
												else entityinstancetype end,
				entityinstanceexternalid = case when update_custagexternalid notnull 
												then update_custagexternalid
												else entityinstanceexternalid end,												
				entityinstanceexternalsystementityuuid = case when update_custagexternalsystemuuid notnull 
														then update_custagexternalsystemuuid
														else entityinstanceexternalsystementityuuid end,
				entityinstancestartdate = case when update_custagstartdate notnull 
										then update_custagstartdate
										else entityinstancestartdate end,
				entityinstancedeleted = case when update_custagdeleted notnull 
											then update_custagdeleted
											else entityinstancedeleted end, 						
				entityinstanceenddate = case 	when update_custagdeleted = true 
									and entityinstanceenddate isNull
									and update_custagenddate isNull then now()
								when update_custagdeleted = true 
									and entityinstanceenddate isNull
									and update_custagenddate notNull then update_custagenddate 
								when update_custagdeleted = true 
									and entityinstanceenddate notNull
									and update_custagenddate isNull then entityinstanceenddate
								when update_custagdeleted = true and entityinstanceenddate notNull
									and update_custagenddate notNull and update_custagenddate <> entityinstanceenddate
									then update_custagenddate	
								else null
							end,
				entityinstancemodifieddate=now(),
				entityinstancemodifiedbyuuid = update_custagmodifiedbyuuid
		WHERE entityinstanceuuid = update_custagentityuuid;
end if;

update_custagownerentityuuid = (select owner from api.entity_instance where id = update_custagentityuuid);

-- update the language master

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,update_custagownerentityuuid,null,false,null,null,null, null);

select systagid,systaguuid into templanguagetypeid,templanguagetypeuuid
	from entity.crud_systag_read_min(null, null, update_languagetypeuuid, null, false,null,null, null,update_languagetypeuuid);

if update_custag_displayname notnull and (coalesce(update_custag_displayname,'') <> '')
	then

	-- update name in languagetranslations (Temp until the retranslate runs)	
		update public.languagetranslations
			set languagetranslationvalue = update_custag_displayname
		from entity.entityinstance
		where languagetranslationmasterid = (select languagemasterid 
												from languagemaster 
												where languagemasteruuid = (select entityfieldinstancevaluelanguagemasteruuid 
																			from entity.entityfieldinstance
																			where entityfieldinstanceentityinstanceentityuuid = update_custagentityuuid
																				and  entityfieldinstanceentityfieldentityuuid = '1b29e7b0-0800-4366-b79e-424dd9bafa71'))
				and languagetranslationtypeid = templanguagetypeid
				and languagetranslationvalue <> update_custag_displayname;
	
	-- update displayname in languagemaster
		update public.languagemaster
			set languagemastersourcelanguagetypeid = templanguagetypeid,
				languagemastersource = update_custag_displayname,
				languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = update_custagmodifiedbyuuid),
				languagemastermodifieddate = now(),
				languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'	
		where languagemasteruuid = (select entityfieldinstancevaluelanguagemasteruuid 
									from entity.entityfieldinstance
									where entityfieldinstanceentityinstanceentityuuid = update_custagentityuuid
										and  entityfieldinstanceentityfieldentityuuid = '1b29e7b0-0800-4366-b79e-424dd9bafa71')
				and languagemastersource <> update_custag_displayname;

	-- update the field instance

		update entity.entityfieldinstance
			set entityfieldinstancevalue = update_custag_displayname,
				entityfieldinstancevaluelanguagetypeentityuuid = update_languagetypeuuid,
				entityfieldinstancemodifieddate = now(),
				entityfieldinstancemodifiedbyuuid = update_custagmodifiedbyuuid
		where entityfieldinstanceentityinstanceentityuuid = update_custagentityuuid
				and  entityfieldinstanceentityfieldentityuuid = '1b29e7b0-0800-4366-b79e-424dd9bafa71'
				and entityfieldinstancevalue <> update_custag_displayname; 

end if;


if update_custag_name notnull and (coalesce(update_custag_name,'') <> '')
	then


	-- update name in languagetranslations (Temp until the retranslate runs)	
		update public.languagetranslations
			set languagetranslationvalue = update_custag_name
		from entity.entityinstance
			where entityinstanceuuid = update_custagentityuuid
				and languagetranslationmasterid = (select languagemasterid from languagemaster where languagemasteruuid = entityinstancenameuuid)
				and languagetranslationtypeid = templanguagetypeid
				and languagetranslationvalue <> update_custag_name;

	-- update name in languagemaster
		update public.languagemaster
			set languagemastersourcelanguagetypeid = templanguagetypeid,
				languagemastersource = update_custag_name,
				languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = update_custagmodifiedbyuuid),
				languagemastermodifieddate = now(),
				languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'	
		from entity.entityinstance
			where entityinstanceuuid = update_custagentityuuid
				and languagemasteruuid = entityinstancenameuuid
				and languagemastersource <> update_custag_name;
				
end if;

-- update custag

update public.custag
		set custagstartdate = case when update_custagstartdate notnull 
									then update_custagstartdate
									else custagstartdate end,
			custagenddate  = update_custagenddate, 
			custagmodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = update_custagmodifiedbyuuid)
where custagid = (select custagid from entity.crud_custag_read_min(update_custagownerentityuuid, 
							null, update_custagentityuuid, null, false,null,null, null,update_languagetypeuuid));

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_custag_update(uuid,uuid,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_custag_update(uuid,uuid,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_custag_update(uuid,uuid,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_custag_update(uuid,uuid,uuid,uuid,integer,text,text,text,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text) TO graphql;
