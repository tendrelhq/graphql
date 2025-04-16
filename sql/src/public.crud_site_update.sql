
-- Type: PROCEDURE ; Name: crud_site_update(text,text,text,bigint,text,text,text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_site_update(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_siteid bigint, IN update_siteexternaluuid text, IN create_siteexternalsystemuuid text, IN update_sitefullname text, IN update_sitelookupname text, IN update_sitescanid text, IN update_sitetimezone text, IN update_languagetypeuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempsiteexternalid text;
	templanguagetypeid bigint;
	templocationlanguagetypeid bigint;	
	updatesitelookupname text;
	updatesitescanid text;
	updatesitetimezone text;
Begin

-- We only allow the name,lookupname, scanid, and languagetype to change
-- We will update timezone for now, but not cascade the change.  
-- Timezone changes casue a dangerous cascade to children and workinstances. 

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

if update_languagetypeuuid isNull
	then 
		templanguagetypeid =  20;
	else 
		templanguagetypeid = (select systagid from systag where systaguuid = update_languagetypeuuid);
end if;

-- update customer id

CREATE TEMP TABLE tempsite
	(tempsiteid bigint,
   	templanguagemasterid bigint,
	tempsitefullname text,
	tempsitelookupname text,
	tempsitescanid text,
	tempsitetimezone text);

insert into tempsite (
	tempsiteid,
   	templanguagemasterid,
	tempsitefullname,
	tempsitelookupname,
	tempsitescanid,
	tempsitetimezone	
)
select 
	locationid as tempsiteid,
   	locationnameid as templanguagemasterid,
	locationfullname as tempsitefullname,
	locationlookupname as tempsitelookupname,
	locationscanid as tempsitescanid,
	locationtimezone as tempsitetimezone	
from view_location
where languagetranslationtypeid = templanguagetypeid
	and locationcustomerid = tempcustomerid
	and locationid = update_siteid;

-- If the name changed then we update the name in the languagemaster and in the customer tables

if update_sitelookupname isNull
	then
		updatesitelookupname = (select tempsitelookupname from tempsite);
	else
		updatesitelookupname = update_sitelookupname;
end if;

if update_sitescanid isNull
	then
		updatesitescanid = (select tempsitescanid from tempsite);
	else
		updatesitescanid = update_sitescanid;
end if;

if update_sitetimezone isNull
	then
		updatesitetimezone = (select tempsitetimezone from tempsite);
	else
		updatesitetimezone = update_sitetimezone;	
end if;

update languagemaster
set languagemastersource = update_sitefullname,
	languagemastersourcelanguagetypeid = templanguagetypeid,
	languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
	languagemastermodifiedby = update_modifiedbyid,
	languagemastermodifieddate = clock_timestamp()
from tempsite
where tempsiteid = update_siteid
	and templanguagemasterid = languagemasterid
	and tempsitefullname <> update_sitefullname;

update location
	set locationlookupname = updatesitelookupname,
	locationscanid = updatesitescanid,
	locationtimezone = updatesitetimezone
where locationid = update_siteid
	and locationcustomerid = tempcustomerid;

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_site_update(text,text,text,bigint,text,text,text,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_update(text,text,text,bigint,text,text,text,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_update(text,text,text,bigint,text,text,text,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;
