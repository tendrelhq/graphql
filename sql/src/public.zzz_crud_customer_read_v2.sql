
-- Type: FUNCTION ; Name: zzz_crud_customer_read_v2(text,text,text); Owner: bombadil

CREATE OR REPLACE FUNCTION public.zzz_crud_customer_read_v2(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text)
 RETURNS TABLE(customerid bigint, customernamelanguagemasterid bigint, customername text, customerlanguagetypeid bigint, customerlanguagetypeuuid text, customerlanguagetypename text, customerstartdate timestamp with time zone, customerenddate timestamp with time zone, customerexternalid text, customerexternalsystemid bigint, customerexternalsystemuuid text, customerexternalsystemname text, customercreateddate timestamp with time zone, customermodifieddate timestamp with time zone, customermodifiedby bigint)
 LANGUAGE sql
AS $function$

/* MJK 20240510
	
	Added in comments only 

	Future:  flip to plpgsql 
	Future: Might want to switch this to use languagetypeuuid.   
	Future: Add in default language if we add language.
	Future: Might want to create a default langaugage customer config.
*/

-- Example to call function

SELECT 
	customerid, 
	customernamelanguagemasterid, 
	customername, 
	customerlanguagetypeid,
	customerlanguagetypeuuid,
	lt.systagtype as customerlanguagetypename,
	customerstartdate, 
	customerenddate, 
	customerexternalid, 
	customerexternalsystemid,
	customerexternalsystemuuid,
	sn.systagtype as  customerexternalsystemname, 
	customercreateddate, 
	customermodifieddate, 
	customermodifiedby
FROM public.customer c
	inner join systag lt
		on customerlanguagetypeuuid = lt.systaguuid
	left join systag sn
		on customerexternalsystemuuid = sn.systaguuid
where (read_customeruuid = customeruuid 
		or (read_customerexternalid = customerexternalid
		and read_customerexternalsystemuuid = customerexternalsystemuuid));

$function$;


REVOKE ALL ON FUNCTION zzz_crud_customer_read_v2(text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_read_v2(text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_read_v2(text,text,text) TO bombadil WITH GRANT OPTION;
