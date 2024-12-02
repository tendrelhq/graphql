-- noqa: disable=AM04
begin;

-- create trackable systag
with name as (
    insert into public.languagemaster (
        languagemastercustomerid,
        languagemastersource,
        languagemastersourcelanguagetypeid
    )
    select
        systagcustomerid,
        'Trackable',
        systagid
    from public.systag
    where systagtype = 'Language'
    returning languagemasterid as id
)
insert into public.systag (
    systagcustomerid,
    systagtype,
    systagparentid,
    systagnameid
)
select
    systagcustomerid,
    'Trackable',
    systagid,
    name.id
from public.systag, name
where systagtype = 'Tag';

-- create user-defined "trackable" sub-type
insert into public.custag (
    custagcustomerid,
    custagsystagid,
    custagtype
)
select
    $1, -- REPLACE WITH YOUR CUSTOMER ID
    systagid,
    'Please track me'
from public.systag
where systagtype = 'Trackable'
returning custagid as id;

-- hack: change my existing location to have this category
update public.location
set locationcategoryid = custagid
from public.custag
where
    locationcustomerid = $1 -- REPLACE WITH YOUR CUSTOMER ID
    and custagcustomerid = $1 -- REPLACE WITH YOUR CUSTOMER ID
    and custagtype = 'Please track me'
returning locationid as id, locationcategoryid as type;

-- hack: opt an existing worktemplate into tracking
with tagged as (
    insert into public.worktemplatetype (
        worktemplatetypecustomerid,
        worktemplatetypeworktemplateuuid,
        worktemplatetypeworktemplateid,
        worktemplatetypesystaguuid,
        worktemplatetypesystagid
    )
    select
        wt.worktemplatecustomerid,
        wt.id,
        wt.worktemplateid,
        s.systaguuid,
        s.systagid
    from public.worktemplate as wt, public.systag as s
    where
        wt.worktemplatecustomerid = $1 -- REPLACE WITH YOUR CUSTOMER ID
        and s.systagtype = 'Trackable'
    limit 1
    returning worktemplatetypeworktemplateid as id
)

insert into public.worktemplateconstraint (
    worktemplateconstraintcustomerid,
    worktemplateconstrainttemplateid,
    worktemplateconstraintconstrainedtypeid,
    worktemplateconstraintconstraintid
)
select
    c.custagcustomerid,
    wt.id,
    s.systaguuid,
    c.custaguuid
from tagged as t
inner join public.worktemplate as wt
    on t.id = wt.worktemplateid
inner join public.systag as s
    on s.systagtype = 'Trackable'
inner join public.custag as c
    on
        wt.worktemplatecustomerid = c.custagcustomerid
        and c.custagtype = 'Please track me'
returning worktemplateconstraintid as id;

commit;
