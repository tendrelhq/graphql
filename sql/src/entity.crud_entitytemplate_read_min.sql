
-- Type: FUNCTION ; Name: entity.crud_entitytemplate_read_min(uuid,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entitytemplate_read_min(read_ownerentityuuid uuid, read_entitytemplateentityuuid uuid, read_entitytemplatesenddeleted boolean, read_entitytemplatesenddrafts boolean, read_entitytemplatesendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(languagetranslationtypeuuid uuid, entitytemplateuuid uuid, entitytemplateownerentityuuid uuid, entitytemplateparententityuuid uuid, entitytemplatetypeentityuuid uuid, entitytemplateisprimary boolean, entitytemplatescanid text, entitytemplatenameuuid text, entitytemplateorder integer, entitytemplatemodifiedbyuuid text, entitytemplatestartdate timestamp with time zone, entitytemplateenddate timestamp with time zone, entitytemplatecreateddate timestamp with time zone, entitytemplatemodifieddate timestamp with time zone, entitytemplateexternalid text, entitytemplaterefid bigint, entitytemplaterefuuid text, entitytemplateexternalsystementityuuid uuid, entitytemplatedeleted boolean, entitytemplatedraft boolean, entitytemplateactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	templanguagetranslationtypeid bigint;
	tempentitytemplatesenddeleted boolean[]; 
	tempentitytemplatesenddrafts  boolean[];  
	tempentitytemplatesendinactive boolean[];
	tendreluuid uuid;
BEGIN

/*  Examples

-- all customers no entity template
select * from entity.crud_entitytemplate_read_min(null, null, null,null, null, null)

-- specific customer no entity template
select * from entity.crud_entitytemplate_read_min(	'f90d618d-5de7-4126-8c65-0afb700c6c61',null, null,null, null,null)

-- specific entity template
select * 
from entity.crud_entitytemplate_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61','957df2f9-051f-4af5-95ee-ea3760fbb83b',	null,null, null,null)

-- negative test - empty or wrong cutomer returns nothing
select * 
from entity.crud_entitytemplate_read_min(null,'957df2f9-051f-4af5-95ee-ea3760fbb83b',	null,null, null,null)

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if read_languagetranslationtypeuuid isNull
	then read_languagetranslationtypeuuid = (
		select systagentityuuid 
		from entity.crud_systag_read_min(	tendreluuid, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,read_entitytemplatesenddeleted, read_entitytemplatesenddrafts,read_entitytemplatesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
		); 
end if;

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if  read_entitytemplatesenddeleted = false
	then tempentitytemplatesenddeleted = Array[false];
	else tempentitytemplatesenddeleted = Array[true,false];
end if;

if read_entitytemplatesenddrafts = false
	then tempentitytemplatesenddrafts = Array[false];
	else tempentitytemplatesenddrafts = Array[true,false];
end if;

if  read_entitytemplatesendinactive = false
	then tempentitytemplatesendinactive = Array[true];
	else tempentitytemplatesendinactive = Array[true,false];
end if;

-- probably can do this cealner with less sql

if allowners = true and (read_entitytemplateentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et.entitytemplateuuid, 
				et.entitytemplateownerentityuuid, 
				et.entitytemplateparententityuuid,
				et.entitytemplatetypeentityuuid,
				et.entitytemplateisprimary,
				et.entitytemplatescanid,
				et.entitytemplatenameuuid,
				et.entitytemplateorder, 
				et.entitytemplatemodifiedbyuuid, 
				et.entitytemplatestartdate, 
				et.entitytemplateenddate, 
				et.entitytemplatecreateddate, 
				et.entitytemplatemodifieddate, 
				et.entitytemplateexternalid, 
				et.entitytemplaterefid, 
				et.entitytemplaterefuuid,
				et.entitytemplateexternalsystementityuuid,
				et.entitytemplatedeleted,
				et.entitytemplatedraft,
	case when et.entitytemplatedeleted then false
			when et.entitytemplatedraft then false
			when et.entitytemplateenddate::Date > now()::date 
				and et.entitytemplatestartdate < now() then false
			else true
	end as entitytemplateactive
			FROM entity.entitytemplate et
			where et.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				 and et.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)) as foo
		where foo.entitytemplateactive = Any (tempentitytemplatesendinactive
		) ;
		return;
end if;

if allowners = false and (read_entitytemplateentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et2.entitytemplateuuid, 
				et2.entitytemplateownerentityuuid, 
				et2.entitytemplateparententityuuid,
				et2.entitytemplatetypeentityuuid,
				et2.entitytemplateisprimary,
				et2.entitytemplatescanid,
				et2.entitytemplatenameuuid,
				et2.entitytemplateorder, 
				et2.entitytemplatemodifiedbyuuid, 
				et2.entitytemplatestartdate, 
				et2.entitytemplateenddate, 
				et2.entitytemplatecreateddate, 
				et2.entitytemplatemodifieddate, 
				et2.entitytemplateexternalid, 
				et2.entitytemplaterefid, 
				et2.entitytemplaterefuuid,
				et2.entitytemplateexternalsystementityuuid,
				et2.entitytemplatedeleted,
				et2.entitytemplatedraft,
	case when et2.entitytemplatedeleted then false
			when et2.entitytemplatedraft then false
			when et2.entitytemplateenddate::Date > now()::date 
				and et2.entitytemplatestartdate < now() then false
			else true
	end as entitytemplateactive
		FROM entity.entitytemplate et2
		where et2.entitytemplateownerentityuuid = read_ownerentityuuid
			and et2.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
			and et2.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)) as foo
		where foo.entitytemplateactive = Any (tempentitytemplatesendinactive
		) ;
		return;
end if;

if allowners = false and (read_entitytemplateentityuuid notNull)
	then
		return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et3.entitytemplateuuid, 
				et3.entitytemplateownerentityuuid, 
				et3.entitytemplateparententityuuid,
				et3.entitytemplatetypeentityuuid,
				et3.entitytemplateisprimary,
				et3.entitytemplatescanid,
				et3.entitytemplatenameuuid,
				et3.entitytemplateorder, 
				et3.entitytemplatemodifiedbyuuid, 
				et3.entitytemplatestartdate, 
				et3.entitytemplateenddate, 
				et3.entitytemplatecreateddate, 
				et3.entitytemplatemodifieddate, 
				et3.entitytemplateexternalid, 
				et3.entitytemplaterefid, 
				et3.entitytemplaterefuuid,
				et3.entitytemplateexternalsystementityuuid,
				et3.entitytemplatedeleted,
				et3.entitytemplatedraft,
	case when et3.entitytemplatedeleted then false
			when et3.entitytemplatedraft then false
			when et3.entitytemplateenddate::Date > now()::date 
				and et3.entitytemplatestartdate < now() then false
			else true
				end as entitytemplateactive
			FROM entity.entitytemplate et3
			where (et3.entitytemplateownerentityuuid = read_ownerentityuuid
					or et3.entitytemplateownerentityuuid = tendreluuid) 
				and et3.entitytemplateuuid = read_entitytemplateentityuuid
				and et3.entitytemplatedeleted = ANY (tempentitytemplatesenddeleted)
				and et3.entitytemplatedraft = ANY (tempentitytemplatesenddrafts)) as foo
		where foo.entitytemplateactive = Any (tempentitytemplatesendinactive) ;
end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entitytemplate_read_min(uuid,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytemplate_read_min(uuid,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytemplate_read_min(uuid,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entitytemplate_read_min(uuid,uuid,boolean,boolean,boolean,uuid) TO graphql;
