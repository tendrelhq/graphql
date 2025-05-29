BEGIN;

/*
DROP PROCEDURE entity.enable_runtime(uuid,text,uuid,text,uuid,text,bigint,text);
*/


-- Type: PROCEDURE ; Name: entity.enable_runtime(uuid,text,uuid,text,uuid,text,bigint,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.enable_runtime(IN create_customer_uuid uuid, IN create_original_customer_uuid text, IN create_site_uuid uuid, IN create_original_site_uuid text, IN create_language_type_uuid uuid, IN create_original_language_type_uuid text, IN modified_by bigint, IN timezone text, OUT testlog text)
 LANGUAGE plpgsql
AS $procedure$
declare

  ins_locations text[];
  ins_template text;
  ins_template_type_n bigint;
  runtime_config_template_uuid text;
  runtime_config_uuid text;
  create_locationentityuuid uuid;
  testtext text;
  
  -- language uuids
  	englishentityuuid uuid;
	englishoriginaluuid text;
	temp_language_type text;
	languageuuid uuid;
	tendreluuid uuid;
 
begin

------------------------------------------------------------------
-- Start setting the missing values
-- grab originaluuids or entityuuids depending on what was sent in
-------------------------------------------------------------------

-- setup language variables.  If there is no language type sent in default to english.  
-- Set these as variables just incast the uuids change in the future.

	tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';
	languageuuid = '580f6ee2-42ca-4a5b-9e18-9ea0c168845a';
 	englishentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
	englishoriginaluuid = '7ebd10ee-5018-4e11-9525-80ab5c6aebee';

	if create_language_type_uuid isNull
		then  select systagentityuuid ,systagdisplayname
				into create_language_type_uuid,temp_language_type
				from entity.crud_systag_read_full(tendreluuid,null,null, languageuuid, false,null,null, null,englishentityuuid)
				where systaguuid = create_original_language_type_uuid
				;
	end if;

	if create_original_language_type_uuid isNull
		then  select systaguuid ,systagdisplayname
				into create_original_language_type_uuid,temp_language_type
				from entity.crud_systag_read_full(tendreluuid,null,null, languageuuid, false,null,null, null,englishentityuuid)
				where systagentityuuid = create_language_type_uuid				
				;
	end if;

-- if language type is still null then set it to the default.

	if create_language_type_uuid isNull or create_original_language_type_uuid isNull
		then create_language_type_uuid = englishentityuuid;
			create_original_language_type_uuid = englishoriginaluuid;
			temp_language_type = 'en';
	end if;

-- setup customer variables

	if create_customer_uuid isNull
		then create_customer_uuid = (select customerentityuuid 
									from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
									where customeruuid = create_original_customer_uuid);
	end if;

	if create_original_customer_uuid isNull
		then create_original_customer_uuid = (select customeruuid 
											from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
											where customerentityuuid = create_customer_uuid);
	end if;

	if create_customer_uuid isNull or create_original_customer_uuid isNull
		then  raise exception 'No owner entity found';
	end if;

-- setup site variables

	if create_site_uuid isNull
		then create_site_uuid = (select locationentityuuid 
									from entity.crud_location_read_min(create_customer_uuid,null,null,null,true,null,null,null,null,null)
									where locationid = create_original_site_uuid);
	end if;

	if create_original_site_uuid isNull
		then create_original_site_uuid = (select locationuuid 
											from entity.crud_location_read_min(create_customer_uuid,null,null,null,true,null,null,null,null,null)
											where locationentityuuid = create_site_uuid);
	end if;

	if create_site_uuid isNull or create_original_site_uuid isNull
		then  raise exception 'No site entity found';
	end if;

-- collect the worker instance info
-- FUTURE:  Flip this to entity once it is Worker is migrated

  perform set_config('user.id', workeridentityid, true)
  from public.workerinstance
  inner join public.worker on workerinstanceworkerid = workerid
  where workerinstanceid = modified_by;

-- Create the first Runtime Location

------------------------------------------------------------------------------------------
-- From what I can tell we are only creating one location right now so I dumbed this down.
-- The original used a loop and I removed it. 
------------------------------------------------------------------------------------------

  call entity.crud_location_create(
			create_locationownerentityuuid := create_customer_uuid, 
			create_locationparententityuuid := create_site_uuid, 
			create_locationcornerstoneentityuuid := null,  
			create_locationcornerstoneorder := null, 
			create_locationtaguuid := null, 
			create_locationtag := 'Runtime Location', 
			create_locationname := 'My First Location', 
			create_locationdisplayname := 'My First Location',
			create_locationscanid := null, 
			create_locationtimezone := timezone, 
			create_languagetypeuuid := create_language_type_uuid, 
			create_locationexternalid := null, 
			create_locationexternalsystemuuid := null, 
			create_locationlatitude := null, 
			create_locationlongitude := null, 
			create_locationradius := null, 
			create_locationdeleted := null, 
			create_locationdraft := null, 
			create_locationentityuuid := create_locationentityuuid, 
			create_modifiedbyid := modified_by
	);

-- Create the first runtime template.
-- FUTURE:  Eventually we need to modify this to point to the entity model --

  select t.id into ins_template
  from legacy0.create_task_t(
      customer_id := create_original_customer_uuid,
      language_type := temp_language_type,
      task_name := 'Run',
      task_parent_id := create_original_site_uuid,
      modified_by := modified_by
  ) as t;

	--

	if ins_template isnull 
  	then raise exception 'failed to create template';
  end if;

-- Set the Runtime Template Type
-- FUTURE:  Eventually we need to modify this to point to the entity model 

	-- NOTE: I'm not exactly sure _why_ this happens but previously we were doing
	-- something like this:
	--   select t.id into template_type_id
	-- and we noticed that only the Runtime template type was being created. I
	-- *think* this is because the query planner sees that the `into` target is
	-- singular and so implicitly `LIMIT`s the query accordingly.
	select count(*) into ins_template_type_n
	from
		public.systag as s,
		legacy0.create_template_type(
			template_id := ins_template,
			systag_id := s.systaguuid,
			modified_by := modified_by
		) as t
	where s.systagparentid = 882 and s.systagtype in ('Trackable', 'Runtime')
  ;
  --
  if ins_template_type_n != 2
      then raise exception 'failed to create template types for root template';
  end if;

-- Setup the Template Fields
-- FUTURE:  Do we need an override by?  It is how we do timeclock. --

    create temp table field (f_name, f_type, f_is_primary, f_order) as (
        values
            ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
            ('Override End Time', 'Date', true, 1),
            ('Run Output', 'Number', false, 2),
            ('Reject Count', 'Number', false, 3),
            ('Comments', 'String', false, 99)
    );
	
    perform '  +field', t.id
    from
        field,
        legacy0.create_field_t(
            customer_id := create_original_customer_uuid,
            language_type := temp_language_type,
            template_id := ins_template,
            field_description := null,
            field_is_draft := false,
            field_is_primary := field.f_is_primary,
            field_is_required := false,
            field_name := field.f_name,
            field_order := field.f_order,
            field_reference_type := null,
            field_type := field.f_type,
            field_value := null,
            field_widget := null,
            modified_by := modified_by
        ) as t
  ;

   drop table field;
  --

  if (select count(*) from workresult 
		where workresultworktemplateid in (select worktemplateid 
											from worktemplate 
											where id = ins_template)) = 0
  	then raise exception 'failed to create template fields';
  end if;

  -- The canonical respawn rule.
  -- This rule tells the engine to create an open Runtime instance whenever an existing instance moves to InProgress.
  -- Note that there are two modes of instantiation under the legacy model (i.e. worktemplatenexttemplate): eager and lazy.
  -- The mode of instantiation is driven by worktemplatenexttemplatenexttypeid, which is a foreign key to systag.
  -- A next type of 'On Demand' indicates lazy instantiation and, practically speaking, allows the _end user_ (e.g. the mobile app)
  -- to explicitly request what to instantiate (if they do not so choose, nothing will be instantiated).
  -- Conversely, any other next type (e.g. Task, Audit, Remediation) implies eager instantiation and will result in
  -- automatic instantiation (by the engine) when the given rule is satisfied (i.e. it satisfies the status constraint
  -- (worktemplatenexttemplateviastatuschangeid) and/or the result constraint (worktemplatenexttemplateviaworkresultid)).
  --
  -- Note that we are still going to do this until the newer Runtime app build
  -- is live! This is to maintain backwards compatibility. Once it is, this can
  -- be removed in favor of lazy instantiation.
  --
  perform '  +irule', t.next
  from legacy0.create_instantiation_rule(
      prev_template_id := ins_template,
      next_template_id := ins_template,
      state_condition := 'In Progress',
      type_tag := 'Task', -- Eager instantiation := driven by the engine
      modified_by := modified_by
  ) as t;
  --
  if not found then
    raise exception 'failed to create canonical on-demand in-progress irule';
  end if;

  -----------------------------------------------------------------------
  -- Create the constraint for the root template at each child location.
  -- Dumbed this down since there is only one.
  -- FUTURE: From what I can tell we are only creating one right now.  
  -- FUTURE: Fix Subfunctions to use entity.  SHORT TERM: look up from entity locationid and pass it in  

       create temp table ins_constraint as 
               select *
               from legacy0.create_template_constraint_on_location(
                   template_id := ins_template,
                   location_id := ( select locationuuid
				   					from entity.crud_location_read_min(
									   read_locationownerentityuuid := create_customer_uuid, 
									   read_locationentityuuid := create_locationentityuuid, 
									   read_locationparententityuuid := null, 
									   read_locationcornerstoneentityuuid := null, 
									   read_alllocations := false, 
									   read_locationtag := null, 
									   read_locationsenddeleted := null, 
									   read_locationsenddrafts := null, 
									   read_locationsendinactive := null, 
									   read_languagetranslationtypeentityuuid := create_language_type_uuid
									)),
                   modified_by := modified_by
               ) as t
           ;

  -- Note that this will eventually get removed as part of the lazy
  -- instantiation merge (once the newer Runtime app build is live). Under the
  -- newer model, pre-creation of On Demand instances is no longer required.
  create temp table ins_instance as 
    select *
    from engine0.instantiate(
      template_id := ins_template,
      location_id := (
        select locationuuid
        from entity.crud_location_read_min(
          read_locationownerentityuuid := create_customer_uuid, 
          read_locationentityuuid := create_locationentityuuid, 
          read_locationparententityuuid := null, 
          read_locationcornerstoneentityuuid := null, 
          read_alllocations := false, 
          read_locationtag := null, 
          read_locationsenddeleted := null, 
          read_locationsenddrafts := null, 
          read_locationsendinactive := null, 
          read_languagetranslationtypeentityuuid := create_language_type_uuid
        )
      ),
      target_state := 'Open',
      target_type := 'Task',
      modified_by := modified_by
    )
  ;

  perform '  +constraint', t.id
  from ins_constraint as t
  union all
  (
    select '   +instance', t.instance
    from ins_instance as t
    group by t.instance
  )
  ;
  --
  if not found then
    raise exception 'failed to create location constraint/initial instance';
  end if;

   drop table ins_constraint;
   drop table ins_instance;
-------------------------------------------------------------------------------------------------
  -- Create the Idle Time template, which is a transition from Runtime.
  -- Note that, under Runtime, Idle is a _choice_. When Runtime is active, the user may _choose_ to
  -- transition into Idle by explicitly choosing it from the list (e.g. clicking the button in the
  -- mobile app). This is the (practical) difference between eager and lazy instantiation.
  -- Lazy instantiations are driven by the user while eager instantiations are automatic (i.e. driven by the engine).

    create temp table field (f_name, f_type, f_is_primary, f_order) as (
            values
                ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
                ('Override End Time', 'Date', true, 1),
                ('Description', 'String', false, 2),
				('Reason Code', 'String', false, 3)
        );

     create temp table ins_next as 
            select t.*
            from legacy0.create_task_t(
                customer_id := create_original_customer_uuid,
                language_type := temp_language_type,
                task_name := 'Idle Time',
                task_parent_id := create_original_site_uuid,
                task_order := 1,
                modified_by := modified_by
            ) as t
        ;

	
       create temp table ins_type as (
            select t.*
            from ins_next, public.systag as s
            cross join lateral legacy0.create_template_type(
                template_id := ins_next.id,
                systag_id := s.systaguuid,
                modified_by := modified_by
            ) as t
            where s.systagtype = 'Idle Time'
        );

        create temp table ins_field as (
            select t.*
            from field, ins_next
            cross join
                lateral legacy0.create_field_t(
                    customer_id := create_original_customer_uuid,
                    language_type := temp_language_type,
                    template_id := ins_next.id,
                    field_description := null,
                    field_is_draft := false,
                    field_is_primary := field.f_is_primary,
                    field_is_required := false,
                    field_name := field.f_name,
                    field_order := field.f_order,
                    field_reference_type := null,
                    field_type := field.f_type,
                    field_value := null,
                    field_widget := null,
                    modified_by := modified_by
                ) as t
        );

        create temp table ins_nt_rule as (		
            select t.*
            from ins_next
            cross join
                lateral legacy0.create_instantiation_rule(
                    prev_template_id := ins_template,
                    next_template_id := ins_next.id,
                    state_condition := 'In Progress',
                    type_tag := 'On Demand', -- Lazy instantiation (read the comments above)
                    modified_by := modified_by
                ) as t
        );

-- replaced with this which matches what is working for main template.
       create temp table ins_constraint as 
               select *
               from legacy0.create_template_constraint_on_location(
                   template_id := (select id from ins_next),
                   location_id := ( select locationuuid
				   					from entity.crud_location_read_min(
									   read_locationownerentityuuid := create_customer_uuid, 
									   read_locationentityuuid := create_locationentityuuid, 
									   read_locationparententityuuid := null, 
									   read_locationcornerstoneentityuuid := null, 
									   read_alllocations := false, 
									   read_locationtag := null, 
									   read_locationsenddeleted := null, 
									   read_locationsenddrafts := null, 
									   read_locationsendinactive := null, 
									   read_languagetranslationtypeentityuuid := create_language_type_uuid
									)),
                   modified_by := modified_by
               ) as t
           ;

        perform '  +next', ins_nt_rule.next
        from ins_nt_rule
        union all
        select '   +type', ins_type.id
        from ins_type
        union all
        select '   +field', ins_field.id
        from ins_field
        union all
        select '   +constraint', ins_constraint.id
        from ins_constraint
  ;
  --
  if not found then
    raise exception 'failed to create next template (Idle Time)';
  end if;
   
   drop table field;
   drop table ins_next;
   drop table ins_type;
   drop table ins_field;
   drop table ins_nt_rule;
   drop table ins_constraint;

  -- Create the Downtime template, which is a transition from Runtime.
  -- Note that, under Runtime, Idle is a _choice_. When Runtime is active, the user may _choose_ to
  -- transition into Down by explicitly choosing it from the list (e.g. clicking the button in the
  -- mobile app). This is the (practical) difference between eager and lazy instantiation.
  -- Lazy instantiations are driven by the user while eager instantiations are automatic (i.e. driven by the engine).

    create temp table field (f_name, f_type, f_is_primary, f_order) as (
            values
                ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
                ('Override End Time', 'Date', true, 1),
                ('Description', 'String', false, 2),
				('Reason Code', 'String', false, 3)
        );

        create temp table ins_next as (
            select t.*
            from legacy0.create_task_t(
                customer_id := create_original_customer_uuid,
                language_type := temp_language_type,
                task_name := 'Downtime',
                task_parent_id := create_original_site_uuid,
                task_order := 0,
                modified_by := modified_by
            ) as t
        );

        create temp table ins_type as (
            select t.*
            from ins_next, public.systag as s
            cross join lateral legacy0.create_template_type(
                template_id := ins_next.id,
                systag_id := s.systaguuid,
                modified_by := modified_by
            ) as t
            where s.systagtype = 'Downtime'
        );

        create temp table ins_field as (
            select t.*
            from field, ins_next
            cross join
                lateral legacy0.create_field_t(
                    customer_id := create_original_customer_uuid,
                    language_type := temp_language_type,
                    template_id := ins_next.id,
                    field_description := null,
                    field_is_draft := false,
                    field_is_primary := field.f_is_primary,
                    field_is_required := false,
                    field_name := field.f_name,
                    field_order := field.f_order,
                    field_reference_type := null,
                    field_type := field.f_type,
                    field_value := null,
                    field_widget := null,
                    modified_by := modified_by
                ) as t
        );

        create temp table ins_nt_rule as (
            select t.*
            from ins_next
            cross join
                lateral legacy0.create_instantiation_rule(
                    prev_template_id := ins_template,
                    next_template_id := ins_next.id,
                    state_condition := 'In Progress',
                    type_tag := 'On Demand', -- Lazy instantiation (read the comments above)
                    modified_by := modified_by
                ) as t
        );

-- replaced with this which matches what is working for main template.
       create temp table ins_constraint as 
               select *
               from legacy0.create_template_constraint_on_location(
                   template_id := (select id from ins_next),
                   location_id := ( select locationuuid
				   					from entity.crud_location_read_min(
									   read_locationownerentityuuid := create_customer_uuid, 
									   read_locationentityuuid := create_locationentityuuid, 
									   read_locationparententityuuid := null, 
									   read_locationcornerstoneentityuuid := null, 
									   read_alllocations := false, 
									   read_locationtag := null, 
									   read_locationsenddeleted := null, 
									   read_locationsenddrafts := null, 
									   read_locationsendinactive := null, 
									   read_languagetranslationtypeentityuuid := create_language_type_uuid
									)),
                   modified_by := modified_by
               ) as t
           ;

        perform '  +next', ins_nt_rule.next
        from ins_nt_rule
        union all
        select '   +type', ins_type.id
        from ins_type
        union all
        select '   +field', ins_field.id
        from ins_field
        union all
        select '   +constraint', ins_constraint.id
        from ins_constraint
  ;
  --
  if not found then
    raise exception 'failed to create next template (Downtime)';
  end if;

   drop table field;
   drop table ins_next;
   drop table ins_type;
   drop table ins_field;
   drop table ins_nt_rule;
   drop table ins_constraint;

  -- Create the Batch template. This is really all we need to do for Batch at
  -- the moment, since it is explicitly NOT on-demand and we don't have any
  -- transition rules yet.
  select t.id into ins_template
  from legacy0.create_task_t(
      customer_id := create_original_customer_uuid,
      language_type := temp_language_type,
      task_name := 'Batch',
      task_parent_id := create_original_site_uuid,
      -- In practice, the implication of this setting is that Batches must
      -- explicitly be created (i.e. instantiated) in order to work on them.
      task_supports_lazy_instantiation := false,
      modified_by := modified_by
  ) as t;
  --
  if not found then
    raise exception 'failed to create Batch template';
  end if;
  --
	select count(*) into ins_template_type_n
	from
		public.systag as s,
		legacy0.create_template_type(
			template_id := ins_template,
			systag_id := s.systaguuid,
			modified_by := modified_by
		) as t
	where s.systagparentid = 882 and s.systagtype in ('Batch');
  --
  if ins_template_type_n != 1 then
    raise exception 'failed to create Batch template type';
  end if;
  --
  perform *
  from
    (
      values
        ('Customer'::text, 'String'::text, false::boolean, 0::integer),
        ('Product Name', 'String', false, 1),
        ('SKU', 'String', false, 2)
    ) as field (f_name, f_type, f_is_primary, f_order),
    legacy0.create_field_t(
        customer_id := create_original_customer_uuid,
        language_type := temp_language_type,
        template_id := ins_template,
        field_description := null,
        field_is_draft := false,
        field_is_primary := field.f_is_primary,
        field_is_required := false,
        field_name := field.f_name,
        field_order := field.f_order,
        field_reference_type := null,
        field_type := field.f_type,
        field_value := null,
        field_widget := null,
        modified_by := modified_by
    ) as t
  ;
  --
  if not found then -- TODO: better validation here.
    raise exception 'failed to create Batch template fields';
  end if;

  select uuid
  into runtime_config_template_uuid
  from public.crud_customer_config_templates_list(20)
  where category = 'Applications'
  and type = 'Runtime';

  call public.crud_customer_config_create(
      customer_uuid := create_original_customer_uuid,
      site_uuid := create_original_site_uuid,
      config_template_uuid := runtime_config_template_uuid,
      config_value := 'true'::text,
      modified_by := null,
      config_id := runtime_config_uuid
  );

  return;

end
$procedure$;


REVOKE ALL ON PROCEDURE entity.enable_runtime(uuid,text,uuid,text,uuid,text,bigint,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.enable_runtime(uuid,text,uuid,text,uuid,text,bigint,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.enable_runtime(uuid,text,uuid,text,uuid,text,bigint,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.enable_runtime(uuid,text,uuid,text,uuid,text,bigint,text) TO graphql;

END;
