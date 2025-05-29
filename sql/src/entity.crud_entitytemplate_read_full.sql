BEGIN;

/*
DROP FUNCTION api.delete_entity_template(uuid,uuid);
DROP FUNCTION api.delete_entity_field(uuid,uuid);
DROP VIEW api.entity_template;
DROP VIEW api.entity_field;

DROP FUNCTION entity.crud_entitytemplate_read_full(uuid,uuid,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_entitytemplate_read_full(uuid,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entitytemplate_read_full(read_ownerentityuuid uuid, read_entitytemplateentityuuid uuid, read_entitytemplatesenddeleted boolean, read_entitytemplatesenddrafts boolean, read_entitytemplatesendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(languagetranslationtypeuuid uuid, entitytemplateuuid uuid, entitytemplateownerentityuuid uuid, entitytemplatecustomername text, entitytemplateparententityuuid uuid, entitytemplatesitename text, entitytemplatetypeentityuuid uuid, entitytemplatetype text, entitytemplateisprimary boolean, entitytemplatescanid text, entitytemplatenameuuid text, entitytemplatename text, entitytemplateorder integer, entitytemplatemodifiedbyuuid text, entitytemplatemodifiedby text, entitytemplatestartdate timestamp with time zone, entitytemplateenddate timestamp with time zone, entitytemplatecreateddate timestamp with time zone, entitytemplatemodifieddate timestamp with time zone, entitytemplateexternalid text, entitytemplaterefid bigint, entitytemplaterefuuid text, entitytemplateexternalsystementityuuid uuid, entitytemplateexternalsystem text, entitytemplatedeleted boolean, entitytemplatedraft boolean, entitytemplateactive boolean)
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

-- all customers no entity template
select * from entity.crud_entitytemplate_read_full(null, null, null, null, null,null)

-- specific customer no entity template
select * from entity.crud_entitytemplate_read_full(	'f90d618d-5de7-4126-8c65-0afb700c6c61',null, null, null, null,null)

-- specific entity template
select * 
from entity.crud_entitytemplate_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','957df2f9-051f-4af5-95ee-ea3760fbb83b',	null, null, null,null)

-- negative test - empty or wrong cutomer returns nothing
select * 
from entity.crud_entitytemplate_read_full(null,'957df2f9-051f-4af5-95ee-ea3760fbb83b',null, null, null,	null)

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if read_languagetranslationtypeuuid isNull
	then read_languagetranslationtypeuuid = (
		select systagentityuuid 
		from entity.crud_systag_read_min(tendreluuid, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,read_languagetranslationtypeuuid)
		); 
end if;

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if  read_entitytemplatesenddeleted = false
	then tempentitytemplatesenddeleted = Array[false];
	else tempentitytemplatesenddeleted = Array[true,false];
end if;

if  read_entitytemplatesenddrafts = false
	then tempentitytemplatesenddrafts = Array[false];
	else tempentitytemplatesenddrafts = Array[true,false];
end if;

if   read_entitytemplatesendinactive = false
	then tempentitytemplatesendinactive = Array[true];
	else tempentitytemplatesendinactive = Array[true,false];
end if;

-- probably can do this cealner with less sql

if allowners = true and (read_entitytemplateentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			et.entitytemplateuuid, 
			et.entitytemplateownerentityuuid, 
			cust.customername,
			et.entitytemplateparententityuuid,
			parentn.languagemastersource as parentname,	
			et.entitytemplatetypeentityuuid,
			enttype.systagname as entitytemplatetype,
			et.entitytemplateisprimary,
			et.entitytemplatescanid,
			et.entitytemplatenameuuid,
			COALESCE(entlt.languagetranslationvalue, entlm.languagemastersource),
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
	case when et.entitytemplatedeleted then false
			when et.entitytemplatedraft then false
			when et.entitytemplateenddate::Date > now()::date 
				and et.entitytemplatestartdate < now() then false
			else true
	end as entitytemplateactive
		from entity.entitytemplate et
			inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as cust
				on cust.customerentityuuid = et.entitytemplateownerentityuuid
					and et.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				 	and et.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)
			left join (select * from entity.crud_entitytemplate_read_min(null, null, null, null, null,null)) as parent
				on parent.entitytemplateuuid = et.entitytemplateparententityuuid
			left join languagemaster parentn
				on parentn.languagemasteruuid = parent.entitytemplatenameuuid
			inner join (select * from entity.crud_systag_read_full(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,read_languagetranslationtypeuuid)) as enttype
				on et.entitytemplatetypeentityuuid = enttype.systagentityuuid
			inner join languagemaster entlm
				on et.entitytemplatenameuuid = entlm.languagemasteruuid
			left join public.languagetranslations entlt
				on entlt.languagetranslationmasterid  = entlm.languagemasterid
					and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, read_languagetranslationtypeuuid, null, false,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,read_languagetranslationtypeuuid)) 
			left join workerinstance workerint
				on workerint.workerinstanceuuid = et.entitytemplatemodifiedbyuuid 
			left join worker templatemodby
				on templatemodby.workerid = workerint.workerinstanceworkerid
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,read_languagetranslationtypeuuid)) as systemtype
				on et.entitytemplateexternalsystementityuuid = systemtype.systagentityuuid) as foo
		where foo.entitytemplateactive = Any (tempentitytemplatesendinactive);
		return;
end if;

if allowners = false and (read_entitytemplateentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			et2.entitytemplateuuid, 
			et2.entitytemplateownerentityuuid, 
			cust.customername,
			et2.entitytemplateparententityuuid,
			parentn.languagemastersource as parentname,
			et2.entitytemplatetypeentityuuid,
			enttype.systagtype as entitytemplatetype,
			et2.entitytemplateisprimary,
			et2.entitytemplatescanid,
			et2.entitytemplatenameuuid,
			COALESCE(entlt.languagetranslationvalue, entlm.languagemastersource),
			et2.entitytemplateorder, 
			et2.entitytemplatemodifiedbyuuid,
			templatemodby.workerfullname as templatemodifiedby,
			et2.entitytemplatestartdate, 
			et2.entitytemplateenddate, 
			et2.entitytemplatecreateddate, 
			et2.entitytemplatemodifieddate, 
			et2.entitytemplateexternalid, 
			et2.entitytemplaterefid, 
			et2.entitytemplaterefuuid,
			et2.entitytemplateexternalsystementityuuid, 
			systemtype.systagtype as externalsystem,
				et2.entitytemplatedeleted,
				et2.entitytemplatedraft,
	case when et2.entitytemplatedeleted then false
			when et2.entitytemplatedraft then false
			when et2.entitytemplateenddate::Date > now()::date 
				and et2.entitytemplatestartdate < now() then false
			else true
	end as entitytemplateactive
		from entity.entitytemplate et2
			inner join (select * from entity.crud_customer_read_full(null, null,null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as cust
				on cust.customerentityuuid = et2.entitytemplateownerentityuuid
					and et2.entitytemplateownerentityuuid = read_ownerentityuuid
					and et2.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				 	and et2.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)
			left join (select * from entity.crud_entitytemplate_read_min(null, null, null, null, null,null)) as parent
				on parent.entitytemplateuuid = et.entitytemplateparententityuuid
			left join languagemaster parentn
				on parentn.languagemasteruuid = parent.entitytemplatenameuuid
			inner join (select * from entity.crud_systag_read_full(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,read_languagetranslationtypeuuid)) as enttype
				on et.entitytemplatetypeentityuuid = enttype.systagentityuuid
			inner join languagemaster entlm
				on et2.entitytemplatenameuuid = entlm.languagemasteruuid
			left join public.languagetranslations entlt
				on entlt.languagetranslationmasterid  = entlm.languagemasterid
					and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, read_languagetranslationtypeuuid, null, false,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,read_languagetranslationtypeuuid)) 
			left join workerinstance workerint
				on workerint.workerinstanceuuid = et2.entitytemplatemodifiedbyuuid 
			left join worker templatemodby
				on templatemodby.workerid = workerint.workerinstanceworkerid
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,read_languagetranslationtypeuuid)) as systemtype
				on et2.entitytemplateexternalsystementityuuid = systemtype.systagentityuuid) as foo
		where foo.entitytemplateactive = Any (tempentitytemplatesendinactive);
		return;
end if;

if allowners = false and (read_entitytemplateentityuuid notNull)
	then
		return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			et3.entitytemplateuuid, 
			et3.entitytemplateownerentityuuid, 
			cust.customername,
			et3.entitytemplateparententityuuid,
			parentn.languagemastersource as parentname,
			et3.entitytemplatetypeentityuuid,
			enttype.systagtype as entitytemplatetype,
			et3.entitytemplateisprimary,
			et3.entitytemplatescanid,
			et3.entitytemplatenameuuid,
			COALESCE(entlt.languagetranslationvalue, entlm.languagemastersource),
			et3.entitytemplateorder, 
			et3.entitytemplatemodifiedbyuuid,
			templatemodby.workerfullname as templatemodifiedby,
			et3.entitytemplatestartdate, 
			et3.entitytemplateenddate, 
			et3.entitytemplatecreateddate, 
			et3.entitytemplatemodifieddate, 
			et3.entitytemplateexternalid, 
			et3.entitytemplaterefid, 
			et3.entitytemplaterefuuid,
			et3.entitytemplateexternalsystementityuuid, 
			systemtype.systagtype as externalsystem,
				et3.entitytemplatedeleted,
				et3.entitytemplatedraft,
	case when et3.entitytemplatedeleted then false
			when et3.entitytemplatedraft then false
			when et3.entitytemplateenddate::Date > now()::date 
				and et3.entitytemplatestartdate < now() then false
			else true
	end as entitytemplateactive
		from entity.entitytemplate et3
			inner join (select * from entity.crud_customer_read_full(null, null, null,true,read_entitytemplatesenddeleted,read_entitytemplatesenddrafts,read_entitytemplatesendinactive, null)) as cust
				on cust.customerentityuuid = et3.entitytemplateownerentityuuid
					and (et3.entitytemplateownerentityuuid = read_ownerentityuuid
						or et3.entitytemplateownerentityuuid = tendreluuid)
					and et3.entitytemplateuuid = read_entitytemplateentityuuid
					and et3.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				 	and et3.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)
			left join (select * from entity.crud_entitytemplate_read_min(null, null, null, null, null,null)) as parent
				on parent.entitytemplateuuid = et.entitytemplateparententityuuid
			left join languagemaster parentn
				on parentn.languagemasteruuid = parent.entitytemplatenameuuid
			inner join (select * from entity.crud_systag_read_full(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,read_languagetranslationtypeuuid)) as enttype
				on et.entitytemplatetypeentityuuid = enttype.systagentityuuid
			inner join languagemaster entlm
				on et3.entitytemplatenameuuid = entlm.languagemasteruuid
			left join public.languagetranslations entlt
				on entlt.languagetranslationmasterid  = entlm.languagemasterid
					and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, read_languagetranslationtypeuuid, null, false,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,read_languagetranslationtypeuuid)) 
			left join workerinstance workerint
				on workerint.workerinstanceuuid = et3.entitytemplatemodifiedbyuuid 
			left join worker templatemodby
				on templatemodby.workerid = workerint.workerinstanceworkerid
			left join (select * from entity.crud_systag_read_min(null,null,null, null, true,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,read_languagetranslationtypeuuid)) as systemtype
				on et3.entitytemplateexternalsystementityuuid = systemtype.systagentityuuid ) as foo
		where foo.entitytemplateactive = Any (tempentitytemplatesendinactive);
		return;
end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entitytemplate_read_full(uuid,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytemplate_read_full(uuid,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytemplate_read_full(uuid,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entitytemplate_read_full(uuid,uuid,boolean,boolean,boolean,uuid) TO graphql;

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

-- Type: VIEW ; Name: entity_template; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_template AS
 SELECT entitytemplateuuid AS id,
    entitytemplateownerentityuuid AS owner,
    entitytemplatecustomername AS owner_name,
    entitytemplateparententityuuid AS parent,
    entitytemplatesitename AS parent_name,
    entitytemplateexternalid AS external_id,
    entitytemplateexternalsystementityuuid AS external_system,
    entitytemplatescanid AS scan_code,
    entitytemplatenameuuid AS name_id,
    entitytemplatename AS name,
    entitytemplatetypeentityuuid AS type,
    entitytemplatetype AS type_name,
    entitytemplateorder AS _order,
    entitytemplateisprimary AS _primary,
    entitytemplatedeleted AS _deleted,
    entitytemplatedraft AS _draft,
    entitytemplateactive AS _active,
    entitytemplatestartdate AS activated_at,
    entitytemplateenddate AS deactivated_at,
    entitytemplatecreateddate AS created_at,
    entitytemplatemodifieddate AS updated_at,
    entitytemplatemodifiedbyuuid AS modified_by
   FROM ( SELECT crud_entitytemplate_read_full.languagetranslationtypeuuid,
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
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entitytemplate_read_full(languagetranslationtypeuuid, entitytemplateuuid, entitytemplateownerentityuuid, entitytemplatecustomername, entitytemplateparententityuuid, entitytemplatesitename, entitytemplatetypeentityuuid, entitytemplatetype, entitytemplateisprimary, entitytemplatescanid, entitytemplatenameuuid, entitytemplatename, entitytemplateorder, entitytemplatemodifiedbyuuid, entitytemplatemodifiedby, entitytemplatestartdate, entitytemplateenddate, entitytemplatecreateddate, entitytemplatemodifieddate, entitytemplateexternalid, entitytemplaterefid, entitytemplaterefuuid, entitytemplateexternalsystementityuuid, entitytemplateexternalsystem, entitytemplatedeleted, entitytemplatedraft, entitytemplateactive)) entitytemplate
  WHERE (entitytemplateownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership))) OR entitytemplateownerentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid AND entitytemplateisprimary = true;

COMMENT ON VIEW api.entity_template IS '
## Entity Template

A description of what an entity tempalte is and why it is used

### get {baseUrl}/entity_template

A bunch of comments explaining get

### del {baseUrl}/entity_template

A bunch of comments explaining del

### patch {baseUrl}/entity_template

A bunch of comments explaining patch
';

CREATE TRIGGER create_entity_template_tg INSTEAD OF INSERT ON api.entity_template FOR EACH ROW EXECUTE FUNCTION api.create_entity_template();
CREATE TRIGGER update_entity_template_tg INSTEAD OF UPDATE ON api.entity_template FOR EACH ROW EXECUTE FUNCTION api.update_entity_template();

GRANT INSERT ON api.entity_template TO authenticated;
GRANT SELECT ON api.entity_template TO authenticated;
GRANT UPDATE ON api.entity_template TO authenticated;

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

-- Type: FUNCTION ; Name: api.delete_entity_template(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_template(owner uuid, id uuid)
 RETURNS SETOF api.entity_template
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
	  call entity.crud_entitytemplate_delete(
	      create_entitytemplateownerentityuuid := owner,
	      create_entitytemplateentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_template t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_template(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_template(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_template(uuid,uuid) TO authenticated;

END;
