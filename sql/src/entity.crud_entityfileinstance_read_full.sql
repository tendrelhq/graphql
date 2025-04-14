
-- Type: FUNCTION ; Name: entity.crud_entityfileinstance_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entityfileinstance_read_full(read_ownerentityuuid uuid, read_entityfileinstanceentityuuid uuid, read_entityfileinstanceentityentityinstanceentityuuid uuid, read_entityfileinstanceentityfieldinstanceentityuuid uuid, read_entityfileinstancesenddeleted boolean, read_entityfileinstancesenddrafts boolean, read_entityfileinstancesendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(languagetranslationtypeuuid uuid, entityfileinstanceuuid uuid, entityfileinstanceownerentityuuid uuid, entityfileinstanceownerentityname text, entityfileinstanceentityentityinstanceentityuuid uuid, entityfileinstanceentityentityinstanceentityname text, entityfileinstanceentityfieldinstanceentityuuid uuid, entityfileinstanceentityfieldinstanceentityname text, entityfileinstancestoragelocation text, entityfileinstancemimetypeuuid uuid, entityfileinstancemimetypename text, entityfileinstancecreateddate timestamp with time zone, entityfileinstancemodifieddate timestamp with time zone, entityfileinstanceexternalid text, entityfileinstanceexternalsystemuuid uuid, entityfileinstancemodifiedbyuuid text, entityfileinstancerefid bigint, entityfileinstancerefuuid text, entityfileinstancedraft boolean, entityfileinstancedeleted boolean, entityfileinstanceinactive boolean)
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
select * from entity.crud_entityfileinstance_read_full(null, null, null,null, null, null,null,null)

-- all file instances for an owner
select * from entity.crud_entityfileinstance_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,null, null, null,null,null)

-- all file instances for a fileinstanceuuid
select * from entity.crud_entityfileinstance_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', 'b19d4a6d-151b-4924-88c8-da66b64f0658', null,null, null, null,null,null)

-- all file instances for a instanceuuid
select * from entity.crud_entityfileinstance_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, '87fc6238-1c3d-4f34-8a38-609855ab94ab',null, null, null,null,null)

-- all file instances for a fieldinstanceuuid
select * from entity.crud_entityfileinstance_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,'6d29bc9a-f37f-43e4-81c0-b34a940ae1f9', null, null,null,null)


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
				cust.customername,				
				efi.entityfileinstanceentityentityinstanceentityuuid, 
				ei.entityinstancename,
				efi.entityfileinstanceentityfieldinstanceentityuuid, 
				efield.entityfieldinstanceentityfieldname,
				efi.entityfileinstancestoragelocation, 
				efi.entityfileinstancemimetypeuuid, 
				mime.systagtype,				
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
				inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entityfileinstancesenddeleted,read_entityfileinstancesenddrafts,read_entityfileinstancesendinactive, null)) as cust
					on cust.customerentityuuid = efi.entityfileinstanceownerentityuuid
						and efi.entityfileinstancedeleted = ANY (tempentityfileinstancesenddeleted)
					 	and efi.entityfileinstancedraft = ANY (tempentityfileinstancesenddrafts)
				left join (select * 
							from entity.crud_entityinstance_read_full(
								read_ownerentityuuid,null,null,null,null,null,true,null,null,null,null,read_languagetranslationtypeuuid)) as ei				
					on ei.entityinstanceuuid = efi.entityfileinstanceentityentityinstanceentityuuid
				left join (select * 
							from entity.crud_entityfieldinstance_read_full(
							read_ownerentityuuid,null, null,true,null,null,null,read_languagetranslationtypeuuid)) as	efield	
					on efield.entityfieldinstanceuuid = efi.entityfileinstanceentityfieldinstanceentityuuid
				inner join (select * from entity.crud_systag_read_full(tendreluuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,read_languagetranslationtypeuuid)) as mime
					on mime.systagentityuuid = efi.entityfileinstancemimetypeuuid
			) as foo
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
				cust.customername,				
				efi.entityfileinstanceentityentityinstanceentityuuid, 
				ei.entityinstancename,
				efi.entityfileinstanceentityfieldinstanceentityuuid, 
				efield.entityfieldinstanceentityfieldname,
				efi.entityfileinstancestoragelocation, 
				efi.entityfileinstancemimetypeuuid, 
				mime.systagtype,				
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
				inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entityfileinstancesenddeleted,read_entityfileinstancesenddrafts,read_entityfileinstancesendinactive, null)) as cust
					on cust.customerentityuuid = efi.entityfileinstanceownerentityuuid
						and (efi.entityfileinstanceownerentityuuid = read_ownerentityuuid
							or efi.entityfileinstanceownerentityuuid = tendreluuid) 
						and efi.entityfileinstancedeleted = ANY (tempentityfileinstancesenddeleted)
					 	and efi.entityfileinstancedraft = ANY (tempentityfileinstancesenddrafts)
						and efi.entityfileinstanceuuid = read_entityfileinstanceentityuuid	
				left join (select * 
							from entity.crud_entityinstance_read_full(
								read_ownerentityuuid,null,null,null,null,null,true,null,null,null,null,read_languagetranslationtypeuuid)) as ei				
					on ei.entityinstanceuuid = efi.entityfileinstanceentityentityinstanceentityuuid
				left join (select * 
							from entity.crud_entityfieldinstance_read_full(
							read_ownerentityuuid,null, null,true,null,null,null,read_languagetranslationtypeuuid)) as	efield	
					on efield.entityfieldinstanceuuid = efi.entityfileinstanceentityfieldinstanceentityuuid
				inner join (select * from entity.crud_systag_read_full(tendreluuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,read_languagetranslationtypeuuid)) as mime
					on mime.systagentityuuid = efi.entityfileinstancemimetypeuuid
			) as foo
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
				cust.customername,				
				efi.entityfileinstanceentityentityinstanceentityuuid, 
				ei.entityinstancename,
				efi.entityfileinstanceentityfieldinstanceentityuuid, 
				efield.entityfieldinstanceentityfieldname,
				efi.entityfileinstancestoragelocation, 
				efi.entityfileinstancemimetypeuuid, 
				mime.systagtype,				
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
				inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entityfileinstancesenddeleted,read_entityfileinstancesenddrafts,read_entityfileinstancesendinactive, null)) as cust
					on cust.customerentityuuid = efi.entityfileinstanceownerentityuuid
						and (efi.entityfileinstanceownerentityuuid = read_ownerentityuuid
							or efi.entityfileinstanceownerentityuuid = tendreluuid)  
						and efi.entityfileinstanceentityentityinstanceentityuuid = read_entityfileinstanceentityentityinstanceentityuuid 
						and efi.entityfileinstancedeleted = ANY (tempentityfileinstancesenddeleted)
						and efi.entityfileinstancedraft = ANY (tempentityfileinstancesenddrafts)
				left join (select * 
							from entity.crud_entityinstance_read_full(
								read_ownerentityuuid,null,null,null,null,null,true,null,null,null,null,read_languagetranslationtypeuuid)) as ei				
					on ei.entityinstanceuuid = efi.entityfileinstanceentityentityinstanceentityuuid
				left join (select * 
							from entity.crud_entityfieldinstance_read_full(
							read_ownerentityuuid,null, null,true,null,null,null,read_languagetranslationtypeuuid)) as	efield	
					on efield.entityfieldinstanceuuid = efi.entityfileinstanceentityfieldinstanceentityuuid
				inner join (select * from entity.crud_systag_read_full(tendreluuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,read_languagetranslationtypeuuid)) as mime
					on mime.systagentityuuid = efi.entityfileinstancemimetypeuuid) as foo
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
				cust.customername,				
				efi.entityfileinstanceentityentityinstanceentityuuid, 
				ei.entityinstancename,
				efi.entityfileinstanceentityfieldinstanceentityuuid, 
				efield.entityfieldinstanceentityfieldname,
				efi.entityfileinstancestoragelocation, 
				efi.entityfileinstancemimetypeuuid, 
				mime.systagtype,				
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
				inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entityfileinstancesenddeleted,read_entityfileinstancesenddrafts,read_entityfileinstancesendinactive, null)) as cust
					on cust.customerentityuuid = efi.entityfileinstanceownerentityuuid
						and (efi.entityfileinstanceownerentityuuid = read_ownerentityuuid
							or efi.entityfileinstanceownerentityuuid = tendreluuid) 
						and efi.entityfileinstanceentityfieldinstanceentityuuid = read_entityfileinstanceentityfieldinstanceentityuuid 
						and efi.entityfileinstancedeleted = ANY (tempentityfileinstancesenddeleted)
						and efi.entityfileinstancedraft = ANY (tempentityfileinstancesenddrafts)
				left join (select * 
							from entity.crud_entityinstance_read_full(
								read_ownerentityuuid,null,null,null,null,null,true,null,null,null,null,read_languagetranslationtypeuuid)) as ei				
					on ei.entityinstanceuuid = efi.entityfileinstanceentityentityinstanceentityuuid
				left join (select * 
							from entity.crud_entityfieldinstance_read_full(
							read_ownerentityuuid,null, null,true,null,null,null,read_languagetranslationtypeuuid)) as	efield	
					on efield.entityfieldinstanceuuid = efi.entityfileinstanceentityfieldinstanceentityuuid
				inner join (select * from entity.crud_systag_read_full(tendreluuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,read_languagetranslationtypeuuid)) as mime
					on mime.systagentityuuid = efi.entityfileinstancemimetypeuuid) as foo
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
				cust.customername,				
				efi.entityfileinstanceentityentityinstanceentityuuid, 
				ei.entityinstancename,
				efi.entityfileinstanceentityfieldinstanceentityuuid, 
				efield.entityfieldinstanceentityfieldname,
				efi.entityfileinstancestoragelocation, 
				efi.entityfileinstancemimetypeuuid, 
				mime.systagtype,				
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
				inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entityfileinstancesenddeleted,read_entityfileinstancesenddrafts,read_entityfileinstancesendinactive, null)) as cust
					on cust.customerentityuuid = efi.entityfileinstanceownerentityuuid
						and (efi.entityfileinstanceownerentityuuid = read_ownerentityuuid
							or efi.entityfileinstanceownerentityuuid = tendreluuid) 
						and efi.entityfileinstancedeleted = ANY (tempentityfileinstancesenddeleted)
					 	and efi.entityfileinstancedraft = ANY (tempentityfileinstancesenddrafts)
				left join (select * 
							from entity.crud_entityinstance_read_full(
								read_ownerentityuuid,null,null,null,null,null,true,null,null,null,null,read_languagetranslationtypeuuid)) as ei				
					on ei.entityinstanceuuid = efi.entityfileinstanceentityentityinstanceentityuuid
				left join (select * 
							from entity.crud_entityfieldinstance_read_full(
							read_ownerentityuuid,null, null,true,null,null,null,read_languagetranslationtypeuuid)) as	efield	
					on efield.entityfieldinstanceuuid = efi.entityfileinstanceentityfieldinstanceentityuuid
				inner join (select * from entity.crud_systag_read_full(tendreluuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,read_languagetranslationtypeuuid)) as mime
					on mime.systagentityuuid = efi.entityfileinstancemimetypeuuid
			) as foo
		where foo.entityfileinstancesendinactive = Any (tempentityfileinstancesendinactive) ;
		return;
end if;	



End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entityfileinstance_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfileinstance_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfileinstance_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
