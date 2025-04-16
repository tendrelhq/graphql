
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




if read_customersenddeleted isNull and read_customersenddeleted = false
	then tempcustomersenddeleted = Array[false];
	else tempcustomersenddeleted = Array[true,false];
end if;

if read_customersenddrafts isNull and read_customersenddrafts = false
	then tempcustomersenddrafts = Array[false];
	else tempcustomersenddrafts = Array[true,false];
end if;

if read_customersendinactive isNull and read_customersendinactive = false
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
		case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
			then false
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
		case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
			then false
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
		case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
			then false
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
		case when ei.entityinstanceenddate notnull and ei.entityinstanceenddate::Date < now()::date
			then false
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
