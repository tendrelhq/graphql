-- noqa: disable=AM04

-- the code to "list all trackable entities";
select *
from public.location
where locationtypeid in (
    select systag.systagid
    from public.systag
    where
        systag.systagparentid = $1 -- 'Location Type'
        and systag.systagtype = 'Trackable'
);

-- in (keller's initial version of) the entity model we might use "tags";
with trackable as (
    select *
    from public.entity_tag
    where type_id = (
        select systag.systagid
        from public.systag
        where
            systag.systagparentid = $1 -- 'Entity Tag'
            and systag.systagtype = 'Trackable'
    )
)

select entity.*
from public.entity
inner join trackable
    on entity.id = trackable.entity
where entity.type = 'Location'
