
-- Type: PROCEDURE ; Name: entity.crud_entityfield_update(uuid,uuid,uuid,uuid,integer,text,uuid,uuid,uuid,text,uuid,uuid,boolean,boolean,boolean,boolean,boolean,boolean,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid); Owner: bombadil

CREATE OR REPLACE PROCEDURE entity.crud_entityfield_update(IN update_entityfielduuid uuid, IN update_entityfieldownerentityuuid uuid, IN update_entityfieldparententityuuid uuid, IN update_entityfieldtemplateentityuuid uuid, IN update_entityfieldcornerstoneorder integer, IN update_entityfieldname text, IN update_entityfieldtypeentityuuid uuid, IN update_entityfieldentityparenttypeentityuuid uuid, IN update_entityfieldentitytypeentityuuid uuid, IN update_entityfielddefaultvalue text, IN update_entityfieldformatentityuuid uuid, IN update_entityfieldwidgetentityuuid uuid, IN update_entityfieldiscalculated boolean, IN update_entityfieldiseditable boolean, IN update_entityfieldisvisible boolean, IN update_entityfieldisrequired boolean, IN update_entityfieldisprimary boolean, IN update_entityfieldtranslate boolean, IN update_entityfieldexternalid text, IN update_entityfieldexternalsystemuuid uuid, IN update_entityfielddeleted boolean, IN update_entityfielddraft boolean, IN update_entityfieldstartdate timestamp with time zone, IN update_entityfieldenddate timestamp with time zone, IN update_entityfieldmodifiedbyuuid text, IN update_languagetypeuuid uuid)
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

 if update_entityfielddraft = true or ((select entityfielddraft 
										from entity.entityfield
										WHERE entityfielduuid = update_entityfielduuid ) = true)
	then -- let everything change
		UPDATE entity.entityfield
			SET entityfieldownerentityuuid = case when update_entityfieldownerentityuuid notnull 
												then update_entityfieldownerentityuuid
												else entityfieldownerentityuuid end,	
				entityfieldparententityuuid = case when update_entityfieldparententityuuid notnull 
												then update_entityfieldparententityuuid
												else entityfieldparententityuuid end,
				entityfieldentitytemplateentityuuid = case when entityfieldentitytemplateentityuuid notnull 
												then update_entityfieldtemplateentityuuid
												else entityfieldentitytemplateentityuuid end,
				entityfieldorder = case when update_entityfieldcornerstoneorder notnull 
												then update_entityfieldcornerstoneorder
												else entityfieldorder end, 
				entityfieldtypeentityuuid = case when update_entityfieldtypeentityuuid notnull 
												then update_entityfieldtypeentityuuid
												else entityfieldtypeentityuuid end,
				entityfieldentityparenttypeentityuuid = case when update_entityfieldentityparenttypeentityuuid notnull 
												then update_entityfieldentityparenttypeentityuuid
												else entityfieldentityparenttypeentityuuid end,
				entityfieldentitytypeentityuuid = case when update_entityfieldentitytypeentityuuid notnull 
												then update_entityfieldentitytypeentityuuid
												else entityfieldentitytypeentityuuid end,
				entityfielddefaultvalue = update_entityfielddefaultvalue,
				entityfieldformatentityuuid = case when update_entityfieldformatentityuuid notnull 
												then update_entityfieldformatentityuuid
												else entityfieldformatentityuuid end,
				entityfieldwidgetentityuuid = case when update_entityfieldwidgetentityuuid notnull 
												then update_entityfieldwidgetentityuuid
												else entityfieldwidgetentityuuid end,
 				entityfieldname  = case when update_entityfieldname notnull and (coalesce(update_entityfieldname,'') <> '')
												then update_entityfieldname
												else entityfieldname end,
				entityfieldisprimary = case when update_entityfieldisprimary notnull 
												then update_entityfieldisprimary
												else entityfieldisprimary end,  
				entityfieldiscalculated = case when update_entityfieldiscalculated notnull 
												then update_entityfieldiscalculated
												else entityfieldiscalculated end,
				entityfieldiseditable = case when update_entityfieldiseditable notnull 
												then update_entityfieldiseditable
												else entityfieldiseditable end,											
				entityfieldisvisible = case when update_entityfieldisvisible notnull 
												then update_entityfieldisvisible
												else entityfieldisvisible end,
				entityfieldisrequired = case when update_entityfieldisrequired notnull 
												then update_entityfieldisrequired
												else entityfieldisrequired end,
				entityfieldtranslate = case when update_entityfieldtranslate notnull 
												then update_entityfieldtranslate
												else entityfieldtranslate end,
				entityfieldexternalid = case when update_entityfieldexternalid notnull 
												then update_entityfieldexternalid
												else entityfieldexternalid end,
				entityfieldexternalsystementityuuid = case when update_entityfieldexternalsystemuuid notnull 
														then update_entityfieldexternalsystemuuid
														else entityfieldexternalsystementityuuid end,
				entityfielddeleted = case when update_entityfielddeleted notnull 
										then update_entityfielddeleted
										else entityfielddeleted end, 
				entityfielddraft = case when update_entityfielddraft notnull 
										then update_entityfielddraft
										else entityfielddraft end,
				entityfieldstartdate = case when update_entityfieldstartdate notnull 
										then update_entityfieldstartdate
										else entityfieldstartdate end,
	 			entityfieldenddate = update_entityfieldenddate,
				entityfieldmodifieddate=now(),
				entityfieldmodifiedbyuuid = update_entityfieldmodifiedbyuuid
		WHERE entityfielduuid = update_entityfielduuid;
	Else -- trim the update to fields allowed to change
		UPDATE entity.entityfield
			SET entityfieldstartdate = case when update_entityfieldstartdate notnull 
										then update_entityfieldstartdate
										else entityfieldstartdate end,
				entityfieldorder = case when update_entityfieldcornerstoneorder notnull 
												then update_entityfieldcornerstoneorder
												else entityfieldorder end, 
				entityfielddefaultvalue = update_entityfielddefaultvalue,
				entityfieldformatentityuuid = case when update_entityfieldformatentityuuid notnull 
												then update_entityfieldformatentityuuid
												else entityfieldformatentityuuid end,
				entityfieldwidgetentityuuid = case when update_entityfieldwidgetentityuuid notnull 
												then update_entityfieldwidgetentityuuid
												else entityfieldwidgetentityuuid end,
 				entityfieldname  = case when update_entityfieldname notnull and (coalesce(update_entityfieldname,'') <> '')
												then update_entityfieldname
												else entityfieldname end,
				entityfieldiseditable = case when update_entityfieldiseditable notnull 
												then update_entityfieldiseditable
												else entityfieldiseditable end,											
				entityfieldisvisible = case when update_entityfieldisvisible notnull 
												then update_entityfieldisvisible
												else entityfieldisvisible end,
				entityfieldisrequired = case when update_entityfieldisrequired notnull 
												then update_entityfieldisrequired
												else entityfieldisrequired end,
				entityfieldtranslate = case when update_entityfieldtranslate notnull 
												then update_entityfieldtranslate
												else entityfieldtranslate end,
				entityfieldexternalid = case when update_entityfieldexternalid notnull 
												then update_entityfieldexternalid
												else entityfieldexternalid end,
				entityfieldexternalsystementityuuid = case when update_entityfieldexternalsystemuuid notnull 
														then update_entityfieldexternalsystemuuid
														else entityfieldexternalsystementityuuid end,
	 			entityfieldenddate = update_entityfieldenddate,
				entityfieldmodifieddate=now(),
				entityfieldmodifiedbyuuid = update_entityfieldmodifiedbyuuid
		WHERE entityfielduuid = update_entityfielduuid;
end if;

-- update the languagemaster if the name changed

if update_entityfieldname notNull and (coalesce(update_entityfieldname,'') <> '') 
	then
		update languagemaster
		set languagemastersource = entityfieldname,
			languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid =update_entityfieldmodifiedbyuuid),
			languagemastersourcelanguagetypeid = (select entityinstanceoriginalid from entity.entityinstance where entityinstanceuuid = update_languagetypeuuid),
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'		
		from entity.entityfield
		where entityfielduuid = update_entityfielduuid
			and languagemasteruuid = entityfieldlanguagemasteruuid
			and languagemastersource <> update_entityfieldname;
End if;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entityfield_update(uuid,uuid,uuid,uuid,integer,text,uuid,uuid,uuid,text,uuid,uuid,boolean,boolean,boolean,boolean,boolean,boolean,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfield_update(uuid,uuid,uuid,uuid,integer,text,uuid,uuid,uuid,text,uuid,uuid,boolean,boolean,boolean,boolean,boolean,boolean,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfield_update(uuid,uuid,uuid,uuid,integer,text,uuid,uuid,uuid,text,uuid,uuid,boolean,boolean,boolean,boolean,boolean,boolean,text,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,text,uuid) TO bombadil WITH GRANT OPTION;
