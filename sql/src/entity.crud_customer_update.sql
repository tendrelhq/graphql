
-- Type: PROCEDURE ; Name: entity.crud_customer_update(text,text,text,uuid,uuid,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,uuid,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_customer_update(IN update_customername text, IN update_customerdisplayname text, IN update_customeruuid text, IN update_customerentityuuid uuid, IN update_customerparentuuid uuid, IN update_customerowner uuid, IN update_customerbillingid text, IN update_customerbillingsystemid uuid, IN update_customerdeleted boolean, IN update_customerdraft boolean, IN update_customerstartdate timestamp with time zone, IN update_customerenddate timestamp with time zone, IN update_languagetypeuuid uuid, IN update_modifiedby text)
 LANGUAGE plpgsql
AS $procedure$
Declare

	tempcustomerid bigint;
	tempcustomeruuid text;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
	templocationid bigint;

Begin

if update_languagetypeuuid isNull 
	then update_languagetypeuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
End if;

UPDATE entity.entityinstance
	SET entityinstanceparententityuuid = case when update_customerparentuuid notnull 
										then update_customerparentuuid
										else entityinstanceparententityuuid end,
		entityinstancetype = case when update_customername notnull and (coalesce(update_customername,'') <> '')
										then update_customername
										else entityinstancetype end,
		entityinstancestartdate = case when update_customerstartdate notnull 
								then update_customerstartdate
								else entityinstancestartdate end,
		entityinstancedraft = update_customerdraft,
		entityinstancedeleted = update_customerdeleted,
		entityinstanceenddate = case 	when update_customerdeleted = true 
											and entityinstanceenddate isNull
											and update_customerenddate isNull then now()
										when update_customerdeleted = true 
											and entityinstanceenddate isNull
											and update_customerenddate notNull then update_customerenddate 
										when update_customerdeleted = true 
											and entityinstanceenddate notNull
											and update_customerenddate isNull then entityinstanceenddate
										when update_customerdeleted = true and entityinstanceenddate notNull
											and update_customerenddate notNull and update_customerenddate <> entityinstanceenddate
											then update_customerenddate	
										else null
									end,
		entityinstancemodifieddate =now(),
		entityinstancemodifiedbyuuid = update_modifiedby
WHERE entityinstanceuuid = update_customerentityuuid;

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,update_customerentityuuid,null,false,null,null,null, null);

select systagid,systaguuid into templanguagetypeid,templanguagetypeuuid
	from entity.crud_systag_read_min(null, null, update_languagetypeuuid, null, false,null,null, null,update_languagetypeuuid);

if  update_customername notNull and (coalesce(update_customername,'') <> '')
	then
		update public.languagetranslations
			set languagetranslationvalue = update_customername
		from entity.entityinstance
			where entityinstanceuuid = update_customerentityuuid
				and languagetranslationmasterid = (select languagemasterid from languagemaster where languagemasteruuid = entityinstancenameuuid)
				and languagetranslationtypeid = templanguagetypeid
				and languagetranslationvalue <> update_customername;
		
		update languagemaster
			set languagemastersourcelanguagetypeid = templanguagetypeid,
				languagemastersource = update_customername,
				languagemastermodifieddate = now(),
				languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = update_modifiedby),
				languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'		
			from entity.entityinstance
			where entityinstanceuuid = update_customerentityuuid
				and languagemasteruuid = entityinstancenameuuid
				and languagemastersource <> update_customername;
end if;

-- update display name
if  update_customerdisplayname notNull and (coalesce(update_customerdisplayname,'') <> '')
	then
		update public.languagetranslations
			set languagetranslationvalue = update_customerdisplayname
		from entity.entityinstance
		where languagetranslationmasterid = (select languagemasterid 
												from languagemaster 
												where languagemasteruuid = (select entityfieldinstancevaluelanguagemasteruuid 
																			from entity.entityfieldinstance
																			where entityfieldinstanceentityinstanceentityuuid = update_customerentityuuid
																				and  entityfieldinstanceentityfieldentityuuid = 'd15bb9c2-0601-4e4f-9009-c791a40be191'))
				and languagetranslationtypeid = templanguagetypeid
				and languagetranslationvalue <> update_customerdisplayname;
				
		update public.languagemaster
			set languagemastersourcelanguagetypeid = templanguagetypeid,
				languagemastersource = update_customerdisplayname,
				languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = update_modifiedby),
				languagemastermodifieddate = now(),
				languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'					
		where languagemasteruuid = (select entityfieldinstancevaluelanguagemasteruuid 
									from entity.entityfieldinstance
									where entityfieldinstanceentityinstanceentityuuid = update_customerentityuuid
										and  entityfieldinstanceentityfieldentityuuid = 'd15bb9c2-0601-4e4f-9009-c791a40be191')
				and languagemastersource <> update_customerdisplayname;

		update entity.entityfieldinstance
			set entityfieldinstancevalue = update_customerdisplayname,
				entityfieldinstancevaluelanguagetypeentityuuid = update_languagetypeuuid,
				entityfieldinstancemodifieddate = now(),
				entityfieldinstancemodifiedbyuuid = update_modifiedby
		where entityfieldinstanceentityinstanceentityuuid = update_customerentityuuid
				and  entityfieldinstanceentityfieldentityuuid = 'd15bb9c2-0601-4e4f-9009-c791a40be191'
				and entityfieldinstancevalue <> update_customerdisplayname;
end if;

-- update customerlanguagetypeuuid

if  update_languagetypeuuid notNull 
	then
		update entity.entityfieldinstance
			set entityfieldinstancevalue = update_languagetypeuuid,
				entityfieldinstancevaluelanguagetypeentityuuid = update_languagetypeuuid,
				entityfieldinstancemodifieddate = now(),
				entityfieldinstancemodifiedbyuuid = update_modifiedby
		where entityfieldinstanceentityinstanceentityuuid = update_customerentityuuid
				and  entityfieldinstanceentityfieldentityuuid = 'c51fbd4a-dbf5-40a2-892c-edaf81bee4ad';
end if;

	

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_customer_update(text,text,text,uuid,uuid,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,uuid,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customer_update(text,text,text,uuid,uuid,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,uuid,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customer_update(text,text,text,uuid,uuid,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,uuid,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_customer_update(text,text,text,uuid,uuid,uuid,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,uuid,text) TO graphql;
