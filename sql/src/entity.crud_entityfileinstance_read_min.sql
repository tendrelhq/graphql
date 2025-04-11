
-- Type: FUNCTION ; Name: entity.crud_entityfileinstance_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid); Owner: bombadil

CREATE OR REPLACE FUNCTION entity.crud_entityfileinstance_read_min(read_ownerentityuuid uuid, read_entityfileinstanceentityuuid uuid, read_entityfileinstanceentityentityinstanceentityuuid uuid, read_entityfileinstanceentityfieldinstanceentityuuid uuid, read_entityfileinstancesenddeleted boolean, read_entityfileinstancesenddrafts boolean, read_entityfileinstancesendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(languagetranslationtypeuuid uuid, entityfileinstanceuuid uuid, entityfileinstanceownerentityuuid uuid, entityfileinstanceentityentityinstanceentityuuid uuid, entityfileinstanceentityfieldinstanceentityuuid uuid, entityfileinstancestoragelocation text, entityfileinstancemimetypeuuid uuid, entityfileinstancecreateddate timestamp with time zone, entityfileinstancemodifieddate timestamp with time zone, entityfileinstanceexternalid text, entityfileinstanceexternalsystemuuid uuid, entityfileinstancemodifiedby text, entityfileinstancerefid bigint, entityfileinstancerefuuid text, entityfileinstancedraft boolean, entityfileinstancedeleted boolean, entityfileinstanceinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	templanguagetranslationtypeid bigint;
	tempentityfileinstancesenddeleted boolean[]; 
	tempentityfileinstancesenddrafts  boolean[];  
	tempentityfileinstancesendinactive boolean[];
	tendreluuid uuid;
BEGIN

/*  Examples

-- all file instances
select * from entity.crud_entityfileinstance_read_min(null, null, null,null, null, null,null,null)

-- all file instances for an owner
select * from entity.crud_entityfileinstance_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,null, null, null,null,null)

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if read_languagetranslationtypeuuid isNull
	then read_languagetranslationtypeuuid = (
		select systagentityuuid 
		from entity.crud_systag_read_min(	tendreluuid, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,read_entityfileinstancesenddeleted, read_entityfileinstancesenddrafts,read_entityfileinstancesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
		); 
end if;

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if read_entityfileinstancesenddeleted isNull and read_entityfileinstancesenddeleted = false
	then tempentityfileinstancesenddeleted = Array[false];
	else tempentityfileinstancesenddeleted = Array[true,false];
end if;

if read_entityfileinstancesenddrafts isNull and read_entityfileinstancesenddrafts = false
	then tempentityfileinstancesenddrafts = Array[false];
	else tempentityfileinstancesenddrafts = Array[true,false];
end if;

if read_entityfileinstancesendinactive isNull and read_entityfileinstancesendinactive = false
	then tempentityfileinstancesendinactive = Array[true];
	else tempentityfileinstancesendinactive = Array[true,false];
end if;

-- probably can do this cealner with less sql

if allowners = true and (read_entityfileinstanceentityuuid isNull)
	then
	return query 
		select *
		from (
			SELECT
				read_languagetranslationtypeuuid,
				efi.entityfileinstanceuuid,
				efi.entityfileinstanceownerentityuuid, 
				efi.entityfileinstanceentityentityinstanceentityuuid, 
				efi.entityfileinstanceentityfieldinstanceentityuuid, 
				efi.entityfileinstancestoragelocation, 
				efi.entityfileinstancemimetypeuuid, 
				efi.entityfileinstancecreateddate, 
				efi.entityfileinstancemodifieddate, 
				efi.entityfileinstanceexternalid, 
				efi.entityfileinstanceexternalsystemuuid, 
				efi.entityfileinstancemodifiedby, 
				efi.entityfileinstancerefid, 
				efi.entityfileinstancerefuuid, 
				efi.entityfileinstancedraft, 
				efi.entityfileinstancedeleted,
				efi.entityfileinstancedeleted as entityfileinstancesendinactive
		FROM entity.entityfileinstance	efi	
			where efi.entityfileinstancedeleted = ANY (tempentityfileinstancesenddeleted)
				 and efi.entityfileinstancedraft = ANY (tempentityfileinstancesenddrafts)) as foo
		where foo.entityfileinstancesendinactive = Any (tempentityfileinstancesendinactive) ;
		return;
end if;

if allowners = false and read_entityfileinstanceentityuuid notNull  
	then
	return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				efi.entityfileinstanceuuid,
				efi.entityfileinstanceownerentityuuid, 
				efi.entityfileinstanceentityentityinstanceentityuuid, 
				efi.entityfileinstanceentityfieldinstanceentityuuid, 
				efi.entityfileinstancestoragelocation, 
				efi.entityfileinstancemimetypeuuid, 
				efi.entityfileinstancecreateddate, 
				efi.entityfileinstancemodifieddate, 
				efi.entityfileinstanceexternalid, 
				efi.entityfileinstanceexternalsystemuuid, 
				efi.entityfileinstancemodifiedby, 
				efi.entityfileinstancerefid, 
				efi.entityfileinstancerefuuid, 
				efi.entityfileinstancedraft, 
				efi.entityfileinstancedeleted,
				efi.entityfileinstancedeleted as entityfileinstancesendinactive
		FROM entity.entityfileinstance	efi	
		where (efi.entityfileinstanceownerentityuuid = read_ownerentityuuid
					or efi.entityfileinstanceownerentityuuid = tendreluuid) 
			and efi.entityfileinstanceuuid = read_entityfileinstanceentityuuid			
			and efi.entityfileinstancedeleted = ANY (tempentityfileinstancesenddeleted)
			and efi.entityfileinstancedraft = ANY (tempentityfileinstancesenddrafts)) as foo
		where foo.entityfileinstancesendinactive = Any (tempentityfileinstancesendinactive
		) ;
		return;
end if;

if allowners = false and read_entityfileinstanceentityentityinstanceentityuuid  notNull
	then
		return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				efi.entityfileinstanceuuid,
				efi.entityfileinstanceownerentityuuid, 
				efi.entityfileinstanceentityentityinstanceentityuuid, 
				efi.entityfileinstanceentityfieldinstanceentityuuid, 
				efi.entityfileinstancestoragelocation, 
				efi.entityfileinstancemimetypeuuid, 
				efi.entityfileinstancecreateddate, 
				efi.entityfileinstancemodifieddate, 
				efi.entityfileinstanceexternalid, 
				efi.entityfileinstanceexternalsystemuuid, 
				efi.entityfileinstancemodifiedby, 
				efi.entityfileinstancerefid, 
				efi.entityfileinstancerefuuid, 
				efi.entityfileinstancedraft, 
				efi.entityfileinstancedeleted,
				efi.entityfileinstancedeleted as entityfileinstancesendinactive
		FROM entity.entityfileinstance	efi	
			where (efi.entityfileinstanceownerentityuuid = read_ownerentityuuid
					or efi.entityfileinstanceownerentityuuid = tendreluuid) 
				and efi.entityfileinstanceentityentityinstanceentityuuid = read_entityfileinstanceentityentityinstanceentityuuid 
				and efi.entityfileinstancedeleted = ANY (tempentityfileinstancesenddeleted)
				and efi.entityfileinstancedraft = ANY (tempentityfileinstancesenddrafts)) as foo
		where foo.entityfileinstancesendinactive = Any (tempentityfileinstancesendinactive) ;
end if;

if allowners = false and read_entityfileinstanceentityfieldinstanceentityuuid notNull
	then
		return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				efi.entityfileinstanceuuid,
				efi.entityfileinstanceownerentityuuid, 
				efi.entityfileinstanceentityentityinstanceentityuuid, 
				efi.entityfileinstanceentityfieldinstanceentityuuid, 
				efi.entityfileinstancestoragelocation, 
				efi.entityfileinstancemimetypeuuid, 
				efi.entityfileinstancecreateddate, 
				efi.entityfileinstancemodifieddate, 
				efi.entityfileinstanceexternalid, 
				efi.entityfileinstanceexternalsystemuuid, 
				efi.entityfileinstancemodifiedby, 
				efi.entityfileinstancerefid, 
				efi.entityfileinstancerefuuid, 
				efi.entityfileinstancedraft, 
				efi.entityfileinstancedeleted,
				efi.entityfileinstancedeleted as entityfileinstancesendinactive
		FROM entity.entityfileinstance	efi	
			where (efi.entityfileinstanceownerentityuuid = read_ownerentityuuid
					or efi.entityfileinstanceownerentityuuid = tendreluuid) 
				and efi.entityfileinstanceentityfieldinstanceentityuuid = read_entityfileinstanceentityfieldinstanceentityuuid
				and efi.entityfileinstancedeleted = ANY (tempentityfileinstancesenddeleted)
				and efi.entityfileinstancedraft = ANY (tempentityfileinstancesenddrafts)) as foo
		where foo.entityfileinstancesendinactive = Any (tempentityfileinstancesendinactive) ;
end if;

if allowners = false and read_entityfileinstanceentityfieldinstanceentityuuid isNull 
	and read_entityfileinstanceentityuuid isNull and read_entityfileinstanceentityentityinstanceentityuuid isNull  
	then
	return query 
		select *
		from (
			SELECT
				read_languagetranslationtypeuuid,
				efi.entityfileinstanceuuid,
				efi.entityfileinstanceownerentityuuid, 
				efi.entityfileinstanceentityentityinstanceentityuuid, 
				efi.entityfileinstanceentityfieldinstanceentityuuid, 
				efi.entityfileinstancestoragelocation, 
				efi.entityfileinstancemimetypeuuid, 
				efi.entityfileinstancecreateddate, 
				efi.entityfileinstancemodifieddate, 
				efi.entityfileinstanceexternalid, 
				efi.entityfileinstanceexternalsystemuuid, 
				efi.entityfileinstancemodifiedby, 
				efi.entityfileinstancerefid, 
				efi.entityfileinstancerefuuid, 
				efi.entityfileinstancedraft, 
				efi.entityfileinstancedeleted,
				efi.entityfileinstancedeleted as entityfileinstancesendinactive
		FROM entity.entityfileinstance	efi	
			where (efi.entityfileinstanceownerentityuuid = read_ownerentityuuid
					or efi.entityfileinstanceownerentityuuid = tendreluuid) 
					and efi.entityfileinstancedeleted = ANY (tempentityfileinstancesenddeleted)
				 	and efi.entityfileinstancedraft = ANY (tempentityfileinstancesenddrafts)
				 ) as foo
		where foo.entityfileinstancesendinactive = Any (tempentityfileinstancesendinactive) ;
		return;
end if;	


End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entityfileinstance_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfileinstance_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfileinstance_read_min(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO bombadil WITH GRANT OPTION;
