-- noqa: disable=*
--
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

