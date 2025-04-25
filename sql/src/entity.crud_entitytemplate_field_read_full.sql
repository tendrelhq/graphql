
-- Type: FUNCTION ; Name: entity.crud_entitytemplate_field_read_full(uuid,uuid,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entitytemplate_field_read_full(read_ownerentityuuid uuid, read_entitytemplateentityuuid uuid, read_entityfieldentityuuid uuid, read_entitytemplatesenddeleted boolean, read_entitytemplatesenddrafts boolean, read_entitytemplatesendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(languagetranslationtypeuuid uuid, entitytemplateuuid uuid, entitytemplateownerentityuuid uuid, entitytemplatecustomername text, entitytemplateparententityuuid uuid, entitytemplatesitename text, entitytemplatetypeentityuuid uuid, entitytemplatetype text, entitytemplateisprimary boolean, entitytemplatescanid text, entitytemplatenameuuid text, entitytemplatename text, entitytemplateorder integer, entitytemplatemodifiedbyuuid text, entitytemplatemodifiedby text, entitytemplatestartdate timestamp with time zone, entitytemplateenddate timestamp with time zone, entitytemplatecreateddate timestamp with time zone, entitytemplatemodifieddate timestamp with time zone, entitytemplateexternalid text, entitytemplaterefid bigint, entitytemplaterefuuid text, entitytemplateexternalsystementityuuid uuid, entitytemplateexternalsystem text, entitytemplatedeleted boolean, entitytemplatedraft boolean, entitytemplateactive boolean, entityfielduuid uuid, entityfieldentitytemplateentityuuid uuid, entityfieldcreateddate timestamp with time zone, entityfieldmodifieddate timestamp with time zone, entityfieldstartdate timestamp with time zone, entityfieldenddate timestamp with time zone, entityfieldlanguagemasteruuid text, entityfieldtranslatedname text, entityfieldorder bigint, entityfielddefaultvalue text, entityfieldiscalculated boolean, entityfieldiseditable boolean, entityfieldisvisible boolean, entityfieldisrequired boolean, entityfieldformatentityuuid uuid, entityfieldformatname text, entityfieldwidgetentityuuid uuid, entityfieldwidgetname text, entityfieldexternalid text, entityfieldexternalsystementityuuid uuid, entityfieldexternalsystemname text, entityfieldmodifiedbyuuid text, entityfieldmodifiedby text, entityfieldrefid bigint, entityfieldrefuuid text, entityfieldisprimary boolean, entityfieldtranslate boolean, entityfieldname text, entityfieldownerentityuuid uuid, entityfieldcustomername text, entityfieldtypeentityuuid uuid, entityfieldtypename text, entityfieldparententityuuid uuid, entityfieldsitename text, entityfieldentitytypeentityuuid uuid, entityfieldentitytypename text, entityfieldentityparenttypeentityuuid uuid, entityfieldparenttypename text, entityfieldeleted boolean, entityfielddraft boolean, entityfieldactive boolean)
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

-- all customers no entity template no field
select * from entity.crud_entitytemplate_field_read_full(null, null, null,null, null, null,null)

-- specific customer no entity template no field
select * from entity.crud_entitytemplate_field_read_full(	'f90d618d-5de7-4126-8c65-0afb700c6c61',null, null, null, null, null,null)

-- specific entity template
select * 
from entity.crud_entitytemplate_field_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null, null, null,	null)

-- specific entity field
select * 
from entity.crud_entitytemplate_field_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null, null, null,	null)

-- negative tests - empty or wrong cutomer returns nothing
select * 
from entity.crud_entitytemplate_field_read_full(null,'b124da10-be8a-4d32-9f68-7f4e6e8b24e9',	null,null, null, null,null)

select * 
from entity.crud_entitytemplate_field_read_full(null,null,	'd15bb9c2-0601-4e4f-9009-c791a40be191',null, null, null,null)

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if read_languagetranslationtypeuuid isNull
	then read_languagetranslationtypeuuid = (
		select systagentityuuid 
		from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,read_entitytemplatesenddeleted , read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
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

if allowners = true and (read_entitytemplateentityuuid isNull) and (read_entityfieldentityuuid isNull)
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
			entlt.languagetranslationvalue as entitytemplatename,
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
				end as entitytemplatesendinactive,
			ef.entityfielduuid, 
			ef.entityfieldentitytemplateentityuuid, 
			ef.entityfieldcreateddate, 
			ef.entityfieldmodifieddate, 
			ef.entityfieldstartdate, 
			ef.entityfieldenddate, 
			ef.entityfieldlanguagemasteruuid, 
			enflt.languagetranslationvalue as entityfieldtranslatedname,			
			ef.entityfieldorder, 
			ef.entityfielddefaultvalue, 
			ef.entityfieldiscalculated, 
			ef.entityfieldiseditable, 
			ef.entityfieldisvisible, 
			ef.entityfieldisrequired, 
			ef.entityfieldformatentityuuid, 
			format.custagtype as entityfieldformatname,			
			ef.entityfieldwidgetentityuuid, 
			widget.custagtype as entityfieldwidgetname,
			ef.entityfieldexternalid,
			ef.entityfieldexternalsystementityuuid, 
			efexsys.systagtype as entityfieldexternalsystemname,
			ef.entityfieldmodifiedbyuuid, 
			fieldmodby.workerfullname as fieldmodifiedby,			
			ef.entityfieldrefid, 
			ef.entityfieldrefuuid,
			ef.entityfieldisprimary, 
			ef.entityfieldtranslate, 
			ef.entityfieldname, 
			ef.entityfieldownerentityuuid, 
			efcust.customername as entityfieldcustomername,			
			ef.entityfieldtypeentityuuid, 
			eft.systagtype as entityfieldtypename,			
			ef.entityfieldparententityuuid, 
			efsiten.languagemastersource as entityfieldsitename,				
			ef.entityfieldentitytypeentityuuid, 
			efet.systagtype as entityfieldentitytypename,			
			ef.entityfieldentityparenttypeentityuuid,
			efpt.systagtype as entityfieldparenttypename,
				ef.entityfielddeleted,
				ef.entityfielddraft,
				case when ef.entityfieldenddate notnull and ef.entityfieldenddate::Date < now()::date
					then false
					else true
				end as entityfieldsendinactive
		from entity.entitytemplate et
			inner join entity.entityfield ef
				on ef.entityfieldentitytemplateentityuuid = et.entitytemplateuuid
					and et.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				 	and et.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)
					and ef.entityfielddeleted = ANY (tempentitytemplatesenddeleted)
				 	and ef.entityfielddraft = ANY (tempentitytemplatesenddrafts)
			inner join (select * from entity.crud_customer_read_full(null, null, null,true, read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive,null)) as cust
				on cust.customerentityuuid = et.entitytemplateownerentityuuid
			inner join (select * from entity.crud_customer_read_full(null, null, null,true, read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive,null)) as efcust
				on efcust.customerentityuuid = ef.entityfieldownerentityuuid
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entitytemplatesenddeleted ,read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as site
				on site.locationentityuuid = et.entitytemplateparententityuuid
			left join languagemaster siten
				on siten.languagemasteruuid = site.locationnameuuid
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted , read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as enttype
				on et.entitytemplatetypeentityuuid = enttype.systagentityuuid
			inner join languagemaster entlm
				on et.entitytemplatenameuuid = entlm.languagemasteruuid
			inner join public.languagetranslations entlt
				on entlt.languagetranslationmasterid  = entlm.languagemasterid
					and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) 
			left join workerinstance workerint
				on workerint.workerinstanceuuid = et.entitytemplatemodifiedbyuuid 
			left join worker templatemodby
				on templatemodby.workerid = workerint.workerinstanceworkerid
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as systemtype
				on et.entitytemplateexternalsystementityuuid = enttype.systagentityuuid
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entitytemplatesenddeleted ,read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efsite
				on efsite.locationentityuuid = ef.entityfieldparententityuuid
			left join languagemaster efsiten
				on efsiten.languagemasteruuid = efsite.locationnameuuid
			inner join languagemaster enflm
				on ef.entityfieldlanguagemasteruuid = enflm.languagemasteruuid
			inner join public.languagetranslations enflt
				on enflt.languagetranslationmasterid  = enflm.languagemasterid
					and enflt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) 
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts, read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as format
				on ef.entityfieldformatentityuuid = format.custagentityuuid	
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts, read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as widget
				on ef.entityfieldwidgetentityuuid = widget.custagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efexsys
				on ef.entityfieldexternalsystementityuuid = efexsys.systagentityuuid	
			left join workerinstance workerintfield
				on workerintfield.workerinstanceuuid = ef.entityfieldmodifiedbyuuid 
			left join worker fieldmodby
				on fieldmodby.workerid = workerintfield.workerinstanceworkerid	
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as eft
				on ef.entityfieldtypeentityuuid = eft.systagentityuuid	 
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efet
				on ef.entityfieldentitytypeentityuuid = efet.systagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efpt
				on ef.entityfieldentityparenttypeentityuuid = efpt.systagentityuuid) as foo
		where foo.entitytemplatesendinactive = Any (tempentitytemplatesendinactive)	
			and foo.entityfieldsendinactive = Any (tempentitytemplatesendinactive)
				;
		return;
end if;

if allowners = false and (read_entitytemplateentityuuid isNull) and (read_entityfieldentityuuid isNull)
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
			entlt.languagetranslationvalue as entitytemplatename,
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
				end as entitytemplatesendinactive,
			ef.entityfielduuid, 
			ef.entityfieldentitytemplateentityuuid, 
			ef.entityfieldcreateddate, 
			ef.entityfieldmodifieddate, 
			ef.entityfieldstartdate, 
			ef.entityfieldenddate, 
			ef.entityfieldlanguagemasteruuid, 
			enflt.languagetranslationvalue as entityfieldtranslatedname,			
			ef.entityfieldorder, 
			ef.entityfielddefaultvalue, 
			ef.entityfieldiscalculated, 
			ef.entityfieldiseditable, 
			ef.entityfieldisvisible, 
			ef.entityfieldisrequired, 
			ef.entityfieldformatentityuuid, 
			format.custagtype as entityfieldformatname,			
			ef.entityfieldwidgetentityuuid, 
			widget.custagtype as entityfieldwidgetname,
			ef.entityfieldexternalid,
			ef.entityfieldexternalsystementityuuid, 
			efexsys.systagtype as entityfieldexternalsystemname,
			ef.entityfieldmodifiedbyuuid, 
			fieldmodby.workerfullname as fieldmodifiedby,			
			ef.entityfieldrefid, 
			ef.entityfieldrefuuid,
			ef.entityfieldisprimary, 
			ef.entityfieldtranslate, 
			ef.entityfieldname, 
			ef.entityfieldownerentityuuid, 
			efcust.customername as entityfieldcustomername,			
			ef.entityfieldtypeentityuuid, 
			eft.systagtype as entityfieldtypename,			
			ef.entityfieldparententityuuid, 
			efsiten.languagemastersource as entityfieldsitename,				
			ef.entityfieldentitytypeentityuuid, 
			efet.systagtype as entityfieldentitytypename,			
			ef.entityfieldentityparenttypeentityuuid,
			efpt.systagtype as entityfieldparenttypename,
				ef.entityfielddeleted,
				ef.entityfielddraft,
				case when ef.entityfieldenddate notnull and ef.entityfieldenddate::Date < now()::date
					then false
					else true
				end as entityfieldsendinactive
		from entity.entitytemplate et
			inner join entity.entityfield ef
				on ef.entityfieldentitytemplateentityuuid = et.entitytemplateuuid
					and (et.entitytemplateownerentityuuid = read_ownerentityuuid
						or et.entitytemplateownerentityuuid = tendreluuid)
					and et.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				 	and et.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)
					and ef.entityfielddeleted = ANY (tempentitytemplatesenddeleted)
				 	and ef.entityfielddraft = ANY (tempentitytemplatesenddrafts)
			inner join (select * from entity.crud_customer_read_full(null, null, null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as cust
				on cust.customerentityuuid = et.entitytemplateownerentityuuid
			inner join (select * from entity.crud_customer_read_full(null, null, null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as efcust
				on efcust.customerentityuuid = ef.entityfieldownerentityuuid
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entitytemplatesenddeleted ,read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as site
				on site.locationentityuuid = et.entitytemplateparententityuuid
			left join languagemaster siten
				on siten.languagemasteruuid = site.locationnameuuid
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as enttype
				on et.entitytemplatetypeentityuuid = enttype.systagentityuuid
			inner join languagemaster entlm
				on et.entitytemplatenameuuid = entlm.languagemasteruuid
			inner join public.languagetranslations entlt
				on entlt.languagetranslationmasterid  = entlm.languagemasterid
					and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) 
			left join workerinstance workerint
				on workerint.workerinstanceuuid = et.entitytemplatemodifiedbyuuid 
			left join worker templatemodby
				on templatemodby.workerid = workerint.workerinstanceworkerid
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as systemtype
				on et.entitytemplateexternalsystementityuuid = enttype.systagentityuuid
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entitytemplatesenddeleted ,read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efsite
				on efsite.locationentityuuid = ef.entityfieldparententityuuid
			left join languagemaster efsiten
				on efsiten.languagemasteruuid = efsite.locationnameuuid
			inner join languagemaster enflm
				on ef.entityfieldlanguagemasteruuid = enflm.languagemasteruuid
			inner join public.languagetranslations enflt
				on enflt.languagetranslationmasterid  = enflm.languagemasterid
					and enflt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) 
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts, read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as format
				on ef.entityfieldformatentityuuid = format.custagentityuuid	
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts, read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as widget
				on ef.entityfieldwidgetentityuuid = widget.custagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efexsys
				on ef.entityfieldexternalsystementityuuid = efexsys.systagentityuuid	
			left join workerinstance workerintfield
				on workerintfield.workerinstanceuuid = ef.entityfieldmodifiedbyuuid 
			left join worker fieldmodby
				on fieldmodby.workerid = workerintfield.workerinstanceworkerid	
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as eft
				on ef.entityfieldtypeentityuuid = eft.systagentityuuid	 
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efet
				on ef.entityfieldentitytypeentityuuid = efet.systagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efpt
				on ef.entityfieldentityparenttypeentityuuid = efpt.systagentityuuid) as foo
		where foo.entitytemplatesendinactive = Any (tempentitytemplatesendinactive)
					and foo.entityfieldsendinactive = Any (tempentitytemplatesendinactive);
			return;
		 
end if;

if allowners = false and (read_entitytemplateentityuuid notNull) and (read_entityfieldentityuuid isNull)
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
			entlt.languagetranslationvalue as entitytemplatename,
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
				end as entitytemplatesendinactive,
			ef.entityfielduuid, 
			ef.entityfieldentitytemplateentityuuid, 
			ef.entityfieldcreateddate, 
			ef.entityfieldmodifieddate, 
			ef.entityfieldstartdate, 
			ef.entityfieldenddate, 
			ef.entityfieldlanguagemasteruuid, 
			enflt.languagetranslationvalue as entityfieldtranslatedname,			
			ef.entityfieldorder, 
			ef.entityfielddefaultvalue, 
			ef.entityfieldiscalculated, 
			ef.entityfieldiseditable, 
			ef.entityfieldisvisible, 
			ef.entityfieldisrequired, 
			ef.entityfieldformatentityuuid, 
			format.custagtype as entityfieldformatname,			
			ef.entityfieldwidgetentityuuid, 
			widget.custagtype as entityfieldwidgetname,
			ef.entityfieldexternalid,
			ef.entityfieldexternalsystementityuuid, 
			efexsys.systagtype as entityfieldexternalsystemname,
			ef.entityfieldmodifiedbyuuid, 
			fieldmodby.workerfullname as fieldmodifiedby,			
			ef.entityfieldrefid, 
			ef.entityfieldrefuuid,
			ef.entityfieldisprimary, 
			ef.entityfieldtranslate, 
			ef.entityfieldname, 
			ef.entityfieldownerentityuuid, 
			efcust.customername as entityfieldcustomername,			
			ef.entityfieldtypeentityuuid, 
			eft.systagtype as entityfieldtypename,			
			ef.entityfieldparententityuuid, 
			efsiten.languagemastersource as entityfieldsitename,				
			ef.entityfieldentitytypeentityuuid, 
			efet.systagtype as entityfieldentitytypename,			
			ef.entityfieldentityparenttypeentityuuid,
			efpt.systagtype as entityfieldparenttypename,
				ef.entityfielddeleted,
				ef.entityfielddraft,
				case when ef.entityfieldenddate notnull and ef.entityfieldenddate::Date < now()::date
					then false
					else true
				end as entityfieldsendinactive
		from entity.entitytemplate et
			inner join entity.entityfield ef
				on ef.entityfieldentitytemplateentityuuid = et.entitytemplateuuid
					and (et.entitytemplateownerentityuuid = read_ownerentityuuid
						or et.entitytemplateownerentityuuid = tendreluuid)
					and et.entitytemplateuuid = read_entitytemplateentityuuid
					and et.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				 	and et.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)
					and ef.entityfielddeleted = ANY (tempentitytemplatesenddeleted)
				 	and ef.entityfielddraft = ANY (tempentitytemplatesenddrafts)
			inner join (select * from entity.crud_customer_read_full(null, null, null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as cust
				on cust.customerentityuuid = et.entitytemplateownerentityuuid
			inner join (select * from entity.crud_customer_read_full(null, null, null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as efcust
				on efcust.customerentityuuid = ef.entityfieldownerentityuuid
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entitytemplatesenddeleted ,read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as site
				on site.locationentityuuid = et.entitytemplateparententityuuid
			left join languagemaster siten
				on siten.languagemasteruuid = site.locationnameuuid
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as enttype
				on et.entitytemplatetypeentityuuid = enttype.systagentityuuid
			inner join languagemaster entlm
				on et.entitytemplatenameuuid = entlm.languagemasteruuid
			inner join public.languagetranslations entlt
				on entlt.languagetranslationmasterid  = entlm.languagemasterid
					and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) 
			left join workerinstance workerint
				on workerint.workerinstanceuuid = et.entitytemplatemodifiedbyuuid 
			left join worker templatemodby
				on templatemodby.workerid = workerint.workerinstanceworkerid
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as systemtype
				on et.entitytemplateexternalsystementityuuid = enttype.systagentityuuid
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entitytemplatesenddeleted ,read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efsite
				on efsite.locationentityuuid = ef.entityfieldparententityuuid
			left join languagemaster efsiten
				on efsiten.languagemasteruuid = efsite.locationnameuuid
			inner join languagemaster enflm
				on ef.entityfieldlanguagemasteruuid = enflm.languagemasteruuid
			inner join public.languagetranslations enflt
				on enflt.languagetranslationmasterid  = enflm.languagemasterid
					and enflt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'))
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts, read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as format
				on ef.entityfieldformatentityuuid = format.custagentityuuid	
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts, read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as widget
				on ef.entityfieldwidgetentityuuid = widget.custagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efexsys
				on ef.entityfieldexternalsystementityuuid = efexsys.systagentityuuid	
			left join workerinstance workerintfield
				on workerintfield.workerinstanceuuid = ef.entityfieldmodifiedbyuuid 
			left join worker fieldmodby
				on fieldmodby.workerid = workerintfield.workerinstanceworkerid	
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as eft
				on ef.entityfieldtypeentityuuid = eft.systagentityuuid	 
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efet
				on ef.entityfieldentitytypeentityuuid = efet.systagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efpt
				on ef.entityfieldentityparenttypeentityuuid = efpt.systagentityuuid) as foo
		where foo.entitytemplatesendinactive = Any (tempentitytemplatesendinactive)
					and foo.entityfieldsendinactive = Any (tempentitytemplatesendinactive);
		return;

end if;

if allowners = false and (read_entityfieldentityuuid notNull)
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
			entlt.languagetranslationvalue as entitytemplatename,
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
				end as entitytemplatesendinactive,
			ef.entityfielduuid, 
			ef.entityfieldentitytemplateentityuuid, 
			ef.entityfieldcreateddate, 
			ef.entityfieldmodifieddate, 
			ef.entityfieldstartdate, 
			ef.entityfieldenddate, 
			ef.entityfieldlanguagemasteruuid, 
			enflt.languagetranslationvalue as entityfieldtranslatedname,			
			ef.entityfieldorder, 
			ef.entityfielddefaultvalue, 
			ef.entityfieldiscalculated, 
			ef.entityfieldiseditable, 
			ef.entityfieldisvisible, 
			ef.entityfieldisrequired, 
			ef.entityfieldformatentityuuid, 
			format.custagtype as entityfieldformatname,			
			ef.entityfieldwidgetentityuuid, 
			widget.custagtype as entityfieldwidgetname,
			ef.entityfieldexternalid,
			ef.entityfieldexternalsystementityuuid, 
			efexsys.systagtype as entityfieldexternalsystemname,
			ef.entityfieldmodifiedbyuuid, 
			fieldmodby.workerfullname as fieldmodifiedby,			
			ef.entityfieldrefid, 
			ef.entityfieldrefuuid,
			ef.entityfieldisprimary, 
			ef.entityfieldtranslate, 
			ef.entityfieldname, 
			ef.entityfieldownerentityuuid, 
			efcust.customername as entityfieldcustomername,			
			ef.entityfieldtypeentityuuid, 
			eft.systagtype as entityfieldtypename,			
			ef.entityfieldparententityuuid, 
			efsiten.languagemastersource as entityfieldsitename,				
			ef.entityfieldentitytypeentityuuid, 
			efet.systagtype as entityfieldentitytypename,			
			ef.entityfieldentityparenttypeentityuuid,
			efpt.systagtype as entityfieldparenttypename,
				ef.entityfielddeleted,
				ef.entityfielddraft,
				case when ef.entityfieldenddate notnull and ef.entityfieldenddate::Date < now()::date
					then false
					else true
				end as entityfieldsendinactive
		from entity.entitytemplate et
			inner join entity.entityfield ef
				on ef.entityfieldentitytemplateentityuuid = et.entitytemplateuuid
					and (et.entitytemplateownerentityuuid = read_ownerentityuuid
						or et.entitytemplateownerentityuuid = tendreluuid)
					and ef.entityfielduuid = read_entityfieldentityuuid
					and et.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				 	and et.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)
					and ef.entityfielddeleted = ANY (tempentitytemplatesenddeleted)
				 	and ef.entityfielddraft = ANY (tempentitytemplatesenddrafts)
			inner join (select * from entity.crud_customer_read_full(null, null, null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as cust
				on cust.customerentityuuid = et.entitytemplateownerentityuuid
			inner join (select * from entity.crud_customer_read_full(null, null, null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as efcust
				on efcust.customerentityuuid = ef.entityfieldownerentityuuid
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entitytemplatesenddeleted ,read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as site
				on site.locationentityuuid = et.entitytemplateparententityuuid
			left join languagemaster siten
				on siten.languagemasteruuid = site.locationnameuuid
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as enttype
				on et.entitytemplatetypeentityuuid = enttype.systagentityuuid
			inner join languagemaster entlm
				on et.entitytemplatenameuuid = entlm.languagemasteruuid
			inner join public.languagetranslations entlt
				on entlt.languagetranslationmasterid  = entlm.languagemasterid
					and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) 
			left join workerinstance workerint
				on workerint.workerinstanceuuid = et.entitytemplatemodifiedbyuuid 
			left join worker templatemodby
				on templatemodby.workerid = workerint.workerinstanceworkerid
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as systemtype
				on et.entitytemplateexternalsystementityuuid = enttype.systagentityuuid
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entitytemplatesenddeleted ,read_entitytemplatesenddrafts ,read_entitytemplatesendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efsite
				on efsite.locationentityuuid = ef.entityfieldparententityuuid
			left join languagemaster efsiten
				on efsiten.languagemasteruuid = efsite.locationnameuuid
			inner join languagemaster enflm
				on ef.entityfieldlanguagemasteruuid = enflm.languagemasteruuid
			inner join public.languagetranslations enflt
				on enflt.languagetranslationmasterid  = enflm.languagemasterid
					and enflt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'))
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts, read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as format
				on ef.entityfieldformatentityuuid = format.custagentityuuid	
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts, read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as widget
				on ef.entityfieldwidgetentityuuid = widget.custagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efexsys
				on ef.entityfieldexternalsystementityuuid = efexsys.systagentityuuid	
			left join workerinstance workerintfield
				on workerintfield.workerinstanceuuid = ef.entityfieldmodifiedbyuuid 
			left join worker fieldmodby
				on fieldmodby.workerid = workerintfield.workerinstanceworkerid	
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as eft
				on ef.entityfieldtypeentityuuid = eft.systagentityuuid	 
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efet
				on ef.entityfieldentitytypeentityuuid = efet.systagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted  , read_entitytemplatesenddrafts  ,read_entitytemplatesendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as efpt
				on ef.entityfieldentityparenttypeentityuuid = efpt.systagentityuuid) as foo
		where foo.entitytemplatesendinactive = Any (tempentitytemplatesendinactive)
					and foo.entityfieldsendinactive = Any (tempentitytemplatesendinactive);
		return;

end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entitytemplate_field_read_full(uuid,uuid,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytemplate_field_read_full(uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytemplate_field_read_full(uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entitytemplate_field_read_full(uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO graphql;
