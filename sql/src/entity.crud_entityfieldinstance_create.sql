BEGIN;

/*
DROP PROCEDURE entity.crud_entityfieldinstance_create(uuid,uuid,uuid,text,text,uuid,text,uuid,text,text,uuid,boolean,boolean,uuid,bigint);
*/


-- Type: PROCEDURE ; Name: entity.crud_entityfieldinstance_create(uuid,uuid,uuid,text,text,uuid,text,uuid,text,text,uuid,boolean,boolean,uuid,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_entityfieldinstance_create(IN create_entityfieldinstanceownerentityuuid uuid, IN create_entityfieldinstanceentityinstanceentityuuid uuid, IN create_entityfieldinstanceentityfieldentityuuid uuid, IN create_entityfieldinstancevalue text, IN create_entityfieldinstanceentityfieldname text, IN create_entityfieldformatentityuuid uuid, IN create_entityfieldformatentityname text, IN create_entityfieldwidgetentityuuid uuid, IN create_entityfieldwidgetentityname text, IN create_entityfieldinstanceexternalid text, IN create_entityfieldinstanceexternalsystemuuid uuid, IN create_entityfieldinstancedeleted boolean, IN create_entityfieldinstancedraft boolean, OUT create_entityfieldinstanceentityuuid uuid, IN create_languagetypeuuid uuid, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tendreluuid uuid;
	tempentityfieldinstanceownerentityuuid uuid;
	tempentityfieldinstanceentityinstanceentityuuid uuid;
	tempentityfieldinstanceentityfieldentityuuid uuid;
	tempcustagid bigint;
	tempcustaguuid text;
	tempentityinstanceownerentityuuid uuid;
	tempentityinstanceentitytemplateentityuuid uuid;
	tempentityfieldinstanceentitytemplateentityuuid uuid;
	templanguagetypeentityuuid uuid;
	tempentityfieldinstanceentityuuid uuid;  -- return value
	tempentityinstancedeleted boolean;
	tempentityinstancedraft boolean;
	tempentityfieldinstanceentityfieldname text;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
 	templanguagemasteruuid text;
	tempcustomerid bigint;
	tempcustomeruuid text;	
	tempentityinstanceuuid uuid;

Begin

/*  Future New
-- Lazy init version
-- create_entityfieldinstancevalue validated?
-- Languagemaster create to be smarter than it is.  Maybe even a function.  (Should only do language master on strings)
-- Validate externalsystem
-- externalsystemuuid vs externalsystementityuuid - one is a systag, but we are not handling this well.  Keep both?  
-- Duplicate checking of field instance creation.

interesting sql:
-- 	select unnest(array['test','test2'])
--	FOREACH tempcustagentityuuid IN ARRAY tempentitytagcustagentityuuid
	LOOP 
		call entity.crud_entitytag_create(tempentityinstanceownerentityuuid,tempentityinstanceuuid,tempcustagentityuuid,tempentitytagcustagentityuuid, null, null, null, null, create_modifiedbyid);
	END LOOP;
*/

/*  Testing

-- select * from entity.entityfield where entityfieldownerentityuuid = '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'
-- select * from entity.entityinstance where entityinstanceentitytemplateentityuuid = '274541f8-5c9f-4e8c-9982-08c35b79e2b3'
-- select * from entity.entityinstance where entityinstanceownerentityuuid = '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0'

-- error if owner isNull or entityinstanceentityuuid isNull or fieldentityuuid isNull
	call entity.crud_entityfieldinstance_create(
		null,-- IN create_entityfieldinstanceownerentityuuid uuid,
		null,-- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
		null,-- IN create_entityfieldinstanceentityfieldentityuuid uuid,
		'test value'||now()::text,-- IN create_entityfieldinstancevalue text,
		null,-- IN create_entityfieldinstanceentityfieldname text,
		null,-- IN create_entityfieldformatentityuuid uuid,
		null,-- IN create_entityfieldformatentityname text,
		null,-- IN create_entityfieldwidgetentityuuid uuid,
		null,-- IN create_entityfieldwidgetentityname text,
		null,-- IN create_entityfieldinstanceexternalid text,
		null,-- IN create_entityfieldinstanceexternalsystemuuid uuid,
		null,-- IN create_entityfieldinstancedeleted boolean,
		null,-- IN create_entityfieldinstancedraft boolean,
		null,-- OUT create_entityfieldinstanceentityuuid uuid,
		null,-- IN create_languagetypeuuid uuid,
		337)

-- invalid customer
	call entity.crud_entityfieldinstance_create(
		'c77db174-7b16-4f47-b138-b56766375449',-- IN create_entityfieldinstanceownerentityuuid uuid,
		'744feee2-a676-41fc-8e03-a70e54e9f8e8',-- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
		'ee3de35e-47e8-4590-a71f-6070abe760c7',-- IN create_entityfieldinstanceentityfieldentityuuid uuid,
		'test value'||now()::text,-- IN create_entityfieldinstancevalue text,
		null,-- IN create_entityfieldinstanceentityfieldname text,
		null,-- IN create_entityfieldformatentityuuid uuid,
		null,-- IN create_entityfieldformatentityname text,
		null,-- IN create_entityfieldwidgetentityuuid uuid,
		null,-- IN create_entityfieldwidgetentityname text,
		null,-- IN create_entityfieldinstanceexternalid text,
		null,-- IN create_entityfieldinstanceexternalsystemuuid uuid,
		null,-- IN create_entityfieldinstancedeleted boolean,
		null,-- IN create_entityfieldinstancedraft boolean,
		null,-- OUT create_entityfieldinstanceentityuuid uuid,
		null,-- IN create_languagetypeuuid uuid,
		337)

-- invalid owner instance combo
	call entity.crud_entityfieldinstance_create(
		'f90d618d-5de7-4126-8c65-0afb700c6c61',-- IN create_entityfieldinstanceownerentityuuid uuid,
		'744feee2-a676-41fc-8e03-a70e54e9f8e8',-- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
		'ee3de35e-47e8-4590-a71f-6070abe760c7',-- IN create_entityfieldinstanceentityfieldentityuuid uuid,
		'test value'||now()::text,-- IN create_entityfieldinstancevalue text,
		null,-- IN create_entityfieldinstanceentityfieldname text,
		null,-- IN create_entityfieldformatentityuuid uuid,
		null,-- IN create_entityfieldformatentityname text,
		null,-- IN create_entityfieldwidgetentityuuid uuid,
		null,-- IN create_entityfieldwidgetentityname text,
		null,-- IN create_entityfieldinstanceexternalid text,
		null,-- IN create_entityfieldinstanceexternalsystemuuid uuid,
		null,-- IN create_entityfieldinstancedeleted boolean,
		null,-- IN create_entityfieldinstancedraft boolean,
		null,-- OUT create_entityfieldinstanceentityuuid uuid,
		null,-- IN create_languagetypeuuid uuid,
		337)

-- invalid templateid
	-- no test written yet

-- valid insert
	call entity.crud_entityfieldinstance_create(
		'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0',-- IN create_entityfieldinstanceownerentityuuid uuid,
		'744feee2-a676-41fc-8e03-a70e54e9f8e8',-- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
		'ee3de35e-47e8-4590-a71f-6070abe760c7',-- IN create_entityfieldinstanceentityfieldentityuuid uuid,
		'test value'||now()::text,-- IN create_entityfieldinstancevalue text,
		null,-- IN create_entityfieldinstanceentityfieldname text,
		null,-- IN create_entityfieldformatentityuuid uuid,
		null,-- IN create_entityfieldformatentityname text,
		null,-- IN create_entityfieldwidgetentityuuid uuid,
		null,-- IN create_entityfieldwidgetentityname text,
		null,-- IN create_entityfieldinstanceexternalid text,
		null,-- IN create_entityfieldinstanceexternalsystemuuid uuid,
		null,-- IN create_entityfieldinstancedeleted boolean,
		null,-- IN create_entityfieldinstancedraft boolean,
		null,-- OUT create_entityfieldinstanceentityuuid uuid,
		null,-- IN create_languagetypeuuid uuid,
		337)


*/

-- constanneeded when looking up entity templates and fields 
-- entity templatse and field are owned by the customer and tendrel
tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

-- validate mandatory fields  
-- might want to split this into 3 checks so each retun can be a unique error
if (create_entityfieldinstanceownerentityuuid isNull
		or create_entityfieldinstanceentityinstanceentityuuid isNull
		or create_entityfieldinstanceentityfieldentityuuid isNull)
	then return; -- need an error code  
	else tempentityfieldinstanceownerentityuuid = create_entityfieldinstanceownerentityuuid;
		tempentityfieldinstanceentityinstanceentityuuid = create_entityfieldinstanceentityinstanceentityuuid;
		tempentityfieldinstanceentityfieldentityuuid = create_entityfieldinstanceentityfieldentityuuid;
end if;

-- Return an error if the entity is not set to a customer.  
-- We need the customerid when dealing with languagemaster
select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,tempentityfieldinstanceownerentityuuid,null,false,null,null,null, null);

if tempcustomerid isNull
	then return; -- need an error code  
end if;

-- Is the instance valid and the owner the same as what was sent in 
select entityinstanceownerentityuuid, entityinstanceentitytemplateentityuuid 
into tempentityinstanceownerentityuuid, tempentityinstanceentitytemplateentityuuid
from entity.crud_entityinstance_read_min(tempentityfieldinstanceownerentityuuid, tempentityfieldinstanceentityinstanceentityuuid, null, null, null, null, false, null, null, null, null, null);

if tempentityinstanceownerentityuuid isNull or tempentityinstanceownerentityuuid <> tempentityfieldinstanceownerentityuuid	
	then return ; -- need an error code  
end if;

-- Is the field valid for the template 
-----------------------------------------------------------------------------------
-- FUTURE: handle lazy init here.  If fielduuid is null and field name is not null.
-- FUTURE: Use the passed in format and widget if this is a create field sceanrio

select entityfieldentitytemplateentityuuid, entityfieldname
into tempentityfieldinstanceentitytemplateentityuuid, tempentityfieldinstanceentityfieldname
from entity.crud_entityfield_read_min(tempentityfieldinstanceownerentityuuid,null,tempentityfieldinstanceentityfieldentityuuid,null, null, null,null);

-- check if this is a primary template
if tempentityfieldinstanceentitytemplateentityuuid isNull
	then  select entityfieldentitytemplateentityuuid, entityfieldname
			into tempentityfieldinstanceentitytemplateentityuuid, tempentityfieldinstanceentityfieldname
			from entity.crud_entityfield_read_min(tendreluuid,null,tempentityfieldinstanceentityfieldentityuuid,null, null, null,null);
end if;

if tempentityfieldinstanceentitytemplateentityuuid isnull 
	or tempentityfieldinstanceentitytemplateentityuuid <> tempentityinstanceentitytemplateentityuuid	
	then return; -- need an error code  
end if;

-- setup the language type
if create_languagetypeuuid isNull
	then templanguagetypeentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
	else templanguagetypeentityuuid = create_languagetypeuuid;
end if;

select systagid,systaguuid into templanguagetypeid,templanguagetypeuuid
	from entity.crud_systag_read_min(null, null, templanguagetypeentityuuid, null, false,null,null, null,templanguagetypeentityuuid);

if templanguagetypeid isNull
	then return;
end if;

-- set default values

If create_entityfieldinstancedeleted isNull
	then tempentityinstancedeleted = false;
	else tempentityinstancedeleted = create_entityinstancedeleted;
end if;

If create_entityfieldinstancedraft isNull
	then tempentityinstancedraft = false;
	else tempentityinstancedraft = create_entityinstancedraft;
end if;

-- this needs to be smarter.  
-- Leverage the result type and the field to know if this is needed and is translatable.  
-- insert value into languagemaster

if create_entityfieldinstancevalue notNull
	then	insert into public.languagemaster
				(languagemastercustomerid,
				languagemastersourcelanguagetypeid,
				languagemastersource,
				languagemastermodifiedby)
			values(tempcustomerid,
				templanguagetypeid, 	
				create_entityfieldinstancevalue,    
				create_modifiedbyid)
			Returning languagemasteruuid into templanguagemasteruuid;
	else templanguagemasteruuid = null;
end if;

-- now let's create the field instance  

	INSERT INTO entity.entityfieldinstance(
		entityfieldinstanceentityinstanceentityuuid,  
		entityfieldinstanceownerentityuuid, 
		entityfieldinstancevalue,  
		entityfieldinstancevaluelanguagemasteruuid, 
		entityfieldinstancecreateddate,
		entityfieldinstancemodifieddate, 
		entityfieldinstancestartdate, 
		entityfieldinstanceenddate, 
		entityfieldinstanceentityfieldentityuuid, 
		entityfieldinstancemodifiedbyuuid, 
		entityfieldinstancerefid, 
		entityfieldinstancerefuuid, 
		entityfieldinstanceentityfieldname,  
		entityfieldinstancevaluelanguagetypeentityuuid, 
		entityfieldinstancedeleted, 
		entityfieldinstancedraft )
	values (
		tempentityfieldinstanceentityinstanceentityuuid,
		tempentityfieldinstanceownerentityuuid,  
		create_entityfieldinstancevalue,
		templanguagemasteruuid,
		now(),
		now(), 
		now(), 
		null, 
		tempentityfieldinstanceentityfieldentityuuid,
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		null,
		null,
		tempentityfieldinstanceentityfieldname,
		templanguagetypeentityuuid,
		tempentityinstancedeleted,
		tempentityinstancedraft
		) 	Returning entityfieldinstanceuuid into tempentityinstanceuuid;

create_entityfieldinstanceentityuuid = tempentityinstanceuuid;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_entityfieldinstance_create(uuid,uuid,uuid,text,text,uuid,text,uuid,text,text,uuid,boolean,boolean,uuid,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfieldinstance_create(uuid,uuid,uuid,text,text,uuid,text,uuid,text,text,uuid,boolean,boolean,uuid,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfieldinstance_create(uuid,uuid,uuid,text,text,uuid,text,uuid,text,text,uuid,boolean,boolean,uuid,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_entityfieldinstance_create(uuid,uuid,uuid,text,text,uuid,text,uuid,text,text,uuid,boolean,boolean,uuid,bigint) TO graphql;

END;
