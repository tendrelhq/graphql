BEGIN;

/*
DROP FUNCTION api.delete_entity_tag(uuid,uuid);
DROP VIEW api.entity_tag;

DROP FUNCTION entity.crud_entitytag_read_api(uuid[],uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_entitytag_read_api(uuid[],uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entitytag_read_api(read_ownerentityuuid uuid[], read_entitytagentityuuid uuid, read_entitytagentityinstanceuuid uuid, read_entitytagtemplateentityuuid uuid, read_entitytagcustagentityuuid uuid, read_allentitytags boolean, read_entitytagsenddeleted boolean, read_entitytagsenddrafts boolean, read_entitytagsendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, entitytaguuid uuid, entitytagownerentityuuid uuid, entitytagownername text, entitytagentityinstanceentityuuid uuid, entitytagentityinstanceentityname text, entitytagentitytemplateentityuuid uuid, entitytagentitytemplatename text, entitytagcreateddate timestamp with time zone, entitytagmodifieddate timestamp with time zone, entitytagstartdate timestamp with time zone, entitytagenddate timestamp with time zone, entitytagrefid bigint, entitytagrefuuid text, entitytagmodifiedbyuuid text, entitytagcustagparententityuuid uuid, entitytagparentcustagtype text, entitytagcustagentityuuid uuid, entitytagcustagtype text, entitytagsenddeleted boolean, entitytagsenddrafts boolean, entitytagsendinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	templanguagetranslationtypeid bigint;
BEGIN

/*  examples

-- all customers all entitytags

select * from entity.crud_entitytag_read_full(null, null,null,null, null, true, null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
limit 100

-- specific tag
select * from entity.crud_entitytag_read_full('ccda3933-c740-40ec-9a2b-a9f1a7d4db28','8cd49ef4-2b70-410b-85aa-4b67f617066a',null,null, null, false, null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- all tags for a specific instance
select * from entity.crud_entitytag_read_full('ccda3933-c740-40ec-9a2b-a9f1a7d4db28',null,'d57f7b9c-fe72-463a-9cc9-1cb03ad4a812',null, null, false, null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- all instances for a template
select * from entity.crud_entitytag_read_full('d7995576-8354-4aea-b052-1ce61052bd2e',null,null,'0b9f3142-e7ed-4f78-8504-ccd2eb505075', null, false, null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- all tags for a template no instances
select distinct entitytagcustagentityuuid from entity.crud_entitytag_read_full('d7995576-8354-4aea-b052-1ce61052bd2e',null,null,'0b9f3142-e7ed-4f78-8504-ccd2eb505075', null, false, null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- all instances for a tag
select * from entity.crud_entitytag_read_full('d7995576-8354-4aea-b052-1ce61052bd2e',null,null, null, 'e7e8223d-3480-42b5-9fc6-9dee59667fa3', false, null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- all instances for a template and a tag
select * from entity.crud_entitytag_read_full('d7995576-8354-4aea-b052-1ce61052bd2e',null,null, '0b9f3142-e7ed-4f78-8504-ccd2eb505075', 'e7e8223d-3480-42b5-9fc6-9dee59667fa3', false, null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

*/

select ei.entityinstanceoriginalid
into templanguagetranslationtypeid
from entity.entityinstance ei
where entityinstanceuuid=read_languagetranslationtypeentityuuid; 

return query 
		SELECT 
		read_languagetranslationtypeentityuuid, 
	    et.entitytaguuid,
	    et.entitytagownerentityuuid,
		COALESCE(customerlt.languagetranslationvalue, customerlm.languagemastersource) AS customername,
	    et.entitytagentityinstanceentityuuid,
		COALESCE(instancelt.languagetranslationvalue, instancelm.languagemastersource) AS entityinstancename,
	    et.entitytagentitytemplateentityuuid,
		COALESCE(templatelt.languagetranslationvalue, templatelm.languagemastersource) AS entitytemplatename,
	    et.entitytagcreateddate,
	    et.entitytagmodifieddate,
	    et.entitytagstartdate,
	    et.entitytagenddate,
	    et.entitytagrefid,
	    et.entitytagrefuuid,
	    et.entitytagmodifiedbyuuid,
		custag.entityinstanceparententityuuid,  
		COALESCE(parentlt.languagetranslationvalue, parentlm.languagemastersource) AS custagparentname,
	    et.entitytagcustagentityuuid,
		COALESCE(custaglt.languagetranslationvalue, custaglm.languagemastersource) AS custagname,
		et.entitytagdeleted boolean,
		et.entitytagdraft boolean,
		case when et.entitytagdeleted then false
			when et.entitytagdraft then false
			when et.entitytagenddate::Date > now()::date 
				and et.entitytagstartdate < now() then false
		else true
	end as entitytagactive
	from entity.entitytag et
		inner join entity.entityinstance customer
			on customer.entityinstanceuuid = et.entitytagownerentityuuid
				and et.entitytagownerentityuuid = ANY(read_ownerentityuuid)
		inner join public.languagemaster customerlm
			on customer.entityinstancenameuuid = customerlm.languagemasteruuid
		left join public.languagetranslations customerlt
			on customerlm.languagemasterid = customerlt.languagetranslationmasterid
				and customerlt.languagetranslationtypeid  = templanguagetranslationtypeid
		left join entity.entitytemplate template
			on template.entitytemplateuuid = et.entitytagentitytemplateentityuuid
		left join public.languagemaster templatelm
			on template.entitytemplatenameuuid = templatelm.languagemasteruuid
		left join public.languagetranslations templatelt
			on templatelm.languagemasterid = templatelt.languagetranslationmasterid
				and templatelt.languagetranslationtypeid  = templanguagetranslationtypeid
		left join entity.entityinstance instance
			on instance.entityinstanceuuid = et.entitytagentityinstanceentityuuid		
		left join public.languagemaster instancelm
			on instance.entityinstancenameuuid = instancelm.languagemasteruuid
		left join public.languagetranslations instancelt
			on instancelm.languagemasterid = instancelt.languagetranslationmasterid
				and instancelt.languagetranslationtypeid  = templanguagetranslationtypeid
		inner join entity.entityinstance custag
			on custag.entityinstanceuuid = et.entitytagcustagentityuuid		
		inner join public.languagemaster custaglm
			on custag.entityinstancenameuuid = custaglm.languagemasteruuid
		left join public.languagetranslations custaglt
			on custaglm.languagemasterid = custaglt.languagetranslationmasterid
				and custaglt.languagetranslationtypeid  = templanguagetranslationtypeid
		inner join entity.entityinstance parent
			on parent.entityinstanceuuid = custag.entityinstanceparententityuuid
		inner join public.languagemaster parentlm
			on parent.entityinstancenameuuid = parentlm.languagemasteruuid
		left join public.languagetranslations parentlt
			on parentlm.languagemasterid = parentlt.languagetranslationmasterid	
				and parentlt.languagetranslationtypeid  = templanguagetranslationtypeid
		;	
return;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entitytag_read_api(uuid[],uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytag_read_api(uuid[],uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytag_read_api(uuid[],uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entitytag_read_api(uuid[],uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO graphql;

-- DEPENDANTS


-- Type: VIEW ; Name: entity_tag; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_tag AS
 SELECT entitytaguuid AS id,
    entitytagownerentityuuid AS owner,
    entitytagownername AS owner_name,
    entitytagentityinstanceentityuuid AS instance,
    entitytagentityinstanceentityname AS instance_name,
    entitytagentitytemplateentityuuid AS template,
    entitytagentitytemplatename AS template_name,
    entitytagcustagparententityuuid AS parent,
    entitytagparentcustagtype AS parent_name,
    entitytagcustagentityuuid AS customer_tag,
    entitytagcustagtype AS customer_tag_name,
    entitytagsenddeleted AS _deleted,
    entitytagsenddrafts AS _draft,
    entitytagsendinactive AS _active,
    entitytagstartdate AS activated_at,
    entitytagenddate AS deactivated_at,
    entitytagcreateddate AS created_at,
    entitytagmodifieddate AS updated_at,
    entitytagmodifiedbyuuid AS modified_by
   FROM ( SELECT crud_entitytag_read_api.languagetranslationtypeentityuuid,
            crud_entitytag_read_api.entitytaguuid,
            crud_entitytag_read_api.entitytagownerentityuuid,
            crud_entitytag_read_api.entitytagownername,
            crud_entitytag_read_api.entitytagentityinstanceentityuuid,
            crud_entitytag_read_api.entitytagentityinstanceentityname,
            crud_entitytag_read_api.entitytagentitytemplateentityuuid,
            crud_entitytag_read_api.entitytagentitytemplatename,
            crud_entitytag_read_api.entitytagcreateddate,
            crud_entitytag_read_api.entitytagmodifieddate,
            crud_entitytag_read_api.entitytagstartdate,
            crud_entitytag_read_api.entitytagenddate,
            crud_entitytag_read_api.entitytagrefid,
            crud_entitytag_read_api.entitytagrefuuid,
            crud_entitytag_read_api.entitytagmodifiedbyuuid,
            crud_entitytag_read_api.entitytagcustagparententityuuid,
            crud_entitytag_read_api.entitytagparentcustagtype,
            crud_entitytag_read_api.entitytagcustagentityuuid,
            crud_entitytag_read_api.entitytagcustagtype,
            crud_entitytag_read_api.entitytagsenddeleted,
            crud_entitytag_read_api.entitytagsenddrafts,
            crud_entitytag_read_api.entitytagsendinactive
           FROM entity.crud_entitytag_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entitytag_read_api(languagetranslationtypeentityuuid, entitytaguuid, entitytagownerentityuuid, entitytagownername, entitytagentityinstanceentityuuid, entitytagentityinstanceentityname, entitytagentitytemplateentityuuid, entitytagentitytemplatename, entitytagcreateddate, entitytagmodifieddate, entitytagstartdate, entitytagenddate, entitytagrefid, entitytagrefuuid, entitytagmodifiedbyuuid, entitytagcustagparententityuuid, entitytagparentcustagtype, entitytagcustagentityuuid, entitytagcustagtype, entitytagsenddeleted, entitytagsenddrafts, entitytagsendinactive)) entitytag
  WHERE (entitytagownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.entity_tag IS '
## Entity tag

A description of what an entity tag is and why it is used

';

CREATE TRIGGER create_entity_tag_tg INSTEAD OF INSERT ON api.entity_tag FOR EACH ROW EXECUTE FUNCTION api.create_entity_tag();
CREATE TRIGGER update_entity_tag_tg INSTEAD OF UPDATE ON api.entity_tag FOR EACH ROW EXECUTE FUNCTION api.update_entity_tag();

GRANT INSERT ON api.entity_tag TO authenticated;
GRANT SELECT ON api.entity_tag TO authenticated;
GRANT UPDATE ON api.entity_tag TO authenticated;

-- Type: FUNCTION ; Name: api.delete_entity_tag(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_tag(owner uuid, id uuid)
 RETURNS SETOF api.entity_tag
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
	  call entity.crud_entitytag_delete(
	      create_entitytagownerentityuuid := owner,
	      create_entitytagentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_tag t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_tag(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_tag(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_tag(uuid,uuid) TO authenticated;

END;
