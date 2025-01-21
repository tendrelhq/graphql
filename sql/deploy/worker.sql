-- Deploy graphql:worker to pg
begin
;

create function
    util.create_worker(
        customer_id text, modified_by bigint, user_id text, user_role text
    )
returns table(_id bigint, id text)
as $$
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
$$
language sql
strict
;

commit
;
