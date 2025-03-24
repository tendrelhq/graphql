-- Revert graphql:i18n-add-language-to-customer from pg
begin;

drop function if exists i18n.add_language_to_customer;

commit;
