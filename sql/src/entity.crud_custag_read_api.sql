
-- Type: FUNCTION ; Name: entity.crud_custag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_custag_read_api(read_ownerentityuuid uuid[], read_siteentityuuid uuid, read_custagentityuuid uuid, read_custagparententityuuid uuid, read_allcustags boolean, read_custagsenddeleted boolean, read_custagsenddrafts boolean, read_custagsendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, custagid bigint, custaguuid text, custagentityuuid uuid, custagownerentityuuid uuid, custagownerentityname text, custagparententityuuid uuid, custagparentname text, custagcornerstoneentityid uuid, custagcustomerid bigint, custagcustomeruuid text, custagcustomerentityuuid uuid, custagcustomername text, custagnameuuid text, custagname text, custagdisplaynameuuid text, custagdisplayname text, custagtype text, custagcreateddate timestamp with time zone, custagmodifieddate timestamp with time zone, custagstartdate timestamp with time zone, custagenddate timestamp with time zone, custagexternalid text, custagexternalsystementityuuid uuid, custagexternalsystemenname text, custagmodifiedbyuuid text, custagabbreviationentityuuid uuid, custagabbreviationname text, custagorder integer, systagsenddeleted boolean, systagsenddrafts boolean, systagsendinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	templanguagetranslationtypeid bigint;
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

select ei.entityinstanceoriginalid
into templanguagetranslationtypeid
from entity.entityinstance ei
where entityinstanceuuid=read_languagetranslationtypeentityuuid; 


return query
	SELECT 
		read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
		ei.entityinstanceoriginalid as custagid,
		ei.entityinstanceoriginaluuid as custaguuid,
		ei.entityinstanceuuid as custagentityuuid,
	    ei.entityinstanceownerentityuuid,
		COALESCE(customerlt.languagetranslationvalue, customerlm.languagemastersource) AS customername,	
		ei.entityinstanceparententityuuid as custagparententityuuid,
		COALESCE(parentlt.languagetranslationvalue, parentlm.languagemastersource) AS custagparentname,
		ei.entityinstancecornerstoneentityuuid  as custagcornerstoneentityid,
		null::bigint as custagcustomerid,	
		null::text as custagcustomeruuid,
		null::uuid as custagcustomerentityuuid,
		null::text as custagcustomername,
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
		null as custagexternalsystementname,
		ei.entityinstancemodifiedbyuuid as custagmodifiedbyuuid,
		null::uuid as custagabbreviationentityuuid,
		null::text as custagabbreviationname,
		ei.entityinstancecornerstoneorder as custagorder,
		ei.entityinstancedeleted, 
		ei.entityinstancedraft,
		case when ei.entityinstancedeleted then false
				when ei.entityinstancedraft then false
				when ei.entityinstanceenddate::Date > now()::date 
					and ei.entityinstancestartdate < now() then false
				else true
		end as entityinstanceactive
	from entity.entityinstance ei
		inner join entity.entityinstance customer
			on customer.entityinstanceuuid = ei.entityinstanceownerentityuuid
				and ei.entityinstanceownerentityuuid = ANY(read_ownerentityuuid)
		inner join public.languagemaster customerlm
			on customer.entityinstancenameuuid = customerlm.languagemasteruuid
		left join public.languagetranslations customerlt
			on customerlm.languagemasterid = customerlt.languagetranslationmasterid
				and customerlt.languagetranslationtypeid  = templanguagetranslationtypeid
		inner join entity.entityinstance parent
			on parent.entityinstanceuuid = ei.entityinstanceparententityuuid
		inner join public.languagemaster parentlm
			on parent.entityinstancenameuuid = parentlm.languagemasteruuid
		left join public.languagetranslations parentlt
			on parentlm.languagemasterid = parentlt.languagetranslationmasterid	
				and parentlt.languagetranslationtypeid  = templanguagetranslationtypeid
		inner join languagemaster namelm  -- this lm to lt pattern can probably become a function instead
			on ei.entityinstancenameuuid = namelm.languagemasteruuid
		left join public.languagetranslations namelt
			on namelt.languagetranslationmasterid  = namelm.languagemasterid
				and namelt.languagetranslationtypeid = templanguagetranslationtypeid
		join entity.entityfieldinstance dn
			on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldentityuuid = '1b29e7b0-0800-4366-b79e-424dd9bafa71' 
		left join languagemaster displaylm
			on dn.entityfieldinstancevaluelanguagemasteruuid = displaylm.languagemasteruuid
		left join public.languagetranslations displaylt
			on displaylt.languagetranslationmasterid  = displaylm.languagemasterid
				and displaylt.languagetranslationtypeid = templanguagetranslationtypeid;
return;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_custag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_custag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_custag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_custag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO graphql;
