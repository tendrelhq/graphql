
-- Type: PROCEDURE ; Name: zzz_crud_customer_update_v2(text,text,text,text,text,bigint); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.zzz_crud_customer_update_v2(INOUT update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_customername text, IN update_languagetypeuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   	templanguagemasterid bigint;
	templanguagetypeid bigint;
	tempcustomerexternalsystemid bigint;
Begin


/* MJK 20240510
	
	Added in a customer check.  

	Future: update external systems.
*/  
	PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	
	if language_id isNull
		then
			templanguagetypeid = 20;
		else
			templanguagetypeid = (select systagid 
					  			from systag
					 			 where systaguuid = update_languagetypeuuid);
	end if;

tempcustomerexternalsystemid = (select systagid 
								  from systag
								  where systaguuid = update_customerexternalsystemuuid);

update_customeruuid = (select customeruuid 
								  from customer
								  where (update_customeruuid = customeruuid 
									or (update_customerexternalid = customerexternalid
									and update_customerexternalsystemuuid = customerexternalsystemuuid)));

if (update_customername notNull and update_customername <> '')
	then 
		update languagemaster
		set languagemastersource = update_customername,
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
			languagemastermodifiedby = update_modifiedbyid,
			languagemastermodifieddate = clock_timestamp()
		from customer
		where (update_customeruuid = customeruuid 
				or (update_customerexternalid = customerexternalid
				and update_customerexternalsystemuuid = customerexternalsystemuuid))
			and customernamelanguagemasterid = languagemasterid
			and customername <> update_customername;
		
		update customer
		set customername = update_customername
		where (update_customeruuid = customeruuid 
				or (update_customerexternalid = customerexternalid
				and update_customerexternalsystemuuid = customerexternalsystemuuid))
			and customername <> update_customername;
end if;

-- Set language type id for the customer
-- We could harden this to check to see if the languagetype id is valid 
-- For now I will assume it is ok

update customer
set customerlanguagetypeid = templanguagetypeid,
	customerlanguagetypeuuid = update_languagetypeuuid	
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid))
	and update_languagetypeuuid notNull
	and customerlanguagetypeuuid <> update_languagetypeuuid;

-- set the customer as modified

update customer
set customermodifiedby = update_modifiedbyid,
	customermodifieddate = clock_timestamp()			
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid));

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_customer_update_v2(text,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_update_v2(text,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_update_v2(text,text,text,text,text,bigint) TO bombadil WITH GRANT OPTION;
