-- Revert graphql:udt from pg
begin
;

drop function if exists util.create_user_type
;

drop function if exists util.create_type
;

commit
;
