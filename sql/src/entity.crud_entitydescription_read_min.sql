BEGIN;

/*
DROP FUNCTION entity.crud_entitydescription_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_entitydescription_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entitydescription_read_min(read_ownerentityuuid uuid, read_entitydescriptionentityuuid uuid, read_entitytemplateentityuuid uuid, read_entityfieldentityuuid uuid, read_entitydescriptionsenddeleted boolean, read_entitydescriptionsenddrafts boolean, read_entitydescriptionsendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(languagetranslationtypeuuid uuid, entitydescriptionuuid uuid, entitydescriptionownerentityuuid uuid, entitydescriptionentitytemplateentityuuid uuid, entitydescriptionentityfieldentityduuid uuid, entitydescriptionname text, entitydescriptionlanguagemasteruuid text, entitydescriptionsoplink text, entitydescriptionfile text, entitydescriptionicon text, entitydescriptioncreateddate timestamp with time zone, entitydescriptionmodifieddate timestamp with time zone, entitydescriptionstartdate timestamp with time zone, entitydescriptionenddate timestamp with time zone, entitydescriptionmodifiedby text, entitydescriptionexternalid text, entitydescriptionexternalsystementityuuid uuid, entitydescriptionrefid bigint, entitydescriptionrefuuid text, entitydescriptiondraft boolean, entitydescriptiondeleted boolean, entitydescriptionactive boolean, entitydescriptionmimetypeuuid uuid)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	templanguagetranslationtypeid bigint;
	tempentitydescriptionsenddeleted boolean[]; 
	tempentitydescriptionsenddrafts  boolean[];  
	tempentitydescriptionsendinactive boolean[];
	tendreluuid uuid;
BEGIN

/*  Examples

-- all descriptions
select * from entity.crud_entitydescription_read_min(null, null, null,null, null, null,null,null)

-- all descriptions for an owner
select * from entity.crud_entitydescription_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,null, null, null,null,null)

-- descriptions for an entity
select * from entity.crud_entitydescription_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', 'f42f8873-37a0-450e-97c8-c223955b2f02', null,null, null, null,null,null)

-- all descriptions for a template
select * from entity.crud_entitydescription_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, '2de8bf04-15bd-4df9-b5bc-4eb7fbb8e37e',null, null, null,null,null)

-- all descriptions for a field
select * from entity.crud_entitydescription_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,'3b477e48-82d7-43fa-a8a4-757d4d5ad457', null, null,null,null)

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if read_languagetranslationtypeuuid isNull
	then read_languagetranslationtypeuuid = (
		select systagentityuuid 
		from entity.crud_systag_read_min(	tendreluuid, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,read_entitydescriptionsenddeleted, read_entitydescriptionsenddrafts,read_entitydescriptionsendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
		); 
end if;

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if read_entitydescriptionsenddeleted isNull and read_entitydescriptionsenddeleted = false
	then tempentitydescriptionsenddeleted = Array[false];
	else tempentitydescriptionsenddeleted = Array[true,false];
end if;

if read_entitydescriptionsenddrafts isNull and read_entitydescriptionsenddrafts = false
	then tempentitydescriptionsenddrafts = Array[false];
	else tempentitydescriptionsenddrafts = Array[true,false];
end if;

if read_entitydescriptionsendinactive isNull and read_entitydescriptionsendinactive = false
	then tempentitydescriptionsendinactive = Array[true];
	else tempentitydescriptionsendinactive = Array[true,false];
end if;

-- probably can do this cealner with less sql

if allowners = true and (read_entitydescriptionentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et.entitydescriptionuuid, 
				et.entitydescriptionownerentityuuid, 
				et.entitydescriptionentitytemplateentityuuid, 
				et.entitydescriptionentityfieldentityduuid, 
				et.entitydescriptionname, 
				et.entitydescriptionlanguagemasteruuid,
				et.entitydescriptionsoplink, 
				et.entitydescriptionfile, 
				et.entitydescriptionicon, 
				et.entitydescriptioncreateddate, 
				et.entitydescriptionmodifieddate, 
				et.entitydescriptionstartdate, 
				et.entitydescriptionenddate, 
				et.entitydescriptionmodifiedby, 
				et.entitydescriptionexternalid, 
				et.entitydescriptionexternalsystementityuuid, 
				et.entitydescriptionrefid, 
				et.entitydescriptionrefuuid, 
				et.entitydescriptiondraft, 
				et.entitydescriptiondeleted,
			case when et.entitydescriptiondeleted then false
			when et.entitydescriptiondraft then false
			when et.entitydescriptionstartdate::Date > now()::date 
				and et.entitydescriptionenddate < now() then false
			else true
	end as entitydescriptionactive,
				et.entitydescriptionmimetypeuuid
			FROM entity.entitydescription et
			where et.entitydescriptiondeleted = ANY (tempentitydescriptionsenddeleted)
				 and et.entitydescriptiondraft = ANY (tempentitydescriptionsenddrafts)) as foo
		where foo.entitydescriptionactive = Any (tempentitydescriptionsendinactive
		) ;
		return;
end if;

if allowners = false and read_entitydescriptionentityuuid notNull  
	then
	return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et2.entitydescriptionuuid, 
				et2.entitydescriptionownerentityuuid, 
				et2.entitydescriptionentitytemplateentityuuid, 
				et2.entitydescriptionentityfieldentityduuid, 
				et2.entitydescriptionname, 
				et2.entitydescriptionlanguagemasteruuid,
				et2.entitydescriptionsoplink, 
				et2.entitydescriptionfile, 
				et2.entitydescriptionicon, 
				et2.entitydescriptioncreateddate, 
				et2.entitydescriptionmodifieddate, 
				et2.entitydescriptionstartdate, 
				et2.entitydescriptionenddate, 
				et2.entitydescriptionmodifiedby, 
				et2.entitydescriptionexternalid, 
				et2.entitydescriptionexternalsystementityuuid, 
				et2.entitydescriptionrefid, 
				et2.entitydescriptionrefuuid, 
				et2.entitydescriptiondraft, 
				et2.entitydescriptiondeleted,
			case when et2.entitydescriptiondeleted then false
			when et2.entitydescriptiondraft then false
			when et2.entitydescriptionstartdate::Date > now()::date 
				and et2.entitydescriptionenddate < now() then false
			else true
	end as entitydescriptionactive,
				et2.entitydescriptionmimetypeuuid
		FROM entity.entitydescription et2
		where (et2.entitydescriptionownerentityuuid = read_ownerentityuuid
					or et2.entitydescriptionownerentityuuid = tendreluuid) 
			and et2.entitydescriptionuuid = read_entitydescriptionentityuuid			
			and et2.entitydescriptiondeleted = ANY (tempentitydescriptionsenddeleted)
			and et2.entitydescriptiondraft = ANY (tempentitydescriptionsenddrafts)) as foo
		where foo.entitydescriptionactive = Any (tempentitydescriptionsendinactive
		) ;
		return;
end if;

if allowners = false and read_entityfieldentityuuid notNull
	then
		return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et3.entitydescriptionuuid, 
				et3.entitydescriptionownerentityuuid, 
				et3.entitydescriptionentitytemplateentityuuid, 
				et3.entitydescriptionentityfieldentityduuid, 
				et3.entitydescriptionname, 
				et3.entitydescriptionlanguagemasteruuid,
				et3.entitydescriptionsoplink, 
				et3.entitydescriptionfile, 
				et3.entitydescriptionicon, 
				et3.entitydescriptioncreateddate, 
				et3.entitydescriptionmodifieddate, 
				et3.entitydescriptionstartdate, 
				et3.entitydescriptionenddate, 
				et3.entitydescriptionmodifiedby, 
				et3.entitydescriptionexternalid, 
				et3.entitydescriptionexternalsystementityuuid, 
				et3.entitydescriptionrefid, 
				et3.entitydescriptionrefuuid, 
				et3.entitydescriptiondraft, 
				et3.entitydescriptiondeleted,
			case when et3.entitydescriptiondeleted then false
			when et3.entitydescriptiondraft then false
			when et3.entitydescriptionstartdate::Date > now()::date 
				and et3.entitydescriptionenddate < now() then false
			else true
	end as entitydescriptionactive,
				et3.entitydescriptionmimetypeuuid
			FROM entity.entitydescription et3
			where (et3.entitydescriptionownerentityuuid = read_ownerentityuuid
					or et3.entitydescriptionownerentityuuid = tendreluuid) 
				and et3.entitydescriptionentityfieldentityduuid = read_entityfieldentityuuid
				and et3.entitydescriptiondeleted = ANY (tempentitydescriptionsenddeleted)
				and et3.entitydescriptiondraft = ANY (tempentitydescriptionsenddrafts)) as foo
		where foo.entitydescriptionactive = Any (tempentitydescriptionsendinactive) ;
end if;

if allowners = false and read_entitytemplateentityuuid notNull
	then
		return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et4.entitydescriptionuuid, 
				et4.entitydescriptionownerentityuuid, 
				et4.entitydescriptionentitytemplateentityuuid, 
				et4.entitydescriptionentityfieldentityduuid, 
				et4.entitydescriptionname, 
				et4.entitydescriptionlanguagemasteruuid,
				et4.entitydescriptionsoplink, 
				et4.entitydescriptionfile, 
				et4.entitydescriptionicon, 
				et4.entitydescriptioncreateddate, 
				et4.entitydescriptionmodifieddate, 
				et4.entitydescriptionstartdate, 
				et4.entitydescriptionenddate, 
				et4.entitydescriptionmodifiedby, 
				et4.entitydescriptionexternalid, 
				et4.entitydescriptionexternalsystementityuuid, 
				et4.entitydescriptionrefid, 
				et4.entitydescriptionrefuuid, 
				et4.entitydescriptiondraft, 
				et4.entitydescriptiondeleted,
			case when et4.entitydescriptiondeleted then false
			when et4.entitydescriptiondraft then false
			when et4.entitydescriptionstartdate::Date > now()::date 
				and et4.entitydescriptionenddate < now() then false
			else true
	end as entitydescriptionactive,
				et4.entitydescriptionmimetypeuuid
			FROM entity.entitydescription et4
			where (et4.entitydescriptionownerentityuuid = read_ownerentityuuid
					or et4.entitydescriptionownerentityuuid = tendreluuid) 
				and et4.entitydescriptionentitytemplateentityuuid = read_entitytemplateentityuuid
				and et4.entitydescriptiondeleted = ANY (tempentitydescriptionsenddeleted)
				and et4.entitydescriptiondraft = ANY (tempentitydescriptionsenddrafts)) as foo
		where foo.entitydescriptionactive = Any (tempentitydescriptionsendinactive) ;
end if;

if allowners = false and read_entitytemplateentityuuid isNull 
	and read_entityfieldentityuuid isNull and read_entitydescriptionentityuuid isNull  
	then
	return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et5.entitydescriptionuuid, 
				et5.entitydescriptionownerentityuuid, 
				et5.entitydescriptionentitytemplateentityuuid, 
				et5.entitydescriptionentityfieldentityduuid, 
				et5.entitydescriptionname, 
				et5.entitydescriptionlanguagemasteruuid,
				et5.entitydescriptionsoplink, 
				et5.entitydescriptionfile, 
				et5.entitydescriptionicon, 
				et5.entitydescriptioncreateddate, 
				et5.entitydescriptionmodifieddate, 
				et5.entitydescriptionstartdate, 
				et5.entitydescriptionenddate, 
				et5.entitydescriptionmodifiedby, 
				et5.entitydescriptionexternalid, 
				et5.entitydescriptionexternalsystementityuuid, 
				et5.entitydescriptionrefid, 
				et5.entitydescriptionrefuuid, 
				et5.entitydescriptiondraft, 
				et5.entitydescriptiondeleted,
			case when et5.entitydescriptiondeleted then false
			when et5.entitydescriptiondraft then false
			when et5.entitydescriptionstartdate::Date > now()::date 
				and et5.entitydescriptionenddate < now() then false
			else true
	end as entitydescriptionactive,
				et5.entitydescriptionmimetypeuuid
		FROM entity.entitydescription et5
		where (et5.entitydescriptionownerentityuuid = read_ownerentityuuid
					or et5.entitydescriptionownerentityuuid = tendreluuid) 
			and et5.entitydescriptiondeleted = ANY (tempentitydescriptionsenddeleted)
			and et5.entitydescriptiondraft = ANY (tempentitydescriptionsenddrafts)) as foo
		where foo.entitydescriptionactive = Any (tempentitydescriptionsendinactive
		) ;
		return;
end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entitydescription_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitydescription_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitydescription_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entitydescription_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO graphql;

END;
