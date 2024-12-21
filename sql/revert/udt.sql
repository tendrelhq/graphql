-- Revert graphql:udt from pg
begin
;

drop function util.create_user_type
;

commit
;

