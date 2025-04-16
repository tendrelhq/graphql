
-- Type: PROCEDURE ; Name: entity.import_entity_systag(text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.import_entity_systag(IN intervaltype text)
 LANGUAGE plpgsql
AS $procedure$
Declare
   location_start timestamp with time zone;
	maxdate timestamp with time zone;
--	updatedate timestamp with time zone;
	insertdate timestamp with time zone;
	tempenglishentityuuid uuid;
	temptendrelenitytuuid uuid;
	tempentitytemplateuuid uuid;
	tempentitytemplatetypeuuid uuid;	
Begin

tempenglishentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
temptendrelenitytuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';
tempentitytemplateuuid = (select entitytemplateuuid from entity.entitytemplate where entitytemplatename = 'System Tag');
tempentitytemplatetypeuuid = (select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatename = 'System Tag');

-- Start the timer on this function
	location_start = clock_timestamp();
	maxdate = 	(select max(systagmodifieddate) 
					from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,tempenglishentityuuid));

	insertdate = 
		case
			when intervaltype = '5 minute' and maxdate notNull
				Then (select (max(systagmodifieddate)- interval '1 hour') 
						from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,tempenglishentityuuid))
			when intervaltype = '1 hour' and maxdate notNull
				Then (select (max(systagmodifieddate)- interval '2 hour') 
						from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,tempenglishentityuuid))			
			Else '01/01/1900'
		end;	

--------------------------------------		

INSERT INTO entity.entityinstance(
	entityinstanceoriginalid, 
	entityinstanceoriginaluuid, 
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
	tag.systagid,
	tag.systaguuid,
	(select entityinstanceuuid from entity.entityinstance 
		where entityinstanceoriginalid = 0 
			and entityinstanceentitytemplatename = 'Customer'),
	parent.entityinstanceuuid,		
	tempentitytemplateuuid,
	tempentitytemplatetypeuuid,
	tag.systagcreateddate,
	tag.systagmodifieddate, 
	tag.systagstartdate, 
	tag.systagenddate, 
	tag.systagexternalid,
	null,
	sys.systagentityuuid as systagexternalsystementityuuid,	
	(select workerinstanceuuid from workerinstance where workerinstanceid = tag.systagmodifiedby),
	tag.systagrefid, 
	tag.systagrefuuid,	
	tag.systagorder::integer,
	'System Tag',
	tag.systagtype,
	(select languagemasteruuid from languagemaster where languagemasterid = tag.systagnameid),
	false,
	false	
from systag tag
	inner join entity.entityinstance parent
		on tag.systagparentid = parent.entityinstanceoriginalid
			and parent.entityinstanceentitytemplatename = 'System Tag'
	left join entity.entityinstance instanceexists
		on tag.systagid = instanceexists.entityinstanceoriginalid
			and instanceexists.entityinstancetypeentityuuid = (select entitytemplatetypeentityuuid from entity.entitytemplate where entitytemplatename = 'System Tag')
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,tempenglishentityuuid)) as sys
		on sys.systagid = tag.systagexternalsystemid
where instanceexists.entityinstanceuuid isNull 
	and tag.systagmodifieddate > insertdate
	and tag.systagmodifieddate < (now() - interval '10 minutes') ;

-- set cornerstone

update entity.entityinstance
set entityinstancecornerstoneentityuuid = entityinstanceuuid
where entityinstanceentitytemplatename in ('System Tag') 
	and entityinstancecornerstoneentityuuid isNull;

-- systagdisplayname

insert into public.languagemaster
    (languagemastercustomerid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
	 languagemasterrefuuid,
     languagemastermodifiedby)
select
	systagcustomerid,
	20,
    systagtype,	
	ent.entityinstanceuuid||'-systagdisplayname',
	337
from entity.entityinstance ent
	inner join systag
		on systagid = ent.entityinstanceoriginalid
			and ent.entityinstanceentitytemplatename = 'System Tag'
			and systagmodifieddate > insertdate
	inner join entity.entitytemplate
		on ent.entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'systagdisplayname'
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
				(select systaguuid from systag 
				where systagid in (languagemastersourcelanguagetypeid))),
	systagcreateddate,
	systagmodifieddate,
	entityfielduuid,
	entityinstancemodifiedbyuuid,
	entityfieldname
from entity.entityinstance
	inner join systag
		on systagid = entityinstanceoriginalid
			and entityinstanceentitytemplatename = 'System Tag'
			and systagmodifieddate > insertdate
	inner join entity.entitytemplate
		on entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'systagdisplayname'
	inner join languagemaster
		on languagemasterrefuuid = entityinstanceuuid||'-systagdisplayname'
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = entityinstanceuuid
			and entityfieldinstanceentityfieldentityuuid = entityfielduuid
where entityfieldinstanceuuid isNull;

-- systagabbreviationentityuuid

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
	abb.entityinstanceuuid,
	loc.systagcreateddate,
	loc.systagmodifieddate,
	entityfielduuid,
	ent.entityinstancemodifiedbyuuid,
	entityfieldname
from entity.entityinstance ent
	inner join systag loc
		on loc.systagid = ent.entityinstanceoriginalid
			and ent.entityinstanceentitytemplatename = 'System Tag'
			and systagmodifieddate > insertdate
	left join entity.entityinstance abb
		on loc.systagabbreviationid = abb.entityinstanceoriginalid
	inner join entity.entitytemplate
		on ent.entityinstanceentitytemplateentityuuid = entitytemplateuuid
	inner join entity.entityfield
		on entityfieldentitytemplateentityuuid = entitytemplateuuid	
			and entityfieldname = 'systagabbreviationentityuuid'
	left join entity.entityfieldinstance
		on entityfieldinstanceentityinstanceentityuuid = ent.entityinstanceuuid
			and entityfieldinstanceentityfieldentityuuid = entityfielduuid
where entityfieldinstanceuuid isNull;


-- update any modified systags

-------  TRIM THIS TABLE TO NEEDED DATA.  RIGHT NOW I GRAB EVERYTHING ------

create temp table sysmodified  as
(select sys.*,
	ent.languagetranslationtypeentityuuid as languagetranslationtypeentityuuid, 
	ent.systagid as ent_systagid, 
	ent.systaguuid as ent_systaguuid, 
	ent.systagentityuuid as ent_systagentityuuid, 
	ent.systagcustomerid as ent_systagcustomerid, 
	ent.systagcustomeruuid as ent_systagcustomeruuid, 
	ent.systagcustomerentityuuid as ent_systagcustomerentityuuid, 
	ent.systagnameuuid as ent_systagnameuuid, 
	ent.systagdisplaynameuuid as ent_systagdisplaynameuuid, 
	ent.systagtype as ent_systagtype, 
	ent.systagcreateddate as ent_systagcreateddate, 
	ent.systagmodifieddate as ent_systagmodifieddate, 
	ent.systagstartdate as ent_systagstartdate, 
	ent.systagenddate as ent_systagenddate, 
	ent.systagexternalid as ent_systagexternalid, 
	ent.systagexternalsystementityuuid as ent_systagexternalsystementityuuid, 
	ent.systagmodifiedbyuuid as ent_systagmodifiedbyuuid, 
	ent.systagabbreviationentityuuid as ent_systagabbreviationentityuuid, 
	ent.systagparententityuuid as ent_systagparententityuuid, 
	ent.systagorder as ent_systagorder 
from systag sys 
		inner join (select * 
			from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,tempenglishentityuuid)) as ent
				on sys.systagid = ent.systagid
where sys.systagmodifieddate <> ent.systagmodifieddate
		and sys.systagmodifieddate > insertdate);

if (select count(*) from sysmodified) > 0
	then

		-- systagname
	
		update languagemaster
		set languagemastersource = systagtype,
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
			languagemastermodifieddate = now()
		from sysmodified 
		where languagemasteruuid = ent_systagnameuuid;
		
		-- systagdisplayname
		
		update languagemaster
		set languagemastersource = systagtype,
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
			languagemastermodifieddate = now()
		from sysmodified 
		where languagemasteruuid = ent_systagdisplaynameuuid;

			
		-- systagabbreviationentityuuid

		update entity.entityfieldinstance efi
		set entityfieldinstancevalue = abb.entityinstanceuuid::text,
			entityfieldinstancemodifieddate = systagmodifieddate	
		from sysmodified sysmod
			inner join entity.entityfieldinstance efiabb
				on efiabb.entityfieldinstanceentityinstanceentityuuid = ent_systagentityuuid
					and efiabb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid'
			left join entity.entityinstance abb
				on sysmod.systagparentid = abb.entityinstanceoriginalid   
					and abb.entityinstanceentitytemplatename = 'System Tag'
		where  efi.entityfieldinstanceuuid = efiabb.entityfieldinstanceuuid;		

		-- entity
			update entity.entityinstance ent
			set 
				entityinstanceownerentityuuid = cust.entityinstanceuuid,
				entityinstancecreateddate = sysmod.systagcreateddate, 
				entityinstancemodifieddate = sysmod.systagmodifieddate, 
				entityinstancestartdate = sysmod.systagstartdate, 
				entityinstanceenddate = sysmod.systagenddate, 
				entityinstanceexternalid = sysmod.systagexternalid, 
				entityinstancemodifiedbyuuid = (select workerinstanceuuid from workerinstance where workerinstanceid = sysmod.systagmodifiedby),
				entityinstancetype = sysmod.systagtype
			from sysmodified sysmod
				inner join entity.entityinstance cust
					on sysmod.systagcustomerid = cust.entityinstanceoriginalid
						and cust.entityinstanceentitytemplatename = 'Customer'
			where sysmod.ent_systaguuid = ent.entityinstanceoriginaluuid;

end if;

drop table sysmodified;



/*
if  (select dwlogginglevel4 from datawarehouse.dw_logginglevels) = false
	Then Return;
end if;

call datawarehouse.insert_tendy_tracker(0, 2521, 12496, 811, 844, 20786, 18068, 20787,20785, customer_start);
*/

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.import_entity_systag(text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_entity_systag(text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_entity_systag(text) TO tendreladmin WITH GRANT OPTION;
