
-- Type: FUNCTION ; Name: entity.crud_systag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_systag_read_api(read_ownerentityuuid uuid[], read_siteentityuuid uuid, read_systagentityuuid uuid, read_systagparententityuuid uuid, read_allsystags boolean, read_systagsenddeleted boolean, read_systagsenddrafts boolean, read_systagsendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, systagid bigint, systaguuid text, systagentityuuid uuid, systagownerentityuuid uuid, systagownerentityname text, systagparententityuuid uuid, systagparentname text, systagcornerstoneentityid uuid, systagcustomerid bigint, systagcustomeruuid text, systagcustomerentityuuid uuid, systagcustomername text, systagnameuuid text, systagname text, systagdisplaynameuuid text, systagdisplayname text, systagtype text, systagcreateddate timestamp with time zone, systagmodifieddate timestamp with time zone, systagstartdate timestamp with time zone, systagenddate timestamp with time zone, systagexternalid text, systagexternalsystementityuuid uuid, systagexternalsystemenname text, systagmodifiedbyuuid text, systagabbreviationentityuuid uuid, systagabbreviationname text, systagorder integer, systagsenddeleted boolean, systagsenddrafts boolean, systagsendinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	templanguagetranslationtypeid bigint;
BEGIN

-- Need to handle language translation in full version.  minimal version does not use languagetranslation
-- Might want to add a parameter to send in active as a boolean
-- Curretnly ignores site since systag does not care about site.  systag does.  
-- May want to flip paramaeters to be arrays in the future.  

/*  examples

-- call entity.test_entity()

-- all customers all systags 
select * from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- all systags for a specific customer
select * from entity.crud_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- all systags for a parent
select * from entity.crud_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- fail scenario for parent
select * from entity.crud_systag_read_full(null,null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- specific systags
-- succeed
select * from entity.crud_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61', null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

--fail
select * from entity.crud_systag_read_full(null, null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

*/

select ei.entityinstanceoriginalid
into templanguagetranslationtypeid
from entity.entityinstance ei
where entityinstanceuuid=read_languagetranslationtypeentityuuid; 

return query
	SELECT 
		read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
		ei.entityinstanceoriginalid as systagid,
		ei.entityinstanceoriginaluuid as systaguuid,
		ei.entityinstanceuuid as systagentityuuid,
	    ei.entityinstanceownerentityuuid,
		COALESCE(customerlt.languagetranslationvalue, customerlm.languagemastersource) AS customername,	
		ei.entityinstanceparententityuuid as systagparententityuuid,
		COALESCE(parentlt.languagetranslationvalue, parentlm.languagemastersource) AS systagparentname,
		ei.entityinstancecornerstoneentityuuid  as systagcornerstoneentityid,
		null::bigint as systagcustomerid,	
		null::text as systagcustomeruuid,
		null::uuid as systagcustomerentityuuid,
		null::text as systagcustomername,
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
		null as systagexternalsystementname,
		ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
		null::uuid as systagabbreviationentityuuid,
		null::text as systagabbreviationname,
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
		inner join entity.entityinstance customer
			on customer.entityinstanceuuid = ei.entityinstanceownerentityuuid
				and (ei.entityinstanceownerentityuuid = ANY(read_ownerentityuuid)
					or	ei.entityinstanceownerentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61')
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


REVOKE ALL ON FUNCTION entity.crud_systag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_systag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_systag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_systag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO graphql;
