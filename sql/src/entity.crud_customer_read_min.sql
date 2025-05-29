BEGIN;

/*
DROP FUNCTION entity.crud_customer_read_min(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_customer_read_min(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_customer_read_min(read_customerentityuuid uuid, read_customerownerentityuuid uuid, read_customerparententityuuid uuid, read_allcustomers boolean, read_customersenddeleted boolean, read_customersenddrafts boolean, read_customersendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(customerid bigint, customeruuid text, customerentityuuid uuid, customerownerentityuuid uuid, customerparententityuuid uuid, customercornerstoneentityuuid uuid, customercornerstoneorder integer, customernameuuid text, customerdisplaynameuuid text, customertypeentityuuid uuid, customercreateddate timestamp with time zone, customermodifieddate timestamp with time zone, customerstartdate timestamp with time zone, customerenddate timestamp with time zone, customermodifiedbyuuid text, customerexternalid text, customerexternalsystementityuuid uuid, customerlanguagetypeentityuuid uuid, customersenddeleted boolean, customersenddrafts boolean, customersendinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	tempcustomersenddeleted boolean[];
	tempcustomersenddrafts boolean[];
	tempcustomersendinactive boolean[];
	tendreluuid uuid;
BEGIN

-- Curently ignores language translation.  We should change this in the future for customer. 
-- Might want to add a parameter to send in active as a boolean

/*  Examples

-- specific customer
select * 
from entity.crud_customer_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null, false,null,null,null, null)
order by customeid desc

-- all customers
select * from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)

select * from entity.crud_customer_read_min(null,null, null, true, null,null,null,'190d8c53-b076-460d-8c10-8ca35396429a')

-- customers to a specific owner
select * 
from entity.crud_customer_read_min(null,'f90d618d-5de7-4126-8c65-0afb700c6c61',null,false,null,null,null, null)

-- customers to a specific parent
select * 
from entity.crud_customer_read_min(null,null,'f90d618d-5de7-4126-8c65-0afb700c6c61',false, null,null,null,null)

*/

if  read_customersenddeleted = false
	then tempcustomersenddeleted = Array[false];
	else tempcustomersenddeleted = Array[true,false];
end if;

if  read_customersenddrafts = false
	then tempcustomersenddrafts = Array[false];
	else tempcustomersenddrafts = Array[true,false];
end if;

if   read_customersendinactive = false
	then tempcustomersendinactive = Array[true];
	else tempcustomersendinactive = Array[true,false];
end if;

if read_allcustomers = true
	then
	return query 
		select *
		from (SELECT 
	    entityinstanceoriginalid as customerid,
	    entityinstanceoriginaluuid as customeruuid,
	    entityinstanceuuid as customerentityuuid,
	    entityinstanceownerentityuuid as customerownerentityuuid,
	    entityinstanceparententityuuid as customerparententityuuid,
		entityinstancecornerstoneentityuuid as customercornerstoneentityuuid,
		entityinstancecornerstoneorder as customercornerstoneorder,
		entityinstancenameuuid as customernameuuid,
		dn.entityfieldinstancevaluelanguagemasteruuid as customerdisplaynameuuid,
	    custtype.entityfieldinstancevalue::uuid as customertypeentityuuid,
	    entityinstancecreateddate as customercreateddate,
	    entityinstancemodifieddate as customermodifieddate,
	    entityinstancestartdate as customerstartdate,	
	    entityinstanceenddate as customerenddate,
	    entityinstancemodifiedbyuuid as customermodifiedbyuuid,
	    entityinstanceexternalid as customerexternalid,
	    entityinstanceexternalsystementityuuid as customerexternalsystementityid,
		efi.entityfieldinstancevalue::uuid AS customerlanguagetypeentityuuid,
		entityinstancedeleted, 
		entityinstancedraft,
	case when entityinstancedeleted then false
			when entityinstancedraft then false
			when entityinstanceenddate::Date > now()::date 
				and entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
	from entity.entityinstance
		JOIN entity.entityfieldinstance efi 
			on entityinstanceuuid = efi.entityfieldinstanceentityinstanceentityuuid
				and efi.entityfieldinstanceentityfieldname = 'customerlanguagetypeentityuuid'
				and entityinstanceentitytemplatename = 'Customer'
				and entityinstancedeleted = ANY (tempcustomersenddeleted)
				and entityinstancedraft = ANY (tempcustomersenddrafts)
		join entity.entityfieldinstance custtype
			on entityinstanceuuid = custtype.entityfieldinstanceentityinstanceentityuuid
				and custtype.entityfieldinstanceentityfieldname = 'customertypeuuid'
		join entity.entityfieldinstance dn
			on entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'customerdisplayname') as foo
		where foo.entityinstanceactive = Any (tempcustomersendinactive) ;
		return;
end if;

if read_customerownerentityuuid notNull
then 
	return query 
		select *
		from (SELECT 
	    entityinstanceoriginalid as customerid,
	    entityinstanceoriginaluuid as customeruuid,
	    entityinstanceuuid as customerentityuuid,
	    entityinstanceownerentityuuid as customerownerentityuuid,
	    entityinstanceparententityuuid as customerparententityuuid,
		entityinstancecornerstoneentityuuid as customercornerstoneentityuuid,
		entityinstancecornerstoneorder as customercornerstoneorder,
		entityinstancenameuuid as customernameuuid,
		dn.entityfieldinstancevaluelanguagemasteruuid as customerdisplaynameuuid,
	    custtype.entityfieldinstancevalue::uuid as customertypeentityuuid,
	    entityinstancecreateddate as customercreateddate,
	    entityinstancemodifieddate as customermodifieddate,
	    entityinstancestartdate as customerstartdate,	
	    entityinstanceenddate as customerenddate,
	    entityinstancemodifiedbyuuid as customermodifiedbyuuid,
	    entityinstanceexternalid as customerexternalid,
	    entityinstanceexternalsystementityuuid as customerexternalsystementityid,
		efi.entityfieldinstancevalue::uuid AS customerlanguagetypeentityuuid,
		entityinstancedeleted, 
		entityinstancedraft,
	case when entityinstancedeleted then false
			when entityinstancedraft then false
			when entityinstanceenddate::Date > now()::date 
				and entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
	from entity.entityinstance
		JOIN entity.entityfieldinstance efi 
			on entityinstanceuuid = efi.entityfieldinstanceentityinstanceentityuuid
				and efi.entityfieldinstanceentityfieldname = 'customerlanguagetypeentityuuid'
				and entityinstanceentitytemplatename = 'Customer'
				and entityinstanceownerentityuuid = read_customerownerentityuuid
				and entityinstancedeleted = ANY (tempcustomersenddeleted)
				and entityinstancedraft = ANY (tempcustomersenddrafts)
		join entity.entityfieldinstance custtype
			on entityinstanceuuid = custtype.entityfieldinstanceentityinstanceentityuuid
				and custtype.entityfieldinstanceentityfieldname = 'customertypeuuid'
		join entity.entityfieldinstance dn
			on entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'customerdisplayname') as foo
		where foo.entityinstanceactive = Any (tempcustomersendinactive) ;
		return;
end if;

if read_customerparententityuuid notNull
then 
	return query 
		select *
		from (SELECT 
	    entityinstanceoriginalid as customerid,
	    entityinstanceoriginaluuid as customeruuid,
	    entityinstanceuuid as customerentityuuid,
	    entityinstanceownerentityuuid as customerownerentityuuid,
	    entityinstanceparententityuuid as customerparententityuuid,
		entityinstancecornerstoneentityuuid as customercornerstoneentityuuid,
		entityinstancecornerstoneorder as customercornerstoneorder,
		entityinstancenameuuid as customernameuuid,
		dn.entityfieldinstancevaluelanguagemasteruuid as customerdisplaynameuuid,
	    custtype.entityfieldinstancevalue::uuid as customertypeentityuuid,
	    entityinstancecreateddate as customercreateddate,
	    entityinstancemodifieddate as customermodifieddate,
	    entityinstancestartdate as customerstartdate,	
	    entityinstanceenddate as customerenddate,
	    entityinstancemodifiedbyuuid as customermodifiedbyuuid,
	    entityinstanceexternalid as customerexternalid,
	    entityinstanceexternalsystementityuuid as customerexternalsystementityid,
		efi.entityfieldinstancevalue::uuid AS customerlanguagetypeentityuuid,
		entityinstancedeleted, 
		entityinstancedraft,
	case when entityinstancedeleted then false
			when entityinstancedraft then false
			when entityinstanceenddate::Date > now()::date 
				and entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
	from entity.entityinstance
		JOIN entity.entityfieldinstance efi 
			on entityinstanceuuid = efi.entityfieldinstanceentityinstanceentityuuid
				and efi.entityfieldinstanceentityfieldname = 'customerlanguagetypeentityuuid'
				and entityinstanceentitytemplatename = 'Customer'
				and entityinstanceparententityuuid = read_customerparententityuuid
				and entityinstancedeleted = ANY (tempcustomersenddeleted)
				and entityinstancedraft = ANY (tempcustomersenddrafts)
		join entity.entityfieldinstance custtype
			on entityinstanceuuid = custtype.entityfieldinstanceentityinstanceentityuuid
				and custtype.entityfieldinstanceentityfieldname = 'customertypeuuid'
		join entity.entityfieldinstance dn
			on entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'customerdisplayname') as foo
		where foo.entityinstanceactive = Any (tempcustomersendinactive) ;
		return;
end if;

return query 
		select *
		from (SELECT 
	    entityinstanceoriginalid as customerid,
	    entityinstanceoriginaluuid as customeruuid,
	    entityinstanceuuid as customerentityuuid,
	    entityinstanceownerentityuuid as customerownerentityuuid,
	    entityinstanceparententityuuid as customerparententityuuid,
		entityinstancecornerstoneentityuuid as customercornerstoneentityuuid,
		entityinstancecornerstoneorder as customercornerstoneorder,
		entityinstancenameuuid as customernameuuid,
		dn.entityfieldinstancevaluelanguagemasteruuid as customerdisplaynameuuid,
	    custtype.entityfieldinstancevalue::uuid as customertypeentityuuid,
	    entityinstancecreateddate as customercreateddate,
	    entityinstancemodifieddate as customermodifieddate,
	    entityinstancestartdate as customerstartdate,	
	    entityinstanceenddate as customerenddate,
	    entityinstancemodifiedbyuuid as customermodifiedbyuuid,
	    entityinstanceexternalid as customerexternalid,
	    entityinstanceexternalsystementityuuid as customerexternalsystementityid,
		efi.entityfieldinstancevalue::uuid AS customerlanguagetypeentityuuid,
		entityinstancedeleted, 
		entityinstancedraft,
	case when entityinstancedeleted then false
			when entityinstancedraft then false
			when entityinstanceenddate::Date > now()::date 
				and entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
	from entity.entityinstance
		JOIN entity.entityfieldinstance efi 
			on entityinstanceuuid = efi.entityfieldinstanceentityinstanceentityuuid
				and efi.entityfieldinstanceentityfieldname = 'customerlanguagetypeentityuuid'
				and entityinstanceuuid = read_customerentityuuid
				and entityinstancedeleted = ANY (tempcustomersenddeleted)
				and entityinstancedraft = ANY (tempcustomersenddrafts)
		join entity.entityfieldinstance custtype
			on entityinstanceuuid = custtype.entityfieldinstanceentityinstanceentityuuid
				and custtype.entityfieldinstanceentityfieldname = 'customertypeuuid'
		join entity.entityfieldinstance dn
			on entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'customerdisplayname') as foo
		where foo.entityinstanceactive = Any (tempcustomersendinactive) ;
		return;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_customer_read_min(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_customer_read_min(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_customer_read_min(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_customer_read_min(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO graphql;

END;
