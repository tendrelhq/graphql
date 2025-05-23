
-- Type: PROCEDURE ; Name: entity.import_entity_customer(text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.import_entity_customer(IN intervaltype text)
 LANGUAGE plpgsql
AS $procedure$
Declare
   customer_start timestamp with time zone;
	maxdate timestamp with time zone;
	updatedate timestamp with time zone;
	insertdate timestamp with time zone;
	englishuuid uuid;
   
Begin

englishuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';

-- Start the timer on this function
	customer_start = clock_timestamp();
	maxdate = 	(select max(customermodifieddate) 
					from entity.crud_customer_read_min(null,null, null, true,null,null, null, null));

	updatedate = 
		case
			when intervaltype = '5 minute' and maxdate notNull
				Then (select (max(customermodifieddate)- interval '2 hours') 
						from entity.crud_customer_read_min(null,null, null, true,null,null, null, null))
			when intervaltype = '1 hour' and maxdate notNull
				Then (select (max(customermodifieddate)- interval '1 day') 
						from entity.crud_customer_read_min(null,null, null, true,null,null, null, null))			
			Else '01/01/1900'
		end;

	insertdate = 
		case
			when intervaltype = '5 minute' and maxdate notNull
				Then (select (max(customermodifieddate)- interval '1 hour') 
						from entity.crud_customer_read_min(null,null, null, true,null,null, null, null))
			when intervaltype = '1 hour' and maxdate notNull
				Then (select (max(customermodifieddate)- interval '2 hour') 
						from entity.crud_customer_read_min(null,null, null, true,null,null, null, null))			
			Else '01/01/1900'
		end;

	INSERT INTO entity.entityinstance(
		entityinstanceoriginalid, 
		entityinstanceoriginaluuid, 
		entityinstanceownerentityuuid, 
		entityinstanceentitytemplateentityuuid, 
		entityinstancetypeentityuuid, 
		entityinstancecreateddate, 
		entityinstancemodifieddate, 
		entityinstancestartdate, 
		entityinstanceenddate, 
		entityinstanceexternalid, 
		entityinstancemodifiedbyuuid, 
		entityinstancerefid,
		entityinstanceentitytemplatename,
		entityinstancetype,
		entityinstanceexternalsystementityuuid,
		entityinstancenameuuid
		)
	SELECT 
		cust.customerid, 
		cust.customeruuid, 
		null,
		(select entitytemplateuuid from entity.entitytemplate where entitytemplatename = 'Customer'),  -- Flip these to the function in the future
		(select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatename = 'Customer'),  -- Flip these to the function in the future
		cust.customercreateddate, 
		cust.customermodifieddate,
		cust.customerstartdate, 
		cust.customerenddate, 
		cust.customerexternalid, 
		(select workerinstanceuuid from workerinstance where workerinstanceid = cust.customermodifiedby),
		cust.customerrefid,
		'Customer',
		customername,
		sys.systagentityuuid,
		(select languagemasteruuid from languagemaster where languagemasterid = customernamelanguagemasterid)
	FROM public.customer cust
		left join entity.entityinstance
			on cust.customerid = entityinstanceoriginalid
				and entityinstancetypeentityuuid = (select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatename = 'Customer')  -- Flip these to the function in the future
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)) as sys
			on sys.systagid = cust.customerexternalsystemid
	where entityinstanceuuid isNull 
		and cust.customermodifieddate > insertdate
		and cust.customermodifieddate < now() - interval '10 minutes';

-- add in the corect customerentity uuid.  It references self.  

	update entity.entityinstance
	set entityinstanceownerentityuuid = entityinstanceuuid
	where entityinstanceownerentityuuid isNull
		and entityinstanceentitytemplatename = 'Customer';

	update entity.entityinstance
	set  entityinstanceparententityuuid = entityinstanceuuid
	where entityinstanceparententityuuid isNull
		and entityinstanceentitytemplatename = 'Customer';

	update entity.entityinstance
	set entityinstancecornerstoneentityuuid = entityinstanceuuid
	where entityinstancecornerstoneentityuuid isNull
		and entityinstanceentitytemplatename = 'Customer';

-- displayname

	insert into public.languagemaster
	    (languagemastercustomerid,
	     languagemastersourcelanguagetypeid,
	     languagemastersource,
		 languagemasterrefuuid,
	     languagemastermodifiedby)
	select
		cust.customerid,
		20,
	    cust.customername,	
		entityinstanceuuid||'-customerdisplayname',
		337
	from entity.entityinstance
		inner join customer cust
			on customerid = entityinstanceoriginalid
				and entityinstancetypeentityuuid = (select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatename = 'Customer')  -- Flip these to the function in the future
				and cust.customermodifieddate > insertdate
				and cust.customermodifieddate < now() - interval '15 minutes'
		inner join entity.entitytemplate
			on entityinstanceentitytemplateentityuuid = entitytemplateuuid
		inner join entity.entityfield
			on entityfieldentitytemplateentityuuid = entitytemplateuuid	
				and entityfieldname = 'customerdisplayname'
		left join entity.entityfieldinstance
			on entityfieldinstanceentityinstanceentityuuid = entityinstanceuuid
				and entityfieldinstanceentityfieldentityuuid = entityfielduuid
	where entityfieldinstanceuuid isNull;
	
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
		customername,
		languagemasteruuid,
		(select systagentityuuid
			from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)
			where systagid = 20 ),  -- Maybe just replace this with the UUID
		customercreateddate,
		customermodifieddate,
		entityfielduuid,
		entitytemplatemodifiedbyuuid,
		entityfieldname
	from entity.entityinstance
		inner join customer
			on customerid = entityinstanceoriginalid
				and entityinstancetypeentityuuid = (select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatename = 'Customer') -- Flip these to the function in the future
				and customermodifieddate > insertdate
				and customermodifieddate < now() - interval '15 minutes'
		inner join entity.entitytemplate
			on entityinstanceentitytemplateentityuuid = entitytemplateuuid
		inner join entity.entityfield
			on entityfieldentitytemplateentityuuid = entitytemplateuuid	
				and entityfieldname = 'customerdisplayname'		
		inner join languagemaster
			on languagemasterrefuuid = entityinstanceuuid||'-customerdisplayname'
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
		(select systaguuid 
			from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid) 
			where systagid = customerlanguagetypeid),
		(select systagentityuuid
			from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)
			where systagid = 20 ),  -- Maybe just replace this with the UUID
		customercreateddate,
		customermodifieddate,
		entityfielduuid,
		entitytemplatemodifiedbyuuid,
		entityfieldname
	from entity.entityinstance
		inner join customer
			on customerid = entityinstanceoriginalid
				and entityinstancetypeentityuuid = (select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatename = 'Customer')  -- Flip these to the function in the future
				and customermodifieddate > insertdate
				and customermodifieddate < now() - interval '15 minutes'
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
		(select systagentityuuid
			from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)
			where systaguuid = customertypeuuid ),
		(select systagentityuuid
			from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)
			where systagid = 20 ),  
		customercreateddate,
		customermodifieddate,
		entityfielduuid,
		entitytemplatemodifiedbyuuid,
		entityfieldname
	from entity.entityinstance
		inner join customer
			on customerid = entityinstanceoriginalid
				and entityinstancetypeentityuuid = (select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatename = 'Customer')  -- Flip these to the function in the future
				and customermodifieddate > insertdate
				and customermodifieddate < now() - interval '15 minutes'
		inner join entity.entitytemplate
			on entityinstanceentitytemplateentityuuid = entitytemplateuuid
		inner join entity.entityfield
			on entityfieldentitytemplateentityuuid = entitytemplateuuid	
				and entityfieldname = 'customertypeuuid'		
		left join entity.entityfieldinstance
			on entityfieldinstanceentityinstanceentityuuid = entityinstanceuuid
				and entityfieldinstanceentityfieldentityuuid = entityfielduuid
	where entityfieldinstanceuuid isNull;

-- update any modified customers
	
	if (select count(*) 
		from customer cust 
			inner join (select * from entity.crud_customer_read_min(null,null, null, true,null,null, null, null)) as ent
				on cust.customerid = ent.customerid
					and cust.customermodifieddate > updatedate
					and cust.customermodifieddate < now() - interval '10 minutes'
		where cust.customermodifieddate <> ent.customermodifieddate) > 0
	then
		-- create list of modified customers
		create temp table custmodified  as 
			(select cust.*, 
				ent.customerid as ent_customerid, 
				ent.customeruuid as ent_customeruuid, 
				ent.customerentityuuid as ent_customerentityuuid, 
				ent.customernameuuid as ent_customernameuuid, 
				ent.customerdisplaynameuuid as ent_customerdisplaynameuuid, 
				ent.customertypeentityuuid as ent_customertypeentityuuid, 
				ent.customercreateddate as ent_customercreateddate, 
				ent.customermodifieddate as ent_customermodifieddate, 
				ent.customerstartdate as ent_customerstartdate, 
				ent.customerenddate as ent_customerenddate, 
				ent.customermodifiedbyuuid as ent_customermodifiedbyuuid, 
				ent.customerexternalid as ent_customerexternalid, 
				ent.customerexternalsystementityuuid as ent_customerexternalsystementityuuid, 
				ent.customerlanguagetypeentityuuid as ent_customerlanguagetypeentityuuid 
	  		from customer cust 
				inner join (select * from entity.crud_customer_read_min(null,null, null, true,null,null, null, null)) as ent
					on cust.customerid = ent.customerid
						and cust.customermodifieddate > updatedate
						and cust.customermodifieddate < now() - interval '15 minutes'
			where cust.customermodifieddate <> ent.customermodifieddate);

	-- customerlanguagetypeuuid
		update entity.entityfieldinstance
		set entityfieldinstancevalue = (select systagentityuuid
										from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)
										where systagid = customerlanguagetypeid )::text,
			entityfieldinstancemodifieddate = customermodifieddate
		from custmodified cust 
		where  entityfieldinstanceentityinstanceentityuuid = cust.ent_customerentityuuid
			and entityfieldinstanceentityfieldname = 'customerlanguagetypeuuid';

	-- customertypeuuid
		update entity.entityfieldinstance
		set entityfieldinstancevalue = (select systagentityuuid
										from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)
										where systaguuid = customertypeuuid )::text,
			entityfieldinstancemodifieddate = customermodifieddate
		from custmodified cust 
		where  entityfieldinstanceentityinstanceentityuuid = cust.ent_customerentityuuid
			and entityfieldinstanceentityfieldname = 'customertypeuuid';

	-- entity
		update entity.entityinstance
		set entityinstancemodifieddate = customermodifieddate,
			entityinstanceenddate = customerenddate,
			entityinstancemodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = customermodifiedby)  -- Eventually migrate to entity model
		from custmodified cust 
		where entityinstanceuuid = cust.ent_customerentityuuid
			and entityinstanceentitytemplatename = 'Customer';

	drop table custmodified;

end if;

  if exists(select 1 from pg_namespace where nspname = 'datawarehouse') then
    if  (select dwlogginglevel4 from datawarehouse.dw_logginglevels) = false
      Then Return;
    end if;

    call datawarehouse.insert_tendy_tracker(0, 2520, 12496, 811, 844, 20782, 18068, 20783,20781, customer_start);
  end if;


End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.import_entity_customer(text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_entity_customer(text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_entity_customer(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.import_entity_customer(text) TO graphql;
