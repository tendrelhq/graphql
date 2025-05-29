BEGIN;

/*
DROP FUNCTION api.delete_systag(uuid,uuid);
DROP FUNCTION api.delete_reason_code(uuid,uuid,text,text);
DROP FUNCTION api.delete_location(uuid,uuid);
DROP FUNCTION api.delete_entity_template(uuid,uuid);
DROP FUNCTION api.delete_entity_tag(uuid,uuid);
DROP FUNCTION api.delete_entity_instance(uuid,uuid);
DROP FUNCTION api.delete_entity_field(uuid,uuid);
DROP FUNCTION api.delete_entity_description(uuid,uuid);
DROP FUNCTION api.delete_customer_requested_language(uuid,text);
DROP FUNCTION api.delete_customer(uuid,uuid);
DROP FUNCTION api.delete_custag(uuid,uuid);
DROP VIEW api.entity_instance_field_ux;
DROP VIEW api.alltag;
DROP VIEW api.systag;
DROP VIEW api.reason_code;
DROP VIEW api.location;
DROP VIEW api.entity_template;
DROP VIEW api.entity_tag;
DROP VIEW api.entity_instance;
DROP VIEW api.entity_field;
DROP VIEW api.entity_description;
DROP VIEW api.customer_requested_language;
DROP VIEW api.customer;
DROP VIEW api.custag;

DROP FUNCTION _api.util_user_details();
*/


-- Type: FUNCTION ; Name: _api.util_user_details(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION _api.util_user_details()
 RETURNS TABLE(get_workerinstanceid bigint, get_workerinstanceuuid text, get_languagetypeid bigint, get_languagetypeuuid text, get_languagetypeentityuuid uuid)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
		tempworkerinstanceid bigint;
		tempworkerinstanceuuid text; 
		templanguagetypeid bigint; 
		templanguagetypeuuid text; 
		templanguagetypeentityuuid uuid;
begin

select workerinstanceid, workerinstanceuuid
into tempworkerinstanceid,tempworkerinstanceuuid
from  workerinstance
	inner join worker
		on workerid = workerinstanceworkerid
			and workeridentityid = ((current_setting('request.jwt.claims'::text, true)::json ->> 'sub'::text)::text)
order by workerinstancecustomerid asc limit 1;

select systagid,systaguuid, systagentityuuid
into templanguagetypeid,templanguagetypeuuid, templanguagetypeentityuuid
from entity.crud_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, '580f6ee2-42ca-4a5b-9e18-9ea0c168845a', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
where systagdisplayname = current_setting('user.preferred_language');

return query select tempworkerinstanceid, tempworkerinstanceuuid, templanguagetypeid, templanguagetypeuuid, templanguagetypeentityuuid;

return;

end 
$function$;


REVOKE ALL ON FUNCTION _api.util_user_details() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION _api.util_user_details() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION _api.util_user_details() TO authenticated;

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

-- Type: VIEW ; Name: customer; Owner: tendreladmin

CREATE OR REPLACE VIEW api.customer AS
 SELECT customer.customerid AS legacy_id,
    customer.customeruuid AS legacy_uuid,
    customer.customerentityuuid AS id,
    customer.customerownerentityuuid AS owner,
    customer.customerparententityuuid AS parent,
    parent.customername AS parent_name,
    customer.customercornerstoneentityuuid AS cornerstonename_id,
    customer.customercornerstoneorder AS _order,
    customer.customernameuuid AS name_id,
    customer.customername AS name,
    customer.customerdisplaynameuuid AS displayname_id,
    customer.customerdisplayname AS displayname,
    customer.customertypeentityuuid AS type_id,
    customer.customertype AS type,
    customer.customercreateddate AS created_at,
    customer.customermodifieddate AS updated_at,
    customer.customerstartdate AS activated_at,
    customer.customerenddate AS deactivated_at,
    customer.customermodifiedbyuuid AS modified_by,
    customer.customerexternalid AS external_id,
    customer.customerexternalsystementityuuid AS external_system,
    customer.customersenddeleted AS _deleted,
    customer.customersenddrafts AS _draft,
    customer.customersendinactive AS _active
   FROM entity.crud_customer_read_full(NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) customer(customerid, customeruuid, customerentityuuid, customerownerentityuuid, customerparententityuuid, customercornerstoneentityuuid, customercornerstoneorder, customernameuuid, customername, customerdisplaynameuuid, customerdisplayname, customertypeentityuuid, customertype, customercreateddate, customermodifieddate, customerstartdate, customerenddate, customermodifiedbyuuid, customerexternalid, customerexternalsystementityuuid, customerexternalsystemname, customerrefid, customerrefuuid, customerlanguagetypeentityuuid, customersenddeleted, customersenddrafts, customersendinactive)
     JOIN entity.crud_customer_read_full(NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) parent(customerid, customeruuid, customerentityuuid, customerownerentityuuid, customerparententityuuid, customercornerstoneentityuuid, customercornerstoneorder, customernameuuid, customername, customerdisplaynameuuid, customerdisplayname, customertypeentityuuid, customertype, customercreateddate, customermodifieddate, customerstartdate, customerenddate, customermodifiedbyuuid, customerexternalid, customerexternalsystementityuuid, customerexternalsystemname, customerrefid, customerrefuuid, customerlanguagetypeentityuuid, customersenddeleted, customersenddrafts, customersendinactive) ON customer.customerparententityuuid = parent.customerentityuuid
  WHERE (customer.customerownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.customer IS '
## Entity Template

A description of what an customer is and why it is used

### get {baseUrl}/customer

A bunch of comments explaining get

### del {baseUrl}/customer

A bunch of comments explaining del

### patch {baseUrl}/customer

A bunch of comments explaining patch
';

CREATE TRIGGER create_customer_tg INSTEAD OF INSERT ON api.customer FOR EACH ROW EXECUTE FUNCTION api.create_customer();
CREATE TRIGGER update_customer_tg INSTEAD OF UPDATE ON api.customer FOR EACH ROW EXECUTE FUNCTION api.update_customer();

GRANT INSERT ON api.customer TO authenticated;
GRANT SELECT ON api.customer TO authenticated;
GRANT UPDATE ON api.customer TO authenticated;

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

-- Type: VIEW ; Name: entity_description; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_description AS
 SELECT entitydescriptionuuid AS id,
    entitydescriptionownerentityuuid AS owner,
    entitydescriptionownerentityname AS owner_name,
    entitydescriptionentitytemplateentityuuid AS template,
    entitydescriptionentitytemplateentityname AS template_name,
    entitydescriptionentityfieldentityduuid AS field,
    entitydescriptionentityfieldentitydname AS field_name,
    entitydescriptionlanguagemasteruuid AS description_id,
    entitydescriptionname AS description,
    entitydescriptionsoplink AS sop_link,
    entitydescriptionfile AS file_link,
    entitydescriptionmimetypeuuid AS file_mime_type,
    entitydescriptionicon AS icon_link,
    entitydescriptionexternalid AS external_id,
    entitydescriptionexternalsystementityuuid AS external_system,
    entitydescriptiondeleted AS _deleted,
    entitydescriptiondraft AS _draft,
    entitydescriptionactive AS _active,
    entitydescriptionstartdate AS activated_at,
    entitydescriptionenddate AS deactivated_at,
    entitydescriptioncreateddate AS created_at,
    entitydescriptionmodifieddate AS updated_at,
    entitydescriptionmodifiedby AS modified_by
   FROM ( SELECT crud_entitydescription_read_full.languagetranslationtypeuuid,
            crud_entitydescription_read_full.entitydescriptionuuid,
            crud_entitydescription_read_full.entitydescriptionownerentityuuid,
            crud_entitydescription_read_full.entitydescriptionownerentityname,
            crud_entitydescription_read_full.entitydescriptionentitytemplateentityuuid,
            crud_entitydescription_read_full.entitydescriptionentitytemplateentityname,
            crud_entitydescription_read_full.entitydescriptionentityfieldentityduuid,
            crud_entitydescription_read_full.entitydescriptionentityfieldentitydname,
            crud_entitydescription_read_full.entitydescriptionname,
            crud_entitydescription_read_full.entitydescriptionlanguagemasteruuid,
            crud_entitydescription_read_full.entitydescriptionsoplink,
            crud_entitydescription_read_full.entitydescriptionfile,
            crud_entitydescription_read_full.entitydescriptionicon,
            crud_entitydescription_read_full.entitydescriptiontranslatedname,
            crud_entitydescription_read_full.entitydescriptioncreateddate,
            crud_entitydescription_read_full.entitydescriptionmodifieddate,
            crud_entitydescription_read_full.entitydescriptionstartdate,
            crud_entitydescription_read_full.entitydescriptionenddate,
            crud_entitydescription_read_full.entitydescriptionmodifiedby,
            crud_entitydescription_read_full.entitydescriptionexternalid,
            crud_entitydescription_read_full.entitydescriptionexternalsystementityuuid,
            crud_entitydescription_read_full.entitydescriptionrefid,
            crud_entitydescription_read_full.entitydescriptionrefuuid,
            crud_entitydescription_read_full.entitydescriptiondraft,
            crud_entitydescription_read_full.entitydescriptiondeleted,
            crud_entitydescription_read_full.entitydescriptionactive,
            crud_entitydescription_read_full.entitydescriptionmimetypeuuid,
            crud_entitydescription_read_full.entitydescriptionmimetypename
           FROM entity.crud_entitydescription_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entitydescription_read_full(languagetranslationtypeuuid, entitydescriptionuuid, entitydescriptionownerentityuuid, entitydescriptionownerentityname, entitydescriptionentitytemplateentityuuid, entitydescriptionentitytemplateentityname, entitydescriptionentityfieldentityduuid, entitydescriptionentityfieldentitydname, entitydescriptionname, entitydescriptionlanguagemasteruuid, entitydescriptionsoplink, entitydescriptionfile, entitydescriptionicon, entitydescriptiontranslatedname, entitydescriptioncreateddate, entitydescriptionmodifieddate, entitydescriptionstartdate, entitydescriptionenddate, entitydescriptionmodifiedby, entitydescriptionexternalid, entitydescriptionexternalsystementityuuid, entitydescriptionrefid, entitydescriptionrefuuid, entitydescriptiondraft, entitydescriptiondeleted, entitydescriptionactive, entitydescriptionmimetypeuuid, entitydescriptionmimetypename)) entitydescription
  WHERE (entitydescriptionownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.entity_description IS '
## Entity Template

A description of what an entity tempalte is and why it is used

### get {baseUrl}/entity_template

A bunch of comments explaining get

### del {baseUrl}/entity_template

A bunch of comments explaining del

### patch {baseUrl}/entity_template

A bunch of comments explaining patch
';

CREATE TRIGGER create_entity_description_tg INSTEAD OF INSERT ON api.entity_description FOR EACH ROW EXECUTE FUNCTION api.create_entity_description();
CREATE TRIGGER update_entity_description_tg INSTEAD OF UPDATE ON api.entity_description FOR EACH ROW EXECUTE FUNCTION api.update_entity_description();

GRANT INSERT ON api.entity_description TO authenticated;
GRANT SELECT ON api.entity_description TO authenticated;
GRANT UPDATE ON api.entity_description TO authenticated;

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

-- Type: VIEW ; Name: entity_instance; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_instance AS
 SELECT entityinstanceuuid AS id,
    entityinstanceownerentityuuid AS owner,
    entityinstanceownerentityname AS owner_name,
    entityinstanceparententityuuid AS parent,
    entityinstanceparententityname AS parent_name,
    entityinstanceentitytemplateentityuuid AS template,
    entityinstanceentitytemplatetranslatedname AS template_name,
    entityinstanceexternalid AS external_id,
    entityinstanceexternalsystementityuuid AS external_system,
    entityinstancescanid AS scan_code,
    entityinstancenameuuid AS name_id,
    entityinstancename AS name,
    entityinstancetypeentityuuid AS type,
    entityinstancetypeentityuuid AS type_name,
    entityinstancecornerstoneentityuuid AS cornerstone,
    entityinstancecornerstoneentitname AS cornerstone_name,
    entityinstancecornerstoneorder AS _order,
    entityinstancedeleted AS _deleted,
    entityinstancedraft AS _draft,
    entityinstanceactive AS _active,
    entityinstancestartdate AS activated_at,
    entityinstanceenddate AS deactivated_at,
    entityinstancecreateddate AS created_at,
    entityinstancemodifieddate AS updated_at,
    entityinstancemodifiedbyuuid AS modified_by
   FROM ( SELECT crud_entityinstance_read_api.languagetranslationtypeentityuuid,
            crud_entityinstance_read_api.entityinstanceoriginalid,
            crud_entityinstance_read_api.entityinstanceoriginaluuid,
            crud_entityinstance_read_api.entityinstanceuuid,
            crud_entityinstance_read_api.entityinstanceownerentityuuid,
            crud_entityinstance_read_api.entityinstanceownerentityname,
            crud_entityinstance_read_api.entityinstanceparententityuuid,
            crud_entityinstance_read_api.entityinstanceparententityname,
            crud_entityinstance_read_api.entityinstancecornerstoneentityuuid,
            crud_entityinstance_read_api.entityinstancecornerstoneentitname,
            crud_entityinstance_read_api.entityinstancecornerstoneorder,
            crud_entityinstance_read_api.entityinstanceentitytemplateentityuuid,
            crud_entityinstance_read_api.entityinstanceentitytemplatename,
            crud_entityinstance_read_api.entityinstanceentitytemplatetranslatedname,
            crud_entityinstance_read_api.entityinstancetypeentityuuid,
            crud_entityinstance_read_api.entityinstancetype,
            crud_entityinstance_read_api.entityinstancenameuuid,
            crud_entityinstance_read_api.entityinstancename,
            crud_entityinstance_read_api.entityinstancescanid,
            crud_entityinstance_read_api.entityinstancesiteentityuuid,
            crud_entityinstance_read_api.entityinstancecreateddate,
            crud_entityinstance_read_api.entityinstancemodifieddate,
            crud_entityinstance_read_api.entityinstancemodifiedbyuuid,
            crud_entityinstance_read_api.entityinstancestartdate,
            crud_entityinstance_read_api.entityinstanceenddate,
            crud_entityinstance_read_api.entityinstanceexternalid,
            crud_entityinstance_read_api.entityinstanceexternalsystementityuuid,
            crud_entityinstance_read_api.entityinstanceexternalsystementityname,
            crud_entityinstance_read_api.entityinstancerefid,
            crud_entityinstance_read_api.entityinstancerefuuid,
            crud_entityinstance_read_api.entityinstancedeleted,
            crud_entityinstance_read_api.entityinstancedraft,
            crud_entityinstance_read_api.entityinstanceactive,
            crud_entityinstance_read_api.entityinstancetagentityuuid
           FROM entity.crud_entityinstance_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entityinstance_read_api(languagetranslationtypeentityuuid, entityinstanceoriginalid, entityinstanceoriginaluuid, entityinstanceuuid, entityinstanceownerentityuuid, entityinstanceownerentityname, entityinstanceparententityuuid, entityinstanceparententityname, entityinstancecornerstoneentityuuid, entityinstancecornerstoneentitname, entityinstancecornerstoneorder, entityinstanceentitytemplateentityuuid, entityinstanceentitytemplatename, entityinstanceentitytemplatetranslatedname, entityinstancetypeentityuuid, entityinstancetype, entityinstancenameuuid, entityinstancename, entityinstancescanid, entityinstancesiteentityuuid, entityinstancecreateddate, entityinstancemodifieddate, entityinstancemodifiedbyuuid, entityinstancestartdate, entityinstanceenddate, entityinstanceexternalid, entityinstanceexternalsystementityuuid, entityinstanceexternalsystementityname, entityinstancerefid, entityinstancerefuuid, entityinstancedeleted, entityinstancedraft, entityinstanceactive, entityinstancetagentityuuid)) entityinstance;


CREATE TRIGGER create_entity_instance_tg INSTEAD OF INSERT ON api.entity_instance FOR EACH ROW EXECUTE FUNCTION api.create_entity_instance();
CREATE TRIGGER update_entity_instance_tg INSTEAD OF UPDATE ON api.entity_instance FOR EACH ROW EXECUTE FUNCTION api.update_entity_instance();

GRANT INSERT ON api.entity_instance TO authenticated;
GRANT SELECT ON api.entity_instance TO authenticated;
GRANT UPDATE ON api.entity_instance TO authenticated;

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

-- Type: VIEW ; Name: location; Owner: tendreladmin

CREATE OR REPLACE VIEW api.location AS
 SELECT location.locationid AS legacy_id,
    location.locationuuid AS legacy_uuid,
    location.locationentityuuid AS id,
    location.locationownerentityuuid AS owner,
    location.locationcustomername AS owner_name,
    location.locationparententityuuid AS parent,
    COALESCE(lt.languagetranslationvalue, lm.languagemastersource) AS parent_name,
    location.locationcornerstoneentityuuid AS cornerstone,
    location.locationnameuuid AS name_id,
    location.locationname AS name,
    location.locationdisplaynameuuid AS displayname_id,
    location.locationdisplayname AS displayname,
    location.locationscanid AS scan_code,
    location.locationcreateddate AS created_at,
    location.locationmodifieddate AS updated_at,
    location.locationmodifiedbyuuid AS modified_by,
    location.locationstartdate AS activated_at,
    location.locationenddate AS deactivated_at,
    location.locationexternalid AS external_id,
    location.locationexternalsystementityuuid AS external_system,
    location.locationcornerstoneorder AS _order,
    location.locationlatitude AS latitude,
    location.locationlongitude AS longitude,
    location.locationradius AS radius,
    location.locationtimezone AS timezone,
    location.locationtagentityuuid AS tag_id,
    location.locationsenddeleted AS _deleted,
    location.locationsenddrafts AS _draft,
    location.locationsendinactive AS _active,
        CASE
            WHEN location.locationparententityuuid = location.locationentityuuid THEN true
            ELSE false
        END AS _is_site,
        CASE
            WHEN location.locationcornerstoneentityuuid = location.locationentityuuid THEN true
            ELSE false
        END AS _is_cornerstone
   FROM entity.crud_location_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) location(languagetranslationtypeentityuuid, locationid, locationuuid, locationentityuuid, locationownerentityuuid, locationparententityuuid, locationcornerstoneentityuuid, locationcustomerid, locationcustomeruuid, locationcustomerentityuuid, locationcustomername, locationnameuuid, locationname, locationdisplaynameuuid, locationdisplayname, locationscanid, locationcreateddate, locationmodifieddate, locationmodifiedbyuuid, locationstartdate, locationenddate, locationexternalid, locationexternalsystementityuuid, locationexternalsystementname, locationcornerstoneorder, locationlatitude, locationlongitude, locationradius, locationtimezone, locationtagentityuuid, locationtagname, locationsenddeleted, locationsenddrafts, locationsendinactive)
     LEFT JOIN ( SELECT crud_location_read_min.languagetranslationtypeentityuuid,
            crud_location_read_min.locationid,
            crud_location_read_min.locationuuid,
            crud_location_read_min.locationentityuuid,
            crud_location_read_min.locationownerentityuuid,
            crud_location_read_min.locationparententityuuid,
            crud_location_read_min.locationcornerstoneentityuuid,
            crud_location_read_min.locationcustomerid,
            crud_location_read_min.locationcustomeruuid,
            crud_location_read_min.locationcustomerentityuuid,
            crud_location_read_min.locationnameuuid,
            crud_location_read_min.locationdisplaynameuuid,
            crud_location_read_min.locationscanid,
            crud_location_read_min.locationcreateddate,
            crud_location_read_min.locationmodifieddate,
            crud_location_read_min.locationmodifiedbyuuid,
            crud_location_read_min.locationstartdate,
            crud_location_read_min.locationenddate,
            crud_location_read_min.locationexternalid,
            crud_location_read_min.locationexternalsystementityuuid,
            crud_location_read_min.locationcornerstoneorder,
            crud_location_read_min.locationlatitude,
            crud_location_read_min.locationlongitude,
            crud_location_read_min.locationradius,
            crud_location_read_min.locationtimezone,
            crud_location_read_min.locationtagentityuuid,
            crud_location_read_min.locationsenddeleted,
            crud_location_read_min.locationsenddrafts,
            crud_location_read_min.locationsendinactive
           FROM entity.crud_location_read_min(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid) crud_location_read_min(languagetranslationtypeentityuuid, locationid, locationuuid, locationentityuuid, locationownerentityuuid, locationparententityuuid, locationcornerstoneentityuuid, locationcustomerid, locationcustomeruuid, locationcustomerentityuuid, locationnameuuid, locationdisplaynameuuid, locationscanid, locationcreateddate, locationmodifieddate, locationmodifiedbyuuid, locationstartdate, locationenddate, locationexternalid, locationexternalsystementityuuid, locationcornerstoneorder, locationlatitude, locationlongitude, locationradius, locationtimezone, locationtagentityuuid, locationsenddeleted, locationsenddrafts, locationsendinactive)) parent ON parent.locationentityuuid = location.locationparententityuuid
     LEFT JOIN languagemaster lm ON lm.languagemasteruuid = parent.locationnameuuid
     LEFT JOIN languagetranslations lt ON lt.languagetranslationmasterid = (( SELECT languagemaster.languagemasterid
           FROM languagemaster
          WHERE languagemaster.languagemasteruuid = parent.locationnameuuid)) AND lt.languagetranslationtypeid = (( SELECT crud_systag_read_min.systagid
           FROM entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid, NULL::uuid, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid)), NULL::uuid, false, NULL::boolean, NULL::boolean, NULL::boolean, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid) crud_systag_read_min(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagnameuuid, systagdisplaynameuuid, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagmodifiedbyuuid, systagabbreviationentityuuid, systagparententityuuid, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)))
  WHERE (location.locationownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.location IS '
## Location

A description of what an location is and why it is used

### get {baseUrl}/location

A bunch of comments explaining get

### del {baseUrl}/location

A bunch of comments explaining del

### patch {baseUrl}/location

A bunch of comments explaining patch
';

CREATE TRIGGER create_location_tg INSTEAD OF INSERT ON api.location FOR EACH ROW EXECUTE FUNCTION api.create_location();
CREATE TRIGGER update_location_tg INSTEAD OF UPDATE ON api.location FOR EACH ROW EXECUTE FUNCTION api.update_location();

GRANT INSERT ON api.location TO authenticated;
GRANT SELECT ON api.location TO authenticated;
GRANT UPDATE ON api.location TO authenticated;

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

-- Type: VIEW ; Name: entity_instance_field_ux; Owner: tendreladmin

CREATE OR REPLACE VIEW api.entity_instance_field_ux AS
 SELECT entityfieldinstanceuuid AS id,
    entityfieldinstanceentityinstanceentityuuid AS instance,
    entityfieldinstanceentityinstanceentityname AS instance_name,
    entityfieldinstanceownerentityuuid AS owner,
    entityfieldinstanceownerentityname AS owner_name,
    entityfieldinstancetemplateentityuuid AS template,
    entityfieldinstancetemplateentityname AS template_name,
    entityfieldinstancetemplateprimary AS template_primary,
    entityfieldinstanceentityfieldentityuuid AS field,
    entityfieldinstancetranslatedname AS field_name,
    entityfieldinstancetypeentityuuid AS type,
    entityfieldinstancetypename AS type_name,
    entityfieldinstanceentitytypeentityuuid AS entity_type,
    entityfieldinstanceentitytypename AS entity_type_name,
    entityfieldinstancevalue AS value,
    entityfieldinstancevaluelanguagemasteruuid AS value_id,
    entityfieldinstanceorder AS "order",
    entityfieldinstanceformatentityuuid AS format,
    entityfieldinstanceformatname AS format_name,
    entityfieldinstancewidgetentityuuid AS widget,
    entityfieldinstancewidgetname AS widget_name,
    entityfieldinstanceiscalculated AS _calculated,
    entityfieldinstanceiseditable AS _editable,
    entityfieldinstanceisvisible AS _visible,
    entityfieldinstanceisrequired AS _required,
    entityfieldinstanceisprimary AS _primary,
    entityfieldinstancetranslate AS _translate,
    entityfieldinstancedeleted AS _deleted,
    entityfieldinstancedraft AS _draft,
    entityfieldinstanceactive AS _active,
    entityfieldinstancestartdate AS activated_at,
    entityfieldinstanceenddate AS deactivated_at,
    entityfieldinstancecreateddate AS created_at,
    entityfieldinstancemodifieddate AS updated_at,
    entityfieldinstancemodifiedbyuuid AS modified_by
   FROM ( SELECT crud_entityfieldinstance_read_api.languagetranslationtypeentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceentityinstanceentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceentityinstanceentityname,
            crud_entityfieldinstance_read_api.entityfieldinstanceownerentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceownerentityname,
            crud_entityfieldinstance_read_api.entityfieldinstancetemplateentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancetemplateentityname,
            crud_entityfieldinstance_read_api.entityfieldinstancetemplateprimary,
            crud_entityfieldinstance_read_api.entityfieldinstanceentityfieldentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancetranslatedname,
            crud_entityfieldinstance_read_api.entityfieldinstancetypeentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancetypename,
            crud_entityfieldinstance_read_api.entityfieldinstanceentitytypeentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceentitytypename,
            crud_entityfieldinstance_read_api.entityfieldinstanceformatentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceformatname,
            crud_entityfieldinstance_read_api.entityfieldinstancewidgetentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancewidgetname,
            crud_entityfieldinstance_read_api.entityfieldinstancevalue,
            crud_entityfieldinstance_read_api.entityfieldinstancevaluelanguagemasteruuid,
            crud_entityfieldinstance_read_api.entityfieldinstanceorder,
            crud_entityfieldinstance_read_api.entityfieldinstanceiscalculated,
            crud_entityfieldinstance_read_api.entityfieldinstanceiseditable,
            crud_entityfieldinstance_read_api.entityfieldinstanceisvisible,
            crud_entityfieldinstance_read_api.entityfieldinstanceisrequired,
            crud_entityfieldinstance_read_api.entityfieldinstanceisprimary,
            crud_entityfieldinstance_read_api.entityfieldinstancetranslate,
            crud_entityfieldinstance_read_api.entityfieldinstancecreateddate,
            crud_entityfieldinstance_read_api.entityfieldinstancemodifieddate,
            crud_entityfieldinstance_read_api.entityfieldinstancestartdate,
            crud_entityfieldinstance_read_api.entityfieldinstanceenddate,
            crud_entityfieldinstance_read_api.entityfieldinstancemodifiedbyuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancerefid,
            crud_entityfieldinstance_read_api.entityfieldinstancerefuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancevaluelanguagetypeentityuuid,
            crud_entityfieldinstance_read_api.entityfieldinstancedeleted,
            crud_entityfieldinstance_read_api.entityfieldinstancedraft,
            crud_entityfieldinstance_read_api.entityfieldinstanceactive
           FROM entity.crud_entityfieldinstance_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_entityfieldinstance_read_api(languagetranslationtypeentityuuid, entityfieldinstanceuuid, entityfieldinstanceentityinstanceentityuuid, entityfieldinstanceentityinstanceentityname, entityfieldinstanceownerentityuuid, entityfieldinstanceownerentityname, entityfieldinstancetemplateentityuuid, entityfieldinstancetemplateentityname, entityfieldinstancetemplateprimary, entityfieldinstanceentityfieldentityuuid, entityfieldinstancetranslatedname, entityfieldinstancetypeentityuuid, entityfieldinstancetypename, entityfieldinstanceentitytypeentityuuid, entityfieldinstanceentitytypename, entityfieldinstanceformatentityuuid, entityfieldinstanceformatname, entityfieldinstancewidgetentityuuid, entityfieldinstancewidgetname, entityfieldinstancevalue, entityfieldinstancevaluelanguagemasteruuid, entityfieldinstanceorder, entityfieldinstanceiscalculated, entityfieldinstanceiseditable, entityfieldinstanceisvisible, entityfieldinstanceisrequired, entityfieldinstanceisprimary, entityfieldinstancetranslate, entityfieldinstancecreateddate, entityfieldinstancemodifieddate, entityfieldinstancestartdate, entityfieldinstanceenddate, entityfieldinstancemodifiedbyuuid, entityfieldinstancerefid, entityfieldinstancerefuuid, entityfieldinstancevaluelanguagetypeentityuuid, entityfieldinstancedeleted, entityfieldinstancedraft, entityfieldinstanceactive)) entityfieldinstance;


GRANT INSERT ON api.entity_instance_field_ux TO authenticated;
GRANT SELECT ON api.entity_instance_field_ux TO authenticated;
GRANT UPDATE ON api.entity_instance_field_ux TO authenticated;

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

-- Type: FUNCTION ; Name: api.delete_customer(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_customer(owner uuid, id uuid)
 RETURNS SETOF api.customer
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

--if (select owner in (select * from _api.util_get_onwership()) )
--	then  
	  call entity.crud_customer_delete(
	      create_customerownerentityuuid := owner,
	      create_customerentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
--	else
--		return;  -- need an exception here
--end if;

  return query
    select *
    from api.customer t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_customer(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_customer(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_customer(uuid,uuid) TO authenticated;

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

-- Type: FUNCTION ; Name: api.delete_entity_description(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_description(owner uuid, id uuid)
 RETURNS SETOF api.entity_description
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
	  call entity.crud_entitydescription_delete(
	      create_entitydescriptionownerentityuuid := owner,
	      create_entitydescriptionentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_description t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_description(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_description(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_description(uuid,uuid) TO authenticated;

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

-- Type: FUNCTION ; Name: api.delete_entity_instance(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_instance(owner uuid, id uuid)
 RETURNS SETOF api.entity_instance
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
	  call entity.crud_entityinstance_delete(
	      create_entityinstanceownerentityuuid := owner,
	      create_entityinstanceentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_instance t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_instance(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_instance(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_instance(uuid,uuid) TO authenticated;

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

-- Type: FUNCTION ; Name: api.delete_location(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_location(owner uuid, id uuid)
 RETURNS SETOF api.location
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
	  call entity.crud_location_delete(
	      create_locationownerentityuuid := owner,
	      create_locationentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.location t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_location(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_location(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_location(uuid,uuid) TO authenticated;

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
