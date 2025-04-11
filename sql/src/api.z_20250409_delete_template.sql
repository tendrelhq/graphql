
-- Type: FUNCTION ; Name: api.z_20250409_delete_template(); Owner: bombadil

CREATE OR REPLACE FUNCTION api.z_20250409_delete_template()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  del_row api.template%rowtype;
begin

-- maybe add a check to see if owner passed in = logged in user

  call entity.crud_entitytemplate_delete(
      create_entitytemplateownerentityuuid := old.owner,
      create_entitytemplateentityuuid := old.id,
      create_modifiedbyid := 895
  );

  select * into del_row
  from api.template
  where id = new.id;

  return del_row;
end 
$function$;

COMMENT ON FUNCTION api.z_20250409_delete_template() IS '
### del {baseUrl}/template

A bunch of comments explaining del
	';

REVOKE ALL ON FUNCTION api.z_20250409_delete_template() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.z_20250409_delete_template() TO bombadil WITH GRANT OPTION;
