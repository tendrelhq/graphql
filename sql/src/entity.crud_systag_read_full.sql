BEGIN;

/*
DROP FUNCTION api.delete_customer_requested_language(uuid,text);
DROP VIEW api.language;
DROP VIEW api.alltag;
DROP VIEW api.customer_requested_language;

DROP FUNCTION entity.crud_systag_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_systag_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_systag_read_full(read_ownerentityuuid uuid, read_siteentityuuid uuid, read_systagentityuuid uuid, read_systagparententityuuid uuid, read_allsystags boolean, read_systagsenddeleted boolean, read_systagsenddrafts boolean, read_systagsendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, systagid bigint, systaguuid text, systagentityuuid uuid, systagcustomerid bigint, systagcustomeruuid text, systagcustomerentityuuid uuid, systagcustomername text, systagnameuuid text, systagname text, systagdisplaynameuuid text, systagdisplayname text, systagtype text, systagcreateddate timestamp with time zone, systagmodifieddate timestamp with time zone, systagstartdate timestamp with time zone, systagenddate timestamp with time zone, systagexternalid text, systagexternalsystementityuuid uuid, systagexternalsystementname text, systagmodifiedbyuuid text, systagabbreviationentityuuid uuid, systagabbreviationname text, systagparententityuuid uuid, systagparentname text, systagorder integer, systagsenddeleted boolean, systagsenddrafts boolean, systagsendinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	tempsystagsenddeleted boolean[];
	tempsystagsenddrafts boolean[];
	tempsystagsendinactive boolean[];
	tendreluuid uuid;
	englishuuid uuid;
BEGIN

/*  examples

-- all customers all systags 
select * from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- all systags for a specific customer
select * from entity.crud_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- all systags for a parent
select * from entity.crud_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- fail scenario for parent
select * from entity.crud_systag_read_full(null,null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- specific systags
select * from entity.crud_systag_read_full(null, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

select * from entity.crud_systag_read_full(null, null, '580f6ee2-42ca-4a5b-9e18-9ea0c168845a', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';
englishuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if read_systagsenddeleted = false
	then tempsystagsenddeleted = Array[false];
	else tempsystagsenddeleted = Array[true,false];
end if;

if read_systagsenddrafts = false
	then tempsystagsenddrafts = Array[false];
	else tempsystagsenddrafts = Array[true,false];
end if;

if read_systagsendinactive = false
	then tempsystagsendinactive = Array[true];
	else tempsystagsendinactive = Array[true,false];
end if;

if read_allsystags = true
	then
	return query
		select *
		from (SELECT 
		read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
		ei.entityinstanceoriginalid as systagid,
		ei.entityinstanceoriginaluuid as systaguuid,
		ei.entityinstanceuuid as systagentityuuid,
		cust.customerid as systagcustomerid,	
		cust.customeruuid as systagcustomeruuid,
		cust.customerentityuuid::uuid as systagcustomerentityuuid,
		cust.customername as systagcustomername,
		ei.entityinstancenameuuid as systagnameuuid,
		COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS systagname,
		dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
		COALESCE(displaylt.languagetranslationvalue, displaylm.languagemastersource) AS systagdisplayname,
		ei.entityinstancetype as systagtype,
		ei.entityinstancecreateddate as systagcreateddate,
		ei.entityinstancemodifieddate as systagmodifieddate,	
		ei.entityinstancestartdate as systagstartdate,
		ei.entityinstanceenddate as systagenddate,
		ei.entityinstanceexternalid as systagexternalid,
		ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
		systemname.systagtype as systagexternalsystementname,
		ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
		abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
		abbname.systagtype as systagabbreviationname,
		ei.entityinstanceparententityuuid as systagparententityuuid,
		parname.systagtype as systagparentname,
		ei.entityinstancecornerstoneorder as systagorder,
		ei.entityinstancedeleted, 
		ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
	from entity.entityinstance ei
		Join (select customerid,customeruuid, customerentityuuid,customername  from entity.crud_customer_read_full(read_ownerentityuuid,null, null,allowners,read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive, null)) as cust  
			on cust.customerentityuuid = ei.entityinstanceownerentityuuid
				and ei.entityinstanceentitytemplatename = 'System Tag' 
				and ei.entityinstancedeleted = ANY (tempsystagsenddeleted)
				and ei.entityinstancedraft = ANY (tempsystagsenddrafts)
		left join languagemaster namelm
			on ei.entityinstancenameuuid = namelm.languagemasteruuid
		left join public.languagetranslations namelt
			on namelt.languagetranslationmasterid  = namelm.languagemasterid
				and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid) as foo)
		join entity.entityfieldinstance dn
			on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
		join entity.entityfieldinstance abb
			on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
				and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid'      	
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as systemname
			on ei.entityinstanceexternalsystementityuuid =  systemname.systagentityuuid
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as abbname
			on abb.entityfieldinstancevalue =  abbname.systagentityuuid::text
		inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as parname
			on ei.entityinstanceparententityuuid =  parname.systagentityuuid
		left join languagemaster displaylm
			on dn.entityfieldinstancevaluelanguagemasteruuid = displaylm.languagemasteruuid
		left join public.languagetranslations displaylt
			on displaylt.languagetranslationmasterid  = displaylm.languagemasterid
				and displaylt.languagetranslationtypeid = (select foo2.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid) as foo2)) as foo3
		where foo3.entityinstanceactive = Any (tempsystagsendinactive) ;  
		return;
end if;

if read_systagentityuuid notNull 
	then
	return query
		select *
		from (SELECT 
		read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
		ei.entityinstanceoriginalid as systagid,
		ei.entityinstanceoriginaluuid as systaguuid,
		ei.entityinstanceuuid as systagentityuuid,
		cust.customerid as systagcustomerid,	
		cust.customeruuid as systagcustomeruuid,
		cust.customerentityuuid::uuid as systagcustomerentityuuid,
		cust.customername as systagcustomername,
		ei.entityinstancenameuuid as systagnameuuid,
		COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS systagname,
		dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
		COALESCE(displaylt.languagetranslationvalue, displaylm.languagemastersource) AS systagdisplayname,
		ei.entityinstancetype as systagtype,
		ei.entityinstancecreateddate as systagcreateddate,
		ei.entityinstancemodifieddate as systagmodifieddate,	
		ei.entityinstancestartdate as systagstartdate,
		ei.entityinstanceenddate as systagenddate,
		ei.entityinstanceexternalid as systagexternalid,
		ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
		systemname.systagtype as systagexternalsystementname,
		ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
		abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
		abbname.systagtype as systagabbreviationname,
		ei.entityinstanceparententityuuid as systagparententityuuid,
		parname.systagtype as systagparentname,
		ei.entityinstancecornerstoneorder as systagorder,
		ei.entityinstancedeleted, 
		ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid,customername  from entity.crud_customer_read_full(read_ownerentityuuid,null, null,allowners, read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive,null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'System Tag' 
			and ei.entityinstanceuuid = read_systagentityuuid
			and ei.entityinstancedeleted = ANY (tempsystagsenddeleted)
			and ei.entityinstancedraft = ANY (tempsystagsenddrafts)
		left join languagemaster namelm
			on ei.entityinstancenameuuid = namelm.languagemasteruuid
		left join public.languagetranslations namelt
			on namelt.languagetranslationmasterid  = namelm.languagemasterid
				and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid) as foo)
		join entity.entityfieldinstance dn
			on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
		join entity.entityfieldinstance abb
			on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
				and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid'      	
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as systemname
			on ei.entityinstanceexternalsystementityuuid =  systemname.systagentityuuid
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as abbname
			on abb.entityfieldinstancevalue =  abbname.systagentityuuid::text
		inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as parname
			on ei.entityinstanceparententityuuid =  parname.systagentityuuid
		left join languagemaster displaylm
			on dn.entityfieldinstancevaluelanguagemasteruuid = displaylm.languagemasteruuid
		left join public.languagetranslations displaylt
			on displaylt.languagetranslationmasterid  = displaylm.languagemasterid
				and displaylt.languagetranslationtypeid = (select foo2.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid) as foo2)) as foo3
				where foo3.entityinstanceactive = Any (tempsystagsendinactive) ;   
		return;
end if;

if read_systagparententityuuid isNull and read_ownerentityuuid notNull
	then
	return query
		select *
		from (SELECT 
		read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
		ei.entityinstanceoriginalid as systagid,
		ei.entityinstanceoriginaluuid as systaguuid,
		ei.entityinstanceuuid as systagentityuuid,
		cust.customerid as systagcustomerid,	
		cust.customeruuid as systagcustomeruuid,
		cust.customerentityuuid::uuid as systagcustomerentityuuid,
		cust.customername as systagcustomername,
		ei.entityinstancenameuuid as systagnameuuid,
		COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS systagname,
		dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
		COALESCE(displaylt.languagetranslationvalue, displaylm.languagemastersource) AS systagdisplayname,
		ei.entityinstancetype as systagtype,
		ei.entityinstancecreateddate as systagcreateddate,
		ei.entityinstancemodifieddate as systagmodifieddate,	
		ei.entityinstancestartdate as systagstartdate,
		ei.entityinstanceenddate as systagenddate,
		ei.entityinstanceexternalid as systagexternalid,
		ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
		systemname.systagtype as systagexternalsystementname,
		ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
		abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
		abbname.systagtype as systagabbreviationname,
		ei.entityinstanceparententityuuid as systagparententityuuid,
		parname.systagtype as systagparentname,
		ei.entityinstancecornerstoneorder as systagorder,
		ei.entityinstancedeleted, 
		ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid,customername from entity.crud_customer_read_full(read_ownerentityuuid,null, null,allowners, read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive,null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'System Tag'  
			and ei.entityinstanceownerentityuuid = read_ownerentityuuid
			and ei.entityinstanceparententityuuid = read_systagparententityuuid
			and ei.entityinstancedeleted = ANY (tempsystagsenddeleted)
			and ei.entityinstancedraft = ANY (tempsystagsenddrafts)
		left join languagemaster namelm
			on ei.entityinstancenameuuid = namelm.languagemasteruuid
		left join public.languagetranslations namelt
			on namelt.languagetranslationmasterid  = namelm.languagemasterid
				and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid) as foo)
		join entity.entityfieldinstance dn
			on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
		join entity.entityfieldinstance abb
			on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
				and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid'      	
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as systemname
			on ei.entityinstanceexternalsystementityuuid =  systemname.systagentityuuid
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as abbname
			on abb.entityfieldinstancevalue =  abbname.systagentityuuid::text
		inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as parname
			on ei.entityinstanceparententityuuid =  parname.systagentityuuid
		left join languagemaster displaylm
			on dn.entityfieldinstancevaluelanguagemasteruuid = displaylm.languagemasteruuid
		left join public.languagetranslations displaylt
			on displaylt.languagetranslationmasterid  = displaylm.languagemasterid
				and displaylt.languagetranslationtypeid = (select foo2.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid) as foo2)) as foo3
				where foo3.entityinstanceactive = Any (tempsystagsendinactive) ;   
	return;
end if;

if read_systagparententityuuid notNull and read_ownerentityuuid notNull
	then
	return query
		select *
		from (SELECT 
		read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
		ei.entityinstanceoriginalid as systagid,
		ei.entityinstanceoriginaluuid as systaguuid,
		ei.entityinstanceuuid as systagentityuuid,
		cust.customerid as systagcustomerid,	
		cust.customeruuid as systagcustomeruuid,
		cust.customerentityuuid::uuid as systagcustomerentityuuid,
		cust.customername as systagcustomername,
		ei.entityinstancenameuuid as systagnameuuid,
		COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS systagname,
		dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
		COALESCE(displaylt.languagetranslationvalue, displaylm.languagemastersource) AS systagdisplayname,
		ei.entityinstancetype as systagtype,
		ei.entityinstancecreateddate as systagcreateddate,
		ei.entityinstancemodifieddate as systagmodifieddate,	
		ei.entityinstancestartdate as systagstartdate,
		ei.entityinstanceenddate as systagenddate,
		ei.entityinstanceexternalid as systagexternalid,
		ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
		systemname.systagtype as systagexternalsystementname,
		ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
		abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
		abbname.systagtype as systagabbreviationname,
		ei.entityinstanceparententityuuid as systagparententityuuid,
		parname.systagtype as systagparentname,
		ei.entityinstancecornerstoneorder as systagorder,
		ei.entityinstancedeleted, 
		ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid,customername from entity.crud_customer_read_full(read_ownerentityuuid,null, null,allowners, read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive,null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'System Tag'  
			and ei.entityinstanceownerentityuuid = read_ownerentityuuid
			and ei.entityinstanceparententityuuid = read_systagparententityuuid
			and ei.entityinstancedeleted = ANY (tempsystagsenddeleted)
			and ei.entityinstancedraft = ANY (tempsystagsenddrafts)
		left join languagemaster namelm
			on ei.entityinstancenameuuid = namelm.languagemasteruuid
		left join public.languagetranslations namelt
			on namelt.languagetranslationmasterid  = namelm.languagemasterid
				and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid) as foo)
		join entity.entityfieldinstance dn
			on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
		join entity.entityfieldinstance abb
			on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
				and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid'      	
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as systemname
			on ei.entityinstanceexternalsystementityuuid =  systemname.systagentityuuid
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as abbname
			on abb.entityfieldinstancevalue =  abbname.systagentityuuid::text
		inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid)) as parname
			on ei.entityinstanceparententityuuid =  parname.systagentityuuid
		left join languagemaster displaylm
			on dn.entityfieldinstancevaluelanguagemasteruuid = displaylm.languagemasteruuid
		left join public.languagetranslations displaylt
			on displaylt.languagetranslationmasterid  = displaylm.languagemasterid
				and displaylt.languagetranslationtypeid = (select foo2.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,read_systagsenddeleted, read_systagsenddrafts,read_systagsendinactive,englishuuid) as foo2)) as foo3
				where foo3.entityinstanceactive = Any (tempsystagsendinactive) ;   
		return;
end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_systag_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_systag_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_systag_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_systag_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO graphql;

-- DEPENDANTS


-- Type: VIEW ; Name: customer_requested_language; Owner: tendreladmin

CREATE OR REPLACE VIEW api.customer_requested_language AS
 SELECT crl.customerrequestedlanguageid AS legacy_id,
    crl.customerrequestedlanguagecustomerid AS legacy_customer_id,
    customer.customerentityuuid AS owner,
    customer.customerdisplayname AS owner_name,
    lang.systagentityuuid AS languagetype_id,
    lang.systagname AS name,
    lang.systagdisplayname AS displayname,
    crl.customerrequestedlanguagestartdate AS activated_at,
    crl.customerrequestedlanguageenddate AS deactivated_at,
    crl.customerrequestedlanguagecreateddate AS created_at,
    crl.customerrequestedlanguagemodifieddate AS updated_at,
    crl.customerrequestedlanguageexternalid AS external_id,
    crl.customerrequestedlanguageexternalsystemid AS external_system,
        CASE
            WHEN crl.customerrequestedlanguagestartdate IS NULL THEN true
            ELSE false
        END AS customerrequestedlanguagedraft,
        CASE
            WHEN crl.customerrequestedlanguageenddate::date < now()::date THEN true
            ELSE false
        END AS customerrequestedlanguagedeleted,
        CASE
            WHEN (crl.customerrequestedlanguageenddate::date > now()::date OR crl.customerrequestedlanguageenddate::date IS NULL) AND crl.customerrequestedlanguagestartdate < now() THEN true
            ELSE false
        END AS customerrequestedlanguageactive,
    crl.customerrequestedlanguagemodifiedby AS modified_by,
    crl.customerrequestedlanguageuuid AS id
   FROM customerrequestedlanguage crl
     JOIN ( SELECT crud_customer_read_full.customerid,
            crud_customer_read_full.customeruuid,
            crud_customer_read_full.customerentityuuid,
            crud_customer_read_full.customerownerentityuuid,
            crud_customer_read_full.customerparententityuuid,
            crud_customer_read_full.customercornerstoneentityuuid,
            crud_customer_read_full.customercornerstoneorder,
            crud_customer_read_full.customernameuuid,
            crud_customer_read_full.customername,
            crud_customer_read_full.customerdisplaynameuuid,
            crud_customer_read_full.customerdisplayname,
            crud_customer_read_full.customertypeentityuuid,
            crud_customer_read_full.customertype,
            crud_customer_read_full.customercreateddate,
            crud_customer_read_full.customermodifieddate,
            crud_customer_read_full.customerstartdate,
            crud_customer_read_full.customerenddate,
            crud_customer_read_full.customermodifiedbyuuid,
            crud_customer_read_full.customerexternalid,
            crud_customer_read_full.customerexternalsystementityuuid,
            crud_customer_read_full.customerexternalsystemname,
            crud_customer_read_full.customerrefid,
            crud_customer_read_full.customerrefuuid,
            crud_customer_read_full.customerlanguagetypeentityuuid,
            crud_customer_read_full.customersenddeleted,
            crud_customer_read_full.customersenddrafts,
            crud_customer_read_full.customersendinactive
           FROM entity.crud_customer_read_full(NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_customer_read_full(customerid, customeruuid, customerentityuuid, customerownerentityuuid, customerparententityuuid, customercornerstoneentityuuid, customercornerstoneorder, customernameuuid, customername, customerdisplaynameuuid, customerdisplayname, customertypeentityuuid, customertype, customercreateddate, customermodifieddate, customerstartdate, customerenddate, customermodifiedbyuuid, customerexternalid, customerexternalsystementityuuid, customerexternalsystemname, customerrefid, customerrefuuid, customerlanguagetypeentityuuid, customersenddeleted, customersenddrafts, customersendinactive)) customer ON customer.customerid = crl.customerrequestedlanguagecustomerid
     JOIN ( SELECT crud_systag_read_full.languagetranslationtypeentityuuid,
            crud_systag_read_full.systagid,
            crud_systag_read_full.systaguuid,
            crud_systag_read_full.systagentityuuid,
            crud_systag_read_full.systagcustomerid,
            crud_systag_read_full.systagcustomeruuid,
            crud_systag_read_full.systagcustomerentityuuid,
            crud_systag_read_full.systagcustomername,
            crud_systag_read_full.systagnameuuid,
            crud_systag_read_full.systagname,
            crud_systag_read_full.systagdisplaynameuuid,
            crud_systag_read_full.systagdisplayname,
            crud_systag_read_full.systagtype,
            crud_systag_read_full.systagcreateddate,
            crud_systag_read_full.systagmodifieddate,
            crud_systag_read_full.systagstartdate,
            crud_systag_read_full.systagenddate,
            crud_systag_read_full.systagexternalid,
            crud_systag_read_full.systagexternalsystementityuuid,
            crud_systag_read_full.systagexternalsystementname,
            crud_systag_read_full.systagmodifiedbyuuid,
            crud_systag_read_full.systagabbreviationentityuuid,
            crud_systag_read_full.systagabbreviationname,
            crud_systag_read_full.systagparententityuuid,
            crud_systag_read_full.systagparentname,
            crud_systag_read_full.systagorder,
            crud_systag_read_full.systagsenddeleted,
            crud_systag_read_full.systagsenddrafts,
            crud_systag_read_full.systagsendinactive
           FROM entity.crud_systag_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_systag_read_full(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagcustomername, systagnameuuid, systagname, systagdisplaynameuuid, systagdisplayname, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagexternalsystementname, systagmodifiedbyuuid, systagabbreviationentityuuid, systagabbreviationname, systagparententityuuid, systagparentname, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)) lang ON lang.systagid = crl.customerrequestedlanguagelanguageid
  WHERE (customer.customerownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.customer_requested_language IS '
## customer_requested_language

A description of what an customer is and why it is used

### get {baseUrl}/customer_requested_language

A bunch of comments explaining get

### del {baseUrl}/customer_requested_language

A bunch of comments explaining del

### patch {baseUrl}/customer_requested_language

A bunch of comments explaining patch
';

CREATE TRIGGER create_customer_requested_language_tg INSTEAD OF INSERT ON api.customer_requested_language FOR EACH ROW EXECUTE FUNCTION api.create_customer_requested_language();
CREATE TRIGGER update_customer_requested_language_tg INSTEAD OF UPDATE ON api.customer_requested_language FOR EACH ROW EXECUTE FUNCTION api.update_customer_requested_language();

GRANT INSERT ON api.customer_requested_language TO authenticated;
GRANT SELECT ON api.customer_requested_language TO authenticated;
GRANT UPDATE ON api.customer_requested_language TO authenticated;

-- Type: VIEW ; Name: alltag; Owner: tendreladmin

CREATE OR REPLACE VIEW api.alltag AS
 SELECT systag.systagentityuuid AS id,
    systag.systagid AS legacy_id,
    systag.systaguuid AS legacy_uuid,
    systag.systagcustomerentityuuid AS owner,
    systag.systagcustomername AS owner_name,
    systag.systagparententityuuid AS parent,
    systag.systagparentname AS parent_name,
    NULL::uuid AS cornerstone,
    systag.systagnameuuid AS name_id,
    systag.systagname AS name,
    systag.systagdisplaynameuuid AS displayname_id,
    systag.systagdisplayname AS displayname,
    systag.systagtype AS type,
    systag.systagcreateddate AS created_at,
    systag.systagmodifieddate AS modified_at,
    systag.systagstartdate AS activated_at,
    systag.systagenddate AS deactivated_at,
    systag.systagexternalid AS external_id,
    systag.systagexternalsystementityuuid AS external_system,
    systag.systagmodifiedbyuuid AS modified_by,
    systag.systagorder AS _order,
    systag.systagsenddeleted AS _deleted,
    systag.systagsenddrafts AS _draft,
    systag.systagsendinactive AS _active
   FROM entity.crud_systag_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) systag(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagcustomername, systagnameuuid, systagname, systagdisplaynameuuid, systagdisplayname, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagexternalsystementname, systagmodifiedbyuuid, systagabbreviationentityuuid, systagabbreviationname, systagparententityuuid, systagparentname, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)
  WHERE (systag.systagcustomerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership))) OR systag.systagcustomerentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid
UNION
 SELECT custag.custagentityuuid AS id,
    custag.custagid AS legacy_id,
    custag.custaguuid AS legacy_uuid,
    custag.custagownerentityuuid AS owner,
    custag.custagownerentityname AS owner_name,
    custag.custagparententityuuid AS parent,
    custag.custagparentname AS parent_name,
    custag.custagcornerstoneentityid AS cornerstone,
    custag.custagnameuuid AS name_id,
    custag.custagname AS name,
    custag.custagdisplaynameuuid AS displayname_id,
    custag.custagdisplayname AS displayname,
    custag.custagtype AS type,
    custag.custagcreateddate AS created_at,
    custag.custagmodifieddate AS modified_at,
    custag.custagstartdate AS activated_at,
    custag.custagenddate AS deactivated_at,
    custag.custagexternalid AS external_id,
    custag.custagexternalsystementityuuid AS external_system,
    custag.custagmodifiedbyuuid AS modified_by,
    custag.custagorder AS _order,
    custag.systagsenddeleted AS _deleted,
    custag.systagsenddrafts AS _draft,
    custag.systagsendinactive AS _active
   FROM entity.crud_custag_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) custag(languagetranslationtypeentityuuid, custagid, custaguuid, custagentityuuid, custagownerentityuuid, custagownerentityname, custagparententityuuid, custagparentname, custagcornerstoneentityid, custagcustomerid, custagcustomeruuid, custagcustomerentityuuid, custagcustomername, custagnameuuid, custagname, custagdisplaynameuuid, custagdisplayname, custagtype, custagcreateddate, custagmodifieddate, custagstartdate, custagenddate, custagexternalid, custagexternalsystementityuuid, custagexternalsystemenname, custagmodifiedbyuuid, custagabbreviationentityuuid, custagabbreviationname, custagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)
  WHERE (custag.custagownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.alltag IS '
## language
';

GRANT INSERT ON api.alltag TO authenticated;
GRANT SELECT ON api.alltag TO authenticated;
GRANT UPDATE ON api.alltag TO authenticated;

-- Type: VIEW ; Name: language; Owner: tendreladmin

CREATE OR REPLACE VIEW api.language AS
 SELECT systagentityuuid AS id,
    systagid AS legacy_id,
    systaguuid AS legacy_uuid,
    systagnameuuid AS name_id,
    systagname AS name,
    systagdisplaynameuuid AS displayname_id,
    systagdisplayname AS displayname,
    systagtype AS type,
    systagcreateddate AS created_at,
    systagmodifieddate AS modified_at,
    systagstartdate AS activated_at,
    systagenddate AS deactivated_at,
    systagmodifiedbyuuid AS modified_by,
    systagorder AS _order,
    systagsenddeleted AS _deleted,
    systagsenddrafts AS _draft,
    systagsendinactive AS _active
   FROM entity.crud_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid, NULL::uuid, NULL::uuid, '580f6ee2-42ca-4a5b-9e18-9ea0c168845a'::uuid, false, NULL::boolean, NULL::boolean, NULL::boolean, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid) systag(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagcustomername, systagnameuuid, systagname, systagdisplaynameuuid, systagdisplayname, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagexternalsystementname, systagmodifiedbyuuid, systagabbreviationentityuuid, systagabbreviationname, systagparententityuuid, systagparentname, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive);


GRANT INSERT ON api.language TO authenticated;
GRANT SELECT ON api.language TO authenticated;
GRANT UPDATE ON api.language TO authenticated;

-- Type: FUNCTION ; Name: api.delete_customer_requested_language(uuid,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_customer_requested_language(owner uuid, id text)
 RETURNS SETOF api.customer_requested_language
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
	templanguagetypeid bigint;
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
		call entity.crud_customerrequestedlanguage_delete(
			create_customerownerentityuuid := owner,
			create_language_id := id,
			create_modifiedbyid := ins_userid
	);
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.customer_requested_language t
    where t.owner = $1  and 
		t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_customer_requested_language(uuid,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_customer_requested_language(uuid,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_customer_requested_language(uuid,text) TO authenticated;

END;
