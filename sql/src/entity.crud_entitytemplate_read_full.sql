
-- Type: FUNCTION ; Name: entity.crud_entitytemplate_read_full(uuid,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entitytemplate_read_full(read_ownerentityuuid uuid, read_entitytemplateentityuuid uuid, read_entitytemplatesenddeleted boolean, read_entitytemplatesenddrafts boolean, read_entitytemplatesendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(languagetranslationtypeuuid uuid, entitytemplateuuid uuid, entitytemplateownerentityuuid uuid, entitytemplatecustomername text, entitytemplateparententityuuid uuid, entitytemplatesitename text, entitytemplatetypeentityuuid uuid, entitytemplatetype text, entitytemplateisprimary boolean, entitytemplatescanid text, entitytemplatenameuuid text, entitytemplatename text, entitytemplateorder integer, entitytemplatemodifiedbyuuid text, entitytemplatemodifiedby text, entitytemplatestartdate timestamp with time zone, entitytemplateenddate timestamp with time zone, entitytemplatecreateddate timestamp with time zone, entitytemplatemodifieddate timestamp with time zone, entitytemplateexternalid text, entitytemplaterefid bigint, entitytemplaterefuuid text, entitytemplateexternalsystementityuuid uuid, entitytemplateexternalsystem text, entitytemplatedeleted boolean, entitytemplatedraft boolean, entitytemplateactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	templanguagetranslationtypeid bigint;
	tempentitytemplatesenddeleted boolean[]; 
	tempentitytemplatesenddrafts  boolean[];  
	tempentitytemplatesendinactive boolean[];
	tendreluuid uuid;
BEGIN

/*  Examples

-- all customers no entity template
select * from entity.crud_entitytemplate_read_full(null, null, null, null, null,null)

-- specific customer no entity template
select * from entity.crud_entitytemplate_read_full(	'f90d618d-5de7-4126-8c65-0afb700c6c61',null, null, null, null,null)

-- specific entity template
select * 
from entity.crud_entitytemplate_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','957df2f9-051f-4af5-95ee-ea3760fbb83b',	null, null, null,null)

-- negative test - empty or wrong cutomer returns nothing
select * 
from entity.crud_entitytemplate_read_full(null,'957df2f9-051f-4af5-95ee-ea3760fbb83b',null, null, null,	null)

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if read_languagetranslationtypeuuid isNull
	then read_languagetranslationtypeuuid = (
		select systagentityuuid 
		from entity.crud_systag_read_min(tendreluuid, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
		); 
end if;

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if read_entitytemplatesenddeleted isNull and read_entitytemplatesenddeleted = false
	then tempentitytemplatesenddeleted = Array[false];
	else tempentitytemplatesenddeleted = Array[true,false];
end if;

if read_entitytemplatesenddrafts isNull and read_entitytemplatesenddrafts = false
	then tempentitytemplatesenddrafts = Array[false];
	else tempentitytemplatesenddrafts = Array[true,false];
end if;

if read_entitytemplatesendinactive isNull and read_entitytemplatesendinactive = false
	then tempentitytemplatesendinactive = Array[true];
	else tempentitytemplatesendinactive = Array[true,false];
end if;

-- probably can do this cealner with less sql

if allowners = true and (read_entitytemplateentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			et.entitytemplateuuid, 
			et.entitytemplateownerentityuuid, 
			cust.customername,
			et.entitytemplateparententityuuid,
			siten.languagemastersource as sitename,	
			et.entitytemplatetypeentityuuid,
			enttype.systagtype as entitytemplatetype,
			et.entitytemplateisprimary,
			et.entitytemplatescanid,
			et.entitytemplatenameuuid,
			COALESCE(entlt.languagetranslationvalue, entlm.languagemastersource),
			et.entitytemplateorder, 
			et.entitytemplatemodifiedbyuuid,
			templatemodby.workerfullname as templatemodifiedby,
			et.entitytemplatestartdate, 
			et.entitytemplateenddate, 
			et.entitytemplatecreateddate, 
			et.entitytemplatemodifieddate, 
			et.entitytemplateexternalid, 
			et.entitytemplaterefid, 
			et.entitytemplaterefuuid,
			et.entitytemplateexternalsystementityuuid, 
			systemtype.systagtype as externalsystem,
				et.entitytemplatedeleted,
				et.entitytemplatedraft,
				case when et.entitytemplateenddate notnull and et.entitytemplateenddate::Date < now()::date
					then false
					else true
				end as entitytemplatesendinactive
		from entity.entitytemplate et
			inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as cust
				on cust.customerentityuuid = et.entitytemplateownerentityuuid
					and et.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				 	and et.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entitytemplatesenddeleted ,read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as site
				on site.locationentityuuid = et.entitytemplateparententityuuid
			left join languagemaster siten
				on siten.languagemasteruuid = site.locationnameuuid
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as enttype
				on et.entitytemplatetypeentityuuid = enttype.systagentityuuid
			inner join languagemaster entlm
				on et.entitytemplatenameuuid = entlm.languagemasteruuid
			left join public.languagetranslations entlt
				on entlt.languagetranslationmasterid  = entlm.languagemasterid
					and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) 
			left join workerinstance workerint
				on workerint.workerinstanceuuid = et.entitytemplatemodifiedbyuuid 
			left join worker templatemodby
				on templatemodby.workerid = workerint.workerinstanceworkerid
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as systemtype
				on et.entitytemplateexternalsystementityuuid = enttype.systagentityuuid) as foo
		where foo.entitytemplatesendinactive = Any (tempentitytemplatesendinactive);
		return;
end if;

if allowners = false and (read_entitytemplateentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			et2.entitytemplateuuid, 
			et2.entitytemplateownerentityuuid, 
			cust.customername,
			et2.entitytemplateparententityuuid,
			siten.languagemastersource as sitename,	
			et2.entitytemplatetypeentityuuid,
			enttype.systagtype as entitytemplatetype,
			et2.entitytemplateisprimary,
			et2.entitytemplatescanid,
			et2.entitytemplatenameuuid,
			COALESCE(entlt.languagetranslationvalue, entlm.languagemastersource),
			et2.entitytemplateorder, 
			et2.entitytemplatemodifiedbyuuid,
			templatemodby.workerfullname as templatemodifiedby,
			et2.entitytemplatestartdate, 
			et2.entitytemplateenddate, 
			et2.entitytemplatecreateddate, 
			et2.entitytemplatemodifieddate, 
			et2.entitytemplateexternalid, 
			et2.entitytemplaterefid, 
			et2.entitytemplaterefuuid,
			et2.entitytemplateexternalsystementityuuid, 
			systemtype.systagtype as externalsystem,
				et2.entitytemplatedeleted,
				et2.entitytemplatedraft,
				case when et2.entitytemplateenddate notnull and et2.entitytemplateenddate::Date < now()::date
					then false
					else true
				end as entitytemplatesendinactive	
		from entity.entitytemplate et2
			inner join (select * from entity.crud_customer_read_full(null, null,null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as cust
				on cust.customerentityuuid = et2.entitytemplateownerentityuuid
					and et2.entitytemplateownerentityuuid = read_ownerentityuuid
					and et2.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				 	and et2.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entitytemplatesenddeleted ,read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as site
				on site.locationentityuuid = et2.entitytemplateparententityuuid
			left join languagemaster siten
				on siten.languagemasteruuid = site.locationnameuuid
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as enttype
				on et2.entitytemplatetypeentityuuid = enttype.systagentityuuid
			inner join languagemaster entlm
				on et2.entitytemplatenameuuid = entlm.languagemasteruuid
			left join public.languagetranslations entlt
				on entlt.languagetranslationmasterid  = entlm.languagemasterid
					and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) 
			left join workerinstance workerint
				on workerint.workerinstanceuuid = et2.entitytemplatemodifiedbyuuid 
			left join worker templatemodby
				on templatemodby.workerid = workerint.workerinstanceworkerid
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as systemtype
				on et2.entitytemplateexternalsystementityuuid = enttype.systagentityuuid) as foo
		where foo.entitytemplatesendinactive = Any (tempentitytemplatesendinactive);
		return;
end if;

if allowners = false and (read_entitytemplateentityuuid notNull)
	then
		return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			et3.entitytemplateuuid, 
			et3.entitytemplateownerentityuuid, 
			cust.customername,
			et3.entitytemplateparententityuuid,
			siten.languagemastersource as sitename,	
			et3.entitytemplatetypeentityuuid,
			enttype.systagtype as entitytemplatetype,
			et3.entitytemplateisprimary,
			et3.entitytemplatescanid,
			et3.entitytemplatenameuuid,
			COALESCE(entlt.languagetranslationvalue, entlm.languagemastersource),
			et3.entitytemplateorder, 
			et3.entitytemplatemodifiedbyuuid,
			templatemodby.workerfullname as templatemodifiedby,
			et3.entitytemplatestartdate, 
			et3.entitytemplateenddate, 
			et3.entitytemplatecreateddate, 
			et3.entitytemplatemodifieddate, 
			et3.entitytemplateexternalid, 
			et3.entitytemplaterefid, 
			et3.entitytemplaterefuuid,
			et3.entitytemplateexternalsystementityuuid, 
			systemtype.systagtype as externalsystem,
				et3.entitytemplatedeleted,
				et3.entitytemplatedraft,
				case when et3.entitytemplateenddate notnull and et3.entitytemplateenddate::Date < now()::date
					then false
					else true
				end as entitytemplatesendinactive
		from entity.entitytemplate et3
			inner join (select * from entity.crud_customer_read_full(null, null, null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as cust
				on cust.customerentityuuid = et3.entitytemplateownerentityuuid
					and (et3.entitytemplateownerentityuuid = read_ownerentityuuid
						or et3.entitytemplateownerentityuuid = tendreluuid)
					and et3.entitytemplateuuid = read_entitytemplateentityuuid
					and et3.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				 	and et3.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entitytemplatesenddeleted ,read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as site
				on site.locationentityuuid = et3.entitytemplateparententityuuid
			left join languagemaster siten
				on siten.languagemasteruuid = site.locationnameuuid
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as enttype
				on et3.entitytemplatetypeentityuuid = enttype.systagentityuuid
			inner join languagemaster entlm
				on et3.entitytemplatenameuuid = entlm.languagemasteruuid
			left join public.languagetranslations entlt
				on entlt.languagetranslationmasterid  = entlm.languagemasterid
					and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) 
			left join workerinstance workerint
				on workerint.workerinstanceuuid = et3.entitytemplatemodifiedbyuuid 
			left join worker templatemodby
				on templatemodby.workerid = workerint.workerinstanceworkerid
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as systemtype
				on et3.entitytemplateexternalsystementityuuid = enttype.systagentityuuid ) as foo
		where foo.entitytemplatesendinactive = Any (tempentitytemplatesendinactive);
		return;
end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entitytemplate_read_full(uuid,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytemplate_read_full(uuid,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytemplate_read_full(uuid,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
