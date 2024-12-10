-- noqa: disable=*
--
-- Seed script to facilitate trackable testing for the "yield" app.
-- We need:
-- 1. a customer: Frozen Tendy Factory
-- 2. five locations: Mixing, Fill, Assembly, Cartoning, Packaging (Line)
-- 3. work template (for each location? yes, because location category 1:1)

BEGIN; -- Customer setup.

WITH customer_name AS (
    INSERT INTO public.languagemaster (
        languagemastercustomerid,
        languagemastersourcelanguagetypeid,
        languagemastersource
    )
    VALUES (
        0,
        20,
        'Frozen Tendy Factory'
    )
    RETURNING languagemasterid AS _id
),

customer AS (
    INSERT INTO public.customer (
        customername,
        customerlanguagetypeid,
        customerlanguagetypeuuid,
        customernamelanguagemasterid
    )
    SELECT
        'Frozen Tendy Factory',
        systag.systagid,
        systag.systaguuid,
        customer_name._id
    FROM customer_name
    INNER JOIN public.systag
        ON systag.systagid = 20
    RETURNING customerid AS _id, customeruuid AS id
),

users AS (
    SELECT
        workerid AS _id,
        workeruuid AS id
    FROM public.worker
    WHERE workerid IN (
        354, -- Will Twait
        2859 -- Will Ruggiano
    )
),

workers AS (
    INSERT INTO public.workerinstance (
        workerinstancecustomerid,
        workerinstancecustomeruuid,
        workerinstanceworkerid,
        workerinstanceworkeruuid,
        workerinstancelanguageid,
        workerinstancelanguageuuid,
        workerinstanceuserroleid,
        workerinstanceuserroleuuid
    )
    SELECT
        c._id,
        c.id,
        u._id,
        u.id,
        l.systagid,
        l.systaguuid,
        r.systagid,
        r.systaguuid
    FROM customer AS c, users AS u
    INNER JOIN public.systag AS l
        ON l.systagid = 20 -- 'en'
    INNER JOIN public.systag AS r
        ON r.systagid = 775 -- 'Admin'
    RETURNING workerinstanceid AS _id, workerinstanceuuid AS id
)

SELECT
    'customer' AS "type",
    _id,
    id
FROM customer
UNION ALL
SELECT
    'worker' AS "type",
    _id,
    id
FROM workers;

COMMIT; -- Customer setup.
--    type   | _id  |                          id                          
-- ----------+------+------------------------------------------------------
--  customer |   99 | customer_83f6f643-132c-4255-ad9e-f3c37dc84885
--  worker   | 7640 | worker-instance_9c0a1f1b-7aa4-4de4-a352-ade204ade71a
--  worker   | 7641 | worker-instance_13b8e916-6796-4361-8274-13db950c1ff9
-- (3 rows)

BEGIN; -- Location setup.

WITH customer AS (
    SELECT
        customerid AS _id,
        customeruuid AS id
    FROM public.customer
    WHERE customerid = 99 -- or whatever the output above is
),

prefixes AS (
    SELECT *
    FROM unnest(ARRAY[
        'Mixing',
        'Fill',
        'Assembly',
        'Cartoning',
        'Packaging'
    ]) AS t (prefix)
),

location_names AS (
    INSERT INTO public.languagemaster (
        languagemastercustomerid,
        languagemastersourcelanguagetypeid,
        languagemastersource,
        languagemasterrefuuid -- but really just text
    )
    SELECT
        c._id,
        20,
        p.prefix || ' Line',
        p.prefix
    FROM
        customer AS c,
        prefixes AS p
    RETURNING languagemasterid AS _id, languagemasterrefuuid AS "ref"
),

location_categories AS (
    INSERT INTO public.custag (
        custagcustomerid,
        custagsystagid,
        custagtype
    )
    SELECT
        c._id,
        s.systagid,
        p.prefix || ' Tracking' -- e.g. "Assembly Tracking"
    FROM
        customer AS c,
        prefixes AS p,
        public.systag AS s
    WHERE s.systagtype = 'Trackable'
    RETURNING custagid AS _id, split_part(custagtype, ' ', 1) AS "ref"
),

locations AS (
    INSERT INTO public.location (
        locationcustomerid,
        locationistop,
        locationiscornerstone,
        locationcornerstoneorder,
        locationcategoryid,
        locationnameid,
        locationtimezone
    )
    SELECT
        c._id,
        true,
        false,
        0,
        lc._id,
        ln._id,
        'America/Denver'
    FROM
        customer AS c,
        location_names AS ln,
        location_categories AS lc
    WHERE ln.ref = lc.ref
    RETURNING locationid AS _id, locationuuid AS id
)

SELECT
    'location' AS "type",
    _id,
    id
FROM locations;

UPDATE public.location
SET locationsiteid = locationid
WHERE locationsiteid IS null AND locationcustomerid = 99;

COMMIT; -- Location setup.

BEGIN; -- Template setup.

WITH
    -- First things first, we need to create the "entrypoint"
    -- (or "root template") for this new trackable chain.
    root_name AS (
        INSERT INTO public.languagemaster (
            languagemastercustomerid,
            languagemastersourcelanguagetypeid,
            languagemastersource
        )
        VALUES (
            99,
            20,
            'Production'
        )
        RETURNING
            languagemastercustomerid AS _parent,
            languagemasterid AS _id
    ),

    root_template AS (
        INSERT INTO public.worktemplate (
            worktemplatecustomerid,
            worktemplatesiteid,
            worktemplatenameid,
            worktemplateallowondemand,
            worktemplateworkfrequencyid,
            worktemplateisauditable
        )
        SELECT
            l.locationcustomerid,
            l.locationid,
            n._id,
            true,
            1404,
            false
        FROM
            public.location AS l,
            root_name AS n
        WHERE l.locationcustomerid = n._parent
        RETURNING
            id,
            worktemplateid AS _id,
            worktemplatesiteid AS _parent
    ),

    tagged_entrypoint AS (
        INSERT INTO public.worktemplateconstraint (
            worktemplateconstraintcustomerid,
            worktemplateconstrainttemplateid,
            worktemplateconstraintconstrainedtypeid,
            worktemplateconstraintconstraintid
        )
        SELECT
            parent.locationcustomerid,
            root_template.id,
            root_type.systaguuid,
            user_type.custaguuid
        FROM root_template
        INNER JOIN public.systag AS root_type
            ON root_type.systagtype = 'Trackable'
        INNER JOIN public.location AS parent
            ON root_template._parent = parent.locationid
        INNER JOIN public.custag AS user_type
            ON parent.locationcategoryid = user_type.custagid
            AND user_type.custagsystagid = root_type.systagid
    ),

    -- Secondly we can create the "transition" templates. These templates
    -- represent the intermediate states that the overarching "tracking system"
    -- can be in at any given time (according to rules we have yet to define).
    transition_name AS (
        INSERT INTO public.languagemaster (
            languagemastercustomerid,
            languagemastersourcelanguagetypeid,
            languagemastersource
        )
        VALUES (
            99,
            20,
            'Planned Downtime'
        ), (
            99,
            20,
            'Unplanned Downtime'
        )
        RETURNING
            languagemastercustomerid AS _parent,
            languagemasterid AS _id
    ),

    transition_template AS (
        INSERT INTO public.worktemplate (
            worktemplatecustomerid,
            worktemplatesiteid,
            worktemplatenameid,
            worktemplateallowondemand,
            worktemplateworkfrequencyid,
            worktemplateisauditable
        )
        SELECT
            l.locationcustomerid,
            l.locationid,
            n._id,
            true,
            1404,
            false
        FROM
            public.location AS l,
            transition_name AS n
        WHERE l.locationcustomerid = n._parent
        RETURNING
            id,
            worktemplateid AS _id,
            worktemplatesiteid AS _parent
    ),

    -- Lastly, we must define the rules for our FSM. We only have the one set of
    -- rules that allow us to enter into the two "downtime" states.
    next_template_rules AS (
        INSERT INTO public.worktemplatenexttemplate (
            worktemplatenexttemplatecustomerid,
            worktemplatenexttemplatesiteid,
            worktemplatenexttemplateprevioustemplateid,
            worktemplatenexttemplatenexttemplateid,
            worktemplatenexttemplateviastatuschange,
            worktemplatenexttemplateviastatuschangeid,
            worktemplatenexttemplatetypeid
        )
        SELECT
            parent.locationcustomerid,
            parent.locationid,
            root_template._id,
            transition_template._id,
            true,
            s.systagid,
            t.systagid
        FROM root_template
        INNER JOIN transition_template ON true
        INNER JOIN public.location AS parent
            ON root_template._parent = parent.locationid
        INNER JOIN public.systag AS s
            ON (s.systagparentid, s.systagtype) = (705, 'In Progress')
        INNER JOIN public.systag AS t
            ON (t.systagparentid, t.systagtype) = (691, 'Task')
    )

    INSERT INTO public.worktemplatetype (
        worktemplatetypecustomerid,
        worktemplatetypeworktemplateuuid,
        worktemplatetypeworktemplateid,
        worktemplatetypesystaguuid,
        worktemplatetypesystagid
    )
    SELECT
        l.locationcustomerid,
        t.id,
        t._id,
        s.systaguuid,
        s.systagid
    FROM (
        SELECT *
        FROM root_template
        UNION ALL
        SELECT *
        FROM transition_template
    ) t
    INNER JOIN public.systag AS s
        ON s.systagtype = 'Trackable'
    INNER JOIN public.location AS l
        ON t._parent = l.locationid;

-- DELETE FROM public.worktemplateconstraint
-- WHERE worktemplateconstraintcustomerid = ??;
--
-- DELETE FROM public.worktemplatetype
-- WHERE worktemplatetypecustomerid = ??;
--
-- DELETE FROM public.customer
-- WHERE customerid = ??;

COMMIT; -- Template setup.
