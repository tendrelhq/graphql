-- Revert graphql:workinstancenameid from pg

BEGIN;

alter table public.workinstance drop column if exists workinstancenameid;

COMMIT;
