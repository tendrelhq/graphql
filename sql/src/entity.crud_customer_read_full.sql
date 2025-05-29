BEGIN;

/*
DROP FUNCTION api.delete_customer_requested_language(uuid,text);
DROP FUNCTION api.delete_customer(uuid,uuid);
DROP VIEW api.customer_requested_language;
DROP VIEW api.customer;

DROP FUNCTION entity.crud_customer_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_customer_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_customer_read_full(read_customerentityuuid uuid, read_customerownerentityuuid uuid, read_customerparententityuuid uuid, read_allcustomers boolean, read_customersenddeleted boolean, read_customersenddrafts boolean, read_customersendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(customerid bigint, customeruuid text, customerentityuuid uuid, customerownerentityuuid uuid, customerparententityuuid uuid, customercornerstoneentityuuid uuid, customercornerstoneorder integer, customernameuuid text, customername text, customerdisplaynameuuid text, customerdisplayname text, customertypeentityuuid uuid, customertype text, customercreateddate timestamp with time zone, customermodifieddate timestamp with time zone, customerstartdate timestamp with time zone, customerenddate timestamp with time zone, customermodifiedbyuuid text, customerexternalid text, customerexternalsystementityuuid uuid, customerexternalsystemname text, customerrefid bigint, customerrefuuid text, customerlanguagetypeentityuuid uuid, customersenddeleted boolean, customersenddrafts boolean, customersendinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare

	templanguagetypeid bigint;
	templanguagetypeuuid uuid;
	templanguagetypeentityuuid uuid;
	allowners boolean; 
	tempcustomersenddeleted boolean[];
	tempcustomersenddrafts boolean[];
	tempcustomersendinactive boolean[];
	tendreluuid uuid;
	englishuuid uuid;
BEGIN

-- Curently ignores language translation.  We should change this in the future for customer. 
-- Might want to add a parameter to send in active as a boolean

/*  Examples

-- specific customer
select * 
from entity.crud_customer_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null, false, null,null, null,null)

-- all customers
select * from entity.crud_customer_read_full(null,null, null, true, null,null, null,null)

select * from entity.crud_customer_read_full(null,null, null, true, null,null, null,null,null, null,'190d8c53-b076-460d-8c10-8ca35396429a')

-- customers to a specific owner
select * 
from entity.crud_customer_read_full(null,'f90d618d-5de7-4126-8c65-0afb700c6c61',null,false, null,null, null,null)

-- customers to a specific parent
select * 
from entity.crud_customer_read_full(null,null,'f90d618d-5de7-4126-8c65-0afb700c6c61',false,null,null, null, null)

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';
englishuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';

if read_languagetranslationtypeuuid isNull
	then templanguagetypeentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
	else templanguagetypeentityuuid = read_languagetranslationtypeuuid;
end if;

select systagid,systaguuid into templanguagetypeid,templanguagetypeuuid
	from entity.crud_systag_read_min(null, null, templanguagetypeentityuuid, null, false,null,null, null,templanguagetypeentityuuid);

if templanguagetypeid isNull
	then return;
end if;

if  read_customersenddeleted = false
	then tempcustomersenddeleted = Array[false];
	else tempcustomersenddeleted = Array[true,false];
end if;

if  read_customersenddrafts = false
	then tempcustomersenddrafts = Array[false];
	else tempcustomersenddrafts = Array[true,false];
end if;

if  read_customersendinactive = false
	then tempcustomersendinactive = Array[true];
	else tempcustomersendinactive = Array[true,false];
end if;		

if read_allcustomers = true
	then
	return query 
		select *
		from (SELECT 
	    ei.entityinstanceoriginalid as customerid,
	    ei.entityinstanceoriginaluuid as customeruuid,
	    ei.entityinstanceuuid as customerentityuuid,
	    ei.entityinstanceownerentityuuid as customerownerentityuuid,
	    ei.entityinstanceparententityuuid as customerparententityuuid,	
		ei.entityinstancecornerstoneentityuuid as customercornerstoneentityuuid,
		ei.entityinstancecornerstoneorder as customercornerstoneorder,
		entityinstancenameuuid as customernameuuid,
		COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS customername,
		dn.entityfieldinstancevaluelanguagemasteruuid as customerdisplaynameuuid,
		coalesce(lt.languagetranslationvalue,dn.entityfieldinstancevalue)  as customerdisplayname,  
	    custtype.entityfieldinstancevalue::uuid as customertypeentityuuid,
		etn.systagtype as customertype,
	    ei.entityinstancecreateddate as customercreateddate,
	    ei.entityinstancemodifieddate as customermodifieddate,
	    ei.entityinstancestartdate as customerstartdate,	
	    ei.entityinstanceenddate as customerenddate,
	    ei.entityinstancemodifiedbyuuid as customermodifiedbyuuid,
	    ei.entityinstanceexternalid as customerexternalid,
		ei.entityinstanceexternalsystementityuuid as customerexternalsystementityuuid, 
		sys.systagtype as customerexternalsystemname, 
		ei.entityinstancerefid as customerrefid,
		ei.entityinstancerefuuid as customerrefuuid,
		efi.entityfieldinstancevalue::uuid AS customerlanguagetypeuuid,
		ei.entityinstancedeleted, 
		ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
	from entity.entityinstance ei
		JOIN entity.entityfieldinstance efi 
			on ei.entityinstanceuuid = efi.entityfieldinstanceentityinstanceentityuuid
				and efi.entityfieldinstanceentityfieldname = 'customerlanguagetypeentityuuid'
				and ei.entityinstanceentitytemplatename = 'Customer'
				and ei.entityinstancedeleted = ANY (tempcustomersenddeleted)
				and ei.entityinstancedraft = ANY (tempcustomersenddrafts)
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,templanguagetypeentityuuid)) as sys
			on sys.systagentityuuid = ei.entityinstanceexternalsystementityuuid
		join entity.entityfieldinstance custtype
			on entityinstanceuuid = custtype.entityfieldinstanceentityinstanceentityuuid
				and custtype.entityfieldinstanceentityfieldname = 'customertypeuuid'
		inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,templanguagetypeentityuuid)) as etn
			on etn.systagentityuuid = custtype.entityfieldinstancevalue::uuid
		left join languagemaster namelm  -- this lm to lt pattern can probably become a function instead
			on ei.entityinstancenameuuid = namelm.languagemasteruuid
		left join public.languagetranslations namelt
				on namelt.languagetranslationmasterid  = namelm.languagemasterid
					and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, templanguagetypeentityuuid, null, false,null,null, null,englishuuid) as foo)
		join entity.entityfieldinstance dn
			on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'customerdisplayname'
		left join public.languagetranslations lt
			on lt.languagetranslationmasterid = (select languagemasterid 
													from public.languagemaster 
													where languagemasteruuid = dn.entityfieldinstancevaluelanguagemasteruuid)
				and lt.languagetranslationtypeid = templanguagetypeid) as foo
		where foo.entityinstanceactive = Any (tempcustomersendinactive) ;
		return;
end if;

if read_customerownerentityuuid notNull
then 
return query 
		select *
		from (SELECT 
	    ei.entityinstanceoriginalid as customerid,
	    ei.entityinstanceoriginaluuid as customeruuid,
	    ei.entityinstanceuuid as customerentityuuid,
	    ei.entityinstanceownerentityuuid as customerownerentityuuid,
	    ei.entityinstanceparententityuuid as customerparententityuuid,	
		ei.entityinstancecornerstoneentityuuid as customercornerstoneentityuuid,
		ei.entityinstancecornerstoneorder as customercornerstoneorder,
		entityinstancenameuuid as customernameuuid,
		COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS customername,
		dn.entityfieldinstancevaluelanguagemasteruuid as customerdisplaynameuuid,
		coalesce(lt.languagetranslationvalue,dn.entityfieldinstancevalue)  as customerdisplayname,  
	    custtype.entityfieldinstancevalue::uuid as customertypeentityuuid,
		etn.systagtype as customertype,
	    ei.entityinstancecreateddate as customercreateddate,
	    ei.entityinstancemodifieddate as customermodifieddate,
	    ei.entityinstancestartdate as customerstartdate,	
	    ei.entityinstanceenddate as customerenddate,
	    ei.entityinstancemodifiedbyuuid as customermodifiedbyuuid,
	    ei.entityinstanceexternalid as customerexternalid,
		ei.entityinstanceexternalsystementityuuid as customerexternalsystementityuuid, 
		sys.systagtype as customerexternalsystemname, 
		ei.entityinstancerefid as customerrefid,
		ei.entityinstancerefuuid as customerrefuuid,
		efi.entityfieldinstancevalue::uuid AS customerlanguagetypeuuid,
		ei.entityinstancedeleted, 
		ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
	from entity.entityinstance ei
		JOIN entity.entityfieldinstance efi 
			on ei.entityinstanceuuid = efi.entityfieldinstanceentityinstanceentityuuid
				and efi.entityfieldinstanceentityfieldname = 'customerlanguagetypeentityuuid'
				and ei.entityinstanceentitytemplatename = 'Customer'
				and ei.entityinstanceownerentityuuid = read_customerownerentityuuid
				and ei.entityinstancedeleted = ANY (tempcustomersenddeleted)
				and ei.entityinstancedraft = ANY (tempcustomersenddrafts)
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,templanguagetypeentityuuid)) as sys
			on sys.systagentityuuid = ei.entityinstanceexternalsystementityuuid
		join entity.entityfieldinstance custtype
			on entityinstanceuuid = custtype.entityfieldinstanceentityinstanceentityuuid
				and custtype.entityfieldinstanceentityfieldname = 'customertypeuuid'
		inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,templanguagetypeentityuuid)) as etn
			on etn.systagentityuuid = custtype.entityfieldinstancevalue::uuid
		left join languagemaster namelm  -- this lm to lt pattern can probably become a function instead
			on ei.entityinstancenameuuid = namelm.languagemasteruuid
		left join public.languagetranslations namelt
				on namelt.languagetranslationmasterid  = namelm.languagemasterid
					and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, templanguagetypeentityuuid, null, false,null,null, null,englishuuid) as foo)
		join entity.entityfieldinstance dn
			on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'customerdisplayname'
		left join public.languagetranslations lt
			on lt.languagetranslationmasterid = (select languagemasterid 
													from public.languagemaster 
													where languagemasteruuid = dn.entityfieldinstancevaluelanguagemasteruuid)
				and lt.languagetranslationtypeid = templanguagetypeid) as foo
		where foo.entityinstanceactive = Any (tempcustomersendinactive) ;
		return;
end if;

if read_customerparententityuuid notNull
then 
return query 
		select *
		from (SELECT 
	    ei.entityinstanceoriginalid as customerid,
	    ei.entityinstanceoriginaluuid as customeruuid,
	    ei.entityinstanceuuid as customerentityuuid,
	    ei.entityinstanceownerentityuuid as customerownerentityuuid,
	    ei.entityinstanceparententityuuid as customerparententityuuid,	
		ei.entityinstancecornerstoneentityuuid as customercornerstoneentityuuid,
		ei.entityinstancecornerstoneorder as customercornerstoneorder,
		entityinstancenameuuid as customernameuuid,
		COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS customername,
		dn.entityfieldinstancevaluelanguagemasteruuid as customerdisplaynameuuid,
		coalesce(lt.languagetranslationvalue,dn.entityfieldinstancevalue)  as customerdisplayname,  
	    custtype.entityfieldinstancevalue::uuid as customertypeentityuuid,
		etn.systagtype as customertype,
	    ei.entityinstancecreateddate as customercreateddate,
	    ei.entityinstancemodifieddate as customermodifieddate,
	    ei.entityinstancestartdate as customerstartdate,	
	    ei.entityinstanceenddate as customerenddate,
	    ei.entityinstancemodifiedbyuuid as customermodifiedbyuuid,
	    ei.entityinstanceexternalid as customerexternalid,
		ei.entityinstanceexternalsystementityuuid as customerexternalsystementityuuid, 
		sys.systagtype as customerexternalsystemname, 
		ei.entityinstancerefid as customerrefid,
		ei.entityinstancerefuuid as customerrefuuid,
		efi.entityfieldinstancevalue::uuid AS customerlanguagetypeuuid,
		ei.entityinstancedeleted, 
		ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
	from entity.entityinstance ei
		JOIN entity.entityfieldinstance efi 
			on ei.entityinstanceuuid = efi.entityfieldinstanceentityinstanceentityuuid
				and efi.entityfieldinstanceentityfieldname = 'customerlanguagetypeentityuuid'
				and ei.entityinstanceentitytemplatename = 'Customer'
				and ei.entityinstanceparententityuuid = read_customerparententityuuid
				and ei.entityinstancedeleted = ANY (tempcustomersenddeleted)
				and ei.entityinstancedraft = ANY (tempcustomersenddrafts)
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,templanguagetypeentityuuid)) as sys
			on sys.systagentityuuid = ei.entityinstanceexternalsystementityuuid
		join entity.entityfieldinstance custtype
			on entityinstanceuuid = custtype.entityfieldinstanceentityinstanceentityuuid
				and custtype.entityfieldinstanceentityfieldname = 'customertypeuuid'
		inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,templanguagetypeentityuuid)) as etn
			on etn.systagentityuuid = custtype.entityfieldinstancevalue::uuid
		left join languagemaster namelm  -- this lm to lt pattern can probably become a function instead
			on ei.entityinstancenameuuid = namelm.languagemasteruuid
		left join public.languagetranslations namelt
				on namelt.languagetranslationmasterid  = namelm.languagemasterid
					and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, templanguagetypeentityuuid, null, false,null,null, null,englishuuid) as foo)
		join entity.entityfieldinstance dn
			on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'customerdisplayname'
		left join public.languagetranslations lt
			on lt.languagetranslationmasterid = (select languagemasterid 
													from public.languagemaster 
													where languagemasteruuid = dn.entityfieldinstancevaluelanguagemasteruuid)
				and lt.languagetranslationtypeid = templanguagetypeid) as foo
		where foo.entityinstanceactive = Any (tempcustomersendinactive) ;
		return;
end if;

return query 
		select *
		from (SELECT 
	    ei.entityinstanceoriginalid as customerid,
	    ei.entityinstanceoriginaluuid as customeruuid,
	    ei.entityinstanceuuid as customerentityuuid,
	    ei.entityinstanceownerentityuuid as customerownerentityuuid,
	    ei.entityinstanceparententityuuid as customerparententityuuid,	
		ei.entityinstancecornerstoneentityuuid as customercornerstoneentityuuid,
		ei.entityinstancecornerstoneorder as customercornerstoneorder,
		entityinstancenameuuid as customernameuuid,
		COALESCE(namelt.languagetranslationvalue, namelm.languagemastersource) AS customername,
		dn.entityfieldinstancevaluelanguagemasteruuid as customerdisplaynameuuid,
		coalesce(lt.languagetranslationvalue,dn.entityfieldinstancevalue)  as customerdisplayname,  
	    custtype.entityfieldinstancevalue::uuid as customertypeentityuuid,
		etn.systagtype as customertype,
	    ei.entityinstancecreateddate as customercreateddate,
	    ei.entityinstancemodifieddate as customermodifieddate,
	    ei.entityinstancestartdate as customerstartdate,	
	    ei.entityinstanceenddate as customerenddate,
	    ei.entityinstancemodifiedbyuuid as customermodifiedbyuuid,
	    ei.entityinstanceexternalid as customerexternalid,
		ei.entityinstanceexternalsystementityuuid as customerexternalsystementityuuid, 
		sys.systagtype as customerexternalsystemname, 
		ei.entityinstancerefid as customerrefid,
		ei.entityinstancerefuuid as customerrefuuid,
		efi.entityfieldinstancevalue::uuid AS customerlanguagetypeuuid,
		ei.entityinstancedeleted, 
		ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
	from entity.entityinstance ei
		JOIN entity.entityfieldinstance efi 
			on ei.entityinstanceuuid = efi.entityfieldinstanceentityinstanceentityuuid
				and efi.entityfieldinstanceentityfieldname = 'customerlanguagetypeentityuuid'
				and entityinstanceuuid = read_customerentityuuid
				and ei.entityinstancedeleted = ANY (tempcustomersenddeleted)
				and ei.entityinstancedraft = ANY (tempcustomersenddrafts)
		left join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,templanguagetypeentityuuid)) as sys
			on sys.systagentityuuid = ei.entityinstanceexternalsystementityuuid
		join entity.entityfieldinstance custtype
			on entityinstanceuuid = custtype.entityfieldinstanceentityinstanceentityuuid
				and custtype.entityfieldinstanceentityfieldname = 'customertypeuuid'
		inner join (select * from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,templanguagetypeentityuuid)) as etn
			on etn.systagentityuuid = custtype.entityfieldinstancevalue::uuid
		left join languagemaster namelm  -- this lm to lt pattern can probably become a function instead
			on ei.entityinstancenameuuid = namelm.languagemasteruuid
		left join public.languagetranslations namelt
				on namelt.languagetranslationmasterid  = namelm.languagemasterid
					and namelt.languagetranslationtypeid = (select foo.systagid from entity.crud_systag_read_min(tendreluuid, null, templanguagetypeentityuuid, null, false,null,null, null,englishuuid) as foo)
		join entity.entityfieldinstance dn
			on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'customerdisplayname'
		left join public.languagetranslations lt
			on lt.languagetranslationmasterid = (select languagemasterid 
													from public.languagemaster 
													where languagemasteruuid = dn.entityfieldinstancevaluelanguagemasteruuid)
				and lt.languagetranslationtypeid = templanguagetypeid) as foo
		where foo.entityinstanceactive = Any (tempcustomersendinactive) ;
	return;
End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_customer_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_customer_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_customer_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_customer_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO graphql;

-- DEPENDANTS


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

END;
