
-- Type: FUNCTION ; Name: legacy0.create_worker(text,text,text,bigint); Owner: bombadil

CREATE OR REPLACE FUNCTION legacy0.create_worker(customer_id text, user_id text, user_role text, modified_by bigint)
 RETURNS TABLE(_id bigint, id text)
 LANGUAGE sql
 STRICT
AS $function$
  insert into public.workerinstance (
      workerinstancecustomerid,
      workerinstancecustomeruuid,
      workerinstanceworkerid,
      workerinstanceworkeruuid,
      workerinstancelanguageid,
      workerinstancelanguageuuid,
      workerinstanceuserroleid,
      workerinstanceuserroleuuid,
      workerinstancemodifiedby
  )
  select
      c.customerid,
      c.customeruuid,
      u.workerid,
      u.workeruuid,
      l.systagid,
      l.systaguuid,
      r.systagid,
      r.systaguuid,
      modified_by
  from public.customer as c
  inner join public.worker as u
      on u.workeruuid = user_id
  inner join public.systag as l
      on u.workerlanguageid = l.systagid
  inner join public.systag as r
      on r.systagparentid = 772 and r.systagtype = user_role
  where c.customeruuid = customer_id
  returning workerinstanceid as _id, workerinstanceuuid as id;
$function$;


REVOKE ALL ON FUNCTION legacy0.create_worker(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_worker(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_worker(text,text,text,bigint) TO bombadil WITH GRANT OPTION;
