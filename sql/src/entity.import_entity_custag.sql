
-- Type: PROCEDURE ; Name: entity.import_entity_custag(text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.import_entity_custag(IN intervaltype text)
 LANGUAGE plpgsql
AS $procedure$
Declare
   location_start timestamp with time zone;
	maxdate timestamp with time zone;
	insertdate timestamp with time zone;
	tempenglishentityuuid uuid;
	temptendrelenitytuuid uuid;
	tempentitytemplateuuid uuid;
	tempentitytemplatetypeuuid uuid;
	
Begin

tempenglishentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
temptendrelenitytuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';
tempentitytemplateuuid = (select entitytemplateuuid from entity.entitytemplate where entitytemplatename = 'Customer Tag');
tempentitytemplatetypeuuid = (select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatename = 'Customer Tag');

-- Start the timer on this function
location_start = clock_timestamp();
maxdate = 	(select max(custagmodifieddate) 
				from entity.crud_custag_read_min(null,null,null, null, true,null,null, null,tempenglishentityuuid));
insertdate = 
	case when intervaltype = '5 minute' and maxdate notNull
			Then (select (max(custagmodifieddate)- interval '1 hour') 
					from entity.crud_custag_read_min(null,null,null, null, true,null,null, null,tempenglishentityuuid))
		when intervaltype = '1 hour' and maxdate notNull
			Then (select (max(custagmodifieddate)- interval '2 hour') 
					from entity.crud_custag_read_min(null,null,null, null, true,null,null, null,tempenglishentityuuid))			
		Else '01/01/1900'
	end;	

-- insert the custag

INSERT INTO entity.entityinstance(
	entityinstanceoriginalid, 
	entityinstanceoriginaluuid, 
	entityinstanceownerentityuuid, 
	entityinstanceparententityuuid,	
	entityinstanceentitytemplateentityuuid,  -- templateentityuuid
	entityinstancetypeentityuuid,  -- template type 
	entityinstancecreateddate, 
	entityinstancemodifieddate, 
	entityinstancestartdate, 
	entityinstanceenddate, 
	entityinstanceexternalid, 
	entityinstanceexternalsystemuuid, -- deprecate
	entityinstanceexternalsystementityuuid,
	entityinstancemodifiedbyuuid, 
	entityinstancerefid,
	entityinstancerefuuid,
	entityinstancecornerstoneorder,
	entityinstanceentitytemplatename,
	entityinstancetype,
	entityinstancenameuuid,
	entityinstancedeleted, 
	entityinstancedraft			
	)
Select
	tag.custagid,
	tag.custaguuid,
	(select entityinstanceuuid from entity.entityinstance 
		where entityinstanceoriginalid = tag.custagcustomerid 
			and entityinstanceentitytemplatename = 'Customer'),
	parent.entityinstanceuuid, -- parent id
	tempentitytemplateuuid,
	tempentitytemplatetypeuuid,
	tag.custagcreateddate,
	tag.custagmodifieddate, 
	tag.custagstartdate, 
	tag.custagenddate, 
	tag.custagexternalid,
	null,  -- deprecate	
	sys.custagentityuuid as custagexternalsystementityuuid,	
	(select workerinstanceuuid from workerinstance where workerinstanceid = tag.custagmodifiedby),
	tag.custagrefid, 
	tag.custagrefuuid,	
	tag.custagorder::integer,
	'Customer Tag',
	tag.custagtype,
	(select languagemasteruuid from languagemaster where languagemasterid = tag.custagnameid),
	false,
	false	
from custag tag
	inner join entity.entityinstance parent
		on tag.custagsystagid = parent.entityinstanceoriginalid
			and parent.entityinstanceentitytemplatename = 'System Tag'	
	left join entity.entityinstance ent
		on tag.custagid = ent.entityinstanceoriginalid
			and ent.entityinstancetypeentityuuid = (select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatename = 'Customer Tag')
	left join (select * from entity.crud_custag_read_min(null,null,null, null, true,null,null, null,tempenglishentityuuid)) as sys
		on sys.custagid = tag.custagexternalsystemid
where ent.entityinstanceuuid isNull 
	and tag.custagmodifieddate > insertdate
	and tag.custagmodifieddate < (now() - interval '10 minutes');

-- cornerstone

update entity.entityinstance
set entityinstancecornerstoneentityuuid = entityinstanceuuid
where entityinstanceentitytemplatename in ('Customer Tag') 
	and entityinstancecornerstoneentityuuid isNull;

-- custagdisplayname

insert into public.languagemaster
    (languagemastercustomerid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
	 languagemasterrefuuid,
     languagemastermodifiedby)
select
	custagcustomerid,
	20,
    custagtype,	
	ent.entityinstanceuuid||'-custagdisplayname',
	337
from entity.entityinstance ent
	inner join custag
		on custagid = ent.entityinstanceoriginalid
			and ent.entityinstanceentitytemplatename = 'Customer Tag'
			and custagmodifieddate > insertdate
	inner join entity.entitytemplate
		on ent.entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'custagdisplayname'	
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = ent.entityinstanceuuid
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
	languagemastersource,
	languagemasteruuid,
	(select entityinstanceuuid from entity.entityinstance 
		where entityinstanceoriginaluuid in 
				(select custaguuid from custag 
				where custagid in (languagemastersourcelanguagetypeid))),
	custagcreateddate,
	custagmodifieddate,
	entityfielduuid,
	entityinstancemodifiedbyuuid,
	entityfieldname
from entity.entityinstance
	inner join custag
		on custagid = entityinstanceoriginalid
			and entityinstanceentitytemplatename = 'Customer Tag'
			and custagmodifieddate > insertdate
	inner join entity.entitytemplate
		on entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'custagdisplayname'
	inner join languagemaster
		on languagemasterrefuuid = entityinstanceuuid||'-custagdisplayname'
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = entityinstanceuuid
			and entityfieldinstanceentityfieldentityuuid = entityfielduuid
where entityfieldinstanceuuid isNull;

-- custagabbreviationentityuuid

INSERT INTO entity.entityfieldinstance(
	entityfieldinstanceentityinstanceentityuuid, 
	entityfieldinstanceownerentityuuid, 
	entityfieldinstancevalue, 
	entityfieldinstancecreateddate, 
	entityfieldinstancemodifieddate, 
	entityfieldinstanceentityfieldentityuuid, 
	entityfieldinstancemodifiedbyuuid,
	entityfieldinstanceentityfieldname)
select 
	ent.entityinstanceuuid,
	ent.entityinstanceownerentityuuid,
	abb.entityinstanceuuid::text,
	loc.custagcreateddate,
	loc.custagmodifieddate,
	entityfielduuid,
	ent.entityinstancemodifiedbyuuid,
	entityfieldname
from entity.entityinstance ent
	inner join custag loc
		on loc.custagid = ent.entityinstanceoriginalid
			and ent.entityinstanceentitytemplatename = 'Customer Tag'
			and custagmodifieddate > insertdate
	left join entity.entityinstance abb
		on loc.custagabbreviationid = abb.entityinstanceoriginalid
	inner join entity.entitytemplate
		on ent.entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'custagabbreviationentityuuid'
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = ent.entityinstanceuuid
			and entityfieldinstanceentityfieldentityuuid = entityfielduuid
where entityfieldinstanceuuid isNull;

------------
-- update any modified custags

-------  TRIM THIS TABLE TO NEEDED DATA.  RIGHT NOW I GRAB EVERYTHING ------

create temp table cusmodified  as
(select cus.*,
	ent.languagetranslationtypeentityuuid as languagetranslationtypeentityuuid, 
	ent.custagid as ent_custagid, 
	ent.custaguuid as ent_custaguuid, 
	ent.custagentityuuid as ent_custagentityuuid, 
	ent.custagcustomerid as ent_custagcustomerid, 
	ent.custagcustomeruuid as ent_custagcustomeruuid, 
	ent.custagcustomerentityuuid as ent_custagcustomerentityuuid, 
	ent.custagnameuuid as ent_custagnameuuid, 
	ent.custagdisplaynameuuid as ent_custagdisplaynameuuid, 
	ent.custagtype as ent_custagtype, 
	ent.custagcreateddate as ent_custagcreateddate, 
	ent.custagmodifieddate as ent_custagmodifieddate, 
	ent.custagstartdate as ent_custagstartdate, 
	ent.custagenddate as ent_custagenddate, 
	ent.custagexternalid as ent_custagexternalid, 
	ent.custagexternalsystementityuuid as ent_custagexternalsystementityuuid, 
	ent.custagmodifiedbyuuid as ent_custagmodifiedbyuuid, 
	ent.custagabbreviationentityuuid as ent_custagabbreviationentityuuid, 
	ent.custagparententityuuid as ent_custagparententityuuid, 
	ent.custagorder as ent_custagorder 
from custag cus 
		inner join (select * 
			from entity.crud_custag_read_min(null,null,null, null, true,null,null, null,tempenglishentityuuid)) as ent
				on cus.custagid = ent.custagid
where cus.custagmodifieddate <> ent.custagmodifieddate
		and cus.custagmodifieddate > insertdate
		);

if (select count(*) from cusmodified) > 0
	then

		-- custagname
	
		update languagemaster
		set languagemastersource = custagtype,
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
			languagemastermodifieddate = now()
		from cusmodified 
		where languagemasteruuid = ent_custagnameuuid;

		-- custagdisplayname
		
		update languagemaster
		set languagemastersource = custagtype,
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
			languagemastermodifieddate = now()
		from cusmodified 
		where languagemasteruuid = ent_custagdisplaynameuuid;

		
		-- custagabbreviationentityuuid

		update entity.entityfieldinstance efi
		set entityfieldinstancevalue = abb.entityinstanceuuid::text,
			entityfieldinstancemodifieddate = custagmodifieddate	
		from cusmodified cusmod
			inner join entity.entityfieldinstance efiabb
				on efiabb.entityfieldinstanceentityinstanceentityuuid = ent_custagentityuuid
					and efiabb.entityfieldinstanceentityfieldname = 'custagabbreviationentityuuid'
			left join entity.entityinstance abb
				on cusmod.custagabbreviationid = abb.entityinstanceoriginalid
					and abb.entityinstanceentitytemplatename = 'Customer Tag'
		where  efi.entityfieldinstanceuuid = efiabb.entityfieldinstanceuuid;		

-- entity
		update entity.entityinstance ent
		set 
			entityinstanceownerentityuuid = cust.entityinstanceuuid,
			entityinstancecreateddate = cusmod.custagcreateddate, 
			entityinstancemodifieddate = cusmod.custagmodifieddate, 
			entityinstancestartdate = cusmod.custagstartdate, 
			entityinstanceenddate = cusmod.custagenddate, 
			entityinstanceexternalid = cusmod.custagexternalid, 
			entityinstancemodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = cusmod.custagmodifiedby),
			entityinstancetype = cusmod.custagtype
		from cusmodified cusmod
			inner join entity.entityinstance cust
				on cusmod.custagcustomerid = cust.entityinstanceoriginalid
					and cust.entityinstanceentitytemplatename = 'Customer'
		where cusmod.ent_custaguuid = ent.entityinstanceoriginaluuid;

end if;

drop table cusmodified;


/*
if  (select dwlogginglevel4 from datawarehouse.dw_logginglevels) = false
	Then Return;
end if;

call datawarehouse.insert_tendy_tracker(0, 2521, 12496, 811, 844, 20786, 18068, 20787,20785, customer_start);
*/

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.import_entity_custag(text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_entity_custag(text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_entity_custag(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.import_entity_custag(text) TO graphql;
