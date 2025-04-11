
-- Type: PROCEDURE ; Name: crud_location_update(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.crud_location_update(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_siteid bigint, IN update_parentid bigint, INOUT update_locationid bigint, IN update_locationexternalid text, IN update_locationexternalsystemuuid text, IN update_locationfullname text, IN update_locationlookupname text, IN update_locationscanid text, IN update_locationiscornerstone boolean, IN update_locationcornerstoneid bigint, IN update_locationcornerstoneorder bigint, IN update_languagetypeuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   	templanguagemasterid bigint;
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempsiteid bigint;
	tempparentid bigint;
	templocationid bigint;	
	updatelocationexternalid text;
	updatelocationexternalsystemid bigint;
	templocationfullname text;
	updatelocationlookupname text;	
	updatelocationscanid text;	
	updatelocationiscornerstone boolean;		
	updatelocationcornerstoneid bigint;
	updatelocationcornerstoneorder bigint;
	updatelocationtimezone text;	
	templanguagetypeid bigint;
	templocationlanguagetypeid bigint;
	updatelocationmodifieddate  timestamp with time zone;
Begin

-- We only allow the name,lookupname, scanid, and languagetype to change
-- we won't update external systems with this change.  Possibly a future enhancement.

if update_languagetypeuuid isNull
	then 
		templanguagetypeid =  20;
	else 
		templanguagetypeid = (select systagid from systag where systaguuid = update_languagetypeuuid);
end if;

-- update customer id

tempcustomeruuid = (select customeruuid
					from customer
					where (update_customeruuid = customeruuid 
						or (update_customerexternalid = customerexternalid
						and update_customerexternalsystemuuid = customerexternalsystemuuid)));

tempcustomerid = (select customerid
					from customer
					where (update_customeruuid = customeruuid 
						or (update_customerexternalid = customerexternalid
						and update_customerexternalsystemuuid = customerexternalsystemuuid)));

CREATE TEMP TABLE templocation AS
select 
	locationid as templocationid,
	locationsiteid as  tempsiteid,
	locationparentid as  tempparentid,	
   	locationnameid as templanguagemasterid,
	locationexternalid as templocationexternalid,
	locationexternalsystemid as templocationexternalsystemid,
	locationfullname as templocationfullname,
	locationlookupname as templocationlookupname,
	locationscanid as templocationscanid,
	locationiscornerstone as templocationiscornerstone,	
	locationcornerstoneid as templocationcornerstoneid,
	locationcornerstoneorder as templocationcornerstoneorder,
	locationtimezone as templocationtimezone	
from view_location
where languagetranslationtypeid = templanguagetypeid
	and locationcustomerid = tempcustomerid
	and locationid = update_locationid;

-- If the name changed then we update the name in the languagemaster and in the customer tables

update languagemaster
set languagemastersource = update_locationfullname,
	languagemastersourcelanguagetypeid = templanguagetypeid,
	languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
	languagemastermodifiedby = update_modifiedbyid,
	languagemastermodifieddate = clock_timestamp()
from location
where locationid = update_locationid
	and locationnameid = languagemasterid;

if update_locationexternalid isNull  
	then
		updatelocationexternalid = (select templocationexternalid from templocation);
	else
		updatelocationexternalid = update_locationexternalid;
end if;

if update_locationexternalsystemuuid isNull  
	then
		updatelocationexternalsystemid = (select templocationexternalsystemid from templocation);
	else
		updatelocationexternalsystemid = update_locationexternalid;
end if;

if update_locationlookupname isNull 
	then
		updatelocationlookupname = (select templocationlookupname from templocation);
	else	
		updatelocationlookupname = update_locationlookupname;
end if;

if update_locationscanid isNull 
	then
		updatelocationscanid = (select templocationscanid from templocation); 
	Else
		updatelocationscanid = update_locationscanid;
end if;

if update_locationiscornerstone = true or update_locationcornerstoneid isnull
	then
		updatelocationcornerstoneid = update_locationid;
		updatelocationiscornerstone = true;
		updatelocationcornerstoneorder = 1;
		updatelocationmodifieddate = clock_timestamp();
	else
		updatelocationcornerstoneid = create_locationcornerstoneid;
		updatelocationiscornerstone = false;
		updatelocationcornerstoneorder = create_locationcornerstoneorder;
		updatelocationmodifieddate = clock_timestamp();
End if;

update location
	set locationexternalid = updatelocationexternalid,
	locationexternalsystemid = updatelocationexternalsystemid,
	locationlookupname = updatelocationlookupname,
	locationscanid = updatelocationscanid,
	locationiscornerstone = updatelocationiscornerstone,
	locationcornerstoneid = updatelocationcornerstoneid,
	locationcornerstoneorder = updatelocationcornerstoneorder,
	locationmodifieddate = updatelocationmodifieddate,
	locationmodifiedby = update_modifiedbyid
where locationid = update_locationid
	and locationcustomerid = tempcustomerid;

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_location_update(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_update(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_update(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint) TO bombadil WITH GRANT OPTION;
