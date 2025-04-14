
-- Type: PROCEDURE ; Name: entity.crud_customer_create(text,uuid,uuid,text,uuid,boolean,boolean,uuid[],bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_customer_create(IN create_customername text, OUT create_customeruuid text, OUT create_customerentityuuid uuid, IN create_customerparentuuid uuid, IN create_customerowner uuid, IN create_customerbillingid text, IN create_customerbillingsystemid uuid, IN create_customerdeleted boolean, IN create_customerdraft boolean, IN create_languagetypeuuids uuid[], IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare


/*

-- generic version

call entity.crud_customer_create(
	'Test'||now()::text, -- IN create_customername text,
	null, -- OUT create_customeruuid text,
	null, -- OUT create_customerentityuuid uuid, -- added this.  Need to handle it.	
	null, -- IN create_customerparentuuid uuid,  -- added this.  Need to handle it.
	null, -- IN create_customerowner uuid,  -- added this.  Need to handle it.
	('Bill'||now())::text, -- IN create_customerbillingid text,
	('c486a0d3-7c44-4129-9629-53920de84215'::text)::uuid, --	IN create_customerbillingsystemid uuid,
	null,
	null,
	ARRAY['bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid], -- IN create_languagetypeuuids uuid[],
	337::bigint -- IN create_modifiedby bigint
	);
	
-- create Lipman Account

call entity.crud_customer_create(
	'Lipman Account'::text, -- IN create_customername text,
	null, -- OUT create_customeruuid text,
	null, -- OUT create_customerentityuuid uuid, -- added this.  Need to handle it.	
	null, -- IN create_customerparentuuid uuid,  -- added this.  Need to handle it.
	null, -- IN create_customerowner uuid,  -- added this.  Need to handle it.
	('Bill'||now())::text, -- IN create_customerbillingid text,
	('c486a0d3-7c44-4129-9629-53920de84215'::text)::uuid, --	IN create_customerbillingsystemid uuid,
	null,
	null,
	ARRAY['bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid], -- IN create_languagetypeuuids uuid[],
	337::bigint -- IN create_modifiedby bigint
	);

-- create Fillogic Account

call entity.crud_customer_create(
	'Fillogic Account'::text, -- IN create_customername text,
	null, -- OUT create_customeruuid text,
	null, -- OUT create_customerentityuuid uuid, -- added this.  Need to handle it.	
	null, -- IN create_customerparentuuid uuid,  -- added this.  Need to handle it.
	null, -- IN create_customerowner uuid,  -- added this.  Need to handle it.
	('Bill'||now())::text, -- IN create_customerbillingid text,
	('c486a0d3-7c44-4129-9629-53920de84215'::text)::uuid, --	IN create_customerbillingsystemid uuid,
	null,
	null,
	ARRAY['bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid], -- IN create_languagetypeuuids uuid[],
	337::bigint -- IN create_modifiedby bigint
	);

-- create with FillLogic as the parent  

call entity.crud_customer_create(
	'Filllogic Sub'||now()::text, -- IN create_customername text,
	null, -- OUT create_customeruuid text,
	null, -- OUT create_customerentityuuid uuid, -- added this.  Need to handle it.	
	'290021c4-3a66-45e4-a860-68d1e7e05c9c'::uuid, -- IN create_customerparentuuid uuid,  -- added this.  Need to handle it.
	null, -- IN create_customerowner uuid,  -- added this.  Need to handle it.
	('Bill'||now())::text, -- IN create_customerbillingid text,
	('c486a0d3-7c44-4129-9629-53920de84215'::text)::uuid, --	IN create_customerbillingsystemid uuid,
	null,
	null,
	ARRAY['bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid], -- IN create_languagetypeuuids uuid[],
	337::bigint -- IN create_modifiedby bigint
	);

 */

-- Customer temp values
    tempcustomerid                 bigint;
    tempbillingsystemid            bigint;
-- General temp values
    templanguagemasterid           bigint;
	templanguagemasteruuid 			text;
    templanguagetypeuuid           text;
    templanguagetypeid           bigint;
	englishuuid uuid;
	tempcustomerdeleted boolean;
	tempcustomerdraft boolean;

Begin

englishuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';

-- customer need a name
if (create_customername isNull or coalesce(create_customername,'')= '')
	then return;  -- need error code
end if;

-- setup billing.  
    tempbillingsystemid = (select systagid
                           from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)
                           where systagentityuuid = create_customerbillingsystemid);

-- setup language
if create_languagetypeuuids isNull
	then templanguagetypeid = 20;
	Else templanguagetypeid = (
		select systagid 
		from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)
		where systagentityuuid = create_languagetypeuuids[1]	
		); 
end if;

    templanguagetypeuuid = (select systaguuid
                            from public.systag
                            where systagid = templanguagetypeid);

If create_customerdeleted isNull
	then tempcustomerdeleted = false;
	else tempcustomerdeleted = create_customerdeleted;
end if;

If create_customerdraft isNull
	then tempcustomerdraft = false;
	else tempcustomerdraft = create_customerdraft;
end if;

-- create the entity first then push it to the original customer table

	INSERT INTO entity.entityinstance(
		entityinstanceownerentityuuid,
		entityinstanceparententityuuid,
		entityinstanceentitytemplateentityuuid, 
		entityinstancetypeentityuuid, 
		entityinstancecreateddate, 
		entityinstancemodifieddate, 
		entityinstancestartdate, 
		entityinstanceenddate,		
		entityinstanceexternalid, 
		entityinstanceexternalsystemuuid,
		entityinstancemodifiedbyuuid, 
		entityinstancerefid,
		entityinstancerefuuid,
		entityinstanceentitytemplatename,
		entityinstancetype,
		entityinstanceexternalsystementityuuid,
		entityinstancedeleted,
		entityinstancedraft,	
		entityinstancenameuuid
		)
	SELECT 
		create_customerowner,
		create_customerparentuuid,  
		(select entitytemplateuuid from entity.entitytemplate where entitytemplatename = 'Customer'),
		(select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatename = 'Customer'),
		now(), 
		now(), 
		now(), 
		null,
		create_customerbillingid, 
		null,
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedby),  
		null,
		null,
		'Customer',
		create_customername,
		(select entityinstanceuuid from entity.entityinstance 
			where entityinstanceentitytemplatename = 'System Tag' 
				and entityinstanceoriginalid = tempbillingsystemid 
				and entityinstanceuuid = create_customerbillingsystemid),
		tempcustomerdeleted,
		tempcustomerdraft,
		'lm_5f7e176e-93d6-4b6e-bf7b-a8b115bfc403' -- dummy data to change later
    Returning entityinstanceuuid into create_customerentityuuid;

-- if the entityinstanceownerentityuuid isNull then set the owner to itself.  

	update entity.entityinstance
	set entityinstanceownerentityuuid = create_customerentityuuid
	where entityinstanceuuid = create_customerentityuuid
		and entityinstanceownerentityuuid isNull;

-- if the entityinstanceparententityuuid isNull then set the parent to itself.  

	update entity.entityinstance
	set entityinstanceparententityuuid = create_customerentityuuid
	where entityinstanceuuid = create_customerentityuuid
		and entityinstanceparententityuuid isNull;

-- if the entityinstancecornerstoneentityuuid isNull then set it to itself.  

	update entity.entityinstance
	set entityinstancecornerstoneentityuuid = create_customerentityuuid
	where entityinstanceuuid = create_customerentityuuid
		and entityinstancecornerstoneentityuuid isNull;

-----------------------------------------------------

-- Insert the customer and get back the customer id and uuid.

    INSERT INTO public.customer(customername,
                                customerstartdate,
                                customerlanguagetypeid,
                                customerlanguagetypeuuid,
                                customernamelanguagemasterid,
                                customerexternalid,
                                customerexternalsystemid,
                                customerexternalsystemuuid,
                                customermodifiedby)
    VALUES (create_customername,
            clock_timestamp(),
            templanguagetypeid,
            templanguagetypeuuid,
            4367,  -- dummy record to be cleaned up later.  
            create_customerbillingid,
            tempbillingsystemid,
            (select systaguuid from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)
			where systagentityuuid = create_customerbillingsystemid),
            create_modifiedby)
    Returning customeruuid,customerid into create_customeruuid,tempcustomerid;

-- replace the dummy variables for languagemaster	

    INSERT INTO public.languagemaster(
			languagemastercustomerid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
	VALUES (
			tempcustomerid,
			templanguagetypeid,
			create_customername,
			create_modifiedby)
	Returning languagemasterid,languagemasteruuid into templanguagemasterid,templanguagemasteruuid;

-- update the entity instance and customer with the id and uuid
	update entity.entityinstance
	set entityinstanceoriginalid = tempcustomerid,
		entityinstanceoriginaluuid = create_customeruuid,
		entityinstancenameuuid = templanguagemasteruuid
	where entityinstanceuuid = create_customerentityuuid;

	update public.customer
	set customernamelanguagemasterid = templanguagemasterid
	where customerid = tempcustomerid;
	
-- get the diplay name set and created in language master and in the field instances
-- displayname

    INSERT INTO public.languagemaster(
		languagemastercustomerid,
		languagemastersourcelanguagetypeid,
		languagemastersource,
		languagemasterrefuuid,
		languagemastermodifiedby)
    VALUES (
		tempcustomerid,
	    templanguagetypeid,
	    create_customername,
		create_customerentityuuid||'-customerdisplayname',
	    create_modifiedby)
    Returning languagemasterid,languagemasteruuid into templanguagemasterid,templanguagemasteruuid;

	INSERT INTO entity.entityfieldinstance(
			entityfieldinstanceentityinstanceentityuuid, 
			entityfieldinstanceownerentityuuid, 
			entityfieldinstancevalue, 
			entityfieldinstancevaluelanguagemasteruuid, 
			entityfieldinstancevaluelanguagetypeentityuuid, 
			entityfieldinstancecreateddate, 
			entityfieldinstancemodifieddate, 
			entityfieldinstanceentityfieldentityuuid, 
			entityfieldinstancemodifiedbyuuid,
			entityfieldinstanceentityfieldname)
		select 
			entityinstanceuuid,
			entityinstanceownerentityuuid,
			create_customername,
			templanguagemasteruuid,
			(select entityinstanceuuid from entity.entityinstance 
				where entityinstanceentitytemplatename = 'System Tag'
					and entityinstanceoriginalid = templanguagetypeid ),  -- shouldn't this be what was passed in
			now(),
			now(),
			entityfielduuid,
			entitytemplatemodifiedbyuuid,
			entityfieldname
		from entity.entityinstance
			inner join entity.entitytemplate
				on entityinstanceentitytemplateentityuuid = entitytemplateuuid
			inner join entity.entityfield
				on entityfieldentitytemplateentityuuid = entitytemplateuuid	
					and entityfieldname = 'customerdisplayname'		
			left join entity.entityfieldinstance
				on entityfieldinstanceentityinstanceentityuuid = entityinstanceuuid
					and entityfieldinstanceentityfieldentityuuid = entityfielduuid
		where entityfieldinstanceuuid isNull;

-- customerlanguagetypeuuid

	INSERT INTO entity.entityfieldinstance(
		entityfieldinstanceentityinstanceentityuuid, 
		entityfieldinstanceownerentityuuid, 
		entityfieldinstancevalue, 
		entityfieldinstancevaluelanguagetypeentityuuid, 
		entityfieldinstancecreateddate, 
		entityfieldinstancemodifieddate, 
		entityfieldinstanceentityfieldentityuuid, 
		entityfieldinstancemodifiedbyuuid,
		entityfieldinstanceentityfieldname)
	select 
		entityinstanceuuid,
		entityinstanceownerentityuuid,
		(select systaguuid from public.systag where systagid = templanguagetypeid),   -- shouldn't this be what was passed in
		(select entityinstanceuuid from entity.entityinstance 
			where entityinstanceentitytemplatename = 'System Tag'
				and entityinstanceoriginalid = templanguagetypeid ),  -- shouldn't this be what was passed in
		now(),
		now(),
		entityfielduuid,
		entitytemplatemodifiedbyuuid,
		entityfieldname
	from entity.entityinstance
		inner join entity.entitytemplate
			on entityinstanceentitytemplateentityuuid = entitytemplateuuid
		inner join entity.entityfield
			on entityfieldentitytemplateentityuuid = entitytemplateuuid	
				and entityfieldname = 'customerlanguagetypeentityuuid'
		left join entity.entityfieldinstance
			on entityfieldinstanceentityinstanceentityuuid = entityinstanceuuid
				and entityfieldinstanceentityfieldentityuuid = entityfielduuid
	where entityfieldinstanceuuid isNull;

-- customertypeuuid

	INSERT INTO entity.entityfieldinstance(
		entityfieldinstanceentityinstanceentityuuid, 
		entityfieldinstanceownerentityuuid, 
		entityfieldinstancevalue, 
		entityfieldinstancevaluelanguagetypeentityuuid, 
		entityfieldinstancecreateddate, 
		entityfieldinstancemodifieddate, 
		entityfieldinstanceentityfieldentityuuid, 
		entityfieldinstancemodifiedbyuuid,
		entityfieldinstanceentityfieldname)
	select 
		entityinstanceuuid,
		entityinstanceownerentityuuid,
		'9b7b06b3-d756-4854-8b70-da3c13b35ad6',   
		(select entityinstanceuuid from entity.entityinstance 
			where entityinstanceentitytemplatename = 'System Tag'
				and entityinstanceoriginalid = templanguagetypeid ),  -- shouldn't this be what was passed in
		now(),
		now(),
		entityfielduuid,
		entitytemplatemodifiedbyuuid,
		entityfieldname
	from entity.entityinstance
		inner join entity.entitytemplate
			on entityinstanceentitytemplateentityuuid = entitytemplateuuid
		inner join entity.entityfield
			on entityfieldentitytemplateentityuuid = entitytemplateuuid	
				and entityfieldname = 'customertypeuuid'		 
		left join entity.entityfieldinstance
			on entityfieldinstanceentityinstanceentityuuid = entityinstanceuuid
				and entityfieldinstanceentityfieldentityuuid = entityfielduuid
	where entityfieldinstanceuuid isNull;

-- Add the languagetype to customer reqeusted languages

	insert into customerrequestedlanguage 
		(customerrequestedlanguagecustomerid,
	     customerrequestedlanguagelanguageid,
	      customerrequestedlanguagemodifiedby)
	select tempcustomerid,
			systagid,
			create_modifiedby
	from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)
				where systagentityuuid = any(create_languagetypeuuids);

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_customer_create(text,uuid,uuid,text,uuid,boolean,boolean,uuid[],bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customer_create(text,uuid,uuid,text,uuid,boolean,boolean,uuid[],bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customer_create(text,uuid,uuid,text,uuid,boolean,boolean,uuid[],bigint) TO tendreladmin WITH GRANT OPTION;
