-- Revert graphql:language from pg
begin
;

drop function if exists i18n.add_language_to_customer
;

drop schema if exists i18n cascade;

commit
;
