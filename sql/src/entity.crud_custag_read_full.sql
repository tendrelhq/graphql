
-- Type: FUNCTION ; Name: entity.crud_custag_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_custag_read_full(read_ownerentityuuid uuid, read_siteentityuuid uuid, read_custagentityuuid uuid, read_custagparententityuuid uuid, read_allcustags boolean, read_custagsenddeleted boolean, read_custagsenddrafts boolean, read_custagsendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, custagid bigint, custaguuid text, custagentityuuid uuid, custagownerentityuuid uuid, custagownerentityname text, custagparententityuuid uuid, custagparentname text, custagcornerstoneentityid uuid, custagcustomerid bigint, custagcustomeruuid text, custagcustomerentityuuid uuid, custagcustomername text, custagnameuuid text, custagname text, custagdisplaynameuuid text, custagdisplayname text, custagtype text, custagcreateddate timestamp with time zone, custagmodifieddate timestamp with time zone, custagstartdate timestamp with time zone, custagenddate timestamp with time zone, custagexternalid text, custagexternalsystementityuuid uuid, custagexternalsystemenname text, custagmodifiedbyuuid text, custagabbreviationentityuuid uuid, custagabbreviationname text, custagorder integer, systagsenddeleted boolean, systagsenddrafts boolean, systagsendinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	tempcustagsenddeleted boolean[];
	tempcustagsenddrafts boolean[];
	tempcustagsendinactive boolean[];
	tendreluuid uuid;
BEGIN

-- Need to handle language translation in full version.  minimal version does not use languagetranslation
-- Might want to add a parameter to send in active as a boolean
-- Curretnly ignores site since custag does not care about site.  Custag does.  
-- May want to flip paramaeters to be arrays in the future.  

/*  examples

-- call entity.test_entity()

-- all customers all custags 
select * from entity.crud_custag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by custagid

-- all custags for a specific customer
select * from entity.crud_custag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by custagid

-- all custags for a parent
select * from entity.crud_custag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by custagid

-- fail scenario for parent
select * from entity.crud_custag_read_full(null,null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by custagid

-- specific custags
-- succeed
select * from entity.crud_custag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61', null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by custagid

--fail
select * from entity.crud_custag_read_full(null, null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by custagid

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if read_custagsenddeleted isNull and read_custagsenddeleted = false
	then tempcustagsenddeleted = Array[false];
	else tempcustagsenddeleted = Array[true,false];
end if;

if read_custagsenddrafts isNull and read_custagsenddrafts = false
	then tempcustagsenddrafts = Array[false];
	else tempcustagsenddrafts = Array[true,false];
end if;

if read_custagsendinactive isNull and read_custagsendinactive = false
	then tempcustagsendinactive = Array[true];
	else tempcustagsendinactive = Array[true,false];
end if;

if read_allcustags = true
	then
	return query
		select *
		from (SELECT 
	read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
	ei.entityinstanceoriginalid as custagid,
	ei.entityinstanceoriginaluuid as custaguuid,
	ei.entityinstanceuuid as custagentityuuid,
	cust.customerentityuuid::uuid as custagownerentityuuid,	
	cust.customername as custagownerentityname,	
	ei.entityinstanceparententityuuid as custagparententityuuid,
	case when parname.systagtype notNull
		then parname.systagtype
		else parnamecust.custagtype
	end as custagparentname,
	ei.entityinstancecornerstoneentityuuid  as custagcornerstoneentityid,
	cust.customerid as custagcustomerid,	
	cust.customeruuid as custagcustomeruuid,
	cust.customerentityuuid::uuid as custagcustomerentityuuid,
	cust.customername as custagcustomername,
	ei.entityinstancenameuuid as custagnameuuid,
	COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS custagname,
	dn.entityfieldinstancevaluelanguagemasteruuid as custagdisplaynameuuid,
	COALESCE(displaylt.languagetranslationvalue, displaylm.languagemastersource) AS custagdisplayname,
	ei.entityinstancetype as custagtype,
	ei.entityinstancecreateddate as custagcreateddate,
	ei.entityinstancemodifieddate as custagmodifieddate,	
	ei.entityinstancestartdate as custagstartdate,
	ei.entityinstanceenddate as custagenddate,
	ei.entityinstanceexternalid as custagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	systemname.systagtype as custagexternalsystementname,
	ei.entityinstancemodifiedbyuuid as custagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as custagabbreviationentityuuid,
	abbname.systagtype as custagabbreviationname,
	ei.entityinstancecornerstoneorder as custagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
		then false
		else true
		end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid,customername  from entity.crud_customer_read_full(read_ownerentityuuid,null, null, allowners, read_custagsenddeleted,read_custagsenddrafts,read_custagsendinactive,null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'Customer Tag' 
			and ei.entityinstancedeleted = ANY (tempcustagsenddeleted)
			and ei.entityinstancedraft = ANY (tempcustagsenddrafts)
	left join languagemaster namelm  -- this lm to lt pattern can probably become a function instead
		on ei.entityinstancenameuuid = namelm.languagemasteruuid
	left join public.languagetranslations namelt
		on namelt.languagetranslationmasterid  = namelm.languagemasterid
			and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as foo)
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'custagdisplayname' 
	left join languagemaster displaylm
		on dn.entityfieldinstancevaluelanguagemasteruuid = displaylm.languagemasteruuid
	left join public.languagetranslations displaylt
		on displaylt.languagetranslationmasterid  = displaylm.languagemasterid
			and displaylt.languagetranslationtypeid = (select foo2.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as foo2)
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'custagabbreviationentityuuid' 
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as parname
		on ei.entityinstanceparententityuuid  =  parname.systagentityuuid
	left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_custagsenddeleted , read_custagsenddrafts, read_custagsendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as parnamecust
		on ei.entityinstanceparententityuuid  =  parnamecust.custagentityuuid
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as abbname
		on abb.entityfieldinstancevalue =  abbname.systagentityuuid::text
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as systemname
		on ei.entityinstanceexternalsystementityuuid =  systemname.systagentityuuid) as foo3
		where foo3.entityinstanceactive = Any (tempcustagsendinactive) ;   
	return;
end if;

if read_custagentityuuid notNull and allowners = false
	then
	return query
		select *
		from (SELECT 
	read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
	ei.entityinstanceoriginalid as custagid,
	ei.entityinstanceoriginaluuid as custaguuid,
	ei.entityinstanceuuid as custagentityuuid,
	cust.customerentityuuid::uuid as custagownerentityuuid,	
	cust.customername as custagownerentityname,	
	ei.entityinstanceparententityuuid as custagparententityuuid,
	case when parname.systagtype notNull
		then parname.systagtype
		else parnamecust.custagtype
	end as custagparentname,
	ei.entityinstancecornerstoneentityuuid  as custagcornerstoneentityid,
	cust.customerid as custagcustomerid,	
	cust.customeruuid as custagcustomeruuid,
	cust.customerentityuuid::uuid as custagcustomerentityuuid,
	cust.customername as custagcustomername,
	ei.entityinstancenameuuid as custagnameuuid,
	COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS custagname,
	dn.entityfieldinstancevaluelanguagemasteruuid as custagdisplaynameuuid,
	COALESCE(displaylt.languagetranslationvalue, displaylm.languagemastersource) AS custagdisplayname,
	ei.entityinstancetype as custagtype,
	ei.entityinstancecreateddate as custagcreateddate,
	ei.entityinstancemodifieddate as custagmodifieddate,	
	ei.entityinstancestartdate as custagstartdate,
	ei.entityinstanceenddate as custagenddate,
	ei.entityinstanceexternalid as custagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	systemname.systagtype as custagexternalsystementname,
	ei.entityinstancemodifiedbyuuid as custagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as custagabbreviationentityuuid,
	abbname.systagtype as custagabbreviationname,
	ei.entityinstancecornerstoneorder as custagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
		then false
		else true
		end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid,customername  from entity.crud_customer_read_full(read_ownerentityuuid,null, null, allowners,read_custagsenddeleted,read_custagsenddrafts,read_custagsendinactive, null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'Customer Tag' 
			and ei.entityinstanceuuid = read_custagentityuuid
			and ei.entityinstancedeleted = ANY (tempcustagsenddeleted)
			and ei.entityinstancedraft = ANY (tempcustagsenddrafts)
	left join languagemaster namelm  -- this lm to lt pattern can probably become a function instead
		on ei.entityinstancenameuuid = namelm.languagemasteruuid
	left join public.languagetranslations namelt
		on namelt.languagetranslationmasterid  = namelm.languagemasterid
			and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as foo)
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'custagdisplayname' 
	left join languagemaster displaylm
		on dn.entityfieldinstancevaluelanguagemasteruuid = displaylm.languagemasteruuid
	left join public.languagetranslations displaylt
		on displaylt.languagetranslationmasterid  = displaylm.languagemasterid
			and displaylt.languagetranslationtypeid = (select foo2.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as foo2)
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'custagabbreviationentityuuid' 
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as parname
		on ei.entityinstanceparententityuuid  =  parname.systagentityuuid
	left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_custagsenddeleted , read_custagsenddrafts, read_custagsendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as parnamecust
		on ei.entityinstanceparententityuuid  =  parnamecust.custagentityuuid
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as abbname
		on abb.entityfieldinstancevalue =  abbname.systagentityuuid::text
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as systemname
		on ei.entityinstanceexternalsystementityuuid =  systemname.systagentityuuid) as foo3
		where foo3.entityinstanceactive = Any (tempcustagsendinactive) ;   
	return;
end if;

if read_custagparententityuuid notNull and allowners = false
	then
	return query
		select *
		from (SELECT 
	read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
	ei.entityinstanceoriginalid as custagid,
	ei.entityinstanceoriginaluuid as custaguuid,
	ei.entityinstanceuuid as custagentityuuid,
	cust.customerentityuuid::uuid as custagownerentityuuid,	
	cust.customername as custagownerentityname,	
	ei.entityinstanceparententityuuid as custagparententityuuid,
	case when parname.systagtype notNull
		then parname.systagtype
		else parnamecust.custagtype
	end as custagparentname,
	ei.entityinstancecornerstoneentityuuid  as custagcornerstoneentityid,
	cust.customerid as custagcustomerid,	
	cust.customeruuid as custagcustomeruuid,
	cust.customerentityuuid::uuid as custagcustomerentityuuid,
	cust.customername as custagcustomername,
	ei.entityinstancenameuuid as custagnameuuid,
	COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS custagname,
	dn.entityfieldinstancevaluelanguagemasteruuid as custagdisplaynameuuid,
	COALESCE(displaylt.languagetranslationvalue, displaylm.languagemastersource) AS custagdisplayname,
	ei.entityinstancetype as custagtype,
	ei.entityinstancecreateddate as custagcreateddate,
	ei.entityinstancemodifieddate as custagmodifieddate,	
	ei.entityinstancestartdate as custagstartdate,
	ei.entityinstanceenddate as custagenddate,
	ei.entityinstanceexternalid as custagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	systemname.systagtype as custagexternalsystementname,
	ei.entityinstancemodifiedbyuuid as custagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as custagabbreviationentityuuid,
	abbname.systagtype as custagabbreviationname,
	ei.entityinstancecornerstoneorder as custagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
		then false
		else true
		end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid,customername  from entity.crud_customer_read_full(read_ownerentityuuid,null, null, allowners, read_custagsenddeleted,read_custagsenddrafts,read_custagsendinactive,null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'Customer Tag' 
			and ei.entityinstanceparententityuuid = read_custagparententityuuid
			and ei.entityinstancedeleted = ANY (tempcustagsenddeleted)
			and ei.entityinstancedraft = ANY (tempcustagsenddrafts)
	left join languagemaster namelm  -- this lm to lt pattern can probably become a function instead
		on ei.entityinstancenameuuid = namelm.languagemasteruuid
	left join public.languagetranslations namelt
		on namelt.languagetranslationmasterid  = namelm.languagemasterid
			and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as foo)
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'custagdisplayname' 
	left join languagemaster displaylm
		on dn.entityfieldinstancevaluelanguagemasteruuid = displaylm.languagemasteruuid
	left join public.languagetranslations displaylt
		on displaylt.languagetranslationmasterid  = displaylm.languagemasterid
			and displaylt.languagetranslationtypeid = (select foo2.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as foo2)
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'custagabbreviationentityuuid' 
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as parname
		on ei.entityinstanceparententityuuid  =  parname.systagentityuuid
	left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_custagsenddeleted , read_custagsenddrafts, read_custagsendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as parnamecust
		on ei.entityinstanceparententityuuid  =  parnamecust.custagentityuuid
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as abbname
		on abb.entityfieldinstancevalue =  abbname.systagentityuuid::text
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as systemname
		on ei.entityinstanceexternalsystementityuuid =  systemname.systagentityuuid) as foo3
		where foo3.entityinstanceactive = Any (tempcustagsendinactive) ;   
	return;
end if;

if read_custagparententityuuid isNull and allowners = false
	then
	return query
		select *
		from (SELECT 
	read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
	ei.entityinstanceoriginalid as custagid,
	ei.entityinstanceoriginaluuid as custaguuid,
	ei.entityinstanceuuid as custagentityuuid,
	cust.customerentityuuid::uuid as custagownerentityuuid,	
	cust.customername as custagownerentityname,	
	ei.entityinstanceparententityuuid as custagparententityuuid,
	case when parname.systagtype notNull
		then parname.systagtype
		else parnamecust.custagtype
	end as custagparentname,
	ei.entityinstancecornerstoneentityuuid  as custagcornerstoneentityid,
	cust.customerid as custagcustomerid,	
	cust.customeruuid as custagcustomeruuid,
	cust.customerentityuuid::uuid as custagcustomerentityuuid,
	cust.customername as custagcustomername,
	ei.entityinstancenameuuid as custagnameuuid,
	COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS custagname,
	dn.entityfieldinstancevaluelanguagemasteruuid as custagdisplaynameuuid,
	COALESCE(displaylt.languagetranslationvalue, displaylm.languagemastersource) AS custagdisplayname,
	ei.entityinstancetype as custagtype,
	ei.entityinstancecreateddate as custagcreateddate,
	ei.entityinstancemodifieddate as custagmodifieddate,	
	ei.entityinstancestartdate as custagstartdate,
	ei.entityinstanceenddate as custagenddate,
	ei.entityinstanceexternalid as custagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	systemname.systagtype as custagexternalsystementname,
	ei.entityinstancemodifiedbyuuid as custagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as custagabbreviationentityuuid,
	abbname.systagtype as custagabbreviationname,
	ei.entityinstancecornerstoneorder as custagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
		then false
		else true
		end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid,customername  from entity.crud_customer_read_full(read_ownerentityuuid,null, null, allowners,read_custagsenddeleted,read_custagsenddrafts,read_custagsendinactive, null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'Customer Tag' 
			and ei.entityinstanceownerentityuuid = read_ownerentityuuid
			and ei.entityinstanceparententityuuid = read_custagparententityuuid
			and ei.entityinstancedeleted = ANY (tempcustagsenddeleted)
			and ei.entityinstancedraft = ANY (tempcustagsenddrafts)
	left join languagemaster namelm  -- this lm to lt pattern can probably become a function instead
		on ei.entityinstancenameuuid = namelm.languagemasteruuid
	left join public.languagetranslations namelt
		on namelt.languagetranslationmasterid  = namelm.languagemasterid
			and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as foo)
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'custagdisplayname' 
	left join languagemaster displaylm
		on dn.entityfieldinstancevaluelanguagemasteruuid = displaylm.languagemasteruuid
	left join public.languagetranslations displaylt
		on displaylt.languagetranslationmasterid  = displaylm.languagemasterid
			and displaylt.languagetranslationtypeid = (select foo2.systagid from entity.crud_systag_read_min(tendreluuid, null, read_languagetranslationtypeentityuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as foo2)
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'custagabbreviationentityuuid' 
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as parname
		on ei.entityinstanceparententityuuid  =  parname.systagentityuuid
	left join (select * from entity.crud_custag_read_min(null,null,null, null, true,read_custagsenddeleted , read_custagsenddrafts, read_custagsendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as parnamecust
		on ei.entityinstanceparententityuuid  =  parnamecust.custagentityuuid
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as abbname
		on abb.entityfieldinstancevalue =  abbname.systagentityuuid::text
	left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as systemname
		on ei.entityinstanceexternalsystementityuuid =  systemname.systagentityuuid) as foo3
		where foo3.entityinstanceactive = Any (tempcustagsendinactive) ;   
	return;
end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_custag_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_custag_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_custag_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_custag_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO graphql;
