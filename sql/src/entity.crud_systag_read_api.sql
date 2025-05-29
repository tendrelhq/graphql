BEGIN;

/*
DROP FUNCTION api.delete_systag(uuid,uuid);
DROP VIEW api.systag;

DROP FUNCTION entity.crud_systag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid);
*/


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
select * from entity.crud_systag_read_api(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- all systags for a specific customer
select * from entity.crud_systag_read_api(ARRAY['f90d618d-5de7-4126-8c65-0afb700c6c61'],null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
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
				and ei.entityinstanceentitytemplateentityuuid = 'def05966-06b2-483e-8988-d0f898e45e6c'
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
				and dn.entityfieldinstanceentityfieldentityuuid = 'cf94ce9c-edd3-4c7b-8128-ab598fc9710a' 
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

-- DEPENDANTS


-- Type: VIEW ; Name: systag; Owner: tendreladmin

CREATE OR REPLACE VIEW api.systag AS
 SELECT systagentityuuid AS id,
    systagid AS legacy_id,
    systaguuid AS legacy_uuid,
    systagownerentityuuid AS owner,
    systagownerentityname AS owner_name,
    systagparententityuuid AS parent,
    systagparentname AS parent_name,
    NULL::uuid AS cornerstone,
    systagnameuuid AS name_id,
    systagname AS name,
    systagdisplaynameuuid AS displayname_id,
    systagdisplayname AS displayname,
    systagtype AS type,
    systagcreateddate AS created_at,
    systagmodifieddate AS updated_at,
    systagstartdate AS activated_at,
    systagenddate AS deactivated_at,
    systagexternalid AS external_id,
    systagexternalsystementityuuid AS external_system,
    systagmodifiedbyuuid AS modified_by,
    systagorder AS _order,
    systagsenddeleted AS _deleted,
    systagsenddrafts AS _draft,
    systagsendinactive AS _active
   FROM ( SELECT crud_systag_read_api.languagetranslationtypeentityuuid,
            crud_systag_read_api.systagid,
            crud_systag_read_api.systaguuid,
            crud_systag_read_api.systagentityuuid,
            crud_systag_read_api.systagownerentityuuid,
            crud_systag_read_api.systagownerentityname,
            crud_systag_read_api.systagparententityuuid,
            crud_systag_read_api.systagparentname,
            crud_systag_read_api.systagcornerstoneentityid,
            crud_systag_read_api.systagcustomerid,
            crud_systag_read_api.systagcustomeruuid,
            crud_systag_read_api.systagcustomerentityuuid,
            crud_systag_read_api.systagcustomername,
            crud_systag_read_api.systagnameuuid,
            crud_systag_read_api.systagname,
            crud_systag_read_api.systagdisplaynameuuid,
            crud_systag_read_api.systagdisplayname,
            crud_systag_read_api.systagtype,
            crud_systag_read_api.systagcreateddate,
            crud_systag_read_api.systagmodifieddate,
            crud_systag_read_api.systagstartdate,
            crud_systag_read_api.systagenddate,
            crud_systag_read_api.systagexternalid,
            crud_systag_read_api.systagexternalsystementityuuid,
            crud_systag_read_api.systagexternalsystemenname,
            crud_systag_read_api.systagmodifiedbyuuid,
            crud_systag_read_api.systagabbreviationentityuuid,
            crud_systag_read_api.systagabbreviationname,
            crud_systag_read_api.systagorder,
            crud_systag_read_api.systagsenddeleted,
            crud_systag_read_api.systagsenddrafts,
            crud_systag_read_api.systagsendinactive
           FROM entity.crud_systag_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_systag_read_api(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagownerentityuuid, systagownerentityname, systagparententityuuid, systagparentname, systagcornerstoneentityid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagcustomername, systagnameuuid, systagname, systagdisplaynameuuid, systagdisplayname, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagexternalsystemenname, systagmodifiedbyuuid, systagabbreviationentityuuid, systagabbreviationname, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)) systag;

COMMENT ON VIEW api.systag IS '
## language
';

CREATE TRIGGER create_systag_tg INSTEAD OF INSERT ON api.systag FOR EACH ROW EXECUTE FUNCTION api.create_systag();
CREATE TRIGGER update_systag_tg INSTEAD OF UPDATE ON api.systag FOR EACH ROW EXECUTE FUNCTION api.update_systag();

GRANT INSERT ON api.systag TO authenticated;
GRANT SELECT ON api.systag TO authenticated;
GRANT UPDATE ON api.systag TO authenticated;

-- Type: FUNCTION ; Name: api.delete_systag(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_systag(owner uuid, id uuid)
 RETURNS SETOF api.systag
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
	  call entity.crud_systag_delete(
	      create_systagownerentityuuid := owner,
	      create_systagentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.systag t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_systag(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_systag(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_systag(uuid,uuid) TO authenticated;

END;
