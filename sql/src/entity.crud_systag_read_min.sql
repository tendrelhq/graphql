BEGIN;

/*
DROP FUNCTION api.delete_location(uuid,uuid);
DROP VIEW api.location;

DROP FUNCTION entity.crud_systag_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_systag_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_systag_read_min(read_ownerentityuuid uuid, read_siteentityuuid uuid, read_systagentityuuid uuid, read_systagparententityuuid uuid, read_allsystags boolean, read_systagsenddeleted boolean, read_systagsenddrafts boolean, read_systagsendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, systagid bigint, systaguuid text, systagentityuuid uuid, systagcustomerid bigint, systagcustomeruuid text, systagcustomerentityuuid uuid, systagnameuuid text, systagdisplaynameuuid text, systagtype text, systagcreateddate timestamp with time zone, systagmodifieddate timestamp with time zone, systagstartdate timestamp with time zone, systagenddate timestamp with time zone, systagexternalid text, systagexternalsystementityuuid uuid, systagmodifiedbyuuid text, systagabbreviationentityuuid uuid, systagparententityuuid uuid, systagorder integer, systagsenddeleted boolean, systagsenddrafts boolean, systagsendinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	tempsystagsenddeleted boolean[];
	tempsystagsenddrafts boolean[];
	tempsystagsendinactive boolean[];
	tendreluuid uuid;
BEGIN

/*  examples

-- all customers all systags 
select * from entity.crud_systag_read_min(null,null,null, null, true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- all systags for a specific customer
select * from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- all systags for a parent
select * from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- fail scenario for parent
select * from entity.crud_systag_read_min(null,null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

-- specific systags
select * from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

select systagentityuuid 
from entity.crud_systag_read_min(null, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,null,null,null'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

select * from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, '580f6ee2-42ca-4a5b-9e18-9ea0c168845a', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
order by systagid

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if  read_systagsenddeleted = false
	then tempsystagsenddeleted = Array[false];
	else tempsystagsenddeleted = Array[true,false];
end if;

if read_systagsenddrafts = false
	then tempsystagsenddrafts = Array[false];
	else tempsystagsenddrafts = Array[true,false];
end if;

if read_systagsendinactive = false
	then tempsystagsendinactive = Array[true];
	else tempsystagsendinactive = Array[true,false];
end if;

if read_allsystags = true
	then
	return query
		select *
		from (SELECT 
	read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
	ei.entityinstanceoriginalid as systagid,
	ei.entityinstanceoriginaluuid as systaguuid,
	ei.entityinstanceuuid as systagentityuuid,
	cust.customerid as systagcustomerid,	
	cust.customeruuid as systagcustomeruuid,
	cust.customerentityuuid::uuid as systagcustomerentityuuid,
	ei.entityinstancenameuuid as systagnameuuid,
	dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
	ei.entityinstancetype as systagtype,
	ei.entityinstancecreateddate as systagcreateddate,
	ei.entityinstancemodifieddate as systagmodifieddate,	
	ei.entityinstancestartdate as systagstartdate,
	ei.entityinstanceenddate as systagenddate,
	ei.entityinstanceexternalid as systagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
	ei.entityinstanceparententityuuid as systagparententityuuid,
	ei.entityinstancecornerstoneorder as systagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid  
				from entity.crud_customer_read_min(read_ownerentityuuid,null, null,allowners, read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive,null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'System Tag' 
			and ei.entityinstancedeleted = ANY (tempsystagsenddeleted)
			and ei.entityinstancedraft = ANY (tempsystagsenddrafts)
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid' ) as foo
		where foo.entityinstanceactive = Any (tempsystagsendinactive) ; 
	return;

end if;

if read_systagentityuuid notNull
	then
	return query
		select *
		from (SELECT 
	read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
	ei.entityinstanceoriginalid as systagid,
	ei.entityinstanceoriginaluuid as systaguuid,
	ei.entityinstanceuuid as systagentityuuid,
	cust.customerid as systagcustomerid,	
	cust.customeruuid as systagcustomeruuid,
	cust.customerentityuuid::uuid as systagcustomerentityuuid,
	ei.entityinstancenameuuid as systagnameuuid,
	dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
	ei.entityinstancetype as systagtype,
	ei.entityinstancecreateddate as systagcreateddate,
	ei.entityinstancemodifieddate as systagmodifieddate,	
	ei.entityinstancestartdate as systagstartdate,
	ei.entityinstanceenddate as systagenddate,
	ei.entityinstanceexternalid as systagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
	ei.entityinstanceparententityuuid as systagparententityuuid,
	ei.entityinstancecornerstoneorder as systagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid  from entity.crud_customer_read_min (read_ownerentityuuid,null, null,allowners, read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive,null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'System Tag'
			and ei.entityinstanceuuid = read_systagentityuuid
			and ei.entityinstancedeleted = ANY (tempsystagsenddeleted)
			and ei.entityinstancedraft = ANY (tempsystagsenddrafts)
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid') as foo
		where foo.entityinstanceactive = Any (tempsystagsendinactive) ;
		return;

end if;

if read_systagparententityuuid isNull and read_ownerentityuuid notNull
	then
	return query
		select *
		from (SELECT 
	read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
	ei.entityinstanceoriginalid as systagid,
	ei.entityinstanceoriginaluuid as systaguuid,
	ei.entityinstanceuuid as systagentityuuid,
	cust.customerid as systagcustomerid,	
	cust.customeruuid as systagcustomeruuid,
	cust.customerentityuuid::uuid as systagcustomerentityuuid,
	ei.entityinstancenameuuid as systagnameuuid,
	dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
	ei.entityinstancetype as systagtype,
	ei.entityinstancecreateddate as systagcreateddate,
	ei.entityinstancemodifieddate as systagmodifieddate,	
	ei.entityinstancestartdate as systagstartdate,
	ei.entityinstanceenddate as systagenddate,
	ei.entityinstanceexternalid as systagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
	ei.entityinstanceparententityuuid as systagparententityuuid,
	ei.entityinstancecornerstoneorder as systagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid from entity.crud_customer_read_min(read_ownerentityuuid,null, null,allowners,read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive, null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'System Tag'  
			and ei.entityinstanceownerentityuuid = read_ownerentityuuid
			and ei.entityinstanceparententityuuid = read_systagparententityuuid
			and ei.entityinstancedeleted = ANY (tempsystagsenddeleted)
			and ei.entityinstancedraft = ANY (tempsystagsenddrafts)
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid') as foo
		where foo.entityinstanceactive = Any (tempsystagsendinactive) ;
		return;
end if;

if read_systagparententityuuid notNull and read_ownerentityuuid notNull
	then
	return query
		select *
		from (SELECT 
	read_languagetranslationtypeentityuuid as languagetranslationtypeentityuuid,
	ei.entityinstanceoriginalid as systagid,
	ei.entityinstanceoriginaluuid as systaguuid,
	ei.entityinstanceuuid as systagentityuuid,
	cust.customerid as systagcustomerid,	
	cust.customeruuid as systagcustomeruuid,
	cust.customerentityuuid::uuid as systagcustomerentityuuid,
	ei.entityinstancenameuuid as systagnameuuid,
	dn.entityfieldinstancevaluelanguagemasteruuid as systagdisplaynameuuid,
	ei.entityinstancetype as systagtype,
	ei.entityinstancecreateddate as systagcreateddate,
	ei.entityinstancemodifieddate as systagmodifieddate,	
	ei.entityinstancestartdate as systagstartdate,
	ei.entityinstanceenddate as systagenddate,
	ei.entityinstanceexternalid as systagexternalid,
	ei.entityinstanceexternalsystementityuuid as systagexternalsystementityuuid,	
	ei.entityinstancemodifiedbyuuid as systagmodifiedbyuuid,
	abb.entityfieldinstancevalue::uuid as systagabbreviationentityuuid,
	ei.entityinstanceparententityuuid as systagparententityuuid,
	ei.entityinstancecornerstoneorder as systagorder,
	ei.entityinstancedeleted, 
	ei.entityinstancedraft,
	case when ei.entityinstancedeleted then false
			when ei.entityinstancedraft then false
			when ei.entityinstanceenddate::Date > now()::date 
				and ei.entityinstancestartdate < now() then false
			else true
	end as entityinstanceactive
from entity.entityinstance ei
	Join (select customerid,customeruuid, customerentityuuid from entity.crud_customer_read_min(read_ownerentityuuid,null, null,allowners,read_systagsenddeleted,read_systagsenddrafts,read_systagsendinactive, null)) as cust  
		on cust.customerentityuuid = ei.entityinstanceownerentityuuid
			and ei.entityinstanceentitytemplatename = 'System Tag'  
			and ei.entityinstanceownerentityuuid = read_ownerentityuuid
			and ei.entityinstanceparententityuuid = read_systagparententityuuid
	join entity.entityfieldinstance dn
		on ei.entityinstanceuuid = dn.entityfieldinstanceentityinstanceentityuuid
			and dn.entityfieldinstanceentityfieldname = 'systagdisplayname' 
	join entity.entityfieldinstance abb
		on ei.entityinstanceuuid = abb.entityfieldinstanceentityinstanceentityuuid
			and abb.entityfieldinstanceentityfieldname = 'systagabbreviationentityuuid') as foo
		where foo.entityinstanceactive = Any (tempsystagsendinactive) ;
		return;
end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_systag_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_systag_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_systag_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_systag_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO graphql;

-- DEPENDANTS


-- Type: VIEW ; Name: location; Owner: tendreladmin

CREATE OR REPLACE VIEW api.location AS
 SELECT location.locationid AS legacy_id,
    location.locationuuid AS legacy_uuid,
    location.locationentityuuid AS id,
    location.locationownerentityuuid AS owner,
    location.locationcustomername AS owner_name,
    location.locationparententityuuid AS parent,
    COALESCE(lt.languagetranslationvalue, lm.languagemastersource) AS parent_name,
    location.locationcornerstoneentityuuid AS cornerstone,
    location.locationnameuuid AS name_id,
    location.locationname AS name,
    location.locationdisplaynameuuid AS displayname_id,
    location.locationdisplayname AS displayname,
    location.locationscanid AS scan_code,
    location.locationcreateddate AS created_at,
    location.locationmodifieddate AS updated_at,
    location.locationmodifiedbyuuid AS modified_by,
    location.locationstartdate AS activated_at,
    location.locationenddate AS deactivated_at,
    location.locationexternalid AS external_id,
    location.locationexternalsystementityuuid AS external_system,
    location.locationcornerstoneorder AS _order,
    location.locationlatitude AS latitude,
    location.locationlongitude AS longitude,
    location.locationradius AS radius,
    location.locationtimezone AS timezone,
    location.locationtagentityuuid AS tag_id,
    location.locationsenddeleted AS _deleted,
    location.locationsenddrafts AS _draft,
    location.locationsendinactive AS _active,
        CASE
            WHEN location.locationparententityuuid = location.locationentityuuid THEN true
            ELSE false
        END AS _is_site,
        CASE
            WHEN location.locationcornerstoneentityuuid = location.locationentityuuid THEN true
            ELSE false
        END AS _is_cornerstone
   FROM entity.crud_location_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) location(languagetranslationtypeentityuuid, locationid, locationuuid, locationentityuuid, locationownerentityuuid, locationparententityuuid, locationcornerstoneentityuuid, locationcustomerid, locationcustomeruuid, locationcustomerentityuuid, locationcustomername, locationnameuuid, locationname, locationdisplaynameuuid, locationdisplayname, locationscanid, locationcreateddate, locationmodifieddate, locationmodifiedbyuuid, locationstartdate, locationenddate, locationexternalid, locationexternalsystementityuuid, locationexternalsystementname, locationcornerstoneorder, locationlatitude, locationlongitude, locationradius, locationtimezone, locationtagentityuuid, locationtagname, locationsenddeleted, locationsenddrafts, locationsendinactive)
     LEFT JOIN ( SELECT crud_location_read_min.languagetranslationtypeentityuuid,
            crud_location_read_min.locationid,
            crud_location_read_min.locationuuid,
            crud_location_read_min.locationentityuuid,
            crud_location_read_min.locationownerentityuuid,
            crud_location_read_min.locationparententityuuid,
            crud_location_read_min.locationcornerstoneentityuuid,
            crud_location_read_min.locationcustomerid,
            crud_location_read_min.locationcustomeruuid,
            crud_location_read_min.locationcustomerentityuuid,
            crud_location_read_min.locationnameuuid,
            crud_location_read_min.locationdisplaynameuuid,
            crud_location_read_min.locationscanid,
            crud_location_read_min.locationcreateddate,
            crud_location_read_min.locationmodifieddate,
            crud_location_read_min.locationmodifiedbyuuid,
            crud_location_read_min.locationstartdate,
            crud_location_read_min.locationenddate,
            crud_location_read_min.locationexternalid,
            crud_location_read_min.locationexternalsystementityuuid,
            crud_location_read_min.locationcornerstoneorder,
            crud_location_read_min.locationlatitude,
            crud_location_read_min.locationlongitude,
            crud_location_read_min.locationradius,
            crud_location_read_min.locationtimezone,
            crud_location_read_min.locationtagentityuuid,
            crud_location_read_min.locationsenddeleted,
            crud_location_read_min.locationsenddrafts,
            crud_location_read_min.locationsendinactive
           FROM entity.crud_location_read_min(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid) crud_location_read_min(languagetranslationtypeentityuuid, locationid, locationuuid, locationentityuuid, locationownerentityuuid, locationparententityuuid, locationcornerstoneentityuuid, locationcustomerid, locationcustomeruuid, locationcustomerentityuuid, locationnameuuid, locationdisplaynameuuid, locationscanid, locationcreateddate, locationmodifieddate, locationmodifiedbyuuid, locationstartdate, locationenddate, locationexternalid, locationexternalsystementityuuid, locationcornerstoneorder, locationlatitude, locationlongitude, locationradius, locationtimezone, locationtagentityuuid, locationsenddeleted, locationsenddrafts, locationsendinactive)) parent ON parent.locationentityuuid = location.locationparententityuuid
     LEFT JOIN languagemaster lm ON lm.languagemasteruuid = parent.locationnameuuid
     LEFT JOIN languagetranslations lt ON lt.languagetranslationmasterid = (( SELECT languagemaster.languagemasterid
           FROM languagemaster
          WHERE languagemaster.languagemasteruuid = parent.locationnameuuid)) AND lt.languagetranslationtypeid = (( SELECT crud_systag_read_min.systagid
           FROM entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid, NULL::uuid, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid)), NULL::uuid, false, NULL::boolean, NULL::boolean, NULL::boolean, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid) crud_systag_read_min(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagnameuuid, systagdisplaynameuuid, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagmodifiedbyuuid, systagabbreviationentityuuid, systagparententityuuid, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)))
  WHERE (location.locationownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.location IS '
## Location

A description of what an location is and why it is used

### get {baseUrl}/location

A bunch of comments explaining get

### del {baseUrl}/location

A bunch of comments explaining del

### patch {baseUrl}/location

A bunch of comments explaining patch
';

CREATE TRIGGER create_location_tg INSTEAD OF INSERT ON api.location FOR EACH ROW EXECUTE FUNCTION api.create_location();
CREATE TRIGGER update_location_tg INSTEAD OF UPDATE ON api.location FOR EACH ROW EXECUTE FUNCTION api.update_location();

GRANT INSERT ON api.location TO authenticated;
GRANT SELECT ON api.location TO authenticated;
GRANT UPDATE ON api.location TO authenticated;

-- Type: FUNCTION ; Name: api.delete_location(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_location(owner uuid, id uuid)
 RETURNS SETOF api.location
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_location_delete(
	      create_locationownerentityuuid := owner,
	      create_locationentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.location t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_location(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_location(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_location(uuid,uuid) TO authenticated;

END;
