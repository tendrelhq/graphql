-- noqa: disable=*
--
-- Seed script to facilitate trackable testing for the "yield" app.
-- We need:
-- 1. a customer: Frozen Tendy Factory
-- 2. five locations: Mixing, Fill, Assembly, Cartoning, Packaging (Line)
-- 3. work template (for each location? yes, because location category 1:1)
begin  -- Customer setup.
;

with
    customer_name as (
        insert into public.languagemaster(
            languagemastercustomerid,
            languagemastersourcelanguagetypeid,
            languagemastersource
        )
        values (0, 20, 'Frozen Tendy Factory')
        returning languagemasterid as _id
    ),

    customer as (
        insert into public.customer(
            customername,
            customerlanguagetypeid,
            customerlanguagetypeuuid,
            customernamelanguagemasterid
        )
        select
            'Frozen Tendy Factory',
            systag.systagid,
            systag.systaguuid,
            customer_name._id
        from customer_name
        inner join public.systag on systag.systagid = 20
        returning customerid as _id, customeruuid as id
    ),

    users as (
        select workerid as _id, workeruuid as id
        from public.worker
        where
            workerid in (
                354,  -- Will Twait
                2859  -- Will Ruggiano
            )
    ),

    workers as (
        insert into public.workerinstance(
            workerinstancecustomerid,
            workerinstancecustomeruuid,
            workerinstanceworkerid,
            workerinstanceworkeruuid,
            workerinstancelanguageid,
            workerinstancelanguageuuid,
            workerinstanceuserroleid,
            workerinstanceuserroleuuid
        )
        select
            c._id, c.id, u._id, u.id, l.systagid, l.systaguuid, r.systagid, r.systaguuid
        from customer as c, users as u
        inner join public.systag as l on l.systagid = 20  -- 'en'
        inner join public.systag as r on r.systagid = 775  -- 'Admin'
        returning workerinstanceid as _id, workerinstanceuuid as id
    )

select 'customer' as "type", _id, id
from customer
union all
select 'worker' as "type", _id, id
from workers
;

commit  -- Customer setup.
;
-- type   | _id  |                          id                          
-- ----------+------+------------------------------------------------------
-- customer |   99 | customer_83f6f643-132c-4255-ad9e-f3c37dc84885
-- worker   | 7640 | worker-instance_9c0a1f1b-7aa4-4de4-a352-ade204ade71a
-- worker   | 7641 | worker-instance_13b8e916-6796-4361-8274-13db950c1ff9
-- (3 rows)
begin  -- Location setup.
;

with
    customer as (
        select customerid as _id, customeruuid as id
        from public.customer
        where customerid = 99  -- or whatever the output above is
    ),

    prefixes as (
        select *
        from
            unnest(array['Mixing', 'Fill', 'Assembly', 'Cartoning', 'Packaging']) as t(
                prefix
            )
    ),

    location_names as (
        insert into public.languagemaster(
            languagemastercustomerid,
            languagemastersourcelanguagetypeid,
            languagemastersource,
            languagemasterrefuuid  -- but really just text
        )
        select c._id, 20, p.prefix || ' Line', p.prefix
        from customer as c, prefixes as p
        returning languagemasterid as _id, languagemasterrefuuid as "ref"
    ),

    location_categories as (
        insert into public.custag(custagcustomerid, custagsystagid, custagtype)
        select c._id, s.systagid, p.prefix || ' Tracking'  -- e.g. "Assembly Tracking"
        from customer as c, prefixes as p, public.systag as s
        where s.systagtype = 'Trackable'
        returning custagid as _id, split_part(custagtype, ' ', 1) as "ref"
    ),

    locations as (
        insert into public.location(
            locationcustomerid,
            locationistop,
            locationiscornerstone,
            locationcornerstoneorder,
            locationcategoryid,
            locationnameid,
            locationtimezone
        )
        select c._id, true, false, 0, lc._id, ln._id, 'America/Denver'
        from customer as c, location_names as ln, location_categories as lc
        where ln.ref = lc.ref
        returning locationid as _id, locationuuid as id
    )

select 'location' as "type", _id, id
from locations
;

UPDATE public.location
SET locationsiteid = locationid
WHERE locationsiteid IS null AND locationcustomerid = 99;

commit  -- Location setup.
;

begin  -- Template setup.
;

with
    -- First things first, we need to create the "entrypoint"
    -- (or "root template") for this new trackable chain.
    root_name as (
        insert into public.languagemaster(
            languagemastercustomerid,
            languagemastersourcelanguagetypeid,
            languagemastersource
        )
        values (99, 20, 'Production')
        returning languagemastercustomerid as _parent, languagemasterid as _id
    ),

    root_template as (
        insert into public.worktemplate(
            worktemplatecustomerid,
            worktemplatesiteid,
            worktemplatenameid,
            worktemplateallowondemand,
            worktemplateworkfrequencyid,
            worktemplateisauditable
        )
        select l.locationcustomerid, l.locationid, n._id, true, 1404, false
        from public.location as l, root_name as n
        where l.locationcustomerid = n._parent
        returning id, worktemplateid as _id, worktemplatesiteid as _parent
    ),

    tagged_entrypoint as (
        insert into public.worktemplateconstraint(
            worktemplateconstraintcustomerid,
            worktemplateconstrainttemplateid,
            worktemplateconstraintconstrainedtypeid,
            worktemplateconstraintconstraintid
        )
        select
            parent.locationcustomerid,
            root_template.id,
            root_type.systaguuid,
            user_type.custaguuid
        from root_template
        inner join public.systag as root_type on root_type.systagtype = 'Trackable'
        inner join
            public.location as parent on root_template._parent = parent.locationid
        inner join
            public.custag as user_type
            on parent.locationcategoryid = user_type.custagid
            and user_type.custagsystagid = root_type.systagid
    ),

    -- Secondly we can create the "transition" templates. These templates
    -- represent the intermediate states that the overarching "tracking system"
    -- can be in at any given time (according to rules we have yet to define).
    transition_name as (
        insert into public.languagemaster(
            languagemastercustomerid,
            languagemastersourcelanguagetypeid,
            languagemastersource
        )
        values (99, 20, 'Planned Downtime'), (99, 20, 'Unplanned Downtime')
        returning languagemastercustomerid as _parent, languagemasterid as _id
    ),

    transition_template as (
        insert into public.worktemplate(
            worktemplatecustomerid,
            worktemplatesiteid,
            worktemplatenameid,
            worktemplateallowondemand,
            worktemplateworkfrequencyid,
            worktemplateisauditable
        )
        select l.locationcustomerid, l.locationid, n._id, true, 1404, false
        from public.location as l, transition_name as n
        where l.locationcustomerid = n._parent
        returning id, worktemplateid as _id, worktemplatesiteid as _parent
    ),

    -- Lastly, we must define the rules for our FSM. We only have the one set of
    -- rules that allow us to enter into the two "downtime" states.
    next_template_rules as (
        insert into public.worktemplatenexttemplate(
            worktemplatenexttemplatecustomerid,
            worktemplatenexttemplatesiteid,
            worktemplatenexttemplateprevioustemplateid,
            worktemplatenexttemplatenexttemplateid,
            worktemplatenexttemplateviastatuschange,
            worktemplatenexttemplateviastatuschangeid,
            worktemplatenexttemplatetypeid
        )
        select
            parent.locationcustomerid,
            parent.locationid,
            root_template._id,
            transition_template._id,
            true,
            s.systagid,
            t.systagid
        from root_template
        inner join transition_template on true
        inner join
            public.location as parent on root_template._parent = parent.locationid
        inner join
            public.systag as s
            on (s.systagparentid, s.systagtype) = (705, 'In Progress')
        inner join
            public.systag as t on (t.systagparentid, t.systagtype) = (691, 'Task')
    )

    insert into public.worktemplatetype(
        worktemplatetypecustomerid,
        worktemplatetypeworktemplateuuid,
        worktemplatetypeworktemplateid,
        worktemplatetypesystaguuid,
        worktemplatetypesystagid
    )
select l.locationcustomerid, t.id, t._id, s.systaguuid, s.systagid
from
    (
        select *
        from root_template
        union all
        select *
        from transition_template
    ) t
inner join public.systag as s on s.systagtype = 'Trackable'
inner join public.location as l on t._parent = l.locationid
;

delete from public.worktemplateconstraint
where worktemplateconstraintcustomerid > 99
;

delete from public.worktemplatetype
where worktemplatetypecustomerid > 99
;

delete from public.customer
where customerid > 99
;

commit  -- Template setup.
;

