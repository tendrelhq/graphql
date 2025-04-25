
-- Type: PROCEDURE ; Name: entity.crud_location_update(uuid,uuid,uuid,uuid,integer,uuid,text,text,text,text,text,uuid,text,uuid,text,text,text,timestamp with time zone,timestamp with time zone,boolean,boolean,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_location_update(IN update_locationentityuuid uuid, IN update_locationownerentityuuid uuid, IN update_locationparententityuuid uuid, IN update_locationcornerstoneentityuuid uuid, IN update_locationcornerstoneorder integer, IN update_locationtaguuid uuid, IN update_locationtag text, IN update_locationname text, IN update_locationdisplayname text, IN update_locationscanid text, IN update_locationtimezone text, IN update_languagetypeuuid uuid, IN update_locationexternalid text, IN update_locationexternalsystemuuid uuid, IN update_locationlatitude text, IN update_locationlongitude text, IN update_locationradius text, IN update_locationstartdate timestamp with time zone, IN update_locationenddate timestamp with time zone, IN update_locationdeleted boolean, IN update_locationdraft boolean, IN update_modifiedby text)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	tempcustomeruuid text;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
	templocationid bigint;
Begin

/*
-- tests 

*/

if update_languagetypeuuid isNull 
	then update_languagetypeuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
End if;

templocationid =  (select entityinstanceoriginalid from entity.entityinstance where entityinstanceuuid = update_locationentityuuid);

-- simpify this.   update the draft values in the if statement.  The update all the common fields.  

if update_locationdraft = true or ((select entityinstancedraft 
										from entity.entityinstance
										WHERE entityinstanceuuid = update_locationentityuuid ) = true)
	then -- let everything change
		UPDATE entity.entityinstance
			SET entityinstanceownerentityuuid = case when update_locationownerentityuuid notnull 
												then update_locationownerentityuuid
												else entityinstanceownerentityuuid end,
 				entityinstancedeleted = case when update_locationdeleted notnull 
										then update_locationdeleted
										else entityinstancedeleted end, 
				entityinstancedraft = case when update_locationdraft notnull 
										then update_locationdraft
										else entityinstancedraft end
		WHERE entityinstanceuuid = update_locationentityuuid;

		update public.location
			set locationcustomerid = case when update_locationownerentityuuid notnull 
											then (select locationcustomerid from entity.crud_location_read_min(update_locationownerentityuuid ,update_locationparententityuuid ,null,null,false,null,null,null,null,update_languagetypeuuid))
											else locationcustomerid end
		where locationid =  templocationid;
end if;

-- update common fields between draft and published
UPDATE entity.entityinstance
	SET entityinstanceparententityuuid = case when update_locationparententityuuid notnull 
										then update_locationparententityuuid
										else entityinstanceparententityuuid end,
		entityinstancetype = case when update_locationname notnull and (coalesce(update_locationname,'') <> '')
										then update_locationname
										else entityinstancetype end,
		entityinstanceexternalid = case when update_locationexternalid notnull 
										then update_locationexternalid
										else entityinstanceexternalid end,	
		entityinstanceexternalsystementityuuid = case when update_locationexternalsystemuuid notnull 
												then update_locationexternalsystemuuid
												else entityinstanceexternalsystementityuuid end,
		entityinstancecornerstoneentityuuid = case when update_locationcornerstoneentityuuid notnull 
												then update_locationcornerstoneentityuuid
												else entityinstancecornerstoneentityuuid end,
		entityinstancecornerstoneorder = case when update_locationcornerstoneorder notnull 
										then update_locationcornerstoneorder
										else entityinstancecornerstoneorder end,
		entityinstancescanid = case when update_locationscanid notnull 
										then update_locationscanid
										else entityinstancescanid end, 
		entityinstancedeleted = case when update_locationdeleted notnull 
								then update_locationdeleted
								else entityinstancedeleted end, 
		entityinstancestartdate = case when update_locationstartdate notnull 
								then update_locationstartdate
								else entityinstancestartdate end,
		entityinstanceenddate = update_locationenddate,
		entityinstancemodifieddate =now(),
		entityinstancemodifiedbyuuid = update_modifiedby
WHERE entityinstanceuuid = update_locationentityuuid;

update public.location
	set locationsiteid = case when update_locationparententityuuid notnull 
										then (select locationid from entity.crud_location_read_min(update_locationownerentityuuid ,update_locationparententityuuid ,null,null,false,null,null,null,null,update_languagetypeuuid))
										else locationsiteid end,
		locationparentid = case when update_locationparententityuuid notnull 
										then (select locationid from entity.crud_location_read_min(update_locationownerentityuuid ,update_locationparententityuuid ,null,null,false,null,null,null,null,update_languagetypeuuid))
										else locationparentid end,
		locationcornerstoneid = case when update_locationparententityuuid notnull 
										then (select locationid from entity.crud_location_read_min(update_locationownerentityuuid ,update_locationcornerstoneentityuuid ,null,null,false,null,null,null,null,update_languagetypeuuid))
										else locationcornerstoneid end,
		locationcornerstoneorder = case when update_locationcornerstoneorder notnull 
										then update_locationcornerstoneorder
										else locationcornerstoneorder end,
		locationlookupname = case when update_locationname notnull and (coalesce(update_locationname,'') <> '')
										then update_locationname
										else locationlookupname end, 
		locationscanid = case when update_locationscanid notnull 
										then update_locationscanid
										else locationscanid end, 
		locationstartdate = case when update_locationstartdate notnull 
								then update_locationstartdate
								else locationstartdate end,
		locationenddate = update_locationenddate,
		locationmodifieddate = now(),
		locationexternalid = case when update_locationexternalid notnull 
										then update_locationexternalid
										else locationexternalid end,	
		locationexternalsystemid = case when update_locationexternalsystemuuid notnull 
												then (select systagid from entity.crud_systag_read_min(update_locationownerentityuuid, null,update_locationexternalsystemuuid, null, false,null,null, null,update_languagetypeuuid))
												else locationexternalsystemid end,			
		locationmodifiedby =  (select workerinstanceid from workerinstance where workerinstanceuuid = update_modifiedby)
where locationid =  templocationid;

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,update_locationentityuuid,null,false,null,null,null, null);

select systagid,systaguuid into templanguagetypeid,templanguagetypeuuid
	from entity.crud_systag_read_min(null, null, update_languagetypeuuid, null, false,null,null, null,update_languagetypeuuid);

		-- update the languagemaster if the name changed
if  update_locationname notNull and (coalesce(update_locationname,'') <> '')
	then
		update languagemaster
			set languagemastersourcelanguagetypeid = templanguagetypeid,
				languagemastersource = update_locationname,
				languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = update_modifiedby),
				languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'		
			from entity.entityinstance
			where entityinstanceuuid = update_locationentityuuid
				and languagemasteruuid = entityinstancenameuuid
				and languagemastersource <> update_locationname;
end if;

	-- update displayname in languagemaster
if  update_locationdisplayname notNull and (coalesce(update_locationdisplayname,'') <> '')
	then
		update public.languagemaster
			set languagemastersourcelanguagetypeid = templanguagetypeid,
				languagemastersource = update_locationdisplayname,
				languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = update_modifiedby),
				languagemastermodifieddate = now(),
				languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'					
		where languagemasteruuid = (select entityfieldinstancevaluelanguagemasteruuid 
									from entity.entityfieldinstance
									where entityfieldinstanceentityinstanceentityuuid = update_locationentityuuid
										and  entityfieldinstanceentityfieldentityuuid = '7bba0fd0-19f4-4984-b8e2-431a5f6c70d0');

		update entity.entityfieldinstance
			set entityfieldinstancevalue = update_locationdisplayname,
				entityfieldinstancevaluelanguagetypeentityuuid = update_languagetypeuuid,
				entityfieldinstancemodifieddate = now(),
				entityfieldinstancemodifiedbyuuid = update_modifiedby
		where entityfieldinstanceentityinstanceentityuuid = update_locationentityuuid
				and  entityfieldinstanceentityfieldentityuuid = '7bba0fd0-19f4-4984-b8e2-431a5f6c70d0';
end if;

	-- update locationtimezone
if  update_locationtimezone notNull and (coalesce(update_locationtimezone,'') <> '')
	then		
		update public.languagemaster
			set languagemastersourcelanguagetypeid = templanguagetypeid,
				languagemastersource = update_locationtimezone,
				languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = update_modifiedby),
				languagemastermodifieddate = now()				
		where languagemasteruuid = (select entityfieldinstancevaluelanguagemasteruuid 
									from entity.entityfieldinstance
									where entityfieldinstanceentityinstanceentityuuid = update_locationentityuuid
										and  entityfieldinstanceentityfieldentityuuid = '2a69677c-b23a-4407-b2ae-1905f0640579');

		update entity.entityfieldinstance
			set entityfieldinstancevalue = update_locationtimezone,
				entityfieldinstancevaluelanguagetypeentityuuid = update_languagetypeuuid,
				entityfieldinstancemodifieddate = now(),
				entityfieldinstancemodifiedbyuuid = update_modifiedby
		where entityfieldinstanceentityinstanceentityuuid = update_locationentityuuid
				and  entityfieldinstanceentityfieldentityuuid = '2a69677c-b23a-4407-b2ae-1905f0640579';
end if;

	-- update locationlatitude
if  update_locationlatitude notNull 
	then		
		update entity.entityfieldinstance
			set entityfieldinstancevalue = update_locationlatitude,
				entityfieldinstancevaluelanguagetypeentityuuid = update_languagetypeuuid,
				entityfieldinstancemodifieddate = now(),
				entityfieldinstancemodifiedbyuuid = update_modifiedby
		where entityfieldinstanceentityinstanceentityuuid = update_locationentityuuid
				and  entityfieldinstanceentityfieldentityuuid = 'db4dfca7-2a2c-45d1-a4ec-f749c48d5ddf';
end if;

	-- update locationlongitude
if  update_locationlongitude notNull 
	then		
		update entity.entityfieldinstance
			set entityfieldinstancevalue = update_locationlongitude,
				entityfieldinstancevaluelanguagetypeentityuuid = update_languagetypeuuid,
				entityfieldinstancemodifieddate = now(),
				entityfieldinstancemodifiedbyuuid = update_modifiedby
		where entityfieldinstanceentityinstanceentityuuid = update_locationentityuuid
				and  entityfieldinstanceentityfieldentityuuid = '37e49e9e-9700-432f-a384-2e68f2279b50';
end if;

	-- update locationradius
if  update_locationradius notNull 
	then		
		update entity.entityfieldinstance
			set entityfieldinstancevalue = update_locationradius,
				entityfieldinstancevaluelanguagetypeentityuuid = update_languagetypeuuid,
				entityfieldinstancemodifieddate = now(),
				entityfieldinstancemodifiedbyuuid = update_modifiedby
		where entityfieldinstanceentityinstanceentityuuid = update_locationentityuuid
				and  entityfieldinstanceentityfieldentityuuid = '421b26da-1529-4951-a0ef-9dfb0d18e413';
end if;

-- set the location indicators
update public.location
set locationistop = true
where locationsiteid = locationid
	and locationistop = false
	and locationid = templocationid;

update public.location
set locationiscornerstone = true
where locationcornerstoneid = locationid
	and locationiscornerstone = false
	and locationid = templocationid;

update public.location
set locationistop = false
where locationsiteid <> locationid
	and locationistop = true
	and locationid = templocationid;

update public.location
set locationiscornerstone = false
where locationcornerstoneid <> locationid
	and locationiscornerstone = true
	and locationid = templocationid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_location_update(uuid,uuid,uuid,uuid,integer,uuid,text,text,text,text,text,uuid,text,uuid,text,text,text,timestamp with time zone,timestamp with time zone,boolean,boolean,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_location_update(uuid,uuid,uuid,uuid,integer,uuid,text,text,text,text,text,uuid,text,uuid,text,text,text,timestamp with time zone,timestamp with time zone,boolean,boolean,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_location_update(uuid,uuid,uuid,uuid,integer,uuid,text,text,text,text,text,uuid,text,uuid,text,text,text,timestamp with time zone,timestamp with time zone,boolean,boolean,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_location_update(uuid,uuid,uuid,uuid,integer,uuid,text,text,text,text,text,uuid,text,uuid,text,text,text,timestamp with time zone,timestamp with time zone,boolean,boolean,text) TO graphql;
