
-- Type: FUNCTION ; Name: entity.func_dim_languagetranslation_read_min(uuid,uuid); Owner: bombadil

CREATE OR REPLACE FUNCTION entity.func_dim_languagetranslation_read_min(read_dim_dimcustomeruuid uuid, read_dim_dimlanguagetranslationtypeuuid uuid)
 RETURNS TABLE(dim_dimlanguatetypeid text, dim_languagetypeid bigint, dim_languagetypeshortname text, dim_languagetypelongname text, dim_languagetranslationtypeid bigint, dim_languagetypecreateddate timestamp with time zone, dim_languagetypemodifieddate timestamp with time zone, dim_languagetypestartdate timestamp with time zone, dim_languagetypeenddate timestamp with time zone, dim_languagetypeuuid text, dim_dimlanguatetypeuuid uuid, dim_languagetypeentityuuid uuid, dim_languagetranslationshortnameuuid text, dim_languagetranslationlongnameuuid text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare

BEGIN

/*  Examples

-- specific customer all languages
select * 
from entity.func_dim_languagetranslation_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61','d279129c-ca61-4fbb-b4fa-f61426c7ecec')

-- d279129c-ca61-4fbb-b4fa-f61426c7ecec -- english
-- f26c1e47-e2b2-4193-80db-4b57dbf0ee4f -- spanish
-- 556b69b5-188e-448f-8b2e-26840b892924 -- hindi

-- specific customer select language
select * 
from entity.func_dim_languagetranslation_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',???)

-- all customers is a fail ???
select * from entity.func_customer_read_min(null,true, null)

*/

--if read_allcustomers = true
--	then
	return query 
	select
		dim.dim_dimlanguatetypeid,
		dim.dim_languagetypeid,
		dim.dim_languagetypeshortname,
		dim.dim_languagetypelongname,
		dim.dim_languagetranslationtypeid,
		dim.dim_languagetypecreateddate,
		dim.dim_languagetypemodifieddate,
		dim.dim_languagetypestartdate,
		dim.dim_languagetypeenddate,
		dim.dim_languagetypeuuid,
		dim.dim_dimlanguatetypeuuid,
		dim.dim_languagetypeentityuuid,
		dim.dim_languagetranslationshortnameuuid,
		dim.dim_languagetranslationlongnameuuid
	from datawarehouse.dim_languagetranslation_v2 dim
		where dim.dim_dimlanguagetranslationcustomeruuid = read_dim_dimcustomeruuid
			and dim.dim_dimlanguagetranslationtypeuuid = read_dim_dimlanguagetranslationtypeuuid;
--end if;

/*

return query 
	select
	    entityinstanceoriginalid as customerid,
	    entityinstanceoriginaluuid as customeruuid,
	    entityinstanceuuid as customerentityuuid,
		cn.entityfieldinstancevaluelanguagemasteruuid as customernameuuid,
		dn.entityfieldinstancevaluelanguagemasteruuid as customerdisplaynameuuid,
	    entityinstancetypeentityuuid as customertypeentityuuid,
	    entityinstancecreateddate as customercreateddate,
	    entityinstancemodifieddate as customermodifieddate,
	    entityinstancestartdate as customerstartdate,	
	    entityinstanceenddate as customerenddate,
	    entityinstancemodifiedbyuuid as customermodifiedbyuuid,
	    entityinstanceexternalid as customerexternalid,
	    entityinstanceexternalsystementityuuid as customerexternalsystementityid,
		efi.entityfieldinstancevalue::uuid AS customerlanguagetypeentityuuid
	from entity.entityinstance
		JOIN entity.entityfieldinstance efi 
			on entityinstanceuuid = efi.entityfieldinstanceentityinstanceentityuuid
				and efi.entityfieldinstanceentityfieldname = 'customerlanguagetypeentityuuid'
				and entityinstanceuuid = read_customerentityuuid
		join entity.entityfieldinstance cn
			on entityinstanceuuid = cn.entityfieldinstanceentityinstanceentityuuid
				and cn.entityfieldinstanceentityfieldname = 'customername'
		join entity.entityfieldinstance dn
			on entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
				and dn.entityfieldinstanceentityfieldname = 'customerdisplayname';
*/
End;	


$function$;


REVOKE ALL ON FUNCTION entity.func_dim_languagetranslation_read_min(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_dim_languagetranslation_read_min(uuid,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_dim_languagetranslation_read_min(uuid,uuid) TO bombadil WITH GRANT OPTION;
