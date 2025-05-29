BEGIN;

/*
DROP FUNCTION api.delete_reason_code(uuid,uuid,text,text);
DROP FUNCTION api.delete_custag(uuid,uuid);
DROP VIEW api.reason_code;
DROP VIEW api.custag;

DROP FUNCTION entity.crud_custag_read_api(uuid[],uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid);
*/


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
				and ei.entityinstanceentitytemplateentityuuid = '30a317b8-6a56-45b4-8480-f9b58e099c77'
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

-- DEPENDANTS


-- Type: VIEW ; Name: custag; Owner: tendreladmin

CREATE OR REPLACE VIEW api.custag AS
 SELECT custagentityuuid AS id,
    custagid AS legacy_id,
    custaguuid AS legacy_uuid,
    custagownerentityuuid AS owner,
    custagownerentityname AS owner_name,
    custagparententityuuid AS parent,
    custagparentname AS parent_name,
    custagcornerstoneentityid AS cornerstone,
    custagnameuuid AS name_id,
    custagname AS name,
    custagdisplaynameuuid AS displayname_id,
    custagdisplayname AS displayname,
    custagtype AS type,
    custagcreateddate AS created_at,
    custagmodifieddate AS updated_at,
    custagstartdate AS activated_at,
    custagenddate AS deactivated_at,
    custagexternalid AS external_id,
    custagexternalsystementityuuid AS external_system,
    custagmodifiedbyuuid AS modified_by,
    custagorder AS _order,
    systagsenddeleted AS _deleted,
    systagsenddrafts AS _draft,
    systagsendinactive AS _active
   FROM ( SELECT crud_custag_read_api.languagetranslationtypeentityuuid,
            crud_custag_read_api.custagid,
            crud_custag_read_api.custaguuid,
            crud_custag_read_api.custagentityuuid,
            crud_custag_read_api.custagownerentityuuid,
            crud_custag_read_api.custagownerentityname,
            crud_custag_read_api.custagparententityuuid,
            crud_custag_read_api.custagparentname,
            crud_custag_read_api.custagcornerstoneentityid,
            crud_custag_read_api.custagcustomerid,
            crud_custag_read_api.custagcustomeruuid,
            crud_custag_read_api.custagcustomerentityuuid,
            crud_custag_read_api.custagcustomername,
            crud_custag_read_api.custagnameuuid,
            crud_custag_read_api.custagname,
            crud_custag_read_api.custagdisplaynameuuid,
            crud_custag_read_api.custagdisplayname,
            crud_custag_read_api.custagtype,
            crud_custag_read_api.custagcreateddate,
            crud_custag_read_api.custagmodifieddate,
            crud_custag_read_api.custagstartdate,
            crud_custag_read_api.custagenddate,
            crud_custag_read_api.custagexternalid,
            crud_custag_read_api.custagexternalsystementityuuid,
            crud_custag_read_api.custagexternalsystemenname,
            crud_custag_read_api.custagmodifiedbyuuid,
            crud_custag_read_api.custagabbreviationentityuuid,
            crud_custag_read_api.custagabbreviationname,
            crud_custag_read_api.custagorder,
            crud_custag_read_api.systagsenddeleted,
            crud_custag_read_api.systagsenddrafts,
            crud_custag_read_api.systagsendinactive
           FROM entity.crud_custag_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_custag_read_api(languagetranslationtypeentityuuid, custagid, custaguuid, custagentityuuid, custagownerentityuuid, custagownerentityname, custagparententityuuid, custagparentname, custagcornerstoneentityid, custagcustomerid, custagcustomeruuid, custagcustomerentityuuid, custagcustomername, custagnameuuid, custagname, custagdisplaynameuuid, custagdisplayname, custagtype, custagcreateddate, custagmodifieddate, custagstartdate, custagenddate, custagexternalid, custagexternalsystementityuuid, custagexternalsystemenname, custagmodifiedbyuuid, custagabbreviationentityuuid, custagabbreviationname, custagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)) custag
  WHERE (custagownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.custag IS '
## Custag

A description of what an entity tempalte is and why it is used

### get {baseUrl}/custag

A bunch of comments explaining get

### del {baseUrl}/custag

A bunch of comments explaining del

### patch {baseUrl}/custag

A bunch of comments explaining patch
';

CREATE TRIGGER create_custag_tg INSTEAD OF INSERT ON api.custag FOR EACH ROW EXECUTE FUNCTION api.create_custag();
CREATE TRIGGER update_custag_tg INSTEAD OF UPDATE ON api.custag FOR EACH ROW EXECUTE FUNCTION api.update_custag();

GRANT INSERT ON api.custag TO authenticated;
GRANT SELECT ON api.custag TO authenticated;
GRANT UPDATE ON api.custag TO authenticated;

-- Type: VIEW ; Name: reason_code; Owner: tendreladmin

CREATE OR REPLACE VIEW api.reason_code AS
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
    custag.custagmodifieddate AS updated_at,
    custag.custagstartdate AS activated_at,
    custag.custagenddate AS deactivated_at,
    custag.custagexternalid AS external_id,
    custag.custagexternalsystementityuuid AS external_system,
    custag.custagmodifiedbyuuid AS modified_by,
    custag.custagorder AS _order,
    custag.systagsenddeleted AS _deleted,
    custag.systagsenddrafts AS _draft,
    custag.systagsendinactive AS _active,
    wtc.worktemplateconstraintid AS work_template_constraint,
    wt.id AS work_template,
    COALESCE(lt.languagetranslationvalue, lm.languagemastersource) AS work_template_name
   FROM ( SELECT crud_custag_read_api.languagetranslationtypeentityuuid,
            crud_custag_read_api.custagid,
            crud_custag_read_api.custaguuid,
            crud_custag_read_api.custagentityuuid,
            crud_custag_read_api.custagownerentityuuid,
            crud_custag_read_api.custagownerentityname,
            crud_custag_read_api.custagparententityuuid,
            crud_custag_read_api.custagparentname,
            crud_custag_read_api.custagcornerstoneentityid,
            crud_custag_read_api.custagcustomerid,
            crud_custag_read_api.custagcustomeruuid,
            crud_custag_read_api.custagcustomerentityuuid,
            crud_custag_read_api.custagcustomername,
            crud_custag_read_api.custagnameuuid,
            crud_custag_read_api.custagname,
            crud_custag_read_api.custagdisplaynameuuid,
            crud_custag_read_api.custagdisplayname,
            crud_custag_read_api.custagtype,
            crud_custag_read_api.custagcreateddate,
            crud_custag_read_api.custagmodifieddate,
            crud_custag_read_api.custagstartdate,
            crud_custag_read_api.custagenddate,
            crud_custag_read_api.custagexternalid,
            crud_custag_read_api.custagexternalsystementityuuid,
            crud_custag_read_api.custagexternalsystemenname,
            crud_custag_read_api.custagmodifiedbyuuid,
            crud_custag_read_api.custagabbreviationentityuuid,
            crud_custag_read_api.custagabbreviationname,
            crud_custag_read_api.custagorder,
            crud_custag_read_api.systagsenddeleted,
            crud_custag_read_api.systagsenddrafts,
            crud_custag_read_api.systagsendinactive
           FROM entity.crud_custag_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, 'f875b28c-ccc9-4c69-b5b4-9f10ad89d23b'::uuid, false, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_custag_read_api(languagetranslationtypeentityuuid, custagid, custaguuid, custagentityuuid, custagownerentityuuid, custagownerentityname, custagparententityuuid, custagparentname, custagcornerstoneentityid, custagcustomerid, custagcustomeruuid, custagcustomerentityuuid, custagcustomername, custagnameuuid, custagname, custagdisplaynameuuid, custagdisplayname, custagtype, custagcreateddate, custagmodifieddate, custagstartdate, custagenddate, custagexternalid, custagexternalsystementityuuid, custagexternalsystemenname, custagmodifiedbyuuid, custagabbreviationentityuuid, custagabbreviationname, custagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)) custag
     LEFT JOIN worktemplateconstraint wtc ON wtc.worktemplateconstraintconstrainedtypeid = 'systag_4bbc3e18-de10-4f93-aabb-b1d051a2923d'::text AND wtc.worktemplateconstraintconstraintid = custag.custaguuid
     LEFT JOIN worktemplate wt ON wtc.worktemplateconstrainttemplateid = wt.id
     LEFT JOIN languagemaster lm ON wt.worktemplatenameid = lm.languagemasterid
     LEFT JOIN languagetranslations lt ON lm.languagemasterid = lt.languagetranslationmasterid
  WHERE (custag.custagownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.reason_code IS '
## Reason Code

A description of what an entity tempalte is and why it is used

### get {baseUrl}/custag

A bunch of comments explaining get

### del {baseUrl}/custag

A bunch of comments explaining del

### patch {baseUrl}/custag

A bunch of comments explaining patch
';

GRANT INSERT ON api.reason_code TO authenticated;
GRANT SELECT ON api.reason_code TO authenticated;
GRANT UPDATE ON api.reason_code TO authenticated;

-- Type: FUNCTION ; Name: api.delete_custag(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_custag(owner uuid, id uuid)
 RETURNS SETOF api.custag
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
	  call entity.crud_custag_delete(
	      create_custagownerentityuuid := owner,
	      create_custagentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
end if;

  return query
    select *
    from api.custag t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_custag(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_custag(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_custag(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_reason_code(uuid,uuid,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_reason_code(owner uuid, id uuid, work_template_constraint text, work_template text)
 RETURNS SETOF api.reason_code
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

-- NEED TO ADD MORE CONDITIONS.  
-- DO WE ALLOW THE CONSTRAINT TO BE DELETED OR JUST THE CUSTAG TO BE DEACTIVATED.
-- VERSION BELOW JUST DEACTIVATES THE CUSTAG, BUT THAT IS FOR ALL TEMPLATES.

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_custag_delete(
	      create_custagownerentityuuid := owner,
	      create_custagentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
end if;

  return query
    select *
    from api.reason_code t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) TO authenticated;

END;
