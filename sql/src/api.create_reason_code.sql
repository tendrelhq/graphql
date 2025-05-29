BEGIN;

/*
DROP FUNCTION api.create_reason_code();
*/


-- Type: FUNCTION ; Name: api.create_reason_code(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_reason_code()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_bigint bigint;
  ins_text text;
  ins_entity uuid;
  ins_row api.custag%rowtype;
 	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
	ins_customerentityuuid uuid;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid);

if (select new.owner in (select * from _api.util_get_onwership()))
	then
	  call entity.crud_custag_create(
	  		create_custagownerentityuuid := new.owner, 
			create_custagparententityuuid := 'f875b28c-ccc9-4c69-b5b4-9f10ad89d23b', 
			create_custagcornerstoneentityuuid := new.cornerstone, 
			create_custagcornerstoneorder := new._order, 
			create_custag := new.type, 
			create_languagetypeuuid := ins_languagetypeentityuuid, 
			create_custagexternalid := new.external_id, 
			create_custagexternalsystemuuid := new.external_system,
			create_custagdeleted := new._deleted, 
			create_custagdraft := new._draft, 
			create_custagid := ins_bigint, 
			create_custaguuid := ins_text, 
			create_custagentityuuid := ins_entity, 
			create_modifiedbyid := ins_userid  
	  );
	-- NEED TO MAKE SURE CREATE RETURNS THE ID IF IT ALREADT EXISTS
	-- Now add the constraint

	if new.work_template notNull
		then
			INSERT INTO public.worktemplateconstraint(
				worktemplateconstraintcreateddate, 
				worktemplateconstraintmodifieddate, 
				worktemplateconstraintmodifiedby, 
				worktemplateconstraintrefid, 
				worktemplateconstraintrefuuid, 
				worktemplateconstraintconstrainedtypeid, 
				worktemplateconstraintconstraintid, 
				worktemplateconstrainttemplateid, 
				worktemplateconstraintresultid, 
				worktemplateconstraintcustomerid, 
				worktemplateconstraintcustomeruuid)
			select 
				now(),
				now(),
				ins_userid,
				null,
				null,
				'systag_4bbc3e18-de10-4f93-aabb-b1d051a2923d',
				ins_text,
				work_template,
				wr.id,
				wt.worktemplatecustomerid,
				(select customeruuid from public.customer where customerid = worktemplatecustomerid)
			from worktemplate wt
				inner join view_workresult wr
					on  workresultworktemplateid = worktemplateid
						and worktemplateid = work_template
						and languagetranslationtypeid = 20
						and workresultname = 'Reason Code'
				left join public.worktemplateconstraint
					on worktemplateconstrainttemplateid = wt.id
						and worktemplateconstraintresultid = wr.id
						and custagsystaguuid = worktemplateconstraintconstrainedtypeid
						and custaguuid = worktemplateconstraintconstraintid
						and custagcustomerid = worktemplateconstraintcustomerid
			where worktemplateconstraintid isNull;
	end if;  
end if;

  select * into ins_row
  from api.reason_code
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_reason_code() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_reason_code() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_reason_code() TO authenticated;

END;
