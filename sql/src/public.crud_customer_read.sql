
-- Type: FUNCTION ; Name: crud_customer_read(text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_customer_read(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text)
 RETURNS TABLE(customerid bigint, customernamelanguagemasterid bigint, customername text, customerlanguagetypeid bigint, customerlanguagetypeuuid text, customerlanguagetypename text, customerstartdate timestamp with time zone, customerenddate timestamp with time zone, customerexternalid text, customerexternalsystemid bigint, customerexternalsystemuuid text, customerexternalsystemname text, customercreateddate timestamp with time zone, customermodifieddate timestamp with time zone, customermodifiedby bigint)
 LANGUAGE sql
AS $function$

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


REVOKE ALL ON FUNCTION crud_customer_read(text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_read(text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_read(text,text,text) TO tendreladmin WITH GRANT OPTION;
