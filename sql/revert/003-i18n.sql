-- Revert graphql:003-i18n from pg
begin
;

drop function if exists i18n.add_language_to_customer
;

drop schema if exists i18n;

commit
;
