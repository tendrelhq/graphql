
-- Type: PROCEDURE ; Name: crud_location_create(text,text,text,bigint,bigint,bigint,boolean,bigint,text,text,text,bigint,text,text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_location_create(IN create_customeruuid text, IN create_customerexternalid text, IN create_customerexternalsystemuuid text, IN create_siteid bigint, IN create_locationparentid bigint, IN create_locationcornerstoneid bigint, IN create_locationiscornerstone boolean, IN create_locationcornerstoneorder bigint, IN create_locationname text, IN create_locationlookupname text, IN create_locationscanid text, IN create_locationtypeid bigint, IN create_locationtype text, IN create_locationexternalid text, IN create_locationexternalsystemuuid text, IN create_languagetypeuuid text, IN create_modifiedbyid bigint, INOUT templocationid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   	templanguagemasterid bigint;
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempcustagid bigint;
	tempcustaguuid text;
	tempsiteid bigint;
	templocationtimezone text;
	templanguagetypeid bigint;
	templocationexternalsystemid bigint;
	templocationcornerstoneid bigint;
	templocationiscornerstone boolean;
	templocationcornerstoneorder bigint;
	templocationmodifieddate  timestamp with time zone;

Begin

-- We could harden this by checking for valid data at the beginning of this call.  Will do this as phase 2.  
	-- Must have a valid customerid or customerexternalid
	-- Site Name and Site type can not be null or ''
	-- languagetype id must be a valid languagetypeid
	-- locationtimezone must be a legit timezone
	-- modified by id gets defaulted if it is not passed in (Maybe validate this)
	-- Could check all this and return null if any of these fail

-- Set the customerid if it is null

tempcustomeruuid = (select customeruuid
					from customer
					where (create_customeruuid = customeruuid 
						or (create_customerexternalid = customerexternalid
						and create_customerexternalsystemuuid = customerexternalsystemuuid)));

tempcustomerid = (select customerid
					from customer
					where (create_customeruuid = customeruuid 
						or (create_customerexternalid = customerexternalid
						and create_customerexternalsystemuuid = customerexternalsystemuuid)));

-- Setup the Custag for the locationtype
	
-- insert the custag 

templanguagetypeid = (select systagid 
					  from systag
					  where systaguuid = create_languagetypeuuid);

if create_locationtypeid isNull
	then
		tempcustaguuid = (select custaguuid from custag 
					where custagtype = create_locationtype
						and custagcustomeruuid = tempcustomeruuid);
		tempcustagid = (select custagid from custag 
					where custagtype = create_locationtype
						and custagcustomeruuid = tempcustomeruuid);
	else 
		tempcustaguuid = (select custaguuid from custag 
					where custagtype = create_locationtype
						and custagcustomerid = create_locationtypeid);
		tempcustagid = create_locationtypeid;
end if;

templocationexternalsystemid = (select systagid from systag
								where systaguuid = create_locationexternalsystemuuid);

if tempcustaguuid isNull
	then 
		INSERT INTO public.custag(
				custagcustomerid, 
				custagcustomeruuid,
				custagsystagid, 
				custagsystaguuid,
				custagnameid, 
				custagtype,
				custagstartdate,
				custagmodifiedby
				)
		values (tempcustomerid,
				tempcustomeruuid,
				713,  -- Systagid for Location Category
				(select systaguuid from systag where systagid = 713),
				4367, -- dummy variable
				create_locationtype,
				clock_timestamp(),
				create_modifiedbyid)
				Returning custaguuid, custagid into tempcustaguuid,tempcustagid;

		insert into public.languagemaster
			(languagemastercustomerid,
			languagemastersourcelanguagetypeid,
			languagemastercustomersiteid,
			languagemastersource,
			languagemastermodifiedby)
		values(tempcustomerid,
			templanguagetypeid, 	
			create_siteid,
			create_locationtype,
			create_modifiedbyid)
		Returning languagemasterid into templanguagemasterid;

		-- Set the CustTag table to reference the correct translations

		update public.custag
		set custagnameid = templanguagemasterid
		where custagid = tempcustagid    
			and custagcustomerid = tempcustomerid;

end if;

-- insert the custag into languagemaster

-- see if the location already exists

templocationid = (select locationid
				 from view_location
				 where locationcustomerid = tempcustomerid
					and locationcategoryid = tempcustagid
					and locationistop = false
					and locationsiteid = create_siteid
					and locationfullname = create_locationname
					and languagetranslationtypeid = templanguagetypeid);

templocationtimezone = (select locationtimezone
						from location
						where locationid = create_siteid);

if templocationid isNull
	then
		insert into public.languagemaster
			(languagemastercustomerid,
			languagemastersourcelanguagetypeid,
			languagemastercustomersiteid,
			languagemastersource,
			languagemastermodifiedby)
		values(
			tempcustomerid,
			templanguagetypeid,
			create_siteid,
			create_locationname,
			create_modifiedbyid)
		returning languagemasterid into templanguagemasterid;

		INSERT INTO public.location(
			locationcustomerid,
			locationsiteid,
			locationparentid,
			locationiscornerstone,
			locationlookupname,
			locationscanid,
			locationistop,
			locationcategoryid,
			locationstartdate,
			locationnameid,
			locationtimezone,
			locationexternalid,
			locationexternalsystemid,			
			locationmodifiedby)
		values(	
			tempcustomerid,
			create_siteid,
			case
				when create_locationparentid isNull
					then create_siteid
				else
					create_locationparentid
			end,
			false,
			create_locationname,
			create_locationscanid,			
			FALSE,
			tempcustagid,
			clock_timestamp(),  
			templanguagemasterid,
			templocationtimezone,   -- https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
			create_locationexternalid,	
			templocationexternalsystemid,
			create_modifiedbyid)
		returning locationid into  templocationid;
end if;

if create_locationiscornerstone = true or create_locationcornerstoneid isnull
	then
		templocationcornerstoneid = templocationid;
		templocationiscornerstone = true;
		templocationcornerstoneorder = 1;
		templocationmodifieddate = clock_timestamp();
	else
		templocationcornerstoneid = create_locationcornerstoneid;
		templocationiscornerstone = false;
		templocationcornerstoneorder = create_locationcornerstoneorder;
		templocationmodifieddate = clock_timestamp();
End if;
		

update location
	set locationcornerstoneid = templocationcornerstoneid,
		locationiscornerstone = templocationiscornerstone,
		locationcornerstoneorder = templocationcornerstoneorder,
		locationmodifieddate = clock_timestamp()
	where locationid = templocationid and locationcustomerid = tempcustomerid;

commit;

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_location_create(text,text,text,bigint,bigint,bigint,boolean,bigint,text,text,text,bigint,text,text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_create(text,text,text,bigint,bigint,bigint,boolean,bigint,text,text,text,bigint,text,text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_create(text,text,text,bigint,bigint,bigint,boolean,bigint,text,text,text,bigint,text,text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;
