BEGIN;

/*
DROP FUNCTION entity.crud_entitytag_read_min(uuid,uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_entitytag_read_min(uuid,uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entitytag_read_min(read_ownerentityuuid uuid, read_entitytagentityuuid uuid, read_entitytagentityinstanceuuid uuid, read_entitytagtemplateentityuuid uuid, read_entitytagcustagentityuuid uuid, read_allentitytags boolean, read_entitytagsenddeleted boolean, read_entitytagsenddrafts boolean, read_entitytagsendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, entitytaguuid uuid, entitytagownerentityuuid uuid, entitytagentityinstanceentityuuid uuid, entitytagentitytemplateentityuuid uuid, entitytagcreateddate timestamp with time zone, entitytagmodifieddate timestamp with time zone, entitytagstartdate timestamp with time zone, entitytagenddate timestamp with time zone, entitytagrefid bigint, entitytagrefuuid text, entitytagmodifiedbyuuid text, entitytagcustagentityuuid uuid, entitytagsenddeleted boolean, entitytagsenddrafts boolean, entitytagsendinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	tempentitytagsenddeleted boolean[]; 
	tempentitytagsenddrafts  boolean[];  
	tempentitytagsendinactive boolean[];
BEGIN

/*  examples

-- all customers all entitytags

select * from entity.crud_entitytag_read_min(null, null,null,null, null, true, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
limit 100

-- specific tag
select * from entity.crud_entitytag_read_min('ccda3933-c740-40ec-9a2b-a9f1a7d4db28','8cd49ef4-2b70-410b-85aa-4b67f617066a',null,null, null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- all tags for a specific instance
select * from entity.crud_entitytag_read_min('ccda3933-c740-40ec-9a2b-a9f1a7d4db28',null,'d57f7b9c-fe72-463a-9cc9-1cb03ad4a812',null, null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- all instances for a template
select * from entity.crud_entitytag_read_min('d7995576-8354-4aea-b052-1ce61052bd2e',null,null,'0b9f3142-e7ed-4f78-8504-ccd2eb505075', null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- all tags for a template no instances
select distinct entitytagcustagentityuuid from entity.crud_entitytag_read_min('d7995576-8354-4aea-b052-1ce61052bd2e',null,null,'0b9f3142-e7ed-4f78-8504-ccd2eb505075', null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- all instances for a tag
select * from entity.crud_entitytag_read_min('d7995576-8354-4aea-b052-1ce61052bd2e',null,null, null, 'e7e8223d-3480-42b5-9fc6-9dee59667fa3', false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

-- all instances for a template and a tag
select * from entity.crud_entitytag_read_min('d7995576-8354-4aea-b052-1ce61052bd2e',null,null, '0b9f3142-e7ed-4f78-8504-ccd2eb505075', 'e7e8223d-3480-42b5-9fc6-9dee59667fa3', false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')

*/

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if read_entitytagsenddeleted isNull and read_entitytagsenddeleted = false
	then tempentitytagsenddeleted = Array[false];
	else tempentitytagsenddeleted = Array[true,false];
end if;

if read_entitytagsenddrafts isNull and read_entitytagsenddrafts = false
	then tempentitytagsenddrafts = Array[false];
	else tempentitytagsenddrafts = Array[true,false];
end if;

if read_entitytagsendinactive isNull and read_entitytagsendinactive = false
	then tempentitytagsendinactive = Array[true];
	else tempentitytagsendinactive = Array[true,false];
end if;

if read_allentitytags = true
	then return query 
		select *
		from (SELECT 
		read_languagetranslationtypeentityuuid, 
	    et.entitytaguuid,
	    et.entitytagownerentityuuid,
	    et.entitytagentityinstanceentityuuid,
	    et.entitytagentitytemplateentityuuid,
	    et.entitytagcreateddate,
	    et.entitytagmodifieddate,
	    et.entitytagstartdate,
	    et.entitytagenddate,
	    et.entitytagrefid,
	    et.entitytagrefuuid,
	    et.entitytagmodifiedbyuuid,
	    et.entitytagcustagentityuuid,
		et.entitytagdeleted boolean,
		et.entitytagdraft boolean,
		case when et.entitytagdeleted then false
			when et.entitytagdraft then false
			when et.entitytagenddate::Date > now()::date 
				and et.entitytagstartdate < now() then false
		else true
	end as entitytagactive
	from entity.entitytag et
	where et.entitytagdeleted = ANY (tempentitytagsenddeleted)
				 and et.entitytagdraft = ANY (tempentitytagsenddrafts)) as foo
		where foo.entitytagactive = Any (tempentitytagsendinactive
		) ;
	return;
end if;

if read_entitytagentityuuid notNull
	then return query 
		select *
		from (SELECT 
		read_languagetranslationtypeentityuuid, 
	    et.entitytaguuid,
	    et.entitytagownerentityuuid,
	    et.entitytagentityinstanceentityuuid,
	    et.entitytagentitytemplateentityuuid,
	    et.entitytagcreateddate,
	    et.entitytagmodifieddate,
	    et.entitytagstartdate,
	    et.entitytagenddate,
	    et.entitytagrefid,
	    et.entitytagrefuuid,
	    et.entitytagmodifiedbyuuid,
	    et.entitytagcustagentityuuid,
		et.entitytagdeleted boolean,
		et.entitytagdraft boolean,
		case when et.entitytagdeleted then false
			when et.entitytagdraft then false
			when et.entitytagenddate::Date > now()::date 
				and et.entitytagstartdate < now() then false
		else true
	end as entitytagactive
	from entity.entitytag et
	where et.entitytaguuid = read_entitytagentityuuid
			and et.entitytagdeleted = ANY (tempentitytagsenddeleted)
			and et.entitytagdraft = ANY (tempentitytagsenddrafts)) as foo
		where foo.entitytagactive = Any (tempentitytagsendinactive
		) ;
	return;
end if;

if read_entitytagentityinstanceuuid notNull
	and read_ownerentityuuid notNull
	then return query 
		select *
		from (SELECT 
		read_languagetranslationtypeentityuuid, 
	    et.entitytaguuid,
	    et.entitytagownerentityuuid,
	    et.entitytagentityinstanceentityuuid,
	    et.entitytagentitytemplateentityuuid,
	    et.entitytagcreateddate,
	    et.entitytagmodifieddate,
	    et.entitytagstartdate,
	    et.entitytagenddate,
	    et.entitytagrefid,
	    et.entitytagrefuuid,
	    et.entitytagmodifiedbyuuid,
	    et.entitytagcustagentityuuid,
		et.entitytagdeleted boolean,
		et.entitytagdraft boolean,
		case when et.entitytagdeleted then false
			when et.entitytagdraft then false
			when et.entitytagenddate::Date > now()::date 
				and et.entitytagstartdate < now() then false
		else true
	end as entitytagactive
	from entity.entitytag et
	where et.entitytagentityinstanceentityuuid = read_entitytagentityinstanceuuid 
		and et.entitytagownerentityuuid = read_ownerentityuuid
			and et.entitytagdeleted = ANY (tempentitytagsenddeleted)
			and et.entitytagdraft = ANY (tempentitytagsenddrafts)) as foo
		where foo.entitytagactive = Any (tempentitytagsendinactive
		) ;
	return;
end if;	

if read_entitytagtemplateentityuuid  notNull
	and read_ownerentityuuid notNull
	and read_entitytagcustagentityuuid isNull
	then return query 
		select *
		from (SELECT 
		read_languagetranslationtypeentityuuid, 
	    et.entitytaguuid,
	    et.entitytagownerentityuuid,
	    et.entitytagentityinstanceentityuuid,
	    et.entitytagentitytemplateentityuuid,
	    et.entitytagcreateddate,
	    et.entitytagmodifieddate,
	    et.entitytagstartdate,
	    et.entitytagenddate,
	    et.entitytagrefid,
	    et.entitytagrefuuid,
	    et.entitytagmodifiedbyuuid,
	    et.entitytagcustagentityuuid,
		et.entitytagdeleted boolean,
		et.entitytagdraft boolean,
		case when et.entitytagdeleted then false
			when et.entitytagdraft then false
			when et.entitytagenddate::Date > now()::date 
				and et.entitytagstartdate < now() then false
		else true
	end as entitytagactive
	from entity.entitytag et
	where et.entitytagentitytemplateentityuuid = read_entitytagtemplateentityuuid  
		and et.entitytagownerentityuuid = read_ownerentityuuid
			and et.entitytagdeleted = ANY (tempentitytagsenddeleted)
			and et.entitytagdraft = ANY (tempentitytagsenddrafts)) as foo
		where foo.entitytagactive = Any (tempentitytagsendinactive
		) ;
	return;
end if;	

if read_entitytagcustagentityuuid  notNull
	and read_entitytagtemplateentityuuid  isNull
	and read_ownerentityuuid notNull
	then return query 
		select *
		from (SELECT 
		read_languagetranslationtypeentityuuid, 
	    et.entitytaguuid,
	    et.entitytagownerentityuuid,
	    et.entitytagentityinstanceentityuuid,
	    et.entitytagentitytemplateentityuuid,
	    et.entitytagcreateddate,
	    et.entitytagmodifieddate,
	    et.entitytagstartdate,
	    et.entitytagenddate,
	    et.entitytagrefid,
	    et.entitytagrefuuid,
	    et.entitytagmodifiedbyuuid,
	    et.entitytagcustagentityuuid,
		et.entitytagdeleted boolean,
		et.entitytagdraft boolean,
		case when et.entitytagdeleted then false
			when et.entitytagdraft then false
			when et.entitytagenddate::Date > now()::date 
				and et.entitytagstartdate < now() then false
		else true
	end as entitytagactive
	from entity.entitytag et
	where et.entitytagcustagentityuuid = read_entitytagcustagentityuuid
		and et.entitytagownerentityuuid = read_ownerentityuuid
			and et.entitytagdeleted = ANY (tempentitytagsenddeleted)
			and et.entitytagdraft = ANY (tempentitytagsenddrafts)) as foo
		where foo.entitytagactive = Any (tempentitytagsendinactive
		) ;
	return;
end if;	

if read_entitytagtemplateentityuuid  notNull
	and read_entitytagcustagentityuuid  notNull
	and read_ownerentityuuid notNull
	then return query 
		select *
		from (SELECT 
		read_languagetranslationtypeentityuuid, 
	    et.entitytaguuid,
	    et.entitytagownerentityuuid,
	    et.entitytagentityinstanceentityuuid,
	    et.entitytagentitytemplateentityuuid,
	    et.entitytagcreateddate,
	    et.entitytagmodifieddate,
	    et.entitytagstartdate,
	    et.entitytagenddate,
	    et.entitytagrefid,
	    et.entitytagrefuuid,
	    et.entitytagmodifiedbyuuid,
	    et.entitytagcustagentityuuid,
		et.entitytagdeleted boolean,
		et.entitytagdraft boolean,
		case when et.entitytagdeleted then false
			when et.entitytagdraft then false
			when et.entitytagenddate::Date > now()::date 
				and et.entitytagstartdate < now() then false
		else true
	end as entitytagactive
	from entity.entitytag et
	where et.entitytagentitytemplateentityuuid = read_entitytagtemplateentityuuid  
		and et.entitytagcustagentityuuid = read_entitytagcustagentityuuid
		and et.entitytagownerentityuuid = read_ownerentityuuid
			and et.entitytagdeleted = ANY (tempentitytagsenddeleted)
			and et.entitytagdraft = ANY (tempentitytagsenddrafts)) as foo
		where foo.entitytagactive = Any (tempentitytagsendinactive
		) ;
	return;
end if;	

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entitytag_read_min(uuid,uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytag_read_min(uuid,uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitytag_read_min(uuid,uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entitytag_read_min(uuid,uuid,uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO graphql;

END;
