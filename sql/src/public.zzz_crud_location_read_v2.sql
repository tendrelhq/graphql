
-- Type: FUNCTION ; Name: zzz_crud_location_read_v2(text,text,text,bigint,text); Owner: bombadil

CREATE OR REPLACE FUNCTION public.zzz_crud_location_read_v2(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text, read_locationid bigint, read_languagetypeuuid text)
 RETURNS TABLE(locationid bigint, locationcustomerid bigint, locationcategoryid bigint, locationcategory text, locationlanguagetypeid bigint, locationlanguagetypename text, locationnameid bigint, locationfullname text, locationscanid text, locationlookupname text, locationtimezone text, locationsiteid bigint, locationsitename text, locationparentid bigint, locationparentname text, locationiscornerstone boolean, locationcornerstoneid bigint, locationcornerstonename text, locationcornerstoneorder bigint, locationstartdate timestamp with time zone, locationenddate timestamp with time zone, locationexternalsystemid bigint, locationexternalid text)
 LANGUAGE plpgsql
AS $function$

Declare
	tempcustomerid bigint;
	templanguagetypeid bigint;

Begin

/* MJK 20240510
	
	Added in a default language of english if Null is accidentally passed in for type.  
	Added exceptions around checks for customer and site.

*/

	-- Check if customer exists
    PERFORM * FROM public.customer 
				WHERE (read_customeruuid = customeruuid 
					or (read_customerexternalid = customerexternalid
						and read_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	-- Check if location exists
    PERFORM * FROM public.location loc
					inner join customer
						on customerid = loc.locationcustomerid		
				WHERE loc.locationid = read_locationid
					and loc.locationistop = false;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'location does not exist';
    END IF;

	tempcustomerid = (select customerid 
						from customer 
						where (read_customeruuid = customeruuid 
							or (read_customerexternalid = customerexternalid
							and read_customerexternalsystemuuid = customerexternalsystemuuid))); 

	templanguagetypeid = (select systagid 
						  from systag
						  where systaguuid = read_languagetypeuuid);
	
	if templanguagetypeid isNull
		then templanguagetypeid = 20;
	end if;

RETURN QUERY SELECT 
	loc.locationid, 
	loc.locationcustomerid, 
	cat.custagid as locationcategoryid,
	cat.custagtype as locationcategory,
	lan.systagid as locationlanguagetypeid,
	lan.systagtype as locationlanguagetypename, 
	loc.locationnameid, 
	loc.locationfullname,  
	loc.locationscanid,
	loc.locationlookupname,
	loc.locationtimezone,
	loc.locationsiteid,	
	site.locationfullname as locationsitename,
	loc.locationparentid,	
	parent.locationfullname as locationparentname,	
	loc.locationiscornerstone, 
	loc.locationcornerstoneid,
	corner.locationfullname as locationcornerstonename,  -- join this in
	loc.locationcornerstoneorder, 
	loc.locationstartdate, 
	loc.locationenddate, 
	loc.locationexternalsystemid, 
	loc.locationexternalid
FROM public.view_location loc
	inner join systag lan
		on lan.systagid = templanguagetypeid
	inner join view_location site
		on site.locationid = loc.locationsiteid
			and site.languagetranslationtypeid = loc.languagetranslationtypeid
	inner join view_location parent
		on parent.locationid = loc.locationparentid
			and parent.languagetranslationtypeid = loc.languagetranslationtypeid
	left join view_location corner
		on corner.locationid = loc.locationcornerstoneid
			and corner.languagetranslationtypeid = loc.languagetranslationtypeid
	inner join custag cat
		on cat.custagid = loc.locationcategoryid
where loc.locationid = read_locationid
	and loc.locationistop = false
	and loc.locationcustomerid = tempcustomerid
	and loc.languagetranslationtypeid = templanguagetypeid;

End;

$function$;


REVOKE ALL ON FUNCTION zzz_crud_location_read_v2(text,text,text,bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_location_read_v2(text,text,text,bigint,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_location_read_v2(text,text,text,bigint,text) TO bombadil WITH GRANT OPTION;
