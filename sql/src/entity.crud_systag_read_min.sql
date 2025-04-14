
-- Type: FUNCTION ; Name: entity.crud_systag_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_systag_read_min(read_ownerentityuuid uuid, read_siteentityuuid uuid, read_systagentityuuid uuid, read_systagparententityuuid uuid, read_allsystags boolean, read_systagsenddeleted boolean, read_systagsenddrafts boolean, read_systagsendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, systagid bigint, systaguuid text, systagentityuuid uuid, systagcustomerid bigint, systagcustomeruuid text, systagcustomerentityuuid uuid, systagnameuuid text, systagdisplaynameuuid text, systagtype text, systagcreateddate timestamp with time zone, systagmodifieddate timestamp with time zone, systagstartdate timestamp with time zone, systagenddate timestamp with time zone, systagexternalid text, systagexternalsystementityuuid uuid, systagmodifiedbyuuid text, systagabbreviationentityuuid uuid, systagparententityuuid uuid, systagorder integer, systagsenddeleted boolean, systagsenddrafts boolean, systagsendinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	tempsystagsenddeleted boolean[];
	tempsystagsenddrafts boolean[];
	tempsystagsendinactive boolean[];
	tendreluuid uuid;
BEGIN

/*  examples

-- all customers all systags 
select * from entity.crud_systag_read_min(null,null,null, null, true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- all systags for a specific customer
select * from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- all systags for a parent
select * from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- fail scenario for parent
select * from entity.crud_systag_read_min(null,null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- specific systags
select * from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

select systagentityuuid 
from entity.crud_systag_read_min(null, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,null,null,null'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

select * from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, '580f6ee2-42ca-4a5b-9e18-9ea0c168845a', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if read_systagsenddeleted isNull and read_systagsenddeleted = false
	then tempsystagsenddeleted = Array[false];
	else tempsystagsenddeleted = Array[true,false];
end if;

if read_systagsenddrafts isNull and read_systagsenddrafts = false
	then tempsystagsenddrafts = Array[false];
	else tempsystagsenddrafts = Array[true,false];
end if;

if read_systagsendinactive isNull and read_systagsendinactive = false
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
	ei.entityinstancenameuuid as systagnameuuid,
	dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
	ei.entityinstancetype as systagtype,
	ei.entityinstancecreateddate as systagcreateddate,
	ei.entityinstancemodifieddate as systagmodifieddate,	
	ei.entityinstancestartdate as systagstartdate,
	ei.entityinstanceenddate as systagenddate,
	ei.entityinstanceexternalid as systagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
	ei.entityinstanceparententityuuid as systagparententityuuid,
	ei.entityinstancecornerstoneorder as systagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
		then false
		else true
	end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid  
				from entity.crud_customer_read_min(read_ownerentityuuid,null, null,allowners, read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive,null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'System Tag' 
			and ei.entityinstancedeleted = ANY (tempsystagsenddeleted)
			and ei.entityinstancedraft = ANY (tempsystagsenddrafts)
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid' ) as foo
		where foo.entityinstanceactive = Any (tempsystagsendinactive) ; 
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
	ei.entityinstancenameuuid as systagnameuuid,
	dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
	ei.entityinstancetype as systagtype,
	ei.entityinstancecreateddate as systagcreateddate,
	ei.entityinstancemodifieddate as systagmodifieddate,	
	ei.entityinstancestartdate as systagstartdate,
	ei.entityinstanceenddate as systagenddate,
	ei.entityinstanceexternalid as systagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
	ei.entityinstanceparententityuuid as systagparententityuuid,
	ei.entityinstancecornerstoneorder as systagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
		then false
		else true
	end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid  from entity.crud_customer_read_min (read_ownerentityuuid,null, null,allowners, read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive,null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'System Tag'
			and ei.entityinstanceuuid = read_systagentityuuid
			and ei.entityinstancedeleted = ANY (tempsystagsenddeleted)
			and ei.entityinstancedraft = ANY (tempsystagsenddrafts)
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid') as foo
		where foo.entityinstanceactive = Any (tempsystagsendinactive) ;
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
	ei.entityinstancenameuuid as systagnameuuid,
	dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
	ei.entityinstancetype as systagtype,
	ei.entityinstancecreateddate as systagcreateddate,
	ei.entityinstancemodifieddate as systagmodifieddate,	
	ei.entityinstancestartdate as systagstartdate,
	ei.entityinstanceenddate as systagenddate,
	ei.entityinstanceexternalid as systagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
	ei.entityinstanceparententityuuid as systagparententityuuid,
	ei.entityinstancecornerstoneorder as systagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
		then false
		else true
	end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid from entity.crud_customer_read_min(read_ownerentityuuid,null, null,allowners,read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive, null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'System Tag'  
			and ei.entityinstanceownerentityuuid = read_ownerentityuuid
			and ei.entityinstanceparententityuuid = read_systagparententityuuid
			and ei.entityinstancedeleted = ANY (tempsystagsenddeleted)
			and ei.entityinstancedraft = ANY (tempsystagsenddrafts)
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid') as foo
		where foo.entityinstanceactive = Any (tempsystagsendinactive) ;
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
	ei.entityinstancenameuuid as systagnameuuid,
	dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
	ei.entityinstancetype as systagtype,
	ei.entityinstancecreateddate as systagcreateddate,
	ei.entityinstancemodifieddate as systagmodifieddate,	
	ei.entityinstancestartdate as systagstartdate,
	ei.entityinstanceenddate as systagenddate,
	ei.entityinstanceexternalid as systagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
	ei.entityinstanceparententityuuid as systagparententityuuid,
	ei.entityinstancecornerstoneorder as systagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
		then false
		else true
	end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid from entity.crud_customer_read_min(read_ownerentityuuid,null, null,allowners,read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive, null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'System Tag'  
			and ei.entityinstanceownerentityuuid = read_ownerentityuuid
			and ei.entityinstanceparententityuuid = read_systagparententityuuid
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid') as foo
		where foo.entityinstanceactive = Any (tempsystagsendinactive) ;
		return;
end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_systag_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_systag_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_systag_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
