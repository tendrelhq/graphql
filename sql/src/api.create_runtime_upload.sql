BEGIN;

/*
DROP TRIGGER create_runtime_upload_tg ON api.runtime_upload;

DROP FUNCTION api.create_runtime_upload();
*/


-- Type: FUNCTION ; Name: api.create_runtime_upload(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_runtime_upload()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.runtime_upload%rowtype;
    	ins_customeruuid text;
	ins_customerentityuuid uuid;
	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid)   ;

if (select new.owner_tendrel_id in (select * from _api.util_get_onwership()))
	then
		INSERT INTO entity.runtime_upload_staging(
			uploadowneruuid, 
			uploadbatchid, 
			uploadrecordid, 
			uploadpreviousrecordid, 
			uploadparentuuid, 
			uploadparentname, 
			uploadlocationuuid, 
			uploadlocationname, 
			uploadstartdate, 
			uploadenddate, 
			uploadduration, 
			uploademployee, 
			uploademployeeid, 
			uploademployeetendreluuid, 
			uploadactivityuuid, 
			uploadactivityname, 
			uploadreasoncodeuuid, 
			uploadreasoncodename, 
		    uploadunitrunoutput,	
		    uploadunitrejectcount,
			uploadresultuuid, 
			uploadresultname, 
			uploadunittypename, 
			uploadunittypeuuid, 
			uploadunitvalue,
			uploadrunid,
			languageid
			)
		values(
			new.owner_tendrel_id, 
			new.batch_id, 
			new.record_id, 
			new.previous_record_id, 
			new.parent_location_tendrel_id, 
			new.parent_location_name, 
			new.location_tendrel_id, 
			new.location_name, 
			new.start_date, 
			new.end_date, 
			new.duration, 
			new.worker, 
			new.worker_id, 
			new.worker_tendrel_id, 
			new.work_tendrel_id, 
			new.work_name, 
			new.reasoncode_tendrel_id, 
			new.reasoncode_name, 
			new.run_output,
		    new.reject_count,
			new.result_tendrel_id, 
			new.result_name, 
			null::text, 
			null::uuid, 
			new.value,
			new.run_id,
			ins_languagetypeid
			);
end if;

  select * into ins_row
  from api.runtime_upload
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_runtime_upload() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_runtime_upload() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_runtime_upload() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER create_runtime_upload_tg INSTEAD OF INSERT ON api.runtime_upload FOR EACH ROW EXECUTE FUNCTION api.create_runtime_upload();


END;
