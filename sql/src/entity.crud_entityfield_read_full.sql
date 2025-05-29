BEGIN;

/*
DROP FUNCTION api.delete_entity_field(uuid,uuid);
DROP VIEW api.entity_field;

DROP FUNCTION entity.crud_entityfield_read_full(uuid,uuid,uuid,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_entityfield_read_full(uuid,uuid,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entityfield_read_full(read_ownerentityuuid uuid, read_entitytemplateentityuuid uuid, read_entityfieldentityuuid uuid, read_entityfieldsenddeleted boolean, read_entityfieldsenddrafts boolean, read_entityfieldsendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(languagetranslationtypeuuid uuid, entityfielduuid uuid, entityfieldentitytemplateentityuuid uuid, entityfieldcreateddate timestamp with time zone, entityfieldmodifieddate timestamp with time zone, entityfieldstartdate timestamp with time zone, entityfieldenddate timestamp with time zone, entityfieldlanguagemasteruuid text, entityfieldtranslatedname text, entityfieldorder bigint, entityfielddefaultvalue text, entityfieldiscalculated boolean, entityfieldiseditable boolean, entityfieldisvisible boolean, entityfieldisrequired boolean, entityfieldformatentityuuid uuid, entityfieldformatname text, entityfieldwidgetentityuuid uuid, entityfieldwidgetname text, entityfieldexternalid text, entityfieldexternalsystementityuuid uuid, entityfieldexternalsystemname text, entityfieldmodifiedbyuuid text, entityfieldmodifiedby text, entityfieldrefid bigint, entityfieldrefuuid text, entityfieldisprimary boolean, entityfieldtranslate boolean, entityfieldname text, entityfieldownerentityuuid uuid, entityfieldcustomername text, entityfieldtypeentityuuid uuid, entityfieldtypename text, entityfieldparententityuuid uuid, entityfieldsitename text, entityfieldentitytypeentityuuid uuid, entityfieldentitytypename text, entityfieldentityparenttypeentityuuid uuid, entityfieldparenttypename text, entityfielddeleted boolean, entityfielddraft boolean, entityfieldactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	templanguagetranslationtypeid bigint;
	tempentityfieldsenddeleted boolean[]; 
	tempentityfieldsenddrafts  boolean[];  
	tempentityfieldsendinactive boolean[];
BEGIN

/*  Examples

-- all customers no entity template no field
select * from entity.crud_entityfield_read_full(null, null, null,null, null, null,null)

select * from entity.crud_entityfieldinstance_read_full(null,null,null,true,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- specific customer no entity template no field
select * from entity.crud_entityfield_read_full(	'f90d618d-5de7-4126-8c65-0afb700c6c61',null, null, null, null, null,null)

-- specific entity template
select * 
from entity.crud_entityfield_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,	null, null, null,null)

-- specific entity field
select * 
from entity.crud_entityfield_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,'d15bb9c2-0601-4e4f-9009-c791a40be191',	null, null, null,null)

-- negative tests - empty or wrong cutomer returns nothing
select * 
from entity.crud_entityfield_read_full(null,'b124da10-be8a-4d32-9f68-7f4e6e8b24e9',	null,null, null, null,null)

select * 
from entity.crud_entityfield_read_full(null,null,	'd15bb9c2-0601-4e4f-9009-c791a40be191',null, null, null,null)

*/

if read_languagetranslationtypeuuid isNull
	then read_languagetranslationtypeuuid = (
		select systagentityuuid 
		from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false, read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
		); 
end if;

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if read_entityfieldsenddeleted isNull and read_entityfieldsenddeleted = false
	then tempentityfieldsenddeleted = Array[false];
	else tempentityfieldsenddeleted = Array[true,false];
end if;

if read_entityfieldsenddrafts isNull and read_entityfieldsenddrafts = false
	then tempentityfieldsenddrafts = Array[false];
	else tempentityfieldsenddrafts = Array[true,false];
end if;

if read_entityfieldsendinactive isNull and read_entityfieldsendinactive = false
	then tempentityfieldsendinactive = Array[true];
	else tempentityfieldsendinactive = Array[true,false];
end if;

-- probably can do this cleaner with less sql

if allowners = true and (read_entitytemplateentityuuid isNull) and (read_entityfieldentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			ef.entityfielduuid, 
			ef.entityfieldentitytemplateentityuuid, 
			ef.entityfieldcreateddate, 
			ef.entityfieldmodifieddate, 
			ef.entityfieldstartdate, 
			ef.entityfieldenddate, 
			ef.entityfieldlanguagemasteruuid, 
			COALESCE(enflt.languagetranslationvalue, enflm.languagemastersource),
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
			cust.customername as entityfieldcustomername,			
			ef.entityfieldtypeentityuuid, 
			eft.systagtype as entityfieldtypename,			
			ef.entityfieldparententityuuid, 
			siten.languagemastersource as entityfieldsitename,				
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
		from entity.entityfield ef
			inner join (select * from entity.crud_customer_read_full(null, null, null,true, read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,null)) as cust
				on cust.customerentityuuid = ef.entityfieldownerentityuuid
					and ef.entityfielddeleted = ANY (tempentityfieldsenddeleted)
				 	and ef.entityfielddraft = ANY (tempentityfieldsenddrafts)
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,read_languagetranslationtypeuuid)) as site
				on site.locationentityuuid = ef.entityfieldparententityuuid
			left join languagemaster siten
				on siten.languagemasteruuid = site.locationnameuuid
			inner join languagemaster enflm
				on ef.entityfieldlanguagemasteruuid = enflm.languagemasteruuid
			left join public.languagetranslations enflt
				on enflt.languagetranslationmasterid  = enflm.languagemasterid
					and enflt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, read_languagetranslationtypeuuid, null, false,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) 
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,read_languagetranslationtypeuuid)) as format
				on ef.entityfieldformatentityuuid = format.custagentityuuid	
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,read_languagetranslationtypeuuid)) as widget
				on ef.entityfieldwidgetentityuuid = widget.custagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as efexsys
				on ef.entityfieldexternalsystementityuuid = efexsys.systagentityuuid	
			left join workerinstance workerintfield
				on workerintfield.workerinstanceuuid = ef.entityfieldmodifiedbyuuid 
			left join worker fieldmodby
				on fieldmodby.workerid = workerintfield.workerinstanceworkerid	
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as eft
				on ef.entityfieldtypeentityuuid = eft.systagentityuuid	 
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as efet
				on ef.entityfieldentitytypeentityuuid = efet.systagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as efpt
				on ef.entityfieldentityparenttypeentityuuid = efpt.systagentityuuid) as foo
		where  foo.entityfieldsendinactive = Any (tempentityfieldsendinactive);		
--		return;
end if;

if allowners = false and (read_entitytemplateentityuuid isNull) and (read_entityfieldentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			ef2.entityfielduuid, 
			ef2.entityfieldentitytemplateentityuuid, 
			ef2.entityfieldcreateddate, 
			ef2.entityfieldmodifieddate, 
			ef2.entityfieldstartdate, 
			ef2.entityfieldenddate, 
			ef2.entityfieldlanguagemasteruuid, 
			COALESCE(enflt.languagetranslationvalue, enflm.languagemastersource),			
			ef2.entityfieldorder, 
			ef2.entityfielddefaultvalue, 
			ef2.entityfieldiscalculated, 
			ef2.entityfieldiseditable, 
			ef2.entityfieldisvisible, 
			ef2.entityfieldisrequired, 
			ef2.entityfieldformatentityuuid, 
			format.custagtype as entityfieldformatname,			
			ef2.entityfieldwidgetentityuuid, 
			widget.custagtype as entityfieldwidgetname,
			ef2.entityfieldexternalid,
			ef2.entityfieldexternalsystementityuuid, 
			efexsys.systagtype as entityfieldexternalsystemname,
			ef2.entityfieldmodifiedbyuuid, 
			fieldmodby.workerfullname as fieldmodifiedby,			
			ef2.entityfieldrefid, 
			ef2.entityfieldrefuuid,
			ef2.entityfieldisprimary, 
			ef2.entityfieldtranslate, 
			ef2.entityfieldname, 
			ef2.entityfieldownerentityuuid, 
			cust.customername as entityfieldcustomername,			
			ef2.entityfieldtypeentityuuid, 
			eft.systagtype as entityfieldtypename,			
			ef2.entityfieldparententityuuid, 
			siten.languagemastersource as entityfieldsitename,				
			ef2.entityfieldentitytypeentityuuid, 
			efet.systagtype as entityfieldentitytypename,			
			ef2.entityfieldentityparenttypeentityuuid,
			efpt.systagtype as entityfieldparenttypename,
				ef2.entityfielddeleted,
				ef2.entityfielddraft,
				case when ef2.entityfieldenddate notnull and ef2.entityfieldenddate::Date < now()::date
					then false
					else true
				end as entityfieldsendinactive
		from entity.entityfield ef2
			inner join (select * from entity.crud_customer_read_full(null, null, null,true, read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,null)) as cust
				on cust.customerentityuuid = ef2.entityfieldownerentityuuid
					and ef2.entityfieldownerentityuuid = read_ownerentityuuid
					and ef2.entityfielddeleted = ANY (tempentityfieldsenddeleted)
				 	and ef2.entityfielddraft = ANY (tempentityfieldsenddrafts)
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entityfieldsenddeleted ,read_entityfieldsenddrafts ,read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as site
				on site.locationentityuuid = ef2.entityfieldparententityuuid
			left join languagemaster siten
				on siten.languagemasteruuid = site.locationnameuuid
			inner join languagemaster enflm
				on ef2.entityfieldlanguagemasteruuid = enflm.languagemasteruuid
			left join public.languagetranslations enflt
				on enflt.languagetranslationmasterid  = enflm.languagemasterid
					and enflt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, read_languagetranslationtypeuuid, null, false,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid))
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,read_languagetranslationtypeuuid)) as format
				on ef2.entityfieldformatentityuuid = format.custagentityuuid	
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,read_languagetranslationtypeuuid)) as widget
				on ef2.entityfieldwidgetentityuuid = widget.custagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as efexsys
				on ef2.entityfieldexternalsystementityuuid = efexsys.systagentityuuid	
			left join workerinstance workerintfield
				on workerintfield.workerinstanceuuid = ef2.entityfieldmodifiedbyuuid 
			left join worker fieldmodby
				on fieldmodby.workerid = workerintfield.workerinstanceworkerid	
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as eft
				on ef2.entityfieldtypeentityuuid = eft.systagentityuuid	 
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as efet
				on ef2.entityfieldentitytypeentityuuid = efet.systagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as efpt
				on ef2.entityfieldentityparenttypeentityuuid = efpt.systagentityuuid) as foo
		where  foo.entityfieldsendinactive = Any (tempentityfieldsendinactive);	
--	return;
end if;

if allowners = false and (read_entitytemplateentityuuid notNull) and (read_entityfieldentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			ef3.entityfielduuid, 
			ef3.entityfieldentitytemplateentityuuid, 
			ef3.entityfieldcreateddate, 
			ef3.entityfieldmodifieddate, 
			ef3.entityfieldstartdate, 
			ef3.entityfieldenddate, 
			ef3.entityfieldlanguagemasteruuid, 
			COALESCE(enflt.languagetranslationvalue, enflm.languagemastersource),			
			ef3.entityfieldorder, 
			ef3.entityfielddefaultvalue, 
			ef3.entityfieldiscalculated, 
			ef3.entityfieldiseditable, 
			ef3.entityfieldisvisible, 
			ef3.entityfieldisrequired, 
			ef3.entityfieldformatentityuuid, 
			format.custagtype as entityfieldformatname,			
			ef3.entityfieldwidgetentityuuid, 
			widget.custagtype as entityfieldwidgetname,
			ef3.entityfieldexternalid,
			ef3.entityfieldexternalsystementityuuid, 
			efexsys.systagtype as entityfieldexternalsystemname,
			ef3.entityfieldmodifiedbyuuid, 
			fieldmodby.workerfullname as fieldmodifiedby,			
			ef3.entityfieldrefid, 
			ef3.entityfieldrefuuid,
			ef3.entityfieldisprimary, 
			ef3.entityfieldtranslate, 
			ef3.entityfieldname, 
			ef3.entityfieldownerentityuuid, 
			cust.customername as entityfieldcustomername,			
			ef3.entityfieldtypeentityuuid, 
			eft.systagtype as entityfieldtypename,			
			ef3.entityfieldparententityuuid, 
			siten.languagemastersource as entityfieldsitename,				
			ef3.entityfieldentitytypeentityuuid, 
			efet.systagtype as entityfieldentitytypename,			
			ef3.entityfieldentityparenttypeentityuuid,
			efpt.systagtype as entityfieldparenttypename,
				ef3.entityfielddeleted,
				ef3.entityfielddraft,
				case when ef3.entityfieldenddate notnull and ef3.entityfieldenddate::Date < now()::date
					then false
					else true
				end as entityfieldsendinactive
		from entity.entityfield ef3
			inner join (select * from entity.crud_customer_read_full(null, null, null,true,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive, null)) as cust
				on cust.customerentityuuid = ef3.entityfieldownerentityuuid
					and ef3.entityfieldownerentityuuid = read_ownerentityuuid
					and ef3.entityfieldentitytemplateentityuuid = read_entitytemplateentityuuid
					and ef3.entityfielddeleted = ANY (tempentityfieldsenddeleted)
				 	and ef3.entityfielddraft = ANY (tempentityfieldsenddrafts)
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entityfieldsenddeleted ,read_entityfieldsenddrafts ,read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as site
				on site.locationentityuuid = ef3.entityfieldparententityuuid
			left join languagemaster siten
				on siten.languagemasteruuid = site.locationnameuuid
			inner join languagemaster enflm
				on ef3.entityfieldlanguagemasteruuid = enflm.languagemasteruuid
			left join public.languagetranslations enflt
				on enflt.languagetranslationmasterid  = enflm.languagemasterid
					and enflt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, read_languagetranslationtypeuuid, null, false,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) 
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,read_languagetranslationtypeuuid)) as format
				on ef3.entityfieldformatentityuuid = format.custagentityuuid	
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,read_languagetranslationtypeuuid)) as widget
				on ef3.entityfieldwidgetentityuuid = widget.custagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as efexsys
				on ef3.entityfieldexternalsystementityuuid = efexsys.systagentityuuid	
			left join workerinstance workerintfield
				on workerintfield.workerinstanceuuid = ef3.entityfieldmodifiedbyuuid 
			left join worker fieldmodby
				on fieldmodby.workerid = workerintfield.workerinstanceworkerid	
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as eft
				on ef3.entityfieldtypeentityuuid = eft.systagentityuuid	 
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as efet
				on ef3.entityfieldentitytypeentityuuid = efet.systagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as efpt
				on ef3.entityfieldentityparenttypeentityuuid = efpt.systagentityuuid) as foo
		where  foo.entityfieldsendinactive = Any (tempentityfieldsendinactive);
--		return;

end if;

if allowners = false and (read_entityfieldentityuuid notNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			ef4.entityfielduuid, 
			ef4.entityfieldentitytemplateentityuuid, 
			ef4.entityfieldcreateddate, 
			ef4.entityfieldmodifieddate, 
			ef4.entityfieldstartdate, 
			ef4.entityfieldenddate, 
			ef4.entityfieldlanguagemasteruuid, 
			COALESCE(enflt.languagetranslationvalue, enflm.languagemastersource),			
			ef4.entityfieldorder, 
			ef4.entityfielddefaultvalue, 
			ef4.entityfieldiscalculated, 
			ef4.entityfieldiseditable, 
			ef4.entityfieldisvisible, 
			ef4.entityfieldisrequired, 
			ef4.entityfieldformatentityuuid, 
			format.custagtype as entityfieldformatname,			
			ef4.entityfieldwidgetentityuuid, 
			widget.custagtype as entityfieldwidgetname,
			ef4.entityfieldexternalid,
			ef4.entityfieldexternalsystementityuuid, 
			efexsys.systagtype as entityfieldexternalsystemname,
			ef4.entityfieldmodifiedbyuuid, 
			fieldmodby.workerfullname as fieldmodifiedby,			
			ef4.entityfieldrefid, 
			ef4.entityfieldrefuuid,
			ef4.entityfieldisprimary, 
			ef4.entityfieldtranslate, 
			ef4.entityfieldname, 
			ef4.entityfieldownerentityuuid, 
			cust.customername as entityfieldcustomername,			
			ef4.entityfieldtypeentityuuid, 
			eft.systagtype as entityfieldtypename,			
			ef4.entityfieldparententityuuid, 
			siten.languagemastersource as entityfieldsitename,				
			ef4.entityfieldentitytypeentityuuid, 
			efet.systagtype as entityfieldentitytypename,			
			ef4.entityfieldentityparenttypeentityuuid,
			efpt.systagtype as entityfieldparenttypename,
				ef4.entityfielddeleted,
				ef4.entityfielddraft,
				case when ef4.entityfieldenddate notnull and ef4.entityfieldenddate::Date < now()::date
					then false
					else true
				end as entityfieldsendinactive
		from entity.entityfield ef4
			inner join (select * from entity.crud_customer_read_full(null, null, null,true,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive, null)) as cust
				on cust.customerentityuuid = ef4.entityfieldownerentityuuid
					and ef4.entityfieldownerentityuuid = read_ownerentityuuid
					and ef4.entityfielduuid = read_entityfieldentityuuid
					and ef4.entityfielddeleted = ANY (tempentityfieldsenddeleted)
				 	and ef4.entityfielddraft = ANY (tempentityfieldsenddrafts)
			left join (select * from entity.crud_location_read_min(null,null,null,null,true,null,read_entityfieldsenddeleted ,read_entityfieldsenddrafts ,read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as site
				on site.locationentityuuid = ef4.entityfieldparententityuuid
			left join languagemaster siten
				on siten.languagemasteruuid = site.locationnameuuid
			inner join languagemaster enflm
				on ef4.entityfieldlanguagemasteruuid = enflm.languagemasteruuid
			left join public.languagetranslations enflt
				on enflt.languagetranslationmasterid  = enflm.languagemasterid
					and enflt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, read_languagetranslationtypeuuid, null, false,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid))
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,read_languagetranslationtypeuuid)) as format
				on ef4.entityfieldformatentityuuid = format.custagentityuuid	
			left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,read_languagetranslationtypeuuid)) as widget
				on ef4.entityfieldwidgetentityuuid = widget.custagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted,read_entityfieldsenddrafts,read_entityfieldsendinactive,read_languagetranslationtypeuuid)) as efexsys
				on ef4.entityfieldexternalsystementityuuid = efexsys.systagentityuuid	
			left join workerinstance workerintfield
				on workerintfield.workerinstanceuuid = ef4.entityfieldmodifiedbyuuid 
			left join worker fieldmodby
				on fieldmodby.workerid = workerintfield.workerinstanceworkerid	
			inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as eft
				on ef4.entityfieldtypeentityuuid = eft.systagentityuuid	 
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as efet
				on ef4.entityfieldentitytypeentityuuid = efet.systagentityuuid	
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,read_languagetranslationtypeuuid)) as efpt
				on ef4.entityfieldentityparenttypeentityuuid = efpt.systagentityuuid) as foo
		where  foo.entityfieldsendinactive = Any (tempentityfieldsendinactive);
--		return;

end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entityfield_read_full(uuid,uuid,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfield_read_full(uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfield_read_full(uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entityfield_read_full(uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO graphql;

-- DEPENDANTS


-- Type: VIEW ; Name: entity_field; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_field AS
 SELECT entityfield.entityfielduuid AS id,
    entityfield.entityfieldownerentityuuid AS owner,
    entityfield.entityfieldcustomername AS owner_name,
    entityfield.entityfieldparententityuuid AS parent,
    entityfield.entityfieldsitename AS parent_name,
    entityfield.entityfieldentityparenttypeentityuuid AS parent_type,
    entityfield.entityfieldentitytypeentityuuid AS entity_type,
    entityfield.entityfieldentitytypename AS entity_type_name,
    entityfield.entityfieldexternalid AS external_id,
    entityfield.entityfieldexternalsystementityuuid AS external_system,
    entityfield.entityfieldentitytemplateentityuuid AS template,
    entitytemplate.entitytemplatename AS template_name,
    entityfield.entityfieldtypeentityuuid AS type,
    entityfield.entityfieldtypename AS type_name,
    entityfield.entityfieldlanguagemasteruuid AS name_id,
    entityfield.entityfieldname AS name,
    entityfield.entityfieldformatentityuuid AS format,
    entityfield.entityfieldformatname AS format_name,
    entityfield.entityfieldwidgetentityuuid AS widget,
    entityfield.entityfieldwidgetname AS widget_name,
    entityfield.entityfieldorder::integer AS _order,
    entityfield.entityfielddefaultvalue AS default_value,
    entityfield.entityfieldisprimary AS _primary,
    entityfield.entityfieldiscalculated AS _calculated,
    entityfield.entityfieldiseditable AS _editable,
    entityfield.entityfieldisvisible AS _visible,
    entityfield.entityfieldisrequired AS _required,
    entityfield.entityfieldtranslate AS _translate,
    entityfield.entityfielddeleted AS _deleted,
    entityfield.entityfielddraft AS _draft,
        CASE
            WHEN entityfield.entityfieldenddate IS NOT NULL AND entityfield.entityfieldenddate::date < now()::date THEN false
            ELSE true
        END AS _active,
    entityfield.entityfieldstartdate AS activated_at,
    entityfield.entityfieldenddate AS deactivated_at,
    entityfield.entityfieldcreateddate AS created_at,
    entityfield.entityfieldmodifieddate AS updated_at,
    entityfield.entityfieldmodifiedbyuuid AS modified_by
   FROM ( SELECT crud_entityfield_read_full.languagetranslationtypeuuid,
            crud_entityfield_read_full.entityfielduuid,
            crud_entityfield_read_full.entityfieldentitytemplateentityuuid,
            crud_entityfield_read_full.entityfieldcreateddate,
            crud_entityfield_read_full.entityfieldmodifieddate,
            crud_entityfield_read_full.entityfieldstartdate,
            crud_entityfield_read_full.entityfieldenddate,
            crud_entityfield_read_full.entityfieldlanguagemasteruuid,
            crud_entityfield_read_full.entityfieldtranslatedname,
            crud_entityfield_read_full.entityfieldorder,
            crud_entityfield_read_full.entityfielddefaultvalue,
            crud_entityfield_read_full.entityfieldiscalculated,
            crud_entityfield_read_full.entityfieldiseditable,
            crud_entityfield_read_full.entityfieldisvisible,
            crud_entityfield_read_full.entityfieldisrequired,
            crud_entityfield_read_full.entityfieldformatentityuuid,
            crud_entityfield_read_full.entityfieldformatname,
            crud_entityfield_read_full.entityfieldwidgetentityuuid,
            crud_entityfield_read_full.entityfieldwidgetname,
            crud_entityfield_read_full.entityfieldexternalid,
            crud_entityfield_read_full.entityfieldexternalsystementityuuid,
            crud_entityfield_read_full.entityfieldexternalsystemname,
            crud_entityfield_read_full.entityfieldmodifiedbyuuid,
            crud_entityfield_read_full.entityfieldmodifiedby,
            crud_entityfield_read_full.entityfieldrefid,
            crud_entityfield_read_full.entityfieldrefuuid,
            crud_entityfield_read_full.entityfieldisprimary,
            crud_entityfield_read_full.entityfieldtranslate,
            crud_entityfield_read_full.entityfieldname,
            crud_entityfield_read_full.entityfieldownerentityuuid,
            crud_entityfield_read_full.entityfieldcustomername,
            crud_entityfield_read_full.entityfieldtypeentityuuid,
            crud_entityfield_read_full.entityfieldtypename,
            crud_entityfield_read_full.entityfieldparententityuuid,
            crud_entityfield_read_full.entityfieldsitename,
            crud_entityfield_read_full.entityfieldentitytypeentityuuid,
            crud_entityfield_read_full.entityfieldentitytypename,
            crud_entityfield_read_full.entityfieldentityparenttypeentityuuid,
            crud_entityfield_read_full.entityfieldparenttypename,
            crud_entityfield_read_full.entityfielddeleted,
            crud_entityfield_read_full.entityfielddraft,
            crud_entityfield_read_full.entityfieldactive
           FROM entity.crud_entityfield_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entityfield_read_full(languagetranslationtypeuuid, entityfielduuid, entityfieldentitytemplateentityuuid, entityfieldcreateddate, entityfieldmodifieddate, entityfieldstartdate, entityfieldenddate, entityfieldlanguagemasteruuid, entityfieldtranslatedname, entityfieldorder, entityfielddefaultvalue, entityfieldiscalculated, entityfieldiseditable, entityfieldisvisible, entityfieldisrequired, entityfieldformatentityuuid, entityfieldformatname, entityfieldwidgetentityuuid, entityfieldwidgetname, entityfieldexternalid, entityfieldexternalsystementityuuid, entityfieldexternalsystemname, entityfieldmodifiedbyuuid, entityfieldmodifiedby, entityfieldrefid, entityfieldrefuuid, entityfieldisprimary, entityfieldtranslate, entityfieldname, entityfieldownerentityuuid, entityfieldcustomername, entityfieldtypeentityuuid, entityfieldtypename, entityfieldparententityuuid, entityfieldsitename, entityfieldentitytypeentityuuid, entityfieldentitytypename, entityfieldentityparenttypeentityuuid, entityfieldparenttypename, entityfielddeleted, entityfielddraft, entityfieldactive)) entityfield
     JOIN ( SELECT crud_entitytemplate_read_full.languagetranslationtypeuuid,
            crud_entitytemplate_read_full.entitytemplateuuid,
            crud_entitytemplate_read_full.entitytemplateownerentityuuid,
            crud_entitytemplate_read_full.entitytemplatecustomername,
            crud_entitytemplate_read_full.entitytemplateparententityuuid,
            crud_entitytemplate_read_full.entitytemplatesitename,
            crud_entitytemplate_read_full.entitytemplatetypeentityuuid,
            crud_entitytemplate_read_full.entitytemplatetype,
            crud_entitytemplate_read_full.entitytemplateisprimary,
            crud_entitytemplate_read_full.entitytemplatescanid,
            crud_entitytemplate_read_full.entitytemplatenameuuid,
            crud_entitytemplate_read_full.entitytemplatename,
            crud_entitytemplate_read_full.entitytemplateorder,
            crud_entitytemplate_read_full.entitytemplatemodifiedbyuuid,
            crud_entitytemplate_read_full.entitytemplatemodifiedby,
            crud_entitytemplate_read_full.entitytemplatestartdate,
            crud_entitytemplate_read_full.entitytemplateenddate,
            crud_entitytemplate_read_full.entitytemplatecreateddate,
            crud_entitytemplate_read_full.entitytemplatemodifieddate,
            crud_entitytemplate_read_full.entitytemplateexternalid,
            crud_entitytemplate_read_full.entitytemplaterefid,
            crud_entitytemplate_read_full.entitytemplaterefuuid,
            crud_entitytemplate_read_full.entitytemplateexternalsystementityuuid,
            crud_entitytemplate_read_full.entitytemplateexternalsystem,
            crud_entitytemplate_read_full.entitytemplatedeleted,
            crud_entitytemplate_read_full.entitytemplatedraft,
            crud_entitytemplate_read_full.entitytemplateactive
           FROM entity.crud_entitytemplate_read_full(NULL::uuid, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entitytemplate_read_full(languagetranslationtypeuuid, entitytemplateuuid, entitytemplateownerentityuuid, entitytemplatecustomername, entitytemplateparententityuuid, entitytemplatesitename, entitytemplatetypeentityuuid, entitytemplatetype, entitytemplateisprimary, entitytemplatescanid, entitytemplatenameuuid, entitytemplatename, entitytemplateorder, entitytemplatemodifiedbyuuid, entitytemplatemodifiedby, entitytemplatestartdate, entitytemplateenddate, entitytemplatecreateddate, entitytemplatemodifieddate, entitytemplateexternalid, entitytemplaterefid, entitytemplaterefuuid, entitytemplateexternalsystementityuuid, entitytemplateexternalsystem, entitytemplatedeleted, entitytemplatedraft, entitytemplateactive)) entitytemplate ON entitytemplate.entitytemplateuuid = entityfield.entityfieldentitytemplateentityuuid
  WHERE (entityfield.entityfieldownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership))) OR entityfield.entityfieldownerentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid AND entitytemplate.entitytemplateisprimary = true;

COMMENT ON VIEW api.entity_field IS '
### Entity fields

TODO describe what Entity fields are.
';

CREATE TRIGGER create_entity_field_tg INSTEAD OF INSERT ON api.entity_field FOR EACH ROW EXECUTE FUNCTION api.create_entity_field();
CREATE TRIGGER update_entity_field_tg INSTEAD OF UPDATE ON api.entity_field FOR EACH ROW EXECUTE FUNCTION api.update_entity_field();

GRANT INSERT ON api.entity_field TO authenticated;
GRANT SELECT ON api.entity_field TO authenticated;
GRANT UPDATE ON api.entity_field TO authenticated;

-- Type: FUNCTION ; Name: api.delete_entity_field(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_field(owner uuid, id uuid)
 RETURNS SETOF api.entity_field
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.
select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_entityfield_delete(
	      create_entityfieldownerentityuuid := owner,
	      create_entityfieldentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_field t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_field(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_field(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_field(uuid,uuid) TO authenticated;

END;
