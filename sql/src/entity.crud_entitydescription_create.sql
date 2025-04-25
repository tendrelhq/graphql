
-- Type: PROCEDURE ; Name: entity.crud_entitydescription_create(uuid,uuid,uuid,text,text,text,text,uuid,uuid,boolean,boolean,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entitydescription_create(IN create_entitydescriptionownerentityuuid uuid, IN create_entitytemplateentityuuid uuid, IN create_entityfieldentityuuid uuid, IN create_entitydescriptionname text, IN create_entitydescriptionsoplink text, IN create_entitydescriptionfile text, IN create_entitydescriptionicon text, IN create_entitydescriptionmimetypeuuid uuid, IN create_languagetypeuuid uuid, IN create_entitydescriptiondeleted boolean, IN create_entitydescriptiondraft boolean, OUT create_entitydescriptionentityuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
 
Declare
	templanguagetypeentityuuid uuid;	
	tempentitydescriptionownerentityuuid uuid;
	tempcustomeruuid text;
	tempcustomerid bigint;
	tendreluuid uuid;
	tempentitydescriptionmimetypeuuid uuid;
	tempentitydescriptiondeleted boolean;
	tempentitydescriptiondraft boolean;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
	templanguagemasteruuid text;	
	
Begin

/*



-- tests needed
	-- need a valid tempalte and filed to work with.  Probably geneerate these.
	select * from entity.entityfield
	where entityfieldownerentityuuid = '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'

	-- mime types
	select * from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,null)


	-- bogus owner fail
	call entity.crud_entitydescription_create(
		'c77db174-7b16-4f47-b138-b56766375449', --IN create_entitydescriptionownerentityuuid uuid,
		'274541f8-5c9f-4e8c-9982-08c35b79e2b3', --	IN create_entitytemplateentityuuid uuid,
		'07d6a055-2d39-4f0f-bcc1-0c61e5cabe0c', --	IN create_entityfieldentityuuid uuid,
		'Test Description '||now()::text, --	IN create_entitydescriptionname text,
		null, --	IN create_entitydescriptionsoplink text,
		null, --	IN create_entitydescriptionfile text,
		null, --	IN create_entitydescriptionicon text,
		null, --	IN create_entitydescriptionmimetypeuuid uuid,
		null, --	IN create_languagetypeuuid uuid,
		null, --	IN create_entitydescriptiondeleted boolean,
		null, --	IN create_entitydescriptiondraft boolean,
		null, -- OUT create_entitydescriptionentityuuid uuid,
		337 )

	-- no field or template then error 
	call entity.crud_entitydescription_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --IN create_entitydescriptionownerentityuuid uuid,
		null, --	IN create_entitytemplateentityuuid uuid,
		null, --	IN create_entityfieldentityuuid uuid,
		'Test Description '||now()::text, --	IN create_entitydescriptionname text,
		null, --	IN create_entitydescriptionsoplink text,
		null, --	IN create_entitydescriptionfile text,
		null, --	IN create_entitydescriptionicon text,
		null, --	IN create_entitydescriptionmimetypeuuid uuid,
		null, --	IN create_languagetypeuuid uuid,
		null, --	IN create_entitydescriptiondeleted boolean,
		null, --	IN create_entitydescriptiondraft boolean,
		null, -- OUT create_entitydescriptionentityuuid uuid,
		337 )



	-- no descriptionname, soplink, file, or icon the error
	call entity.crud_entitydescription_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --IN create_entitydescriptionownerentityuuid uuid,
		'274541f8-5c9f-4e8c-9982-08c35b79e2b3', --	IN create_entitytemplateentityuuid uuid,
		'07d6a055-2d39-4f0f-bcc1-0c61e5cabe0c', --	IN create_entityfieldentityuuid uuid,
		null, --	IN create_entitydescriptionname text,
		null, --	IN create_entitydescriptionsoplink text,
		null, --	IN create_entitydescriptionfile text,
		null, --	IN create_entitydescriptionicon text,
		null, --	IN create_entitydescriptionmimetypeuuid uuid,
		null, --	IN create_languagetypeuuid uuid,
		null, --	IN create_entitydescriptiondeleted boolean,
		null, --	IN create_entitydescriptiondraft boolean,
		null, -- OUT create_entitydescriptionentityuuid uuid,
		337 )
	
	-- add description to template
	call entity.crud_entitydescription_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --IN create_entitydescriptionownerentityuuid uuid,
		'274541f8-5c9f-4e8c-9982-08c35b79e2b3', --	IN create_entitytemplateentityuuid uuid,
		null, --	IN create_entityfieldentityuuid uuid,
		'Test Description '||now()::text, --	IN create_entitydescriptionname text,
		null, --	IN create_entitydescriptionsoplink text,
		null, --	IN create_entitydescriptionfile text,
		null, --	IN create_entitydescriptionicon text,
		null, --	IN create_entitydescriptionmimetypeuuid uuid,
		null, --	IN create_languagetypeuuid uuid,
		null, --	IN create_entitydescriptiondeleted boolean,
		null, --	IN create_entitydescriptiondraft boolean,
		null, -- OUT create_entitydescriptionentityuuid uuid,
		337 )

	-- add description to field 
	call entity.crud_entitydescription_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', --IN create_entitydescriptionownerentityuuid uuid,
		null, --	IN create_entitytemplateentityuuid uuid,
		'07d6a055-2d39-4f0f-bcc1-0c61e5cabe0c', --	IN create_entityfieldentityuuid uuid,
		'Test Description '||now()::text, --	IN create_entitydescriptionname text,
		null, --	IN create_entitydescriptionsoplink text,
		null, --	IN create_entitydescriptionfile text,
		null, --	IN create_entitydescriptionicon text,
		null, --	IN create_entitydescriptionmimetypeuuid uuid,
		null, --	IN create_languagetypeuuid uuid,
		null, --	IN create_entitydescriptiondeleted boolean,
		null, --	IN create_entitydescriptiondraft boolean,
		null, -- OUT create_entitydescriptionentityuuid uuid,
		337 )

	-- need a test in the future loading a file.  

select * from entity.entitydescription
*/


tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if create_entitydescriptionownerentityuuid isNull
	then tempentitydescriptionownerentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid; -- default is customer 0.  Could look this up instead.  
	else tempentitydescriptionownerentityuuid = create_entitydescriptionownerentityuuid;
end if;

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
					from entity.crud_customer_read_min(null,tempentitydescriptionownerentityuuid,null,false,null,null,null, null);

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

if 	(create_entitytemplateentityuuid isNull 
		and create_entityfieldentityuuid isNull)
	then return;
end if;

-- we need something to not be null

if 	(create_entitydescriptionname isNull and coalesce(create_entitydescriptionname, '') = ''
	and create_entitydescriptionsoplink isNull and coalesce(create_entitydescriptionname, '') = ''
	and create_entitydescriptionfile isNull and coalesce(create_entitydescriptionfile, '') = ''
	and create_entitydescriptionicon isNull and coalesce(create_entitydescriptionicon, '') = '')
	then return;
end if;

-- Check for valid mime type -- mime type is only for file.  

if create_entitydescriptionmimetypeuuid in (
	select systagentityuuid from entity.crud_systag_read_min(tendreluuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,templanguagetypeentityuuid)
	)
	then tempentitydescriptionmimetypeuuid = create_entitydescriptionmimetypeuuid;
	else tempentitydescriptionmimetypeuuid = null;
end if;

If create_entitydescriptiondeleted isNull
	then tempentitydescriptiondeleted = false;
	else tempentitydescriptiondeleted = create_entitydescriptiondeleted;
end if;

If create_entitydescriptiondraft isNull
	then tempentitydescriptiondraft = false;
	else tempentitydescriptiondraft = create_entitydescriptiondraft;
end if;

-- time to insert the base entity tables

-- insert name into languagemaster
	insert into public.languagemaster
		(languagemastercustomerid,
		languagemastersourcelanguagetypeid,
		languagemastersource,
		languagemastermodifiedby)
	values(tempcustomerid,
		templanguagetypeid, 	
		create_entitydescriptionname,    
		create_modifiedbyid)  
	Returning languagemasteruuid into templanguagemasteruuid;

INSERT INTO entity.entitydescription(
	entitydescriptionownerentityuuid, 
	entitydescriptionentitytemplateentityuuid, 
	entitydescriptionentityfieldentityduuid, 
	entitydescriptionname, 
	entitydescriptionsoplink, 
	entitydescriptionfile, 
	entitydescriptionicon, 
	entitydescriptionlanguagemasteruuid, 
	entitydescriptioncreateddate, 
	entitydescriptionmodifieddate, 
	entitydescriptionstartdate, 
	entitydescriptionenddate, 
	entitydescriptionmodifiedby, 
	entitydescriptionexternalid, 
	entitydescriptionexternalsystementityuuid, 
	entitydescriptionrefid, 
	entitydescriptionrefuuid, 
	entitydescriptiondraft, 
	entitydescriptiondeleted, 
	entitydescriptionmimetypeuuid)
values(
	tempentitydescriptionownerentityuuid, 
	create_entitytemplateentityuuid , 
	create_entityfieldentityuuid , 
	create_entitydescriptionname, 
	create_entitydescriptionsoplink, 
	create_entitydescriptionfile, 
	create_entitydescriptionicon, 
	templanguagemasteruuid, 
	now(), 
	now(), 
	now(), 
	null, 
	(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid), 
	null, 
	null, 
	null, 
	null, 
	tempentitydescriptiondraft , 
	tempentitydescriptiondeleted, 
	tempentitydescriptionmimetypeuuid
)
	Returning entitydescriptionuuid into create_entitydescriptionentityuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entitydescription_create(uuid,uuid,uuid,text,text,text,text,uuid,uuid,boolean,boolean,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitydescription_create(uuid,uuid,uuid,text,text,text,text,uuid,uuid,boolean,boolean,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entitydescription_create(uuid,uuid,uuid,text,text,text,text,uuid,uuid,boolean,boolean,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_entitydescription_create(uuid,uuid,uuid,text,text,text,text,uuid,uuid,boolean,boolean,bigint) TO graphql;
