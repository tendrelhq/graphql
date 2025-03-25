begin;
set local client_min_messages to 'notice';
set local search_path to tap;

select plan(12);

select set_config('user.id', 'user_2jJ7Xl0LFewQGKKNYwfFWAM0Lmc', true);
select set_config('user.locale', 'en', true);

create temporary table setup as (
  select btrim(op) as op, id
  from runtime.create_demo(
      customer_name := 'Frozen Tendy Factory',
      admins := (
          select array_agg(workeruuid)
          from public.worker
          where workerfullname = 'Jerry Garcia'
      ),
      modified_by := 895
  )
);

select set_config('test.customer', id, true)
from setup
where setup.op = '+customer'
limit 1;

select ok(current_setting('test.customer', true) is not null);

select set_config('test.template', id, true)
from setup
where setup.op = '+task'
limit 1;

select ok(current_setting('test.template', true) is not null);

select isnt_empty($$
  select e.*
  from
    engine1.delete_node('worktemplate', current_setting('test.template')) as op,
    engine1.execute(op.*) as e
$$);

select ok(worktemplatedeleted, 'should mark template as deleted')
from public.worktemplate
where id = current_setting('test.template');

select is_empty(
  $$
    select *
    from public.workinstance
    where
      workinstancestatusid != 711
      and workinstanceworktemplateid = (
          select worktemplateid
          from public.worktemplate
          where id = current_setting('test.template')
      )
  $$,
  'should reap all open instances'
);

-- Simulate a template in draft state:
update public.worktemplate
set worktemplatedeleted = false, worktemplatedraft = true
where id = current_setting('test.template');

-- Simulate template results in draft state:
update public.workresult
set workresultdraft = true
where
    workresultworktemplateid = (
        select worktemplateid
        from public.worktemplate
        where id = current_setting('test.template')
    )
    and workresultisprimary = false
;

select is(count(*), 3::bigint) -- Comments, Reject Count, Run Output
from public.workresult
where
    workresultworktemplateid = (
        select worktemplateid
        from public.worktemplate
        where id = current_setting('test.template')
    )
    and workresultdraft = true
;

select is(count(*), 5::bigint) -- Location, Worker, TAT, Override Start, Override End
from public.workresult
where
    workresultworktemplateid = (
        select worktemplateid
        from public.worktemplate
        where id = current_setting('test.template')
    )
    and workresultdraft = false
;

select isnt_empty($$
  with ops as (
    select *
    from engine1.set_worktemplatedraft(
        jsonb_build_array(
            jsonb_build_object(
                'id', current_setting('test.template'),
                'enabled', false
          )
        )
    )
  )
  select t.*
  from ops, engine1.execute(ops.*) as t
$$);

select is(count(*), 5::bigint, 'should have created 5 instances, one per location')
from public.workinstance
where
    workinstanceworktemplateid = (
        select worktemplateid
        from public.worktemplate
        where id = current_setting('test.template')
    )
    and workinstancestatusid = 706 -- Open
;

-- Only the 5 primaries are active at the moment, 1 per instance => 25
select is(count(*), (5 * 5)::bigint, 'should only instantiate active results')
from public.workresultinstance
where
    workresultinstanceworkinstanceid in (
        select workinstanceid
        from public.workinstance
        where
            workinstanceworktemplateid = (
                select worktemplateid
                from public.worktemplate
                where id = current_setting('test.template')
            )
            and workinstancestatusid = 706 -- Open
    )
;

select isnt_empty($$
  select e.*
  from
      engine1.publish_workresult((
          select jsonb_agg(workresult.id)
          from public.workresult
          where workresultworktemplateid = (
              select worktemplateid
              from public.worktemplate
              where id = current_setting('test.template')
          )
      )) as op,
      engine1.execute(op.*) as e
$$);

-- All results are now active for a total of 8, 1 per instance => 40
select is(count(*), (8 * 5)::bigint, 'should have instantiated previously draft results')
from public.workresultinstance
where
    workresultinstanceworkinstanceid in (
        select workinstanceid
        from public.workinstance
        where
            workinstanceworktemplateid = (
                select worktemplateid
                from public.worktemplate
                where id = current_setting('test.template')
            )
            and workinstancestatusid = 706 -- Open
    )
;

select * from finish();

rollback;
