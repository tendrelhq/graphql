
-- Type: PROCEDURE ; Name: entity.crud_entityfileinstance_create(uuid,uuid,uuid,text,uuid,uuid,boolean,boolean,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entityfileinstance_create(IN create_entityfileinstanceownerentityuuid uuid, IN create_entityfileinstanceentityentityinstanceentityuuid uuid, IN create_entityfileinstanceentityfieldinstanceentityuuid uuid, IN create_entityfileinstancestoragelocation text, IN create_entityfileinstancemimetypeuuid uuid, IN create_languagetypeuuid uuid, IN create_entityfileinstancedeleted boolean, IN create_entityfileinstancedraft boolean, OUT create_entityfileinstanceentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
 
Declare
	templanguagetypeentityuuid uuid;	
	tempentityfileinstanceownerentityuuid uuid;
	tempcustomeruuid text;
	tempcustomerid bigint;
	tendreluuid uuid;
	tempentityfileinstancemimetypeuuid uuid;
	tempentityfileinstancedeleted boolean;
	tempentityfileinstancedraft boolean;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
	templanguagemasteruuid text;	
	
Begin

/*
-- tests needed
	-- mime types
	select * from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,null)

	-- bogus owner fail
		call entity.crud_entityfileinstance_create(
			'744feee2-a676-41fc-8e03-a70e54e9f8e8', -- IN create_entityfileinstanceownerentityuuid uuid,
			'744feee2-a676-41fc-8e03-a70e54e9f8e8', -- IN create_entityfileinstanceentityentityinstanceentityuuid uuid,
			'a89f6687-dcb1-423d-8906-7ab1b3a49892', -- IN create_entityfileinstanceentityfieldinstanceentityuuid uuid,
			'storagelocation '||now()::text, -- IN create_entityfileinstancestoragelocation text,
			'c262c14c-7f33-4a51-b11a-b65892b59d0e', -- IN create_entityfileinstancemimetypeuuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null, -- IN create_entityfileinstancedeleted boolean,
			null, -- IN create_entityfileinstancedraft boolean,
			null, -- OUT create_entityfileinstanceentityuuid uuid,
			337)
			
	-- no instance or  field instance then error 
		call entity.crud_entityfileinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfileinstanceownerentityuuid uuid,
			null, -- IN create_entityfileinstanceentityentityinstanceentityuuid uuid,
			null, -- IN create_entityfileinstanceentityfieldinstanceentityuuid uuid,
			'storagelocation '||now()::text, -- IN create_entityfileinstancestoragelocation text,
			'c262c14c-7f33-4a51-b11a-b65892b59d0e', -- IN create_entityfileinstancemimetypeuuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null, -- IN create_entityfileinstancedeleted boolean,
			null, -- IN create_entityfileinstancedraft boolean,
			null, -- OUT create_entityfileinstanceentityuuid uuid,
			337)

	-- no storage location
		call entity.crud_entityfileinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfileinstanceownerentityuuid uuid,
			'744feee2-a676-41fc-8e03-a70e54e9f8e8', -- IN create_entityfileinstanceentityentityinstanceentityuuid uuid,
			'a89f6687-dcb1-423d-8906-7ab1b3a49892', -- IN create_entityfileinstanceentityfieldinstanceentityuuid uuid,
			null, -- IN create_entityfileinstancestoragelocation text,
			'c262c14c-7f33-4a51-b11a-b65892b59d0e', -- IN create_entityfileinstancemimetypeuuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null, -- IN create_entityfileinstancedeleted boolean,
			null, -- IN create_entityfileinstancedraft boolean,
			null, -- OUT create_entityfileinstanceentityuuid uuid,
			337)
	
	-- add description to template


	-- add File to field instance
		call entity.crud_entityfileinstance_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfileinstanceownerentityuuid uuid,
			'744feee2-a676-41fc-8e03-a70e54e9f8e8', -- IN create_entityfileinstanceentityentityinstanceentityuuid uuid,
			'a89f6687-dcb1-423d-8906-7ab1b3a49892', -- IN create_entityfileinstanceentityfieldinstanceentityuuid uuid,
			'storagelocation '||now()::text, -- IN create_entityfileinstancestoragelocation text,
			'c262c14c-7f33-4a51-b11a-b65892b59d0e', -- IN create_entityfileinstancemimetypeuuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null, -- IN create_entityfileinstancedeleted boolean,
			null, -- IN create_entityfileinstancedraft boolean,
			null, -- OUT create_entityfileinstanceentityuuid uuid,
			337)
		
select * from entity.entityfieldinstance where entityfieldinstanceuuid = 'a89f6687-dcb1-423d-8906-7ab1b3a49892'
*/


tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if create_entityfileinstanceownerentityuuid isNull
	then tempentityfileinstanceownerentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid; -- default is customer 0.  Could look this up instead.  
	else tempentityfileinstanceownerentityuuid = create_entityfileinstanceownerentityuuid;
end if;

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
					from entity.crud_customer_read_min(null,tempentityfileinstanceownerentityuuid,null,false,null,null,null, null);

-- probably return an error if the entity is not set to a customer.  Need to sort this out.  
if tempcustomerid isNull
	then return;
end if;

-- setup the language type

if create_languagetypeuuid isNull
	then templanguagetypeentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
	else templanguagetypeentityuuid = create_languagetypeuuid;
end if;

select systagid,systaguuid into templanguagetypeid,templanguagetypeuuid
	from entity.crud_systag_read_min(null, null, templanguagetypeentityuuid, null, false,null,null, null,templanguagetypeentityuuid);

-- one of these can't be null. 

if 	(create_entityfileinstanceentityentityinstanceentityuuid isNull 
		and create_entityfileinstanceentityfieldinstanceentityuuid isNull)
	then return;
end if;

-- storagelocation can't be null

if 	(create_entityfileinstancestoragelocation isNull and coalesce(create_entityfileinstancestoragelocation, '') = '')
	then return;
end if;

-- Check for valid mime type 

if create_entityfileinstancemimetypeuuid in (
	select systagentityuuid from entity.crud_systag_read_min(tendreluuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,templanguagetypeentityuuid)
	)
	then tempentityfileinstancemimetypeuuid = create_entityfileinstancemimetypeuuid;
	else return;
end if;

If create_entityfileinstancedeleted isNull
	then tempentityfileinstancedeleted = false;
	else tempentityfileinstancedeleted = create_entityfileinstancedeleted;
end if;

If create_entityfileinstancedraft isNull
	then tempentityfileinstancedraft = false;
	else tempentityfileinstancedraft = create_entityfileinstancedraft;
end if;

-- time to insert the base entity tables

INSERT INTO entity.entityfileinstance(
	entityfileinstanceownerentityuuid, 
	entityfileinstanceentityentityinstanceentityuuid, 
	entityfileinstanceentityfieldinstanceentityuuid, 
	entityfileinstancestoragelocation, 
	entityfileinstancemimetypeuuid, 
	entityfileinstancecreateddate, 
	entityfileinstancemodifieddate, 
	entityfileinstanceexternalid, 
	entityfileinstancemodifiedby, 
	entityfileinstancerefid, 
	entityfileinstancerefuuid, 
	entityfileinstancedraft, 
	entityfileinstancedeleted, 
	entityfileinstanceexternalsystemuuid)
values(
	tempentityfileinstanceownerentityuuid,
	create_entityfileinstanceentityentityinstanceentityuuid,
	create_entityfileinstanceentityfieldinstanceentityuuid,
	create_entityfileinstancestoragelocation,
	tempentityfileinstancemimetypeuuid,
	now(),
	now(),
	null,
	(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid), 
	null,
	null,
	tempentityfileinstancedraft,
	tempentityfileinstancedeleted,
	null)
	Returning entityfileinstanceuuid into create_entityfileinstanceentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entityfileinstance_create(uuid,uuid,uuid,text,uuid,uuid,boolean,boolean,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfileinstance_create(uuid,uuid,uuid,text,uuid,uuid,boolean,boolean,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfileinstance_create(uuid,uuid,uuid,text,uuid,uuid,boolean,boolean,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfileinstance_create(uuid,uuid,uuid,text,uuid,uuid,boolean,boolean,bigint) TO graphql;
